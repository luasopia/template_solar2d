printf('hello luasopia')

--[[
setdebug{}

require 'img.lib1'
require 'img.lib.lib'


printf("hi")
for k=1,10 do printf("%d",k) end

local m1 = Image('moon.png')
local m2 = Image('img/gear.png'):y(1200):dr(1)
local m3 = Image('moon.png'):xy(100,100)

local sht = getsheet('img/bird.png',200,200,8)
local ani = Sprite(sht,{time=1000}):play():y(500)


-- _luasopia.showg()
--]]