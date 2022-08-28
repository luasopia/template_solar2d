--------------------------------------------------------------------------------
-- 2022/08/26 created
--------------------------------------------------------------------------------

--[[-----------------------------------------------------------------------------
-- dobj:hover(opt)
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

    self:waveX{peak=pk, period=pr}
    self:waveY{peak=-pk, period=pr*0.5}

    if opt.rot then
        self:waveRot{peak=opt.rot,period=pr}
    end

    return self

end


function Disp:stopHover(isToOrigin)

    self:stopWaveX(isToOrigin)
    self:stopWaveY(isToOrigin)


end


--[[
        img:waveRot{peak=3,period=2000}
    img:waveX{peak=50,period=2000}
    img:waveY{peak=-50,period=1000}

]]
    