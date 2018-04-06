import struct
import math
from parser import Parser
import ctypes


class TlgRecord(ctypes.Structure):

    _fields_ = [
        ('timestamp',       ctypes.c_ulonglong),
        ('east',            ctypes.c_double),
        ('north',           ctypes.c_double),
        ('up',              ctypes.c_double),
        ('rot_x',           ctypes.c_double),
        ('rot_y',           ctypes.c_double),
        ('rot_z',           ctypes.c_double),
    ]
    _pack_ = 1


class TlgParser(Parser):

    def __init__(self, tlg_file):
        self.tlg_file = tlg_file

    def __enter__(self):
        return self

    def __exit__(self):
        self.tlg_file.close()

    def __iter__(self):
        return self.parse()

    def parse(self):
        tlg_record = TlgRecord()
        while self.tlg_file.readinto(tlg_record):
            yield tlg_record

if __name__ == '__main__':

    import sys
    tlg_file = open(sys.argv[1], 'rb')

    # read header
    tlg_file.read(8)

    seq = 1
    for tlg_record in TlgParser(tlg_file):
        print seq, tlg_record.timestamp, tlg_record.east, tlg_record.north, tlg_record.up, tlg_record.rot_x, tlg_record.rot_y, tlg_record.rot_z
        seq += 1
