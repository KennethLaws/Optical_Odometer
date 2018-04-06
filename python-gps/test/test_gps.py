import os
import gps
from gps.GpsParser import ShortHeader, ShortRawImu
from nose.tools import raises

def test_parse():
    
    first = None
    number_of_marks = 0
    for header, log in gps.GpsParser(open(os.path.join(os.path.dirname(__file__), 'test_parse', 'HTX00_1000000001.gps')), check_crc=True):
        if type(log) == gps.Mark1Pva:
            number_of_marks += 1
        if not first:
            EPSILON = 1000
            print header.gps_microseconds
            difference = abs(header.gps_microseconds - 1059771809993050)
            assert difference < EPSILON
            first = object()
        assert header.message_id == type(log).message_id

        # XXX assert header.week == log.week

    assert (number_of_marks == 5) 


@raises(gps.GpsCrcCheckFailed)
def test_bad_crc(): 
    for header, log in gps.GpsParser(open(os.path.join(os.path.dirname(__file__), 'bad_crc', 'HTX00_1000000001.gps')), check_crc=True):
        pass


#This test case is probably obsolete now that we are using the bad header forgiving code 
@raises(gps.GpsParseException)
def test_unknown_log_header_type():

    for header, log in gps.GpsParser(open(os.path.join(os.path.dirname(__file__), 'unknown_log_header_type', 'HTX00_1000000000.gps')), check_crc = False, strict = True):
        pass

def test_unknown_log_header_type_forgiving():
    print os.path.join(os.path.dirname(__file__))
    for header, log in gps.GpsParser(open(os.path.join(os.path.dirname(__file__), 'unknown_log_header_type', 'HT001_0000000001.gps'))):
        assert isinstance(header, ShortHeader)
        assert isinstance(log, ShortRawImu)
        #assert(type(header) is gps.GpsParser.ShortHeader)  
        print log
        pass

def test_unknown_message_id():

    for header, log in gps.GpsParser(open(os.path.join(os.path.dirname(__file__), 'unknown_message_id', 'HTX00_1000000000.gps'))):
        pass


# see note below
#@raises(gps.GpsGapException)
def test_big_gap():
    '''
        We've decided not to check for large time gaps in the gps files,
        because the timestamps are not necessarily increasing.
        Naturally, this makes checking for gaps a little more problematic.
        The underlying reason is that ephemeris logs can take a few
        seconds/minutes/weeks/months/years to come in and be written.
        Thus, their timestamp appears to come before a subsequent 
        raw imu log.
    '''
    
    for header, log in gps.GpsParser(open(os.path.join(os.path.dirname(__file__), 'big_gap', 'HT027_1382607102_gap.gps'))):
        pass

