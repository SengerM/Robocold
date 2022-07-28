#ifndef _LINEAR_STAGE_H_
#define _LINEAR_STAGE_H_

#include <Adafruit_MotorShield.h> // Use with this shield: https://www.adafruit.com/product/1438
#include <EEPROM.h> // https://www.arduino.cc/en/Reference/EEPROM

#define MOTOR_STEPS_PER_REVOLUTION 200

class LinearStage {
	private:
		uint64_t current_position = 0;
		Adafruit_StepperMotor* motor = nullptr;
		uint16_t default_RPM;
		uint8_t backward_end_switch_pin_number;
		uint8_t forward_end_switch_pin_number;
		uint8_t EEPROM_address_for_position;
		
		bool reached_backward_limit(void) {
			// Returns `true` if the stage is at the backward limit, `false` otherwise.
			if (digitalRead(this->backward_end_switch_pin_number) == HIGH) // This is implemented in Arduino.
				return true;
			else
				return false;
		}
		
		bool reached_forward_limit(void) {
			// Returns `true` if the stage is at the forward limit, `false` otherwise.
			if (digitalRead(this->forward_end_switch_pin_number) == HIGH) // This is implemented in Arduino.
				return true;
			else
				return false;
		}
		
		uint8_t oneStep(uint8_t dir, uint8_t style) { // This is a replica of the function from the Adafruit library, but checking the end switches.
			if (dir == BACKWARD and not this->reached_backward_limit()) {
				this->current_position -= 1;
				return this->motor->onestep(BACKWARD, style);
			} else if (dir == FORWARD and not this->reached_forward_limit()) {
				this->current_position += 1;
				return this->motor->onestep(FORWARD, style);
			}
			// We should never reach this point, unless something is (hardware) wrong.
			return -1;
		}
		void write_position_to_EEPROM(void) {
			for (int i=0; i<8; i++) {
				EEPROM.write(this->EEPROM_address_for_position+i, uint8_t(this->current_position>>i));
			}
		}
		uint64_t read_position_from_EEPROM(void) {
			uint64_t pos=0;
			for (int i=0; i<8; i++) {
				pos |= (EEPROM.read(this->EEPROM_address_for_position+i)<<i);
			}
			return pos;
		}
	public:
		LinearStage(
			Adafruit_StepperMotor* motor, 
			uint8_t backward_end_switch_pin_number, 
			uint8_t forward_end_switch_pin_number, 
			uint8_t EEPROM_address_for_position, 
			uint16_t default_RPM=11
		) {
			this->motor = motor;
			if (default_RPM == 0)
				default_RPM = 1;
			this->default_RPM = default_RPM;
			this->motor->setSpeed(default_RPM);
			this->backward_end_switch_pin_number = backward_end_switch_pin_number;
			this->forward_end_switch_pin_number = forward_end_switch_pin_number;
			//~ this->motor->release(); // I would like to do this here, but it hangs the program. Don't know why... Anyway by default the motors start non blocked.
			this->EEPROM_address_for_position = EEPROM_address_for_position;
			this->current_position = this->read_position_from_EEPROM();
		}
		
		void Move(uint16_t steps, uint8_t dir, uint16_t speed=0) {
			// Moves the stage `steps` steps in direction `dir` and stops if it reaches one of the end switches.
			// This function blocks the program until it finishes.
			// `steps` is the number of steps to move.
			// `dir` is one of {FORWARD, BACKWARD}. These come from the Adafruit_MotorShield.h.
			if (speed == 0)
				speed = this->default_RPM;
			uint16_t sleep_time = 60*1000/speed/MOTOR_STEPS_PER_REVOLUTION;
			for (uint16_t step=0; step<steps; step++) {
				this->oneStep(dir, SINGLE);
				if (dir == FORWARD and this->reached_forward_limit())
					break;
				if (dir == BACKWARD and this->reached_backward_limit())
					break;
				delay(sleep_time); // This is defined in Arduino.
			}
			this->motor->release(); // Turn off the coils.
			this->write_position_to_EEPROM();
		}
		
		void ResetPosition(void) {
			// Moves the stage to the backward-most position and then set this position as 0. Positive values go forward.
			while (not this->reached_backward_limit())
				this->Move(MOTOR_STEPS_PER_REVOLUTION, BACKWARD, 9999); // Move fast to the limit.
			this->current_position = 0; // Reset the position.
			this->write_position_to_EEPROM();
		}
		
		void MoveTo(int position, uint16_t speed=0) {
			// Moves to a specific position.
			if (speed == 0)
				speed = this->default_RPM;
			if (position == this->current_position)
				return;
			uint8_t direction = position - int(this->current_position) > 0 ? FORWARD : BACKWARD;
			uint16_t steps = direction == FORWARD ? position - this->current_position : this->current_position - position;
			this->Move(steps, direction, speed);
		}
		
		uint64_t GetCurrentPosition(void) {
			return this->read_position_from_EEPROM();
		}
};

#endif
