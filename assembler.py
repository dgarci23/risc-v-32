# Assembler
from openpyxl import load_workbook

encoding = {}

ISA = load_workbook("ISA Encoding.xlsx")

wb = ISA.active

prev_op = ""
for row in wb.values:
    opcode = ""
    func3 = ""

    if row[0] == None: continue

    for digit in row[26:33]:
        opcode += str(digit)

    for digit in row[18:21]:
        func3 += str(digit)

    if "None" in opcode:
        encoding[row[0].lower().strip()] = [prev_op, func3]
    else:
        encoding[row[0].lower().strip()] = [opcode, func3]
        prev_op = opcode

def assemble(line):

    assembly = ""

    line = line.replace(",", "")
    # NOPS
    if (line == "nops\n"):
        assembly = 32*"0"
        opcode = "0000000"
    else:
        instr = line.split(" ")[0].lower()
        opcode, func3 = encoding[instr]


    # BRANCH
    if (opcode == "1100011"):
        ra, rb, imm = line.split(" ")[1:4]
        ra = getBinStr(ra, 5)
        rb = getBinStr(rb, 5)
        imm = getBinStr(imm, 12)
        assembly = imm[0] + imm[2:8] + rb + ra + func3 + imm[8:12] + imm[1] + opcode
    # JALR
    if (opcode == "1100111"):
        rd, ra, imm = line.split(" ")[1:4]
        rd = getBinStr(rd, 5)
        ra = getBinStr(ra, 5)
        imm = getBinStr(imm, 12)
        assembly = imm + ra + func3 + rd + opcode
    # JAL
    if (opcode == "1101111"):
        rd, imm = line.split(" ")[1:3]
        rd = getBinStr(rd, 5)
        imm = getBinStr(imm, 20)
        assembly = imm[0] + imm[10:20] + imm[9] + imm[1:9] + rd + opcode
    # LUI and AUIPC
    if (opcode == "0110111" or opcode == "0010111"):
        rd, imm = line.split(" ")[1:3]
        rd = getBinStr(rd, 5)
        imm = getBinStr(imm, 20)
        assembly = imm + rd + opcode
    # Immediate Arithmetic
    if (opcode == "0010011"):
        rd, ra, imm = line.split(" ")[1:4]
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
        rd, ra, rb = line.split(" ")[1:4]
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
        rd, ra, imm = line.split(" ")[1:4]
        rd = getBinStr(rd, 5)
        ra = getBinStr(ra, 5)
        imm = getBinStr(imm, 12)
        assembly = imm + ra + func3 + rd + opcode
    #  Store
    if (opcode == "0100011"):
        ra, rb, imm = line.split(" ")[1:4]
        rb = getBinStr(rb, 5)
        ra = getBinStr(ra, 5)
        imm = getBinStr(imm, 12)
        assembly = imm[0:7] + rb + ra + func3 + imm[7:12] + opcode


    assembly = assembly[24:32] + " " + assembly[16:24] + " " + assembly[8:16] + " " + assembly[0:8]

    return assembly


def getBinStr(x, l):

    if x[0:2] == "0b":
        x = format(int(x[3:len(x)]), "b")
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

code_f = open("code.txt", "r")
mem_f = open("hdl/if_stage/text.mem", "w")

index = 64

for line in code_f.readlines():
    assembly = assemble(line)
    mem_f.write(assembly + "\n")
    index -= 1

for i in range(index):
    mem_f.write("00000000 00000000 00000000 00000000\n")

mem_f.close()
