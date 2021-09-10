local luasp = _luasopia
local esclayer = luasp.esclayer
local Disp = Display
local infocolor = Color.LIGHT_PINK

--------------------------------------------------------------------------------


local xgap = 100
local ygap = 100
local color = Color.DARK_SLATE_GRAY
local width = 2

for x = xgap, screen.width0, xgap do
    local g = Line1(x, 0, x, screen.height0, {width=width, color=color})
    g:addto(esclayer)
    g.__nocnt = true
end

for y = ygap, screen.height0, ygap do
    local g = Line1(0, y, screen.width0, y, {width=width, color=color})
    g:addto(esclayer)
    g.__nocnt = true
end

--------------------------------------------------------------------------------

local getTxtMem
if _Gideros then
		
    getTxtMem = function()
        return _Gideros.application:getTextureMemoryUsage()
    end

    -- luasp.getFps = function(e)
    --     return 1/e.deltaTime
    -- end

elseif _Corona then
    
    getTxtMem = function()
        return system.getInfo("textureMemoryUsed") / 1000
    end
    
    -- local prvms = 0
    -- luasp.getFps = function()
    --     local ms = system.getTimer()
    --     local fps = 1000/(ms - prvms)
    --     prvms = ms
    --     return fps
    -- end

end

local infotxts = Group():addto(esclayer):setxy(0,75)
infotxts.__nocnt = true

local memtxt = Text1("",{color=infocolor}):addto(infotxts):setxy(10, 45)
memtxt.__nocnt = true

local objtxt = Text1("",{color=infocolor}):addto(infotxts):setxy(10, 90)
objtxt.__nocnt = true


local updateInfo = function(e)

    local txtmem = getTxtMem()
    local mem = collectgarbage('count')
    memtxt:setstrf('memory:%d kb,texture memory:%d kb', mem, txtmem)
    local ndisp = Disp.__getNumObjs() -- - logf.__getNumObjs() - 2
    objtxt:setstrf('DispObj:%d, TimerObj:%d', ndisp, Timer.__getNumObjs())
        
end

updateInfo()
local tmrInfo = Timer(200, updateInfo, INF)
tmrInfo.__nocnt = true

function luasp.showConsole(isToShow)

    -- print('esc pressed')

    if isToShow then

        luasp.stdoutlayer:hide()
        esclayer:show()
        tmrInfo:resume()
        luasp.cli.entry:focus()
    
    else

        luasp.stdoutlayer:show()
        esclayer:hide()
        tmrInfo:pause()
        luasp.cli.entry:focus(false)

    end

end
--------------------------------------------------------------------------------

_require0('luasp.util.toolbar')
_require0('luasp.util.cli')