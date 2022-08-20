
#define lextralib_c
#define LUA_LIB

/* #include "lprefix.h" */

#include "lua.h"
#include "lauxlib.h"
#include "lualib.h"

#include <stdio.h> /* scanf */
#include <sys/time.h> /* gettimeofday */
#include <unistd.h> /* usleep write */

#include <termios.h> /* tcsetattr, tcgetattr, ICANON, ECHO, TCSANOW, struct termios */

int
getTickCount() {
	struct timeval tv;
	gettimeofday(&tv, NULL);
	return (tv.tv_sec * 100 + tv.tv_usec / 10000) & 0x7fffffff;
}

void
getConsoleSize(int *columnOut, int *rowOut) {
	struct termios initialSettings;
	struct termios term;

	tcgetattr(0, &initialSettings);
	tcgetattr(0, &term);

	term.c_lflag &= ~(ICANON | ECHO);
	tcsetattr(0, TCSANOW, &term);

	write(1, "\033[s", 3); /* save cursor position */
	write(1, "\033[9999;9999H", 12); /* place the cursor the farthest away */
	write(1, "\033[6n", 4); /* get the cursor position which should be the screen size */

	scanf("\x1b[%d;%dR", rowOut, columnOut); /* parse the cursor position result */

	tcsetattr(0, TCSANOW, &initialSettings);

	write(1, "\033[u", 3); /* restore cursor position */
}

static int
extra_usleep(lua_State *L) {
	if (lua_isinteger(L, 1)) {
		lua_Integer n = lua_tointeger(L, 1);
		usleep(n);
	}
	return 1;
}

static int
extra_getTickCount(lua_State *L) {
	struct timeval tv;
	gettimeofday(&tv, NULL);
	lua_pushinteger(L, l_mathop((tv.tv_sec * 100 + tv.tv_usec / 10000) & 0x7fffffff));
	return 1;
}

static int
extra_getConsoleSize(lua_State *L) {
	int column, row;
	getConsoleSize(&column, &row);
	lua_pushinteger(L, l_mathop(column));
	lua_pushinteger(L, l_mathop(row - 1));

	return 2;
}


/***********************************************/

static const luaL_Reg extralib[] = {
	{"usleep", extra_usleep}
	,{"getTickCount", extra_getTickCount}
	,{"getConsoleSize", extra_getConsoleSize}
	,{NULL, NULL}
};

LUAMOD_API int luaopen_extra (lua_State *L) {
	luaL_newlib(L, extralib);
	return 1;
}
