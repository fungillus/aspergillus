# custom simple lua compilation

core_files = [
'lua/lapi.c', 'lua/lcode.c', 'lua/lctype.c', 'lua/ldebug.c', 'lua/ldo.c'
, 'lua/ldump.c', 'lua/lfunc.c', 'lua/lgc.c', 'lua/llex.c', 'lua/lmem.c'
, 'lua/lobject.c', 'lua/lopcodes.c', 'lua/lparser.c', 'lua/lstate.c'
, 'lua/lstring.c', 'lua/ltable.c', 'lua/ltm.c', 'lua/lundump.c'
, 'lua/lvm.c', 'lua/lzio.c', 'lua/ltests.c']

aux_files = [
'lua/lauxlib.c'
]

lib_files = [
'lua/lbaselib.c', 'lua/ldblib.c', 'lua/liolib.c', 'lua/lmathlib.c'
, 'lua/loslib.c', 'lua/ltablib.c', 'lua/lstrlib.c', 'lua/lutf8lib.c'
, 'lua/loadlib.c', 'lua/lcorolib.c', 'lua/linit.c'
]

luaDep = static_library('lua', core_files + aux_files + lib_files, install: true)
