project('fungillus-platform', 'c')

subdir('lua/')
subdir('libs/')

cc = meson.get_compiler('c')

mDep = cc.find_library('m', required: true)
dlDep = cc.find_library('dl', required: true)

luaIncludePath = include_directories('lua/lua')


executable('runGame', ['main.c'], customLibs, dependencies: [mDep, dlDep], link_with: [luaDep], include_directories: luaIncludePath)
