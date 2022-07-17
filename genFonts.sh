#! /bin/sh

newFonts=$(lua luaLibs/convertImage.lua fonts.txt)

sed -i luaLibs/fonts.lua -e "s/o\.fontsImg = {.*}$/o.fontsImg = $newFonts/"
