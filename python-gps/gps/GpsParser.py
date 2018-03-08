"""
This module contains a class, GpsParser,
for parsing binary GPS files produced by HT server.

It also contains a number classes that represent GPS logs.

    NOTE #1

    We've decided not to check for large time gaps in the gps files,
    because the timestamps are not necessarily increasing.
    Naturally, this makes checking for gaps a little more problematic.
    The underlying reason is that ephemeris logs can take a few
    seconds/minutes/weeks/months/years to come in and be written.
    Thus, their timestamp appears to come before a subsequent
    raw imu log.

    NOTE #2

    I disable "too few public methods" since
    we're using a number of ctypes.Structure-based types
"""

#pylint: disable-msg=R0903

__author__ = 'Tom Slankard <tom.slankard@here.com>'

from gps.parser import Parser
import ctypes
from gps.novatel_crc import novatel_crc


class GpsException(Exception):
    """
    The base class for exceptions
    raised by the GPS parser.
    """
    pass


class GpsParseException(GpsException):
    """
    This class is the base class for all parsing exceptions
    that occur during the parsing of a .gps file.
    """
    pass


class GpsCrcCheckFailed(GpsException):
    """
    Raised when crc_check=True
    and the crc check fails for a gps log.
    """
    pass


class Sync(ctypes.Structure):
    """
    Represents the three sync bytes that precede each GPS header.
    """
    _pack_ = 1
    _fields_ = [
        ('sync',                        ctypes.c_uint8 * 3)
    ]


class Crc(ctypes.Structure):
    """
    Represents the CRC bytes that are part
    of a gps log.
    """
    _pack_ = 1
    _fields_ = [
        ('crc',                         ctypes.c_uint32)
    ]


class GpsHeader(ctypes.Structure):
    """
    The base class of all gps log headers.
    """

    @property
    def gps_microseconds(self):
        """
        returns the number of microseconds
        since Jan 6 1980, 00:00:00 GMT
        """
        return 1000 * (self.milliseconds + 1000 * 604800 * self.week)


class ShortHeader(GpsHeader):
    """
    Represents a short header (3rd sync byte is 0x13)
    """
    _pack_ = 1
    _fields_ = [
        ('message_length',              ctypes.c_uint8),
        ('message_id',                  ctypes.c_uint16),
        ('week',                        ctypes.c_uint16),
        ('milliseconds',                ctypes.c_uint32)
    ]


class LongHeader(GpsHeader):
    """
    Represents a long header (3rd sync byte is 0x12)
    """
    _pack_ = 1
    _fields_ = [
        ('header_length',               ctypes.c_uint8),
        ('message_id',                  ctypes.c_uint16),
        ('message_type',                ctypes.c_char),
        ('port_address',                ctypes.c_uint8),
        ('message_length',              ctypes.c_uint16),
        ('seq',                         ctypes.c_uint16),
        ('idle_time',                   ctypes.c_uint8),
        ('gps_time_status',             ctypes.c_uint8),
        ('week',                        ctypes.c_uint16),
        ('milliseconds',                ctypes.c_uint32),
        ('receiver_status',             ctypes.c_uint32),
        ('reserved',                    ctypes.c_uint16),
        ('receiver_software_version',   ctypes.c_uint16)
    ]


class GpsMessage(ctypes.Structure):
    """
    This is the base class for all GPS log messages.
    It has no methods or attributes because it's meant to
    be an abstract type.
    """
    @staticmethod
    def message_class(message_id):
        """returns the subclass of GpsMessage that has the given message id"""
        classes = [
            cls for cls
            in GpsMessage.__subclasses__() if cls.message_id == message_id
        ]
        if classes:
            return classes[0]
        return None


class Mark1Pva(GpsMessage):
    """ :class Mark1Pva:

    This class encapsulates the information read from a MARK1PVA GPS log.
    """

    message_id = 1067
    _pack_ = 1
    _fields_ = [
        ('week',                        ctypes.c_uint32),
        ('seconds',                     ctypes.c_double),
        ('latitude',                    ctypes.c_double),
        ('longitude',                   ctypes.c_double),
        ('height',                      ctypes.c_double),
        ('north_velocity',              ctypes.c_double),
        ('east_velocity',               ctypes.c_double),
        ('up_velocity',                 ctypes.c_double),
        ('roll',                        ctypes.c_double),
        ('pitch',                       ctypes.c_double),
        ('azimuth',                     ctypes.c_double),
        ('status',                      ctypes.c_uint32)
    ]


class InsSpeed(GpsMessage):
    """ This class encapsulates the information read from a INSSPD GPS log.
    """

    message_id = 266
    _pack_ = 1
    _fields_ = [
        ('week',                        ctypes.c_uint32),
        ('seconds',                     ctypes.c_double),
        ('track_over_ground',           ctypes.c_double),
        ('horizontal_speed',            ctypes.c_double),
        ('vertical_speed',              ctypes.c_double),
        ('status',                      ctypes.c_uint32)

    ]


