# Arduino Assignment 2

This folder contains the code for the second Arduino assignment. This project focuses on prompting the user for (1) an LED number, and (2) a delay at which to blink the LED. The program then uses the pins on the Arduino to blink
two LEDs based on the user given parameters.

The top of the program defines several constants like the LED pin numbers. The `BlinkProperty` struct stores parameters that control the LED blinking. The `PromptType` enum stores what prompt to show the user on the next loop iteration.

In the main loop, the program works by first reading in all available characters from the Serial buffer into a String buffer. When the program detects that there are 2 newline characters present in the string buffer, it knows that the user has entered both parameters(LED number and delay). It then processes these parameters from the buffer in the `updateBlink()` function. This function extracts the relavant information from the buffer, converts the parameters into integers, and updates the `BlinkProperty` struct. While the input is being processed, the `blink()` function updates the LED pin states.

More detailed documentation is contained in the comments present in `ArduinoAssignment2.ino`



Author: Murali Indukuri \
Updated: May 1, 2025