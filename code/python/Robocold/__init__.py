import serial, serial.tools.list_ports
import time

END_OF_ANSWER_SEQUENCE = b'<EndOfAnswer>'

def find_Robocold_port():
	MY_CASTLES_SERIAL_NUMBER = '' # This is the serial number of the Arduino board which I used to build up my castle. I will probably never build another of this so I don't care hardcoding this serial number here.
	for p in serial.tools.list_ports.comports():
		if 'arduino' in p.manufacturer.lower():
			if p.serial_number == MY_CASTLES_SERIAL_NUMBER:
				return p

class ArduinoSerialCommander:
	def __init__(self, port:str):
		if not isinstance(port, str):
			raise TypeError(f'`port` must be a string, received object of type {type(port)}')
		self.ser = serial.Serial(port, 9600, timeout=2)
		time.sleep(1.8) # The Arduino board always resets when the communication is established and it seems this is impossible to disable, so we have to wait for it to start up...
		
	def query(self, command:str):
		if not isinstance(command, str):
			raise TypeError(f'`command` must be a string, received object of type {type(command)}')
		
		if command[-1] != '\n':
			command = command + '\n'
		
		thing_to_send = command.encode('ascii')
		self.ser.write(thing_to_send)
		time.sleep(.1)
		response = self.ser.read_until(END_OF_ANSWER_SEQUENCE)
		return response.decode('ascii')[:-len(END_OF_ANSWER_SEQUENCE)]

class Robocold(ArduinoSerialCommander):
	

if __name__ == '__main__':
	print(END_OF_ANSWER_SEQUENCE)
	for cmd in {'IDN?','VERSION?','inexistent_command'}:
		print(cmd)
		print(The_Castle.query(cmd))
	
	for k in [1,2,3,4,5,6,7,8,9]:
		print(f'Connecting channel {k}...')
		The_Castle.connect_channel(k)