class BestVel(GpsMessage):
    """ This class encapsulates the information read from a BESTPOS GPS log.
    """

    message_id = 99
    _pack_ = 1
    _fields_ = [
        ('solution_status',             ctypes.c_uint32),
        ('velocity_type',               ctypes.c_uint32),
        ('latency',                     ctypes.c_float),
        ('age',                         ctypes.c_float),
        ('horizontal_speed',            ctypes.c_double),
        ('track_over_ground',           ctypes.c_double),
        ('vertical_speed',              ctypes.c_double),
        ('reserved',                    ctypes.c_float)
    ]


class BestPos(GpsMessage):
    """A BestPos gps log."""
    message_id = 42
    _pack_ = 1
    _fields_ = [
        ('solution_status',                                 ctypes.c_uint32),
        ('position_type',                                   ctypes.c_uint32),
        ('latitude',                                        ctypes.c_double),
        ('longitude',                                       ctypes.c_double),
        ('height',                                          ctypes.c_double),
        ('undulation',                                      ctypes.c_float),
        ('datum_type',                                      ctypes.c_uint32),
        ('latitude_std_dev',                                ctypes.c_float),
        ('longitude_std_dev',                               ctypes.c_float),
        ('height_std_dev',                                  ctypes.c_float),
        ('base_station_id',
         ctypes.c_uint8 * 4),
        ('differential_age',                                ctypes.c_float),
        ('solution_age',                                    ctypes.c_float),
        ('number_of_observations_tracked',                  ctypes.c_uint8),
        ('number_of_gps_l1_ranges_used_in_computation',     ctypes.c_uint8),
        ('number_of_gps_l1_ranges_above_rtk_mask_angle',    ctypes.c_uint8),
        ('number_of_gps_l2_ranges_above_rtk_mask_angle',    ctypes.c_uint8),
        ('reserved',                                        ctypes.c_uint8),
        ('reserved',                                        ctypes.c_uint8),
        ('reserved',                                        ctypes.c_uint8),
        ('reserved',                                        ctypes.c_uint8)
    ]


class ShortRawImu(GpsMessage):
    """A ShortRawImu gps log."""
    message_id = 325
    _pack_ = 1
    _fields_ = [
        ('week',                                            ctypes.c_uint32),
        ('seconds',                                         ctypes.c_double),
        ('imu_status',                                      ctypes.c_int32),
        ('z_acceleration',                                  ctypes.c_int32),
        ('minus_y_acceleration',                            ctypes.c_int32),
        ('x_acceleration',                                  ctypes.c_int32),
        ('z_gyro',                                          ctypes.c_int32),
        ('minus_y_gyro',                                    ctypes.c_int32),
        ('x_gyro',                                          ctypes.c_int32)
    ]


class GpsParser(Parser):
    """Parses a binary NovAtel GPS file.

    A typical way to use this class is to provide
    a file object to the constructor, and then use
    iteration. Each iteration yields a header and
    a log. For example:

    parser = GpsParser(gps_file)
    for header, log in parser:
        # do stuff
    """

    MAX_GPS_GAP_MS = 1000

    def __init__(self, gps_file, check_crc=False, strict=False):
        """Construct a new parser for the specified gps file (a File object)."""
        super(GpsParser, self).__init__()
        self.gps_file = gps_file
        self.check_crc = check_crc
        self.strict = strict

    def __enter__(self):
        return self

    def __exit__(self):
        self.gps_file.close()

    def __iter__(self):
        """Iterates over the logs found in the gps file."""

        byte = True
        while byte:

            byte = self.gps_file.read(1)
            if not byte:
                break

            if ord(byte) != 0xAA:
                continue

            #  next sync byte
            byte = self.gps_file.read(1)
            if not byte:
                break

            if ord(byte) != 0x44:
                continue

            #  next sync byte
            byte = self.gps_file.read(1)
            if not byte:
                break

            header = None
            if ord(byte) == 0x12:
                header = LongHeader()
            elif ord(byte) == 0x13:
                header = ShortHeader()
            else:
                if self.strict:
                    raise GpsParseException(
                        'unknown log header type @ 0x%X' % self.gps_file.tell())
                continue

            self.gps_file.readinto(header)
            message_class = GpsMessage.message_class(header.message_id)

            message = None
            if message_class:
                message = message_class()
                self.gps_file.readinto(message)
                yield (header, message)
            else:
                self.log("Ignoring message id %d" % header.message_id)
                message = self.gps_file.read(header.message_length)
                yield (header, None)

            #  read the 32 bit CRC from the gps file
            crc2 = Crc()
            self.gps_file.readinto(crc2)

            if self.check_crc:
                #  compute the CRC of the log, which includes the header
                #  (including the sync bytes) and the log data
                crc_data = bytearray(
                    '\xAA\x44' + byte) + bytearray(header) + bytearray(message)
                crc = novatel_crc(crc_data)

                #  compare the CRCs
                if crc != crc2.crc:
                    raise GpsCrcCheckFailed()
