from serial import Serial

ser = Serial("COM13", baudrate=9600, timeout=5)

while (True):
    instr = input()
    instr_int = int(instr, 2)
    tx_data = instr_int.to_bytes(1, byteorder="big")
    ser.write(tx_data)
