#! /bin/sh

newFonts=$(lua convertImage.lua fonts.txt)

sed -i luaLibs/fonts.lua -e "s/o\.fontsImg = {.*}$/o.fontsImg = $newFonts/"
