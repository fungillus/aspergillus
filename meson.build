project('fungillus-platform', 'c')

subdir('lua/')
subdir('libs/')
subdir('joystick/')
subdir('luaLibs/')

cc = meson.get_compiler('c')

mDep = cc.find_library('m', required: true)
#dlDep = cc.find_library('dl', required: true)
dlDep = cc.find_library('dl', required: false)

luaIncludePath = include_directories(['lua/lua', 'luaLibs'])

extraDependencies = [luaDep, libjoystick]

conf_data = configuration_data()
if get_option('embed-custom-luaLibs')
  extraDependencies += libCustomLuaLibs
  conf_data.set('EMBED_CUSTOM_LUALIBS', 1)
  conf_data.set('lua_search_path', '/usr/share/lua/?.lua' + ';./?.lua')
else
  conf_data.set('EMBED_CUSTOM_LUALIBS', 0)
  conf_data.set('lua_search_path', '/usr/share/lua/?.lua;' + meson.project_source_root() + '/luaLibs/?.lua' + ';./?.lua')
endif

linkArgs = []
if get_option('static')
  linkArgs += '-static'
endif

configure_file(input: 'config.h.in'
		,output: 'config.h'
		,configuration: conf_data)

executable('runGame', ['main.c'], customLibs, dependencies: [mDep, dlDep], link_with: extraDependencies, include_directories: [luaIncludePath, libjoystickPath], link_args: linkArgs)
