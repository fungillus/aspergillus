#! /bin/sh

projectDirectory=$1

if [ "$projectDirectory" = "" ]; then
	echo "Please input the directory name of your project"
	exit 1
fi

if [ -e $projectDirectory ]; then
	echo "A file or directory already exist with that name, please choose another"
	exit 1
fi

mkdir $projectDirectory

cat - > $projectDirectory/main.lua << EOF
function Init()
	local bmp = Bitmap:new(-1, -1)
	local screenSize = bmp:getSize()
	local screenCol, screenRow = screenSize.width, screenSize.height
	local fonts = Fonts:new()

	console.clearScreen()

	fonts:printText(bmp, {x = 5, y = 5}, "Your new project's directory : $projectDirectory")

	bmp:draw()
end

function Poll()
	stopGame()
end
EOF
