#! /bin/sh

newFonts="$(cd luaLibs; lua convertImage.lua ../fonts.txt)"

sed -i luaLibs/fonts.lua -e "s/o\.fontsImg = .*$/o.fontsImg = $newFonts/"
