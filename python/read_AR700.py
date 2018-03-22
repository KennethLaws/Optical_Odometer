#!/usr/bin/env python

from range_finder import AR700



# use 'with' here to cause the class AR700 to run its enter and exit functions
with AR700() as rngSnsr:
	# configure the range sensor
	dataRate = 600 					# 600 data rate in measurements per second (min value = 22)
	print("configuring AR700 for %f Hz data rate" % dataRate)
	rngSnsr.configAR700(dataRate)

	runTime = 60
	print "starting data collection, collecting for %d seconds" % runTime
	# read from the device for given number of seconds and store to disk file 
	rngSnsr.read_nsec(runTime)
