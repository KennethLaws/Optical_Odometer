#!/usr/bin/env python
# Created on: 03/23/2018
#    Authors: Kenneth Laws
#             HERE.com
#
# start data collection from rangefinder, camera and GPS/IMU

import subprocess
from range_finder import AR700

# start the camera
print("launching frame grabber")
proc = ['../Cprog/src/grabframes', '10']
subprocess.Popen(proc)

# start the gps


# use 'with' here to cause the class AR700 to run its enter and exit functions
# with AR700() as rngSnsr:
# 	# configure the range sensor
# 	dataRate = 600 					# 600 data rate in measurements per second (min value = 22)
# 	print("configuring AR700 for %f Hz data rate" % dataRate)
# 	rngSnsr.configAR700(dataRate)

# 	runTime = 10 		# run duration in seconds
# 	print "starting data collection, collecting for %d seconds" % runTime
# 	# read from the device for given number of seconds and store to disk file 
# 	rngSnsr.read_nsec(runTime)
