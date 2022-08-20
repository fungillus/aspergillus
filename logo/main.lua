require("basic2")
require("console")
require("convertImage")
require("fonts")
require("animation")

function Init()
	--print "\x1b[25l"
	local screenCol, screenRow = extra.getConsoleSize()
	local leftOffset = screenCol - 45
	local topOffset = screenRow - 15
	console.clearScreen()
	screen = Bitmap:new(screenCol * 2, screenRow * 4)

	local fonts = Fonts:new()

	local sparkAnim2 = {}

	sparkAnim2[1] = convertRawTextToImage([[
  *  
  *  
*****
  *  
  *  
]])
	sparkAnim2[2] = convertRawTextToImage([[
* * *
  *  
*****
  *  
* * *
]])
	sparkAnim2[3] = convertRawTextToImage([[
  *  
 * * 
*   *
 * * 
  *  
]])
	sparkAnim2[4] = convertRawTextToImage([[
* * *
 * * 
*   *
 * * 
* * *
]])
	sparkAnim2[5] = convertRawTextToImage([[
  *  
     
*   *
     
  *  
]])

	local fungillusLogo = {}

	fungillusLogo[1] = convertRawTextToImage(
		string.rep(string.rep("*", 24), 16, "\n")
	)

	fungillusLogo[2] = convertRawTextToImage(
		string.rep(string.rep(" ", 24), 16, "\n")
	)

	for i = 1, 4 do
		table.insert(fungillusLogo, fungillusLogo[1])
	end
	for i = 1, 6 do
		table.insert(fungillusLogo, fungillusLogo[2])
	end
	table.insert(fungillusLogo, fungillusLogo[1])
	table.insert(fungillusLogo, fungillusLogo[1])
	for i = 1, 2 do
		table.insert(fungillusLogo, fungillusLogo[2])
	end

	table.insert(fungillusLogo, convertRawTextToImage([[
         ******
      ***     ***
     *          ***
    *             **
    *              *
     **      *     *
      *******     *
           *     *
      *****     *
    **          *
   *            *
   *             *
  *               *
 *                **
 *                  **
*                     **
]]))
	for i = 1, 60 do
		table.insert(fungillusLogo, fungillusLogo[#fungillusLogo])
	end

	local funkyAnim = {}

	funkyAnim[1] = convertRawTextToImage([[
*       
*       
*       
*       
*       
*       
]])
	funkyAnim[2] = convertRawTextToImage([[
  *     
  *     
  *     
  *     
  *     
  *     
]])
	funkyAnim[3] = convertRawTextToImage([[
    *   
    *   
    *   
    *   
    *   
    *   
]])
	funkyAnim[4] = convertRawTextToImage([[
      * 
      * 
      * 
      * 
      * 
      * 
]])

	animations = {}
	table.insert(animations, Animate:new(sparkAnim2, 5, {x= leftOffset + 20, y = topOffset + 20}, extra.getTickCount() + 130))
	table.insert(animations, Animate:new(sparkAnim2, 5, {x= leftOffset + 41, y = topOffset + 45}, extra.getTickCount() + 20))
	table.insert(animations, Animate:new(sparkAnim2, 5, {x= leftOffset + 50, y = topOffset + 2}, extra.getTickCount() + 70))
	table.insert(animations, Animate:new(sparkAnim2, 5, {x= leftOffset + 72, y = topOffset + 50}, extra.getTickCount() + 170))
	table.insert(animations, Animate:new(sparkAnim2, 5, {x= leftOffset + 30, y = topOffset + 12}, extra.getTickCount() + 40))
	table.insert(animations, Animate:new(sparkAnim2, 5, {x= leftOffset + 62, y = topOffset + 25}, extra.getTickCount() + 150))

	endTime = extra.getTickCount() + 400

	table.insert(animations, Animate:new(fungillusLogo, 5, {x= leftOffset +35, y= topOffset +20}, extra.getTickCount() + 50))

	local gameMakerName = "Fungillus"
	local gameMakerNameBitmap = Bitmap:new(#gameMakerName * fonts:getCharacterWidth(), fonts:getCharacterHeight())
	fonts:printText(gameMakerNameBitmap, {x=0, y=0}, gameMakerName)
	table.insert(animations, Animate:new({gameMakerNameBitmap}, 250, {x= leftOffset +20, y= topOffset +40}, extra.getTickCount() + 220))

	table.insert(animations, Animate:new(funkyAnim, 5, {x= leftOffset +20, y= topOffset +40}, extra.getTickCount() + 30))
	table.insert(animations, Animate:new(funkyAnim, 5, {x= leftOffset +28, y= topOffset +40}, extra.getTickCount() + 60))
	table.insert(animations, Animate:new(funkyAnim, 5, {x= leftOffset +34, y= topOffset +40}, extra.getTickCount() + 90))
	table.insert(animations, Animate:new(funkyAnim, 5, {x= leftOffset +40, y= topOffset +40}, extra.getTickCount() + 120))
	table.insert(animations, Animate:new(funkyAnim, 5, {x= leftOffset +48, y= topOffset +40}, extra.getTickCount() + 150))
end

function quit()
	print "\x1b[25h"
	stopGame()
end

function Poll()
	local currentTicks = extra.getTickCount()

	if endTime <= currentTicks then
		quit()
	end

	drawAnimationsOnScreen(animations, screen)
end
