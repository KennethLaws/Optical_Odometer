import gps
import math


def gps_weeks_millis(microseconds):

    milliseconds = microseconds / 1000.0
    gps_weeks = int(math.floor(milliseconds/(604800*1000)))
    return gps_weeks, long(milliseconds - gps_weeks*604800*1000)

with open('HTX00_1000000000.gps', 'w') as f:
    f.write('\xAA\x44\x13')
    first = gps.ShortHeader()
    first.week, first.milliseconds = gps_weeks_millis(1059771809993050)
    first.message_id = 696969 # not a real message id
    first.message_length = 0
    f.write('    ')
