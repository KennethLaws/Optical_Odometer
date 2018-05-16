#!/usr/bin/python

# Created on: 02/12/2018
#    Authors: Kenneth Laws
#             HERE.com
#
# interface with sensors for running data collection 
# Optical Odometer Project


import serial
import sys
import time
import threading

class AR700(object):


	def __init__(self, comm='Serial', arg=None, timeout=5.0):
		"""
		Starts an AR700 device and tries to talk to it via given comm type
		arg is optional in case you want to change Default of comm device
		timeout is the timeout in seconds for serial comunication
		"""

		self._timeout = timeout
		self._arg = arg


		if comm == 'Serial' or comm == 'serial' or comm == 'S' or comm == 's':
			self._comm_type = "Serial"
		else:
			raise Exception("Bad comm type, pick either 'Serial'. Got '%s'"%(comm))

		if self._comm_type == 'Serial':
			if self._arg == None:
				self._initSerial()
			else:
				print "initializing port: " + self.arg
				self._initSerial(port=self._arg)

	# def __enter__(self):

	# 	if self._comm_type == 'Serial':
	# 		if self._arg == None:
	# 			self._initSerial()
	# 		else:
	# 			print "initializing port: " + self.arg
	# 			self._initSerial(port=self._arg)
	# 	return self

	# def __exit__(self, exc_type, exc_value, traceback):
	# 	self._deviceSerial.close()



	"""
	Internal functions
	"""

	"""
	Section Petaining to serial only
	"""
	def _initSerial(self, port='/dev/ttyAR700'):
		print "setting up rangefinder on port ttyAR700"
		self._deviceSerial = serial.Serial(port,115200, timeout=self._timeout)
		self._read  = self._read_serial


	def _read_serial(self):
		timeout_time = time.time() + self._timeout
		message = ""
		while True:
			c = self._deviceSerial.read()
			if len(c) != 0:
				if c == "\n":
					return message
				else:
					message += c
			else:
				raise Exception("Timeout")

	"""
	External functions
	"""

	def read_forever(self):
		while True:
			try:
				sys.stdout.write(self._read_serial())
				sys.stdout.flush()
			except Exception as e:
				pass

	def configAR700(self, dataRate = 2):
		rateParam = int(200000/dataRate) 	# default is 2 Hz
		print "config rangefinder, rateParam = %d" % rateParam
		self._deviceSerial.write("S%d." % rateParam)  		# set the data rate
		self._deviceSerial.write("A2")						# zero based metric units ASCII

	def read_nsec(self, n=0):
		tStart = time.time()
		tEnd = tStart + n
		print "starting logging, %d seconds" % n
		fname = "/media/kip/960Pro/rangefinder/AR700.txt"
		fid = open(fname, "w")
		firstLine = 0
		bigTextArray = "% time 	distance \r\n"
		while time.time() < tEnd:
			tnow = time.time()
			d="";
			try:
				d = self._read_serial()
			except Exception as e:
				pass
			if len(d) > 1 & len(d) < 10:
				# print("%f, %s" % (tnow, d))
				bigTextArray =  "%s%10.6f\t%s" % ( bigTextArray, tnow, d )

			# time.sleep(.001)
		fid.write(bigTextArray)
		fid.close()
		self._deviceSerial.close()



class spanCPT6(object):

	def __init__(self, comm='Serial', arg=None, timeout=5.0):
		"""
		Starts a span CPT OEM 6 device and tries to talk to it via given comm type
		arg is optional in case you want to change Default of comm device
		timeout is the timeout in seconds for serial comunication
		"""

		# threading.Thread.__init__(self)
		self._timeout = timeout
		self._arg = arg


		if comm == 'Serial' or comm == 'serial' or comm == 'S' or comm == 's':
			self._comm_type = "Serial"
		else:
			raise Exception("Bad comm type, pick either 'Serial'. Got '%s'"%(comm))

		if self._comm_type == 'Serial':
			if self._arg == None:
				self._initSerial()
			else:
				print "initializing port: " + self.arg
				self._initSerial(port=self._arg)
		# return self


	# def __enter__(self):

	# 	if self._comm_type == 'Serial':
	# 		if self._arg == None:
	# 			self._initSerial()
	# 		else:
	# 			print "initializing port: " + self.arg
	# 			self._initSerial(port=self._arg)
	# 	return self

	# def __exit__(self, exc_type, exc_value, traceback):
	# 	self._deviceSerial.close()

	"""
	Section Petaining to serial only
	"""
	def _initSerial(self, port='/dev/ttyGPS'):
		print "setting up span CPT on port ttyGPS"
		self._deviceSerial = serial.Serial(port,115200, timeout=self._timeout)


	def _read_line(self):
		timeout_time = time.time() + self._timeout
		message = ""
		while True:
			c = self._deviceSerial.read()
			if len(c) != 0:
				if c == "\n":
					return message
				message += c
			else:
				raise Exception("Timeout")
			# time.sleep(.00001)

	def _read_cmnd_resp(self):
		timeout_time = time.time() + self._timeout
		message = ""
		while True:
			c = self._deviceSerial.read()
			if len(c) != 0:
				message += c
				if '<OK' in message:
					c = self._deviceSerial.read() 		# read the last <cr>
					c = self._deviceSerial.read() 		# read the last <lf>
					return message
			else:
				raise Exception("Timeout")
			# time.sleep(.00001)

	def log_session(self, dataRate = 2, runTime = 5):
		period = 1.0/dataRate 	# default is 2 Hz
		endTime = time.time() + runTime

		# stop any logging processes that might be running
		print("clear all span logging")
		self._deviceSerial.write('UNLOGALL USB1 TRUE\r\n')
		s = self._read_cmnd_resp()

		# start data logging 
		print("starting span log session")
		self._deviceSerial.write('LOG USB1 BESTPOSA ONTIME %0.1f\r\n' % period)
		s = self._read_line()
		s = self._read_line()
		self._deviceSerial.write('LOG USB1 BESTVELA ONTIME %0.1f\r\n' % period)
		s = self._read_line()
		s = self._read_line()
		self._deviceSerial.write('LOG USB1 INSATTA ONTIME %0.1f\r\n' % period)
		s = self._read_line()
		s = self._read_line()

		# open output file
		fname = "/media/kip/960Pro/gps/span6.txt"
		fid = open(fname, "w")

		bigTextArray = "gps data \r\n"
		# read in streaming data for given duration time
		while time.time() < endTime: 
			# start logging best position data
			s = self._read_line()
			# log data, ignore port id line
			# if '[USB1]' not in s:
			# 	print(s)
			if  '[USB1]' not in s:
				bigTextArray = "%s%s" % (bigTextArray, s)
				

		# close the file
		fid.write(bigTextArray)
		fid.close()


		# stop logging
		# print("stop logging")
		self._deviceSerial.write('UNLOGALL USB1 TRUE\r\n')
		s = self._read_cmnd_resp()
		# print(s)

		self._deviceSerial.close()

