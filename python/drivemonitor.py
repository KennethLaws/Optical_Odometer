#!/usr/bin/env python
# Created on: 03/23/2018
#    Authors: Kenneth Laws
#             HERE.com
#
# start data collection from rangefinder, camera and GPS/IMU

import subprocess
from multiprocessing import Process
from sensor_interface import AR700
from sensor_interface import spanCPT6

runTime = 600				# runt time in seconds

"""
 start the camera
"""
print("launching frame grabber")
proc = ['../cprog/src/grabframes', str(runTime)]
subprocess.Popen(proc)

"""
start the gps
""" 
gpsSnsr = spanCPT6() 
spanDataRate = 10 					# data rate (Hz)
print "starting gps logging, %d seconds"  % runTime
# initiate a span log session with data rate and session duration parameters as a thread
gpslogging = Process(target=gpsSnsr.log_session, args = (spanDataRate, runTime) )
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
# start the process as a thread
rnglogging = Process(target=rngSnsr.read_nsec, args=(runTime, ) )
rnglogging.start()


# wait for threads to complete, threads will not continue if main exits
gpslogging.join()
rnglogging.join()
