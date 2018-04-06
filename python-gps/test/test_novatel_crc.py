from gps.novatel_crc import crc32_value, novatel_crc


def test_crc32_value():
    assert 0          == crc32_value(0)
    assert 1996959894 == crc32_value(1)
    assert 1256170817 == crc32_value(100)
    assert 1594198072 == crc32_value(12345)



def test_novatel_crc():
    assert 4029829531 == novatel_crc(bytearray("hello")) 
    assert 4221711447 == novatel_crc(bytearray("goodbyegoodbye")) 

