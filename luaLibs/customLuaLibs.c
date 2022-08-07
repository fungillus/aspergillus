
/*      lua       */
#include <lua.h>
#include <lauxlib.h>
#include <lualib.h>

#include <internal_customLuaLibs.h>
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
	for (int i = 0; i < libraryEntriesCount; i++) {
		loadLibrary(L, libraryEntries[i].data, *(libraryEntries[i].length), libraryEntries[i].name);
	}
}
