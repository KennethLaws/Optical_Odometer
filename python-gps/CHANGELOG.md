Change Log
==========

0.4.0
-----

* Adds `check_crc` option to GpsParser.

0.3.0
-----

* Adds convenience method "gps_microseconds" to LongHeader and ShortHeader.

0.2.0
-----

* GpsParser's `__iter__` method now yields a tuple of header, message, where header is one of
    - LongHeader
    - ShortHeader

0.1.2
-----

* Removes packed_struct dependency, replacing it with ctypes.

0.1.1
-----

* Removes packed_struct from the code and adds it as an install dependency.

0.1.0
-----

* First version.
