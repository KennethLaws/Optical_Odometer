#!/usr/bin/env python
# Created on: 02/28/2018
#    Authors: Kenneth Laws
#             HERE.com
#
# communicate with span CPT OEM 6

import threading
from sensor_interface import spanCPT6

gpsSnsr = spanCPT6() 

# initiate a span log session with data rate and session duration parameters
dataRate = 4 					# 600 data rate in measurements per second (min value = 22)
runTime = 5		#
print("configuring span for %f Hz data rate" % dataRate)

# don't need to use threading here, was used to learn threading for drivemonitor.py
gpslogging = threading.Thread(target=gpsSnsr.log_session, args = (dataRate, runTime) )
# gpsSnsr.log_session(dataRate, runTime)
gpslogging.daemon = True
gpslogging.start()
print("span is logging")

gpslogging.join()

