/* joystick.c
 * Module : joystick
 * Prefix : joystick_
 */

/*-------------------- External Header Includes --------------------*/
#include <stdlib.h>
#include <stdio.h>
#include <unistd.h>
#include <errno.h>
#include <string.h>
#include <linux/joystick.h>
#include <fcntl.h>

/*-------------------- Internal Header Includes --------------------*/
#include "epoll.h"

/*----------------------- Main Module Header -----------------------*/
#include "joystick.h"

/*----------------------------- Other ------------------------------*/

struct JsState {
	FILE *joystickFd;
	unsigned int statusBits;
};

#ifndef js_event
typedef struct {
	unsigned int time;
	signed short value;
	unsigned char type;
	unsigned char number;
}js_event;
#endif /* not js_event */

#define debugging 0

/*------------------------ Global Variables ------------------------*/

/*------------------------ Static Variables ------------------------*/

/*----------------------- Static Prototypes ------------------------*/

/*------------------------ Static Functions ------------------------*/

/*
 * returns 1 if pipe type [types]
 * is available else 0
 * types : 
 * 0 -- read
 * 1 -- write
 * 2 -- exception
 * 
 */
static int
Util_CheckPipeAvail(int connection, int type, int timeout_sec, int timeout_usec)
{
	EPOLL *fd;
	EPOLL_EVENT ev;
	int _err = 0;
	EPOLL_EVENT *event;

	memset(&ev, 0, sizeof(EPOLL_EVENT));

	switch (type)
	{
		case 0:
			ev.events = EPOLLIN;
			break;

		case 1:
			ev.events = EPOLLOUT;
			break;

		case 2:
			ev.events = EPOLLERR;
			break;

		default:
			return -1;
			break;
	}
	ev.data.fd = connection;

	fd = Epoll_Create();

	_err = Epoll_Ctl(fd, EPOLL_CTL_ADD, connection, &ev);

	if (_err == -1)
	{
		/*ERROR(Neuro_s("Epoll_Ctl raised an error %d\n", errno));*/
		return -1;
	}

	if (timeout_sec < 0)
		timeout_sec = 0;

	if (timeout_usec < 0)
		timeout_usec = 0;

	_err = 0;
	event = Epoll_Wait(fd, (timeout_sec * 1000) + timeout_usec, &_err);

	if (!event)
		_err = 0;

	Epoll_Destroy(fd);

	if (_err > 0)
		return 1;

	return 0;
}

static void
showEvent(struct js_event *e) {
	fprintf(stderr, "time %d value %d type %d number %d\n"
		, e->time
		, e->value
		, e->type
		, e->number);
}

static inline int
updateBits(int bits, int offset, int value) {
	if (value == 1) {
		return bits | offset;
	} else if (value == 0) {
		if ((bits & offset) == offset)
			return bits ^ offset;
	}

	return bits;
}

static int
openJoystickDevice(JsState *state) {
	FILE *fd = fopen("/dev/input/js0", "rb");
	if (!fd) {
		state->joystickFd = NULL;
		return 1;
	} else {
		fcntl(fileno(fd), F_SETFL, O_NONBLOCK);
		state->joystickFd = fd;
		return 0;
	}
}

/*------------------------ Global Functions ------------------------*/

int
joystick_GetButtonState(JsState *state) {
	return state->statusBits;
}

void
joystick_SetButtonState(JsState *state, int statusBits) {
	state->statusBits = statusBits;
}

int
joystick_IsJoystickPresent(JsState *state) {
	if (!state)
		return 0;
	if (state->joystickFd == NULL) {
		return 0;
	} else {
		return 1;
	}
}

/*------------------------------ Poll ------------------------------*/

void
joystick_Poll(JsState *state) {
	struct js_event joystickEvent;
	int result = 0;
	int err = 0;

	if (state->joystickFd == NULL) {
		if (openJoystickDevice(state)) /* could not load the joystick device */
			return;
	}

	/* printf("awaiting for the pipe to be available\n"); */
	err = Util_CheckPipeAvail(fileno(state->joystickFd), 0, 0, 30);
	if (debugging) fprintf(stderr, "joystick_Poll : %d epoll result is %d\n", getTickCount(), err);

	if (err <= 0)
		return;

	result = fread(&joystickEvent, sizeof(struct js_event), 1, state->joystickFd);

	if (debugging) {
		showEvent(&joystickEvent);
	}

	if (result > 0) {
		if (joystickEvent.type == 1) {
			switch (joystickEvent.number) {
				case 0: /* Button A */
				{
					state->statusBits = updateBits(state->statusBits, kButtonA, joystickEvent.value);
					break;
				}

				case 2: /* Button B */
				{
					state->statusBits = updateBits(state->statusBits, kButtonB, joystickEvent.value);
					break;
				}

				case 9: /* D-pad up */
				{
					state->statusBits = updateBits(state->statusBits, kButtonUp, joystickEvent.value);
					break;
				}

				case 10: /* D-pad down */
				{
					state->statusBits = updateBits(state->statusBits, kButtonDown, joystickEvent.value);
					break;
				}

				case 11: /* D-pad left */
				{
					state->statusBits = updateBits(state->statusBits, kButtonLeft, joystickEvent.value);
					break;
				}

				case 12: /* D-pad right */
				{
					state->statusBits = updateBits(state->statusBits, kButtonRight, joystickEvent.value);
					break;
				}
				
				default:
				{
					if (debugging)
						fprintf(stderr, "Unhandled event : %d\n", joystickEvent.number);
					break;
				}
			}
		} else if (joystickEvent.type == 2) {
			switch (joystickEvent.number) {
				case 6: /* D-Pad horizontal */
				{
					if (joystickEvent.value <= -1) { /* left */
						state->statusBits = updateBits(state->statusBits, kButtonLeft, 1);
					} else if (joystickEvent.value >= 1) { /* right */
						state->statusBits = updateBits(state->statusBits, kButtonRight, 1);
					} else if (joystickEvent.value == 0) {
						state->statusBits = updateBits(state->statusBits, kButtonLeft, 0);
						state->statusBits = updateBits(state->statusBits, kButtonRight, 0);
					}
					break;
				}

				case 7: /* D-Pad vertical */
				{
					if (joystickEvent.value <= -1) { /* left */
						state->statusBits = updateBits(state->statusBits, kButtonUp, 1);
					} else if (joystickEvent.value >= 1) { /* right */
						state->statusBits = updateBits(state->statusBits, kButtonDown, 1);
					} else if (joystickEvent.value == 0) {
						state->statusBits = updateBits(state->statusBits, kButtonUp, 0);
						state->statusBits = updateBits(state->statusBits, kButtonDown, 0);
					}
					break;
				}

				default:
				{
					if (debugging)
						fprintf(stderr, "Unhandled event : %d value : %d \n", joystickEvent.number, joystickEvent.value);
					break;
				}
			}
		} else {
			if (debugging)
				fprintf(stderr, "Unhandled type : %d event : %d\n", joystickEvent.type, joystickEvent.number);
		}
		/* showEvent(&joystickEvent); */
	}
}

/*--------------------- Constructor Destructor ---------------------*/

JsState *
joystick_Create(void) {
	JsState *state = malloc(sizeof(JsState));
	openJoystickDevice(state);

	return state;
}

void
joystick_Destroy(JsState *state) {
	if (state) {
		if (state->joystickFd)
			fclose(state->joystickFd);

		free(state);
	}
}
