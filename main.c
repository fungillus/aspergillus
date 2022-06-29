#include <stdlib.h>
#include <stdio.h>
#include <unistd.h>
#include <sys/time.h>

/*      lua       */
#include <lua.h>
#include <lauxlib.h>
#include <lualib.h>

/* internal configuration */
#include <config.h>

LUAMOD_API int luaopen_extra (lua_State *L);
extern int getTickCount();

static int running = 1;

static int buttonsState = 0;

static int
stopGame(lua_State *L) {
	running = 0;
	return 0;
}

static int
getButtonState(lua_State *L) {
	lua_pushinteger(L, buttonsState); /* current */
	lua_pushinteger(L, 0); /* pressed */
	lua_pushinteger(L, 0); /* released */
	return 3;
}

typedef enum {
	kButtonLeft = (1<<0)
	,kButtonRight = (1<<1)
	,kButtonUp = (1<<2)
	,kButtonDown = (1<<3)
	,kButtonB = (1<<4)
	,kButtonA = (1<<5)
} Buttons;

static void
setCFunctions(lua_State *luaCtx) {
	lua_pushcfunction(luaCtx, &stopGame);
	lua_setglobal(luaCtx, "stopGame");

	lua_pushcfunction(luaCtx, &getButtonState);
	lua_setglobal(luaCtx, "getButtonState");

	/* set buttons enumeration */
	lua_newtable(luaCtx);
	lua_pushinteger(luaCtx, kButtonLeft);
	lua_setfield(luaCtx, -2, "kButtonLeft");

	lua_pushinteger(luaCtx, kButtonRight);
	lua_setfield(luaCtx, -2, "kButtonRight");

	lua_pushinteger(luaCtx, kButtonUp);
	lua_setfield(luaCtx, -2, "kButtonUp");

	lua_pushinteger(luaCtx, kButtonDown);
	lua_setfield(luaCtx, -2, "kButtonDown");

	lua_pushinteger(luaCtx, kButtonB);
	lua_setfield(luaCtx, -2, "kButtonB");

	lua_pushinteger(luaCtx, kButtonA);
	lua_setfield(luaCtx, -2, "kButtonA");

	lua_setglobal(luaCtx, "buttons");
}

static void
setMockButtonsState(int tick) {
	buttonsState = 0;

	if (tick == 0)
		buttonsState = buttonsState | kButtonLeft;
	else if (tick == 35)
		buttonsState = buttonsState | kButtonUp;
	else if (tick == 45)
		buttonsState = buttonsState | kButtonRight;
	else if (tick == 85)
		buttonsState = buttonsState | kButtonDown;
	else if (tick == 110)
		buttonsState = buttonsState | kButtonLeft;
	else if (tick == 145)
		buttonsState = buttonsState | kButtonDown;
	else if (tick == 160)
		buttonsState = buttonsState | kButtonRight;
	else if (tick == 180)
		buttonsState = buttonsState | kButtonUp;
	else if (tick == 195)
		buttonsState = buttonsState | kButtonRight;
	else if (tick == 210)
		buttonsState = buttonsState | kButtonUp;
	else if (tick == 222)
		buttonsState = buttonsState | kButtonLeft;
	else if (tick == 255)
		buttonsState = buttonsState | kButtonA | kButtonB;
}

int main() {
	lua_State *luaCtx = NULL;
	luaCtx = luaL_newstate();
	int targetFramesPerSecond = 30;
	int programStartTime = getTickCount();
	int tick = 0;

	if (!luaCtx) {
		printf("Error allocating lua state\n");
		return 1;
	}

	setenv("LUA_PATH", LUA_PATH, 1);

	luaL_openlibs(luaCtx);
	luaL_requiref(luaCtx, "extra", luaopen_extra, 1);
	lua_pop(luaCtx, 1);

	setCFunctions(luaCtx);

	if (luaL_dofile(luaCtx, "main.lua") != 0) {
		const char *msg = lua_tostring(luaCtx, -1);
		printf("Error in the script file main.lua -> %s\n", msg);
	}

	lua_getglobal(luaCtx, "Init");
	lua_pcall(luaCtx, 0, 0, 0);

	int idealCycleTime = (int)((double)1 / ((double)targetFramesPerSecond / 100.0));
	int outstandingFreeTimeLeftThisTick = 0;
	int pollStartTime = 0;
	int pollDeltaTime = 0;
	while (running) {
		pollStartTime = getTickCount();
		/* handle input events */
		setMockButtonsState(tick);

		/* run the lua Poll function */
		lua_getglobal(luaCtx, "Poll");
		if (lua_pcall(luaCtx, 0, 0, 0) != 0) {
			const char *msg = lua_tostring(luaCtx, -1);
			fprintf(stderr, "Catched an error -> %s\n", msg);
			break;
		}
		pollDeltaTime = getTickCount() - pollStartTime;

		outstandingFreeTimeLeftThisTick = idealCycleTime - pollDeltaTime;

		/*
		fprintf(stderr, "Tick remaining time : %d -- deltaTime : %d  idealCycleTime : %d\n"
			, outstandingFreeTimeLeftThisTick
			, pollDeltaTime
			, idealCycleTime);
		*/
		if (outstandingFreeTimeLeftThisTick > 0) {
			usleep(outstandingFreeTimeLeftThisTick * 10000);
		}
		tick++;
	}

	lua_close(luaCtx);

	return 0;
}
