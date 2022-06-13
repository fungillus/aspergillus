project('fungillus-platform', 'c')

cc = meson.get_compiler('c')

mDep = cc.find_library('m', required: true)
dlDep = cc.find_library('dl', required: true)

luaPath = meson.global_source_root() + '/lua'
luaIncludePath = include_directories('lua')

luaDep = cc.find_library('lua', dirs: luaPath, static: true)

executable('runGame', ['main.c'], dependencies: [mDep, dlDep, luaDep], include_directories: luaIncludePath)
