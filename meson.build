project('fungillus-platform', 'c')

subdir('lua/')
subdir('libs/')

cc = meson.get_compiler('c')

mDep = cc.find_library('m', required: true)
#dlDep = cc.find_library('dl', required: true)
dlDep = cc.find_library('dl', required: false)

luaIncludePath = include_directories('lua/lua')

conf_data = configuration_data()
conf_data.set('lua_search_path', meson.project_source_root() + '/luaLibs/?.lua' + ';./?.lua')
configure_file(input: 'config.h.in'
		,output: 'config.h'
		,configuration: conf_data)


executable('runGame', ['main.c'], customLibs, dependencies: [mDep, dlDep], link_with: [luaDep], include_directories: luaIncludePath)
