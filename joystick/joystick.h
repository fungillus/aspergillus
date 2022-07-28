/* joystick.h */

#ifndef __JOYSTICK_H
#define __JOYSTICK_H

typedef enum
{
	kButtonLeft		= (1<<0)
	,kButtonRight		= (1<<1)	
	,kButtonUp		= (1<<2)
	,kButtonDown		= (1<<3)
	,kButtonB		= (1<<4)
	,kButtonA		= (1<<5)
} Buttons;

typedef struct JsState JsState;

extern int joystick_GetButtonState(JsState *state);
extern void joystick_SetButtonState(JsState *state, int statusBits);

extern int joystick_IsJoystickPresent(JsState *state);

extern void joystick_Poll(JsState *state);
extern JsState *joystick_Create(void);
extern void joystick_Destroy(JsState *state);

#endif /* NOT __JOYSTICK_H */
