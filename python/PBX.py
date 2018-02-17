#!/usr/bin/python

# PBX.py
# Created on: Oct 10, 2017
#    Authors: Blake Tacklind
#             HERE.com
#
# Handles the PBX as either a Serial or USB device.


import serial
import sys
import time

class PBX(object):
	#Serial Transfer special characters
	STX = '{'  #Start of transfer
	ETX = '|'  #End of line of text
	CR  = '\r' #carage return
	EOT = '}'  #End of transmission

	ACK = "ACK|"

	CURRENT_VERSION = "1.1.0"

	def __init__(self, comm='Serial', arg=None, set_time=True, timeout=1.0, debug=False, Safety=True):
		"""
		Starts a PBX device and tries to talk to it via given comm type
		arg is optional in case you want to change Default of comm device
		fw_version is set when you want to treat the device as a specific firmware version. If not set it will query
		the device for its current firmware version
		set_time is a boolean (default true) if you want to set the time on the PBX during setup
		timeout is the timeout in seconds for serial (and USB?) comunication
		debug is a boolean (default false) for when you want to see the debug statements. Often used with read_forever
		Safety is a boolean (default true) if set false it will disable all setup checks and assume device to be up to date
		"""
		self._timeout = timeout
		self._debug = debug
		self._arg = arg

		if Safety:
			self._do_set_time = set_time
			self._deviceVersion = None
		else:
			self._do_set_time = False
			self._deviceVersion = 0

		if comm == 'Serial' or comm == 'serial' or comm == 'S' or comm == 's':
			self._comm_type = "Serial"
		elif self._comm == 'USB':
			self._comm_type = "USB"
		else:
			raise Exception("Bad comm type, pick either 'Serial' or 'USB'. Got '%s'"%(comm))


	def __enter__(self):
		if self._comm_type == 'Serial':
			if self._arg == None:
				self._initSerial()
			else:
				self._initSerial(port=self._arg)
		elif self._comm == 'USB':
			self._initUSB()

		if self._deviceVersion is None:
			self._deviceVersion = self._get_fw_version()
			if self._debug:
				print "read fw version:", self._deviceVersion
		else:
			if self._debug:
				print "setting fw version to:", self._deviceVersion

		self._validate_version()

		if self._do_set_time:
			self.set_time()

		return self

	def __exit__(self, exc_type, exc_value, traceback):
		self._deviceSerial.close()

	def _validate_version(self):
		if self._deviceVersion not in PBX.INTERFACE_MAP:
			raise Exception("unsupported firmware version: %s"%self._deviceVersion)

		if self._deviceVersion != PBX.CURRENT_VERSION and self._deviceVersion != 0:
			print "Suggests updating to version {}. Current version: {}".format(PBX.CURRENT_VERSION, self._deviceVersion)

		self.i = PBX.INTERFACE_MAP[self._deviceVersion](self._write, self._read, self._deviceVersion, self._debug)

		self.message = self.i.message
		self.set_time = self.i.set_time
		self.get_time = self.i.get_time
		self.turn_off_leds = self.i.turn_off_leds
		self.set_backlight = self.i.set_backlight
		self.get_status = self.i.get_status
		self.get_status_headers = self.i.get_status_headers
		self.get_sd_card_status = self.i.get_sd_card_status
		self.play_test_song = self.i.play_test_song
		self.get_logs_all = self.i.get_logs_all
		self.get_logs_new = self.i.get_logs_new
		self.cancel_get_logs = self.i.cancel_get_logs

	"""
	"Public" functions
	"""
	def reset(self):
		"""
		Puts device into bootloader mode. Ready for programming
		"""
		self._write("reset")

	def _get_fw_version(self):
		"""
		get the current firmware version of build as defined in main.h
		"""
		self._write("version")
		return self._read()

	@property
	def device_version(self):
		return self._deviceVersion

	"""
	Internal functions
	"""
	def _read(self):
		"""
		This function should get overriden when a device gets set up.
		Otherwise it will throw an error.
		"""
		raise Exception("No device type set up")


	def read_forever(self):
		if not hasattr(self, "_deviceSerial"):
			raise Exception("Must be in serial mode to debug")

		while True:
			try:
				sys.stdout.write(self._read_serial())
			except Exception as e:
				pass

	def _write(self, message):
		"""
		This function should get overriden when a device gets set up.
		Otherwise it will throw an error.
		"""
		raise Exception("No device type set up")



	"""
	Section Petaining to serial only
	"""
	def _initSerial(self, port='/dev/ttyUSB0'):
		self._deviceSerial = serial.Serial(port,115200, timeout=self._timeout)
		self._write = self._write_serial
		self._read  = self._read_serial

	def _write_serial(self, message):

		if self._debug:
			sys.stdout.write("W: {%s}\n"%message)

		self._deviceSerial.write("{%s}"%message)

	def _read_serial(self):

		c = ""

		timeout_time = time.time() + self._timeout


		if self._debug:
			sys.stdout.write("R: ")

		while c != PBX.STX:
			c = self._deviceSerial.read()

			if len(c) == 0:
				raise Exception("Timeout")

			if time.time() > timeout_time:
				raise Exception("Timeout")

			if self._debug:
				if c != '\r':
					sys.stdout.write(c)
				else:
					sys.stdout.write("\n")


		message = ""
		while True:
			c = self._deviceSerial.read()

			if len(c) != 0:
				if c == PBX.EOT:
					if self._debug:
						sys.stdout.write("%c\n"%PBX.EOT)

					return message
				else:
					message += c
			else:
				raise Exception("Timeout")

			if self._debug:
				if c != '\r':
					sys.stdout.write(c)
				else:
					sys.stdout.write("\n")


	"""
	Section Petaining to USB only
	"""

	def _initUSB(self, idVendor=0x1337, idProduct=0x8704):
		raise Exception("USB not implemented")


	"""
	Interface section
	"""
	class Interface_Stub(object):
		def __init__(self, write, read, version, debug):
			self._write = write
			self._read = read
			self._deviceVersion = version
			self._debug = debug

		def message(self):
			raise Exception("message function is unsupported by this version: %s"%self._deviceVersion)

		def set_time(self):
			raise Exception("set_time function is unsupported by this version: %s"%self._deviceVersion)

		def get_time(self):
			raise Exception("get_time function is unsupported by this version: %s"%self._deviceVersion)

		def turn_off_leds(self):
			raise Exception("turn_off_leds function is unsupported by this version: %s"%self._deviceVersion)

		def set_backlight(self, level):
			raise Exception("set_backlight function is unsupported by this version: %s"%self._deviceVersion)

		def get_status(self):
			raise Exception("get_status function is unsupported by this version: %s"%self._deviceVersion)

		def get_status_headers(self):
			raise Exception("get_status function is unsupported by this version: %s"%self._deviceVersion)

		def get_sd_card_status(self):
			raise Exception("get_sd_card_status function is unsupported by this version: %s"%self._deviceVersion)

		def play_test_song(self):
			raise Exception("play_test_song function is unsupported by this version: %s"%self._deviceVersion)

		def get_logs_all(self):
			raise Exception("get_logs_all function is unsupported by this version: %s"%self._deviceVersion)

		def get_logs_new(self):
			raise Exception("get_logs_new function is unsupported by this version: %s"%self._deviceVersion)

		def cancel_get_logs(self):
			raise Exception("cancel_get_logs function is unsupported by this version: %s"%self._deviceVersion)

	class Interface_v1_0(Interface_Stub):

		def message(self, mes):
			"""
			sends a message to LCD
			"""

			#sanitize string of potentially dangerous characters
			mes = mes.replace('\n', '\r')
			mes = mes.replace(PBX.EOT, '')
			mes = mes.replace(PBX.STX, '')

			self._write("message|%s"%mes)

		def set_time(self, stamp = None):
			"""
			Set the UTC time of the PBX
			Can set to a specific time if so desired
			"""
			if stamp == None:
				stamp = int(round(time.time()))

			self._write("time|%s"%stamp)

		def get_status(self):
			"""
			Essentially latest log read
			"""
			self._write("getStatus")

			return self._read()

		def get_status_headers(self):
			"""
			Get the names for each of the log columns
			"""
			return "Log Version,"\
				"Log Time,"\
				"UTC offset,"\
				"Power State,"\
				"Inverter State,"\
				"Motherboard State,"\
				"ACR State,"\
				"Main power voltage,"\
				"Main power amps,"\
				"Aux power voltage,"\
				"Aux power amps,"\
				"CPU temp,"\
				"Firmware version,"\
				"Power Fault,"\
				"dummy fault";

		def set_backlight(self, level):
			"""
			Set the backlight levels of the LCD
			Can set to a specific time if so desired
			"""
			#values must me integer
			level = int(round(level))

			#Clamp values to be in a range
			if level > 8:
				level = 8
			elif level < 1:
				level = 1

			self._write("light|%s"%level)

		def get_time(self):
			"""
			Get the time of the PBX
			"""
			self._write("gettime")
			return self._read()

		def turn_off_leds(self):
			"""
			turn off the LEDs, usefully in some dubugging
			"""
			self._write("led")

		def get_sd_card_status(self):
			"""
			Get current status of SD card
			"""
			self._write("getSdCardStatus")

			return self._read()

	class Interface_v1_0_6(Interface_v1_0):
		def get_status_headers(self):
			"""
			Get the names for each of the log columns
			"""
			return "Log Version,"\
				"Log Time,"\
				"UTC Time,"\
				"Power State,"\
				"Inverter State,"\
				"Motherboard State,"\
				"ACR State,"\
				"Main power voltage,"\
				"Main power amps,"\
				"Aux power voltage,"\
				"Aux power amps,"\
				"CPU temp,"\
				"Firmware version,"\
				"Power Fault,"\
				"dummy fault";


	class Interface_v1_1_0(Interface_v1_0_6):

		def play_test_song(self):
			"""
			Play the test song
			"""
			self._write("testSong")

		# def get_logs_all(self, first_number=False):
		# 	"""
		# 	Return number of records to be transfered
		# 	"""
		# 	self._write("getLogAll")

		# 	return self._get_records(first_number)

		def get_logs_new(self, first_number=False):
			"""
			Return number of records to be transfered
			"""
			self._write("getLogNew")

			return self._get_records(first_number)

		def _get_records(self, first_number):
			ack = self._read()

			if ack[0:len(PBX.ACK)] != PBX.ACK:
				raise Exception("Not an ACK recieved")

			number = int(ack[len(PBX.ACK):])

			if self._debug:
				print "Expecting %i records"%number

			if first_number:
				yield number

			self._write("ACK")

			#add one to the number for the DONE message
			number += 1

			# results = list()
			self._getting_records = True

			read = ""
			while number > 0:
				read = self._read()
				number -= 1
				if read == "DONE":
					if number != 0:
						raise Exception("expected %i more records"%number)
				else:
					yield read

			self._getting_records = False

			if read != "DONE":
				raise Exception("expected last message to be 'DONE'")


		def cancel_get_logs(self):
			"""
			Return all the logs in the SD card
			"""
			if self._getting_records:
				self._write("getLogCancel")
			else:
				raise Exception("Must be currently collecting logs")

		def get_sd_card_status(self):
			"""
			Return all the logs in the SD card
			"""
			self._write("getSdCardStatus")
			return self._read()


	INTERFACE_MAP = {
		#usually used for reset
		0: Interface_Stub,
		#0.0.0 is actually 1.0 - 1.0.2
		"0.0.0": Interface_v1_0,
		"1.0.3": Interface_v1_0,
		"1.0.4": Interface_v1_0,
		"1.0.5": Interface_v1_0,
		"1.0.6": Interface_v1_0_6,
		"1.0.7": Interface_v1_0_6,
		"1.1.0": Interface_v1_1_0,
	}



if __name__ == "__main__":
	with PBX(debug=False, Safety=True) as device:
		print device.get_status()

