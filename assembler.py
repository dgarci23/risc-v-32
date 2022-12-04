# Assembler
# from openpyxl import load_workbook

# Serial
import serial
import time
ser = serial.Serial("COM13")

def sendSerial(x):

    packet = bytearray()
    packet.append(x)

    ser.write(packet)

# Some memory dependent variables
hex = "32"
led = "36"
sw = "40"

class Instruction:
    def __init__(self, line, index, encoding):
        self.index = index
        line = common_names(line).split(" ")
        # Checking for labels and raising instruction exceptions
        if (line[0] not in encoding.keys()):
            if (":" in line[0]):
                self.label = line[0]
            else:
                raise SyntaxError("Line: {}, Instruction: {}".format(self.index, line[0]))
        else:
            self.label = None
            self.instr = line[0]
        # Checking for instructions when there is a label
        if (self.label != None and line[1] not in encoding.keys()):
            raise SyntaxError("Line: {}, Instruction: {}".format(self.index, line[1]))
        elif (self.label != None):
            self.instr = line[1]
        # Get the func3 and the opcode
        if (self.instr == "nops"):
            self.assembly = 32*"0"
            self.opcode = "0000000"
        else:
            self.opcode, self.func3 = encoding[self.instr]


        if (self.label == None):
            self.instr_encoded = assemble(line, self.instr, self.opcode, self.func3, encoding)
        else:
            self.instr_encoded = assemble(line[1:len(line)], self.instr, self.opcode, self.func3, encoding)

    def getInstrEncoded(self):
        return self.instr_encoded

def load_encoding(encoding):

    fp = open("encoding.txt", "r")

    for line in fp.readlines():
        line = line.replace(",", "")
        line = line.replace("\n", "")
        line = line.split(" ")
        if len(line)==2:
            encoding[line[0]] = [line[1], None]
        if len(line)==3:
            encoding[line[0]] = [line[1], line[2]]

    fp.close()

def common_names(line):
    line = line.replace(", ", " ")
    line = line.replace(",", " ")
    line = line.replace("#", "")
    line = line.replace("fp", "8")
    line = line.replace("sp", "2")
    line = line.replace("ra", "1")
    line = line.replace("led", led)
    line = line.replace("hex", hex)
    line = line.replace("switch", sw)
    line = line.replace("x", "")

    return line

def assemble(line, instr, opcode, func3, encoding):

    # BRANCH
    if (opcode == "1100011"):
        ra, rb, imm = line[1:4]
        ra = getBinStr(ra, 5)
        rb = getBinStr(rb, 5)
        imm = getBinStr(imm, 12)
        assembly = imm[0] + imm[2:8] + rb + ra + func3 + imm[8:12] + imm[1] + opcode
    # JALR
    if (opcode == "1100111"):
        rd, ra, imm = line[1:4]
        rd = getBinStr(rd, 5)
        ra = getBinStr(ra, 5)
        imm = getBinStr(imm, 12)
        assembly = imm + ra + func3 + rd + opcode
    # JAL
    if (opcode == "1101111"):
        rd, imm = line[1:3]
        rd = getBinStr(rd, 5)
        imm = getBinStr(imm, 20)
        assembly = imm[0] + imm[10:20] + imm[9] + imm[1:9] + rd + opcode
    # LUI and AUIPC
    if (opcode == "0110111" or opcode == "0010111"):
        rd, imm = line[1:3]
        rd = getBinStr(rd, 5)
        imm = getBinStr(imm, 20)
        assembly = imm + rd + opcode
    # Immediate Arithmetic
    if (opcode == "0010011"):
        rd, ra, imm = line[1:4]
        rd = getBinStr(rd, 5)
        ra = getBinStr(ra, 5)
        imm = getBinStr(imm, 12)
        if (instr == "ssli" or instr == "srli"):
            assembly = "000000" + imm[6:12]
        elif (instr == "srai"):
            assembly = "010000" + imm[6:12]
        else:
            assembly = imm
        assembly += ra + func3 + rd + opcode
    # Register Arithmetic
    if (opcode == "0110011"):
        rd, ra, rb = line[1:4]
        rd = getBinStr(rd, 5)
        ra = getBinStr(ra, 5)
        rb = getBinStr(rb, 5)
        if (instr == "sub" or instr == "sra"):
            assembly = "0100000"
        else:
            assembly = "0000000"
        assembly += rb + ra + func3 + rd + opcode
    # Load
    if (opcode == "0000011"):
        rd, ra, imm = line[1:4]
        rd = getBinStr(rd, 5)
        ra = getBinStr(ra, 5)
        imm = getBinStr(imm, 12)
        assembly = imm + ra + func3 + rd + opcode
    #  Store
    if (opcode == "0100011"):
        rb, ra, imm = line[1:4]
        rb = getBinStr(rb, 5)
        ra = getBinStr(ra, 5)
        imm = getBinStr(imm, 12)
        assembly = imm[0:7] + ra + rb + func3 + imm[7:12] + opcode

    assembly = assembly[24:32] + " " + assembly[16:24] + " " + assembly[8:16] + " " + assembly[0:8]

    return assembly

def getBinStr(x, l):

    if x[0:2] == "0b":
        x = format(int(x[2:len(x)]), "b")
    if x[0:2] == "0x":
        x = format(int(x, 16), "b")
    else:
        if x[0] == "-":
            x = bin(((1 << l) - 1) & int(x))
            x = x[2:len(x)]
        else:
            x = format(int(x), "b")

    l = l - len(x)
    x = l*"0" + x

    return x
                      # return positive value as is

code_f = open("program.s", "r")
mem_f = open("hdl/if_stage/text.mem", "w")

encoding = {}
load_encoding(encoding)

index = 64

instructions = []

for line in code_f.readlines():
    print(line)
    instr = Instruction(line, 64 - index, encoding)
    instructions.append(instr)
    print(instr.getInstrEncoded())
    mem_f.write(instr.getInstrEncoded() + "\n")
    for i in instr.getInstrEncoded().split():
        instr_int = int(i, 2)
        tx_data = instr_int.to_bytes(1, byteorder="big")
        ser.write(tx_data)
        time.sleep(0.05)
    index -= 1

for i in range(index):
    mem_f.write("00000000 00000000 00000000 00000000\n")

mem_f.close()
