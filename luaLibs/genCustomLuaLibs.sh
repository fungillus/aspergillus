#! /bin/sh

first=1

sep=""

entries=""

stripExtension() {
	sed -e 's/^\([^\.]\+\)\..*$/\1/'
}

entriesCount=0
for entry in $@; do
	entries="$entries $(basename $entry | stripExtension)"
	entriesCount=$((entriesCount + 1))
done

cat - > customLuaLibs.h << EOF
/* This content is automatically generated, don't edit here */

#ifndef __CUSTOMLUALIBS_H
#define __CUSTOMLUALIBS_H

typedef struct {
	const char *data;
	unsigned int *length;
	char *name;
} LuaCustomLibraryEntry;

$(for entry in $entries; do
	echo "extern unsigned char ___luaLibs_${entry}_lua[];"
	echo "extern unsigned int ___luaLibs_${entry}_lua_len;"
	echo
done)

LuaCustomLibraryEntry libraryEntries[$entriesCount] = {
$(for entry in $entries; do
	echo "	$sep{(const char *)___luaLibs_${entry}_lua, &___luaLibs_${entry}_lua_len, \"${entry}\"}"

	if [ "$first" = "1" ]; then
		first=0
		sep=","
	fi
done)
};
const int libraryEntriesCount = $entriesCount;

extern void loadLuaLibraries(lua_State *L);

#endif /* NOT __CUSTOMLUALIBS_H */
EOF

exit 0
