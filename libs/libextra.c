
#define lextralib_c
#define LUA_LIB

/* #include "lprefix.h" */

#include "lua.h"
#include "lauxlib.h"
#include "lualib.h"

#include <stdio.h> /* fscanf */
#include <sys/time.h> /* gettimeofday */
#include <unistd.h> /* usleep write */
#include <fcntl.h> /* fcntl */
#include <errno.h>
#include <sys/ioctl.h> /* ioctl */

#include <termios.h> /* tcsetattr, tcgetattr, ICANON, ECHO, TCSANOW, struct termios */

int
getTickCount() {
	struct timeval tv;
	gettimeofday(&tv, NULL);
	return (tv.tv_sec * 100 + tv.tv_usec / 10000) & 0x7fffffff;
}

void
getConsoleSize_old(int *columnOut, int *rowOut) {
	struct termios initialSettings;
	struct termios term;
	int _err = 0;

	tcgetattr(0, &initialSettings);
	tcgetattr(0, &term);

	term.c_lflag &= ~(ICANON | ECHO);
	tcsetattr(0, TCSANOW, &term);

	write(1, "\033[s", 3); /* save cursor position */
	write(1, "\033[9999;9999H", 12); /* place the cursor the farthest away */
	write(1, "\033[6n", 4); /* get the cursor position which should be the screen size */

	fcntl(0, F_SETFL, O_NONBLOCK);
	int timeout = 0;

	while (1) {
		_err = fscanf(stdin, "\x1b[%d;%dR", rowOut, columnOut); /* parse the cursor position result */

		if (_err > 0)
			break;

		if (errno != EAGAIN)
			break;

		if (errno == EAGAIN) {
			if (timeout < 2000000) { /* 2 seconds timeout */
				timeout += 500;
			} else { /* time's up, we break */
				break;
			}
		}

		usleep(500);
	}

	if (_err < 0) {
		*columnOut = 60;
		*rowOut = 40;
	}

	tcsetattr(0, TCSANOW, &initialSettings);

	write(1, "\033[u", 3); /* restore cursor position */
}

void
getConsoleSize(int *columnOut, int *rowOut) {
	struct winsize wsz;

	*columnOut = 60;
	*rowOut = 40;
	if (ioctl(STDIN_FILENO, TIOCGWINSZ, &wsz) != -1) {
		*columnOut = wsz.ws_col;
		*rowOut = wsz.ws_row;
	}
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
