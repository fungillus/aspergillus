#include <stdlib.h>
#include <stdio.h>
#include <unistd.h>
#include <errno.h>
#include <string.h>
#include <time.h>

#include "joystick.h"

void
prettyShowButtonsState(int buttonsBits) {
	printf("%s", buttonsBits & kButtonUp ? "1" : "0");
	printf("%s", buttonsBits & kButtonRight ? "1" : "0");
	printf("%s", buttonsBits & kButtonDown ? "1" : "0");
	printf("%s", buttonsBits & kButtonLeft ? "1" : "0");
	printf("%s", buttonsBits & kButtonA ? "1" : "0");
	printf("%s", buttonsBits & kButtonB ? "1" : "0");
	printf("\n");
}

int main() {
	JsState *joystickCtx = NULL;
	int oldState = 0, currentState = 0;

	int joystickWaitTimeout = time(NULL) + 10;
	int firstCycle = 1;

	joystickCtx = joystick_Create();

	while (!joystick_IsJoystickPresent(joystickCtx)) {
		joystick_Poll(joystickCtx);
		if (!joystick_IsJoystickPresent(joystickCtx)) {
			if (firstCycle) {
				printf("No joystick seem to be available, waiting for 10 seconds for one to be connected\n");
				firstCycle = 0;
			}

			if (time(NULL) >= joystickWaitTimeout) {
				printf("Could not find a joystick after 10 seconds of waiting, leaving\n");
				joystick_Destroy(joystickCtx);
				return 1;
			}
		}
		usleep(1000);
	}

	printf("Press A and B to quit\n");

	while (1) {
		joystick_Poll(joystickCtx);

		currentState = joystick_GetButtonState(joystickCtx);
		if (oldState != currentState) {
			prettyShowButtonsState(currentState);
			oldState = currentState;
		}

		if ((currentState & kButtonA) == kButtonA && (currentState & kButtonB) == kButtonB) {
			break;
		}

		usleep(1000);
	}

	joystick_Destroy(joystickCtx);

	return 0;
}
