#include <stdlib.h>
#include <stdio.h>
#include <unistd.h>
#include <sys/time.h>
#include <string.h>

/*      lua       */
#include <lua.h>
#include <lauxlib.h>
#include <lualib.h>

#include <joystick.h>

/* internal configuration */
#include <config.h> /* LUA_PATH */

#if IS_CUSTOM_LUALIBS_EMBEDDED
#include <customLuaLibs.h>
#endif /* IS_CUSTOM_LUALIBS_EMBEDDED */

LUAMOD_API int luaopen_extra (lua_State *L);
extern int getTickCount();

static int running = 1;

static int buttonsState = 0;

static JsState *jsContext;

static int
stopGame(lua_State *L) {
	running = 0;
	return 0;
}

static int
getButtonState(lua_State *L) {
#if oldVersion
	lua_pushinteger(L, buttonsState); /* current */
#else /* not oldVersion */
	lua_pushinteger(L, joystick_GetButtonState(jsContext)); /* current */
#endif /* not oldVersion */
	lua_pushinteger(L, 0); /* pressed */
	lua_pushinteger(L, 0); /* released */
	return 3;
}

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
callMockButtonsState(JsState *js, lua_State *luaCtx, int tick) {
	lua_pushvalue(luaCtx, -1); /* copy the saved setMockButtonsState to the top of the stack */
	lua_pushinteger(luaCtx, tick);
	if (lua_pcall(luaCtx, 1, 1, 0) != 0) {
		/* printf("ERROR CALLING setMockButtonsState!!!\n"); */
		return;
	} else {
		if (!lua_isinteger(luaCtx, -1)) {
			fprintf(stderr, "RESULT IS NOT AN INTEGER!!! -> %d\n", lua_type(luaCtx, -1));
		} else {
			/* buttonsState = lua_tointeger(luaCtx, -1); */
			joystick_SetButtonState(js, lua_tointeger(luaCtx, -1));
			/* remove the returned value from the stack */
			lua_pop(luaCtx, 1);
		}
	}
}

int main(int argc, char **argv) {
	lua_State *luaCtx = NULL;
	luaCtx = luaL_newstate();
	int targetFramesPerSecond = 30;
	int programStartTime = getTickCount();
	int tick = 0;
	char luaGamePath[2048];

	if (!luaCtx) {
		printf("Error allocating lua state\n");
		return 1;
	}

	if (argc > 1) {
		char luaPathEnvBuffer[2048 * 2];
		unsigned int len;
		snprintf(luaGamePath, 2048, "%s/main.lua", argv[1]);
		strcpy(luaPathEnvBuffer, LUA_PATH);

		snprintf(&luaPathEnvBuffer[strlen(LUA_PATH)], 2048, ";%s/?.lua", argv[1]);
		setenv("LUA_PATH", luaPathEnvBuffer, 1);
	} else {
		strcpy(luaGamePath, "main.lua");
		setenv("LUA_PATH", LUA_PATH, 1);
	}

	jsContext = joystick_Create();

	luaL_openlibs(luaCtx);
	luaL_requiref(luaCtx, "extra", luaopen_extra, 1);
	lua_pop(luaCtx, 1);

#if IS_CUSTOM_LUALIBS_EMBEDDED
	loadLuaLibraries(luaCtx);
#endif /* IS_CUSTOM_LUALIBS_EMBEDDED */

	setCFunctions(luaCtx);

	if (luaL_dofile(luaCtx, luaGamePath) != 0) {
		const char *msg = lua_tostring(luaCtx, -1);
		printf("Error in the script file main.lua -> %s\n", msg);

		joystick_Destroy(jsContext);
		lua_close(luaCtx);
		return 1;
	}

	lua_getglobal(luaCtx, "Init");
	if (!lua_isfunction(luaCtx, -1)) {
		fprintf(stderr, "Module is missing the 'Init' function.\n");
		joystick_Destroy(jsContext);
		lua_close(luaCtx);
		return 1;
	}
	if (lua_pcall(luaCtx, 0, 0, 0)) {
		const char *msg = lua_tostring(luaCtx, -1);
		fprintf(stderr, "Init - Catched an error -> %s\n", msg);
		joystick_Destroy(jsContext);
		lua_close(luaCtx);
		return 1;
	}

	/* Save the two function calls in the stack so we can call them later */
	lua_getglobal(luaCtx, "Poll"); /* idx -2 */
	lua_getglobal(luaCtx, "setMockButtonsState"); /* idx -1 */

	/* check if what we loaded in the stack are really functions */
	if (!lua_isfunction(luaCtx, -2)) {
		fprintf(stderr, "Module is missing the 'Poll' function.\n");
		lua_close(luaCtx);
		return 1;
	}

	int idealCycleTime = (int)((double)1 / ((double)targetFramesPerSecond / 100.0));
	int outstandingFreeTimeLeftThisTick = 0;
	int pollStartTime = 0;
	int pollDeltaTime = 0;
	while (running) {
		pollStartTime = getTickCount();
		/* handle input events */
		joystick_Poll(jsContext);
		if (lua_isfunction(luaCtx, -1)) {
			callMockButtonsState(jsContext, luaCtx, tick);
		}

		/* run the lua Poll function */
		lua_pushvalue(luaCtx, -2); /* copy the location of the Poll function to the top of the stack */

		if (!lua_isfunction(luaCtx, -1)) {
			fprintf(stderr, "Top of the stack should contain the 'Poll' function but it does not\n");
			break;
		}

		if (lua_pcall(luaCtx, 0, 0, 0) != LUA_OK) {
			const char *msg = lua_tostring(luaCtx, -1);
			lua_pop(luaCtx, -1);
			fprintf(stderr, "Poll - Catched an error -> %s\n", msg);
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
			outstandingFreeTimeLeftThisTick *= 10000;
			/* fprintf(stderr, "%d sleeping off excess frames - %d\n", getTickCount(), outstandingFreeTimeLeftThisTick);*/
			/* usleep(outstandingFreeTimeLeftThisTick); */
			while (outstandingFreeTimeLeftThisTick >= 5000) {
				outstandingFreeTimeLeftThisTick -= 5000;
				usleep(5000);
			}
			/* fprintf(stderr, "%d done venting excess ticks this frame\n", getTickCount()); */
		}
		tick++;
	}

	joystick_Destroy(jsContext);

	lua_close(luaCtx);

	return 0;
}
