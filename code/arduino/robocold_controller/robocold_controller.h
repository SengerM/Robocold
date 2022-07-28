#ifndef _ROBOCOLD_CONTROLLER_H_
#define _ROBOCOLD_CONTROLLER_H_

#include <SerialCommands.h> // https://www.arduino.cc/reference/en/libraries/serialcommands/
#include "LinearStage.h"
#include "ErrorLogger.h"

#define __VERSION__ "2"

#define END_OF_ANSWER_SEQUENCE "<EndOfAnswer>"

// Stuff related to the motors and stages ------------------------------
#define LONG_STAGE_BACKWARD_END_SWITCH_PIN_NUMBER 6
#define LONG_STAGE_FORWARD_END_SWITCH_PIN_NUMBER 5
#define SHORT_STAGE_BACKWARD_END_SWITCH_PIN_NUMBER 7
#define SHORT_STAGE_FORWARD_END_SWITCH_PIN_NUMBER 4

#define MOTORS_DEFAULT_SPEED_RPM 1111 // Just go as fast as you can...

#define BUTTON_MOVE_LONG_STAGE_FORWARD_PIN_NUMBER 11
#define BUTTON_MOVE_LONG_STAGE_BACKWARD_PIN_NUMBER 3
#define BUTTON_MOVE_SHORT_STAGE_FORWARD_PIN_NUMBER 2
#define BUTTON_MOVE_SHORT_STAGE_BACKWARD_PIN_NUMBER 12

#define STAGES_STEPS_WHEN_BUTTONS_PRESSED 100
// ---------------------------------------------------------------------

void cmd_unrecognized(SerialCommands* sender, const char* cmd);
void log_wrong_argument_error(void);
void cmd_idn(SerialCommands* sender);
void cmd_version(SerialCommands* sender);
void cmd_move_stage(SerialCommands* sender);
void cmd_get_current_position(SerialCommands* sender);
void cmd_move_to(SerialCommands* sender);
void cmd_reset_position(SerialCommands* sender);
void cmd_help(SerialCommands* sender);

SerialCommand commands_list[] = {
	SerialCommand("HELP?", cmd_help),
	SerialCommand("IDN?", cmd_idn),
	SerialCommand("VERSION?", cmd_version),
	SerialCommand("MOVE", cmd_move_stage),
	SerialCommand("POSITION?", cmd_get_current_position),
	SerialCommand("MOVE_TO", cmd_move_to),
	SerialCommand("RESET", cmd_reset_position),
};

const char *HELP_TEXT[] = {
	"HELP?: Print this",
	"IDN?: Return device name",
	"VERSION?: Return firmware version",
	"POSITION?: Return position of stage. Syntax: `POSITION? stage`",
	"  `stage`: 'L' long, 'S' short",
	"MOVE: Move stage relative. Syntax: `MOVE stage steps direction`",
	"  `stage`: 'L' long, 'S' short",
	"  `steps`: integer",
	"  `direction`: 'F' forward, 'B' backward",
	"MOVE_TO: Move stage absolute. Syntax `MOVE stage position`",
	"  `stage`: 'L' long, 'S' short",
	"  `position`: integer",
	"RESET: Moves stages to backward-most position and set it to 0",
};

#endif
