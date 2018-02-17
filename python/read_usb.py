#!/usr/bin/env python

from RFNDR import RFNDR

print "read usb port:"

with RFNDR() as d:
	d.read_forever()
