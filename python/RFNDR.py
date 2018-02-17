#!/usr/bin/python

# PBX.py
# Created on: 02/12/2018
#    Authors: Kenneth Laws
#             HERE.com
#
# communicate with a serial device (rangefinder).


import serial
import sys
import time

class RFNDR(object):


	def __init__(self, comm='Serial', arg=None, timeout=1.0):
		"""
		Starts a RFNDR device and tries to talk to it via given comm type
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



	"""
	Section Petaining to serial only
	"""
	def _initSerial(self, port='/dev/ttyUSB1'):
		print "setting up ttyUSB1"
		self._deviceSerial = serial.Serial(port,9600, timeout=self._timeout)
		self._read  = self._read_serial


	def _read_serial(self):
		c = ""
		timeout_time = time.time() + self._timeout
		message = ""
		while True:
			c = self._deviceSerial.read()

			if len(c) != 0:
				if c != "R":
					if c == "\r":
						return message + "\n"
					else:
						message += c
			else:
				raise Exception("Timeout")





