import serial, serial.tools.list_ports
import time

END_OF_ANSWER_SEQUENCE = b'<EndOfAnswer>'
STAGES_NAMES_TUPLE = ('L','S')

def find_Robocold_port():
	MY_CASTLES_SERIAL_NUMBER = '75830333438351908062' # This is the serial number of the Arduino board which I used to build up my castle. I will probably never build another of this so I don't care hardcoding this serial number here.
	for p in serial.tools.list_ports.comports():
		if 'arduino' in p.manufacturer.lower():
			if p.serial_number == MY_CASTLES_SERIAL_NUMBER:
				return p

class ArduinoSerialCommander:
	def __init__(self, port:str):
		if not isinstance(port, str):
			raise TypeError(f'`port` must be a string, received object of type {type(port)}')
		self.ser = serial.Serial(port, 9600, timeout=None)
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
	def query(self, command:str):
		answer = super().query(command)
		if 'error' in answer.lower():
			raise RuntimeError(f'Error in Robocold while executing command `{command}`, Robocold answered `{answer}`')
		return answer
	
	def reset(self):
		"""Reset the position of both stages.
		"""
		self.query('RESET')
	
	@property
	def position(self) -> tuple:
		"""Query the current position of the stages. Returns a tuple with
		the position, e.g. (111,22).
		"""
		positions = []
		for stage in STAGES_NAMES_TUPLE:
			positions.append(int(self.query(f'POSITION? {stage}')))
		return tuple(positions)
	
	def move_to(self, position:tuple):
		"""Move stages to a new position, absolute.
		
		Arguments
		---------
		position: tuple of int
			New position to move to, e.g. (111,66).
		"""
		for stage in STAGES_NAMES_TUPLE:
			self.query(f'MOVE_TO {stage} {position[STAGES_NAMES_TUPLE.index(stage)]}')
	
	def move(self, displacement:tuple):
		"""Move stages to a new position, relative.
		
		Arguments
		---------
		displacement: tuple of int
			Displacement vector, e.g. (1,0) moves 1 the first stage and 0
			the second stage, (-1,0) moves backward, and so.
		"""
		for stage in STAGES_NAMES_TUPLE:
			d = displacement[STAGES_NAMES_TUPLE.index(stage)]
			self.query(f'MOVE {stage} {abs(d)} {"F" if d>0 else "B"}')

if __name__ == '__main__':
	robocold = Robocold(find_Robocold_port().device)
	
	for cmd in {'IDN?','VERSION?'}:
		print(cmd)
		print(robocold.query(cmd))
	
	print('Resetting position, may take a while...')
	robocold.reset()
	
	print(robocold.position)
	for kL in range(11):
		robocold.move((0,-1111))
		robocold.move((55,0))
		for kS in range(10):
			print('Moving...')
			robocold.move((0,22))
			print(robocold.position)
			time.sleep(.1)
	
	p = (270,200)
	print(f'Moving to {p}')
	robocold.move_to(p)
	print(robocold.position)
