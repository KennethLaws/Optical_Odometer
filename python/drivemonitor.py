#!/usr/bin/env python
# Created on: 03/23/2018
#    Authors: Kenneth Laws
#             HERE.com
#
# start data collection from rangefinder, camera and GPS/IMU

import subprocess
import threading
from sensor_interface import AR700
from sensor_interface import spanCPT6

runTime = 5						# runt time in seconds

"""
start the gps
""" 
gpsSnsr = spanCPT6() 
spanDataRate = 1 					# data rate (Hz)
print "starting gps logging, %d seconds"  % runTime
# initiate a span log session with data rate and session duration parameters as a thread
gpslogging = threading.Thread(target=gpsSnsr.log_session, args = (spanDataRate, runTime) )
gpslogging.daemon = True
gpslogging.start()
	
"""
start the rangefinder
""" 
rngSnsr =  AR700()
ARdataRate = 600  	# (600) data rate in measurements per second
print("starting the rangefinder")

# configure the range sensor
rngSnsr.configAR700(ARdataRate)


print "starting rangefinder logging, %d seconds" % runTime
# read from the device for given number of seconds and store to disk file 
# rngSnsr.read_nsec(runTime)
# start the process as a thread
rnglogging = threading.Thread(target=rngSnsr.read_nsec, args=(runTime, ) )
# print "create deamon"
rnglogging.daemon = True
rnglogging.start()

# # start the camera
# print("launching frame grabber")
# proc = ['../cprog/src/grabframes', '5']
# subprocess.Popen(proc)

# wait for threads to complete, threads will not continue if main exits
gpslogging.join()
rnglogging.join()
