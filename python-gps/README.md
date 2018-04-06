python-gps
==========
2013 Tom Slankard *tom.slankard@here.com*

python-gps is a module for parsing .gps files produced using the NovAtel SPAN-CPT. It can also parse two RCP proprietary formats: tlg/txt. 

Right now, it has support for the following logs:

* BestPos
* BestVel
* Mark1Pva
* InsSpeed
* ShortRawImu

You can easily add other log types by creating new subclasses of the GpsMessage class. In each subclass, you should provide two class members:

* `message_id` - should be set to the to the Message ID of the corresponding log from the SPAN-CPT firmware manual.
* `fields` - should be an array containing one or more subclasses of PackedStruct.Field, e.g. "Double" or "UnsignedShort". The constructor argument is the name of the field.

Installing
==========

The easiest way to install the module is from the Software Freedom server using pip:

    pip install gps --extra-index-url http://software-freedom.rcp-p.solo-experiments.com

To upgrade, include the `--upgrade` flag.


Usage Example
=============

A simple example is included below. You can access the fields of each log as regular Python object attributes:

<pre>
    gps_file = open('raw.gps', 'rb')
    
    marks = 0
    messages = 0
    for header, message in GpsParser(gps_file, check_crc=False):
        
        messages += 1 
        if type(message) == Mark1Pva:
            marks += 1
            #print message.week, message.seconds
    
    print "Total number of Mark1Pva events:", marks
    print "Total messages:", messages
</pre>


Note, NovAtel .gps files have a CRC32 checksum associated with each record. By default, the GpsParser class does not verify the checksum. To enable checksum verification, pass `check_crc=True` to the constructor. If a checksum does not verify, then an exception of type GpsCrcCheckFailed is raised.


Other Formats
=============

Two other classes are provided as well, TlgParser and TxtParser. These parse the corresponding .tlg and .txt files produced in other stages of RPP. Naturally, since these files are different formats, the data contains other fields which may be accessible in different ways.

Tlg Format
----------

The TLG format contains the following fields:

* GPS microseconds `timestamp` (microseconds since 1980-01-06 00:00:00 UTC)
* UTM `east`, meters
* UTM `north`, meters
* UTM `up`, meters
* `rot_x` - ??? Darsh knows
* `rot_y` - ??? 
* `rot_z` - ???

Txt Format
----------

TXT format contains the following fields, in this order, as of 2013-08-26. The TxtParser class does not parse all of the fields.

* Week (weeks since 1980-01-06 00:00:00 UTC)
* GPS Time (seconds since 1980-01-06 00:00:00 UTC)
* Latitude (degrees)
* Longitude (degrees)
* H-Ell (elevation, relative to WSG84 ellipsoid)
* Heading (degrees)
* Pitch (degrees)
* Roll (degrees)
* VNorth (velocity in North direction, m/s)
* VEast (velocity in East direction, m/s)
* VUp (velocity in Up direction, m/s)
* AccNorth (acceleration in North direction, m/s)
* AccEast (acceleration in East direction, m/s)
* AccUp (acceleration in Up direction, m/s)
* AngRateY - ???
* AngRateX - ???
* AngRateZ - ???
* SDNorth (standard deviation, meters)
* SDEast
* SDUp
* SD-VN
* SD-VE
* SD-VH
* RollSD
* PitchSD
* HdngSD
* HDOP
* VDOP
* NS
* N-SEP
* E-SEP
* H-SEP
* RollSep
* PtchSep
* HdngSep
* AmbStatus
* iFlag
* Update
* Station
* Q

At this time, the parser returns a tuple, rather than a dictionary, containing the following:

* Week
* GPS Time
* Latitude
* Longitude
* H-Ell
* Heading
* Pitch
* Roll
