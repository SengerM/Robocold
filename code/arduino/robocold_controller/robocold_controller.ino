#include "robocold_controller.h"

ErrorLogger error_logger(13);

Adafruit_MotorShield AFMS = Adafruit_MotorShield(); // Create the motor shield object with the default I2C address

Adafruit_StepperMotor *motor_long = AFMS.getStepper(200, 2); // Connect here the motor that moves the long stage.
Adafruit_StepperMotor *motor_short = AFMS.getStepper(200, 1); // Connect here the motor that moves the short stage.

LinearStage long_stage = LinearStage(
	motor_long, // Adafruit_StepperMotor* motor
	LONG_STAGE_BACKWARD_END_SWITCH_PIN_NUMBER, // uint8_t backward_end_switch_pin_number
	LONG_STAGE_FORWARD_END_SWITCH_PIN_NUMBER, // uint8_t forward_end_switch_pin_number
	0,// uint EEPROM_address_for_position
	MOTORS_DEFAULT_SPEED_RPM // uint16_t default_RPM=11
);
LinearStage short_stage = LinearStage(
	motor_short, // Adafruit_StepperMotor* motor
	SHORT_STAGE_BACKWARD_END_SWITCH_PIN_NUMBER, // uint8_t backward_end_switch_pin_number
	SHORT_STAGE_FORWARD_END_SWITCH_PIN_NUMBER, // uint8_t forward_end_switch_pin_number
	20,// uint EEPROM_address_for_position
	MOTORS_DEFAULT_SPEED_RPM // uint16_t default_RPM=11
);

// Stuff related to the serial commands --------------------------------
bool command_has_just_finished = false; // Each command must switch this to `true` before every return.

void cmd_unrecognized(SerialCommands* sender, const char* cmd) {
	// Default command handler when command does not match other commands.
	sender->GetSerial()->print("ERROR: Unknown command '");
	sender->GetSerial()->print(cmd);
	sender->GetSerial()->println("'");
	command_has_just_finished = true;
}

void log_wrong_argument_error(void) {
	error_logger.new_error(Error(ERROR, "Bad arguments for command."));
}

void cmd_idn(SerialCommands* sender) {
	sender->GetSerial()->println("Robocold controller");
	command_has_just_finished = true;
}

void cmd_version(SerialCommands* sender) {
	sender->GetSerial()->println("Version " __VERSION__ " - " __DATE__ " " __TIME__);
	command_has_just_finished = true;
}

void cmd_move_stage(SerialCommands* sender) {
	// Moves one of the stages some number of steps. Expect the following arguments in the following order:
	// `stage` one of {'L', 'S'} meaning 'Long' and 'Short'.
	// `steps` an integer number with the number of steps you want to move.
	// `direction` one of {'F', 'B'} meaning 'Forward' and 'Backward'.
	char* argument = sender->Next();
	if (argument == NULL) {
		log_wrong_argument_error();
		command_has_just_finished = true;
		return;
	}
	char stage = *argument;
	
	argument = sender->Next();
	if (argument == NULL) {
		log_wrong_argument_error();
		command_has_just_finished = true;
		return;
	}
	uint16_t steps = atoi(argument);
	if (steps >= 32767 | steps <= -32768) {
		error_logger.new_error(Error(ERROR, "<steps> must be within (-32768,32767). I will do nothing."));
		command_has_just_finished = true;
		return;
	}
	
	argument = sender->Next();
	if (argument == NULL) {
		log_wrong_argument_error();
		command_has_just_finished = true;
		return;
	}
	uint8_t direction = *argument;
	
	if (not (stage == 'L' or stage == 'S')) {
		log_wrong_argument_error();
		command_has_just_finished = true;
		return;
	}
	if (not (direction == 'F' or direction == 'B')) {
		log_wrong_argument_error();
		command_has_just_finished = true;
		return;
	}
	
	direction = direction  == 'F' ? FORWARD : BACKWARD;
	
	// If we are here, arguments are fine ---
	if (stage == 'L')
		long_stage.Move(steps, direction);
	else
		short_stage.Move(steps, direction);
	
	command_has_just_finished = true;
	return;
}

void cmd_get_current_position(SerialCommands* sender) {
	// Prints the current position of the stage in the serial port. Arguments:
	// `stage` one of {'L', 'S'} meaning 'Long' and 'Short'.
	char* argument = sender->Next();
	if (argument == NULL) {
		log_wrong_argument_error();
		command_has_just_finished = true;
		return;
	}
	char stage = *argument;
	if (not (stage == 'L' or stage == 'S')) {
		log_wrong_argument_error();
		command_has_just_finished = true;
		return;
	}
	LinearStage* stage_object;
	if (stage == 'L')
		stage_object = &long_stage;
	else
		stage_object = &short_stage;
	sender->GetSerial()->println(int(stage_object->GetCurrentPosition()));
	
	command_has_just_finished = true;
	return;
}

