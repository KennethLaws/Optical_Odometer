import re
from parser import Parser


class TxtColumns(object):
    WEEK = 'Week'
    GPSTIME = 'GPSTime'
    LATITUDE = 'Latitude'
    LONGITUDE = 'Longitude'
    HEIGHT_ELL = 'H-Ell'
    HEADING = 'Heading'
    PITCH = 'Pitch'
    ROLL = 'Roll'
    VEL_N = 'VNorth'
    VEL_E = 'VEast'
    VEL_U = 'VUp'
    ACC_N = 'AccNrth'
    ACC_E = 'AccEast'
    ACC_U = 'AccUp'
    ANG_RATE_Y = 'AngRateY'
    ANG_RATE_X = 'AngRateX'
    ANG_RATE_Z = 'AngRateZ'
    STDDEV_N = 'SDNorth'
    STDDEV_E = 'SDEast'
    STDDEV_H = 'SDHeight'
    STDDEV_VN = 'SD-VN'
    STDDEV_VE = 'SD-VE'
    STDDEV_VH = 'SD-VH'
    STDDEV_ROLL = 'RollSD'
    STDDEV_PITCH = 'PitchSD'
    STDDEV_HEADING = 'HdngSD'
    HDOP = 'HDOP'
    VDOP = 'VDOP'
    NUM_SATS = 'NS'
    SEP_N = 'N-Sep'
    SEP_E = 'E-Sep'
    SEP_H = 'H-Sep'
    SEP_ROLL = 'RollSep'
    SEP_PITCH = 'PitchSep'
    SEP_HEADING = 'HdngSep'
    AMB_STATUS = 'AmbStatus'
    IMU_STATUS_FLAG = 'iFlag'
    IMU_UPDATE_TYPES = 'Update'
    STATION = 'Station'
    QUALITY = 'Q'


class TxtParser(Parser):

    number_re = '(-?[0-9]+(\.[0-9]+)?)'
    origin_str = "IMU->Secondary Sensor Lever Arms:"

    origin_re = ("\s+x={number_re}," +
                 "\s+y={number_re}," +
                 "\s+z={number_re}\s+m.*").format(**vars())

    match_origin = re.compile(origin_re)

    def na_or_float(val):
        if 'N/A' in val:
            return None
        else:
            return float(val)

    def na_or_str(val):
        if 'N/A' in val:
            return None
        else:
            return str(val)

    CastMap = [float] * 29 + \
              [na_or_float] * 6 + \
              [str] * 2 + \
              [na_or_str] * 1 + \
              [int] * 2

    # This dictionary defines the columns that will be `yield`-ed in the
    # `parse` method
    MagicIndex = {TxtColumns.WEEK: 0,
                  TxtColumns.GPSTIME: 1,
                  TxtColumns.LATITUDE: 2,
                  TxtColumns.LONGITUDE: 3,
                  TxtColumns.HEIGHT_ELL: 4,
                  TxtColumns.HEADING: 5,
                  TxtColumns.PITCH: 6,
                  TxtColumns.ROLL: 7,
                  TxtColumns.STDDEV_N: 17,
                  TxtColumns.STDDEV_E: 18,
                  TxtColumns.STDDEV_H: 19,
                  TxtColumns.STDDEV_ROLL: 23,
                  TxtColumns.STDDEV_PITCH: 24,
                  TxtColumns.STDDEV_HEADING: 25,
                  TxtColumns.HDOP: 26,
                  TxtColumns.VDOP: 27,
                  TxtColumns.NUM_SATS: 28,
                  TxtColumns.AMB_STATUS: 35,
                  TxtColumns.IMU_STATUS_FLAG: 36,
                  TxtColumns.STATION: 38,
                  TxtColumns.QUALITY: 39}

    def __init__(self, txt_file):
        self.txt_file = txt_file

    def __enter__(self):

        self.origin = None
        for line in self.txt_file:

            if line[:len(origin_str)] == origin_str:
                line = self.txt_file.next()
                m = match_origin.match(line)
                assert m
                self.origin = (-float(m.group(5)), -float(m.group(3)),
                               -float(m.group(1)))
                break

        if self.origin is None:
            raise RuntimeError("origin not found")

        return self

    def __iter__(self):
        return self.parse()

    def parse(self):
        for line in self.txt_file:

            try:
                datas = []

                for data, cast in zip(map(lambda x: x.strip(), line.split(',')),
                                      TxtParser.CastMap[:40]):
                    datas.append(cast(data))

            except Exception as err:
                if type(err) not in [IndexError, ValueError]:
                    raise
                continue

            # if the performance is bad this can be changed
            yield {key: datas[ind] for (key, ind) in self.MagicIndex.iteritems()}

    def __exit__(self, exc_type, exc_value, traceback):
        self.txt_file.close()


if __name__ == "__main__":
    import sys
    txt_file = open(sys.argv[1], 'r')
    for line in TxtParser(txt_file):
        print line
