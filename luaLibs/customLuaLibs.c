
/*      lua       */
#include <lua.h>
#include <lauxlib.h>
#include <lualib.h>

#include <customLuaLibs.h>

static void
loadLibrary(lua_State *L, const char *buffer, int bufferLen, const char *name) {
	lua_settop(L, 1);
	lua_getfield(L, LUA_REGISTRYINDEX, LUA_LOADED_TABLE);
	luaL_loadbuffer(L, buffer, bufferLen, name);
	lua_pcall(L, 0, 0, 0);
	lua_setfield(L, 2, name);
}

void
loadLuaLibraries(lua_State *L) {
	loadLibrary(L, (const char *)___luaLibs_console_lua, ___luaLibs_console_lua_len, "console");
	loadLibrary(L, (const char *)___luaLibs_vector_lua, ___luaLibs_vector_lua_len, "vector");
	loadLibrary(L, (const char *)___luaLibs_basic2_lua, ___luaLibs_basic2_lua_len, "basic2");
	loadLibrary(L, (const char *)___luaLibs_fps_lua, ___luaLibs_fps_lua_len, "fps");
	loadLibrary(L, (const char *)___luaLibs_fonts_lua, ___luaLibs_fonts_lua_len, "fonts");
	loadLibrary(L, (const char *)___luaLibs_tester_lua, ___luaLibs_tester_lua_len, "tester");
	loadLibrary(L,
		(const char *)___luaLibs_convertImage_lua, ___luaLibs_convertImage_lua_len, "convertImage");
	loadLibrary(L, (const char *)___luaLibs_menu_lua, ___luaLibs_menu_lua_len, "menu");
}
