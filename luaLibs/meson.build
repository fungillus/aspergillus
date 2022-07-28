
xxdExecutable = find_program('xxd')

luaLibsPath = include_directories('.')

customLuaLibs = []

# the order of these custom_targets is significant
# because of their inter dependencies

customLuaLibs += custom_target('tester'
	      ,input: 'tester.lua'
	      ,output: 'tester.lua.c'
	      ,capture: true
	      ,command: [xxdExecutable, '-i', '@INPUT0@'])

customLuaLibs += custom_target('console'
	      ,input: 'console.lua'
	      ,output: 'console.lua.c'
	      ,capture: true
	      ,command: [xxdExecutable, '-i', '@INPUT0@'])

customLuaLibs += custom_target('vector'
	      ,input: 'vector.lua'
	      ,output: 'vector.lua.c'
	      ,capture: true
	      ,command: [xxdExecutable, '-i', '@INPUT0@'])

customLuaLibs += custom_target('fps'
	      ,input: 'fps.lua'
	      ,output: 'fps.lua.c'
	      ,capture: true
	      ,command: [xxdExecutable, '-i', '@INPUT0@'])

customLuaLibs += custom_target('basic2'
	      ,input: 'basic2.lua'
	      ,output: 'basic2.lua.c'
	      ,capture: true
	      ,command: [xxdExecutable, '-i', '@INPUT0@'])

customLuaLibs += custom_target('fonts'
	      ,input: 'fonts.lua'
	      ,output: 'fonts.lua.c'
	      ,capture: true
	      ,command: [xxdExecutable, '-i', '@INPUT0@'])

customLuaLibs += custom_target('convertImage'
	      ,input: 'convertImage.lua'
	      ,output: 'convertImage.lua.c'
	      ,capture: true
	      ,command: [xxdExecutable, '-i', '@INPUT0@'])

customLuaLibs += custom_target('menu'
	      ,input: 'menu.lua'
	      ,output: 'menu.lua.c'
	      ,capture: true
	      ,command: [xxdExecutable, '-i', '@INPUT0@'])

customLuaLibs += 'luaLibs/customLuaLibs.c'
