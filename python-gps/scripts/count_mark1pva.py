import sys
import gps

if __name__ == '__main__':

    marks = 0
    gps_file = open(sys.argv[1], 'rb')
    try:
        for header, log in gps.GpsParser(gps_file, check_crc=False):
            if type(log) == gps.Mark1Pva:
                marks += 1
    except (gps.GpsCrcCheckFailed, gps.GpsParseException) as e:
        print "At byte 0x%X Marks so far: %d, Exception: %s" % (gps_file.tell(), marks, e)

    print marks
