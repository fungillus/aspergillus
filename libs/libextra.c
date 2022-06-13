
#define lextralib_c
#define LUA_LIB

/* #include "lprefix.h" */

#include "lua.h"
#include "lauxlib.h"
#include "lualib.h"

#include <sys/time.h> /* gettimeofday */
#include <unistd.h> /* usleep */

int
getTickCount() {
	struct timeval tv;
	gettimeofday(&tv, NULL);
	return (tv.tv_sec * 100 + tv.tv_usec / 10000) & 0x7fffffff;
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



/***********************************************/

static const luaL_Reg extralib[] = {
	{"usleep", extra_usleep}
	,{"getTickCount", extra_getTickCount}
	,{NULL, NULL}
};

LUAMOD_API int luaopen_extra (lua_State *L) {
	luaL_newlib(L, extralib);
	return 1;
}
