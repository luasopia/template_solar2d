--------------------------------------------------------------------------------
-- 2022/08/26 created
--------------------------------------------------------------------------------

--[[-----------------------------------------------------------------------------
-- dobj:hover(opt) 둥둥 떠다니는 이펙트
--
        opt.peak (in px, default:100)
        opt.period (in ms, default:1000 ms)
        opt.rot (in degree)

-- dobj:stopHover()
------------------------------------------------------------------------------]]
local period0 = 1800 -- ms default period for x and y
local peak0 = 30 -- default peak for x and y
--------------------------------------------------------------------------------
local luasp = _luasopia
local Disp = luasp.Display
--------------------------------------------------------------------------------

function Disp:hover(opt)

    opt = opt or {}
    local pk = opt.peak or peak0
    local pr = opt.period or period0

    self:waveX{peak=pk, peak2=-pk, period=pr}
    self:waveY{peak=-pk, peak2=pk, period=pr*0.5}

    if opt.rot then
        self:waveRot{peak=opt.rot,peak2=-opt.rot, period=pr}
    end

    self.__hoverRot = opt.rot
    return self

end


function Disp:stopHover(isToOrigin)

    self:stopWaveX(isToOrigin)
    self:stopWaveY(isToOrigin)
    if self.__hoverRot then
        self:stopWaveRot(isToOrigin)
    end

    return self

end


--[[ special moving examples

--(1)
local g1 = Group():hover():setDrot(1)
local s = Circle(20,{fill=Color.RED}):addTo(g1):waveX{peak=150,peak2=-150,period=700}
local c= Circle(50):addTo(g1)
Timer(175, function()
    local s2 = Circle(20,{fill=Color.ORANGE}):addTo(g1):waveY{peak=100,peak2=-100,period=700}
end)


--(2)
Timer(500,function()
    local x,y=rand(200,880),rand(300,1720)
    local img = Image('ex/robot1.png'):set{x=x,y=y,scale=rand(4,6)/10}
    img:waveScale{peak=rand(7,13)/10}
    img:hover{rot=5}
    img:removeAfter(20000)
end,INF)


--]]

--------------------------------------------------------------------------------
-- 2022/9/4 created
--------------------------------------------------------------------------------
--[[-----------------------------------------------------------------------------
-- dobj:foam(opt) 비누방울 이펙트
--
        opt.peak (in px, default:100)
        opt.period (in ms, default:1000 ms)
        opt.rot (in degree)

-- dobj:stopHover()
------------------------------------------------------------------------------]]
local prd0foam = 1000 -- ms default period for x and y
local pk0foam = 0.9 -- default peak for x and y
local rot0foam = 10
--------------------------------------------------------------------------------

function Disp:foam(opt)

    opt = opt or {}
    local pk = opt.peak or pk0foam
    local pr = opt.period or prd0foam
    local rot = opt.rot or rot0foam

    self:waveScaleX{peak=pk, period=pr}
    self:waveRot{peak=rot,peak2=-rot, period=pr*0.85}
    self:addTimer(pr*0.5, function(self)
        self:waveScaleY{peak=pk, period=pr}
    end)

    self.__foamRot = opt.rot
    return self

end


function Disp:stopFoam(isToOrigin)

    self:stopWaveScaleX(isToOrigin)
    self:stopWaveScaleY(isToOrigin)
    self:stopWaveRot(isToOrigin)

    return self

end
    