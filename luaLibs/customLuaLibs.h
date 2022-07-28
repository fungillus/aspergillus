#ifndef __CUSTOMLUALIBS_H
#define __CUSTOMLUALIBS_H

extern unsigned char ___luaLibs_console_lua[];
extern unsigned int ___luaLibs_console_lua_len;

extern unsigned char ___luaLibs_basic2_lua[];
extern unsigned int ___luaLibs_basic2_lua_len;

extern unsigned char ___luaLibs_vector_lua[];
extern unsigned int ___luaLibs_vector_lua_len;

extern unsigned char ___luaLibs_fps_lua[];
extern unsigned int ___luaLibs_fps_lua_len;

extern unsigned char ___luaLibs_fonts_lua[];
extern unsigned int ___luaLibs_fonts_lua_len;

extern unsigned char ___luaLibs_menu_lua[];
extern unsigned int ___luaLibs_menu_lua_len;

extern unsigned char ___luaLibs_convertImage_lua[];
extern unsigned int ___luaLibs_convertImage_lua_len;

extern unsigned char ___luaLibs_tester_lua[];
extern unsigned int ___luaLibs_tester_lua_len;

extern void loadLuaLibraries(lua_State *L);

#endif /* NOT __CUSTOMLUALIBS_H */
