#!/usr/bin/python

# Created on: 02/12/2018
#    Authors: Kenneth Laws
#             HERE.com
#
# communicate with a serial device (Aquity AR700 laser rangefinder).


import serial
import sys
import time

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


	def __enter__(self):

		if self._comm_type == 'Serial':
			if self._arg == None:
				self._initSerial()
			else:
				print "initializing port: " + self.arg
				self._initSerial(port=self._arg)
		return self

	def __exit__(self, exc_type, exc_value, traceback):
		self._deviceSerial.close()



	"""
	Internal functions
	"""

	def read_forever(self):
		while True:
			try:
				sys.stdout.write(self._read_serial())
				sys.stdout.flush()
			except Exception as e:
				pass

	def read_nsec(self, n=0):
		tStart = time.time()
		tEnd = tStart + n
		fname = "/media/kip/960Pro/rangefinder/AR700.txt"
		fid = open(fname, "w")
		while time.time() < tEnd:
			tnow = time.time()
			try:
				d = self._read_serial()
			except Exception as e:
				pass
			if len(d) > 1:
				# print("%f, %s" % (tnow, d))
				fid.write("%f, %s" % (tnow, d))
		fid.close()

	def configAR700(self, dataRate = 2):
		rateParam = int(200000/dataRate) 	# default is 2 Hz
		self._deviceSerial.write(("S%d." % rateParam))


	"""
	Section Petaining to serial only
	"""
	def _initSerial(self, port='/dev/ttyUSB1'):
		print "setting up ttyUSB1"
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



