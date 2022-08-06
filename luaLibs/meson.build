
xxdExecutable = find_program('xxd')

luaLibsPath = include_directories('.')

customLuaLibs = []

# the order of these custom_targets is significant
# because of their inter dependencies

luaLibFiles = [
	'tester.lua'
	,'console.lua'
	,'vector.lua'
	,'fps.lua'
	,'basic2.lua'
	,'fonts.lua'
	,'convertImage.lua'
	,'menu.lua'
]

foreach luaLib : luaLibFiles
  customLuaLibs += custom_target(luaLib
	      ,input: luaLib
	      ,output: luaLib + '.c'
	      ,capture: true
	      ,command: [xxdExecutable, '-i', '@INPUT0@'])
endforeach

customLuaLibs += custom_target('customLuaLibHeader'
    ,input: luaLibFiles
    ,output: 'customLuaLibs.h'
    ,command: ['genCustomLuaLibs.sh', '@INPUT@']
)

customLuaLibs += 'luaLibs/customLuaLibs.c'
