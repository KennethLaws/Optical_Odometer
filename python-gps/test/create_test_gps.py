import os
import math
from gps.novatel_crc import novatel_crc
import ctypes
from gps import ShortHeader, Sync, Mark1Pva

def gps_weeks_millis(microseconds):

    milliseconds = microseconds / 1000.0
    gps_weeks = int(math.floor(milliseconds/(604800*1000)))
    return gps_weeks, long(milliseconds - gps_weeks*604800*1000)


def write_mark1pva_with_ts(f, timestamp, crc=True):


    header = ShortHeader()
    header.week, header.milliseconds = gps_weeks_millis(timestamp)
    header.message_id = Mark1Pva.message_id 
    header.message_length = 0

    message = Mark1Pva() 

    f.write('\xAA\x44\x13')
    f.write(header)
    f.write(message)
    if crc:
        f.write(
            ctypes.c_uint32(
                novatel_crc(bytearray('\xAA\x44\x13')+bytearray(header)+bytearray(message))
            )
        )
    else:
        f.write('    ')


#  write a good file
file_path = os.path.join(os.path.dirname(__file__), 'test_parse', 'HTX00_1000000001.gps')
f = open(file_path, 'wb')
for i in range(5):
    write_mark1pva_with_ts(f, 1059771809993050+554*i)
f.close()

#  write a file without crcs
file_path = os.path.join(os.path.dirname(__file__), 'bad_crc', 'HTX00_1000000001.gps')
f = open(file_path, 'wb')
for i in range(5):
    write_mark1pva_with_ts(f, 1059771809993050+554*i, crc=False)
f.close()
