"""
Methods for computing the CRC32 for a NovAtel GPS record.
"""

__author__ = 'Tom Slankard <tom.slankard@here.com>'

CRC32_POLYNOMIAL = 0xEDB88320L


def crc32_value(i):
    ul_crc = i
    for _ in range(8, 0, -1):
        if ul_crc & 1:
            ul_crc = (ul_crc >> 1) ^ CRC32_POLYNOMIAL
        else:
            ul_crc >>= 1
    return ul_crc


def novatel_crc(byte_data):
    """Compute the CRC32 of the supplied byte data."""
    ul_crc = 0
    for i in range(len(byte_data)):
        ul_temp1 = (ul_crc >> 8) & 0x00FFFFFFL
        ul_temp2 = crc32_value((ul_crc ^ (byte_data[i])) & 0xFF)
        ul_crc = ul_temp1 ^ ul_temp2

    return ul_crc


