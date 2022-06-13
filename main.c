#include <stdlib.h>
#include <stdio.h>
#include <unistd.h>
#include <sys/time.h>

/*      lua       */
#include <lua.h>
#include <lauxlib.h>
#include <lualib.h>

LUAMOD_API int luaopen_extra (lua_State *L);
extern int getTickCount();

static int running = 1;

static int
stopGame(lua_State *L) {
	running = 0;
	return 0;
}

void
setCFunctions(lua_State *luaCtx) {
	lua_pushcfunction(luaCtx, &stopGame);
	lua_setglobal(luaCtx, "stopGame");
}

int main() {
	lua_State *luaCtx = NULL;
	luaCtx = luaL_newstate();
	int targetFramesPerSecond = 30;

	if (!luaCtx) {
		printf("Error allocating lua state\n");
		return 1;
	}

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

		/* run the lua Poll function */
		lua_getglobal(luaCtx, "Poll");
		if (lua_pcall(luaCtx, 0, 0, 0) != 0) {
			const char *msg = lua_tostring(luaCtx, -1);
			/* we don't care about the error, 
			 * usually it's just that the function doesn't exist
			 */
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
	}

	lua_close(luaCtx);

	return 0;
}
