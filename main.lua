-- Warning : Don't edit this file.
-- Instead, start coding 'root/main.lua' since luasopia app starts from that file.

-------------------------------------------------------------------------------
-- 2021/05/13 created
-------------------------------------------------------------------------------
require 'luasopia.init'

-- in this point, the (relative) root foler is replaced by '/root'
-- require()함수는 root폴더를 기본으로 하는 것으로 위에서 치환되었다.
-- The original 'require()' function has been changed its name into '_req()'

-- The '/root/main.lua' file is firstly executed.
return require 'main' -- root/main.lua 파일로 점프(goto)


--[[
local myText = display.newText( "0", 500, 200, native.systemFont, 50 )
local count = 0
timer.performWithDelay(20, function()
    count = count + 1
    myText.text = string.format('This function has been called %d times',count)
end, 0)
--]]