void cmd_move_to(SerialCommands* sender) {
	// Moves the stage to the specified position. Arguments:
	// `stage` one of {'L', 'S'} meaning 'Long' and 'Short'.
	// `position` an integer number.
	char* argument = sender->Next();
	if (argument == NULL) {
		log_wrong_argument_error();
		command_has_just_finished = true;
		return;
	}
	char stage = *argument;
	if (not (stage == 'L' or stage == 'S')) {
		log_wrong_argument_error();
		command_has_just_finished = true;
		return;
	}
	
	argument = sender->Next();
	if (argument == NULL) {
		log_wrong_argument_error();
		command_has_just_finished = true;
		return;
	}
	uint16_t position = atoi(argument);
	if (position >= 32767 | position <= -32768) {
		error_logger.new_error(Error(ERROR, "<steps> must be within (-32768,32767). I will do nothing."));
		command_has_just_finished = true;
		return;
	}
	
	LinearStage* stage_object;
	if (stage == 'L')
		stage_object = &long_stage;
	else
		stage_object = &short_stage;
	
	stage_object->MoveTo(position);
	
	command_has_just_finished = true;
	return;
}

void cmd_reset_position(SerialCommands* sender) {
	// Reset the position of the two stages. No arguments.
	short_stage.ResetPosition();
	long_stage.ResetPosition();
	
	command_has_just_finished = true;
	return;
}

void cmd_help(SerialCommands* sender) {
	for (int i=0; i<sizeof(HELP_TEXT)/sizeof(HELP_TEXT[0]); i++) {
		sender->GetSerial()->println(HELP_TEXT[i]);
	}
}

char serial_command_buffer[32];
SerialCommands serial_commands(&Serial, serial_command_buffer, sizeof(serial_command_buffer), "\n", " ");

// ---------------------------------------------------------------------

void serial_flush(void) {
	while (Serial.available())
		Serial.read();
}

void setup() {
	pinMode(LONG_STAGE_BACKWARD_END_SWITCH_PIN_NUMBER, INPUT_PULLUP);
	pinMode(LONG_STAGE_FORWARD_END_SWITCH_PIN_NUMBER, INPUT_PULLUP);
	pinMode(SHORT_STAGE_BACKWARD_END_SWITCH_PIN_NUMBER, INPUT_PULLUP);
	pinMode(SHORT_STAGE_FORWARD_END_SWITCH_PIN_NUMBER, INPUT_PULLUP);
	
	pinMode(BUTTON_MOVE_LONG_STAGE_BACKWARD_PIN_NUMBER, INPUT_PULLUP);
	pinMode(BUTTON_MOVE_LONG_STAGE_FORWARD_PIN_NUMBER, INPUT_PULLUP);
	pinMode(BUTTON_MOVE_SHORT_STAGE_BACKWARD_PIN_NUMBER, INPUT_PULLUP);
	pinMode(BUTTON_MOVE_SHORT_STAGE_FORWARD_PIN_NUMBER, INPUT_PULLUP);
	
	Serial.begin(9600);
	serial_commands.SetDefaultHandler(cmd_unrecognized);
	for (uint16_t i = 0; i < sizeof(commands_list)/sizeof(commands_list[0]); i++)
		serial_commands.AddCommand(&commands_list[i]);
	if (!AFMS.begin()) { // Create with the default frequency 1.6KHz
		Serial.println("Cannot find motors hardware controller");
		while (true); // If the motor shield cannot be found, halt the execution here.
	}
}

void loop() {
	
	while (not Serial.available()) {
		delay(10);
		if (command_has_just_finished == true) {
			serial_flush(); // Discard any garbage that was sent while the command was being executed.
			command_has_just_finished = false; // Reset this variable.
			Serial.print(END_OF_ANSWER_SEQUENCE);
		}
		if (digitalRead(BUTTON_MOVE_LONG_STAGE_BACKWARD_PIN_NUMBER) == LOW) {
			long_stage.Move(STAGES_STEPS_WHEN_BUTTONS_PRESSED, BACKWARD);
		} else if (digitalRead(BUTTON_MOVE_LONG_STAGE_FORWARD_PIN_NUMBER) == LOW) {
			long_stage.Move(STAGES_STEPS_WHEN_BUTTONS_PRESSED, FORWARD);
		} else if (digitalRead(BUTTON_MOVE_SHORT_STAGE_BACKWARD_PIN_NUMBER) == LOW) {
			short_stage.Move(STAGES_STEPS_WHEN_BUTTONS_PRESSED, BACKWARD);
		} else if (digitalRead(BUTTON_MOVE_SHORT_STAGE_FORWARD_PIN_NUMBER) == LOW) {
			short_stage.Move(STAGES_STEPS_WHEN_BUTTONS_PRESSED, FORWARD);
		}
	} // Wait...
	serial_commands.ReadSerial(); // Do!
	error_logger.report_all_errors(); // Report.
}
