--------------------------------------------------------------------------------
-- 2022/09/23: refactored
--------------------------------------------------------------------------------
--[[----------------------------------------------------------------------------
Disp:chase(target, {
    speed=n, -- (default:20) 선속도
    dx0=n, -- (default:0)초기 속도벡터x
    dy0=n, -- (default:-speed)초기 속도벡터y
    gain, -- (default:0.8)1차필터의 gain(0<g<1, 작을수록 추적이 빠르다.)
    onHit,-- function
    
    -- 아래는 target에서 간격(gap)을 smooth하게 유지시키기 위한 옵션들
    xGap=n,
    yGap=n,
    noRot, -- bool(default:true) true라면 회전각을 변경하지 않는다
    rSlow, -- target+gap 과의 거리가 이 반경(radius) 이하라면 speed/10 속도로 느려진다
})


--------------------------------------------------------------------------------
(ex1)

local r=Image('ex/mymsl.png'):chase(t, {dx0=20,dy0=50})

(Gap ex2)

local c2=Rect(30,60):setXY(1080,0):chase(t2,{
    speed=50, -- rSlow반경 밖에서의 속도
    gain=0.7,
    xGap=100,yGap=100,
    noRot=true,
    rSlow=50,
})
------------------------------------------------------------------------------]]
--------------------------------------------------------------------------------
local Disp = _luasopia.Display
local sqrt, atan2 = math.sqrt, math.atan2
local R2D = 180/math.pi -- radian to degree constant
local tdobj = Disp.__tdobj
-- local cos, sin, D2R = math.cos, math.sin, math.pi/180
--------------------------------------------------------------------------------

local function chaseUpd(self, e)

    local chs = self.__chs
    if chs==nil then return end

    -- 타겟이 없거나 삭제되었다면 현재 방향으로 계속 진행한다.
    if chs.trgt==nil or chs.trgt.__bd == nil then
        self:setXY(
            self.__bdx + chs.pdx,
            self.__bdy + chs.pdy
        )
        return
    end


    -- 타겟을 향하는 단위벡터x선속도 의 xy값들 계산
    local x,y = self.__bdx, self.__bdy
    local dx = (chs.trgt.__bdx+chs.xgap)-x
    local dy = (chs.trgt.__bdy+chs.ygap)-y
    local dist = sqrt(dx*dx + dy*dy) -- faster calc than (dx*dx+dy*dy)^0.5
    local sd = chs.spd/dist

    -- rSlow반경 안에서는 속도를 1/10로 줄인다
    if chs.rslow and dist<chs.rslow then
            --if chs.rstop and dist<chs.rstop then
            if dist<1.5 then -- 진동방지
                return
            else
                sd = sd*0.1
            end
    end


    dx, dy = dx*sd, dy*sd 
    -- 1st-order filtering for smooth movement
    local g, _1_g = chs.gain, chs._1_g
    dx = g*chs.pdx + _1_g*dx  -- g·pdx + (1-ga)·dx
    dy = g*chs.pdy + _1_g*dy  -- g·pdy + (1-ga)·dy

    -- setting attrs
    self:setXY(x+dx, y+dy)
    if chs.doRot then
        self:setRot(atan2(dy,dx)*R2D + 90)
    end

    -- recursive substitution
    chs.pdx, chs.pdy = dx, dy

end


function Disp:chase(target, opt) -- oncotact

    --if target == nil or target.__bd==nil then return end

    opt = opt or {}
    local spd = opt.speed or 20 
    local dx0, dy0 = opt.dx0 or 0, opt.dy0 or -spd
    local gain = opt.gain or 0.8 --0.85, -- 0<g<1,(각속도) 작을수록 추적이 빠르다.
    local chs = {
        trgt = target,
        pdx = dx0, -- 초기x속도
        pdy = dy0, -- 초기y속도
        spd = spd, -- linearSpeed 선속도 (따라가는 속도)
        gain = gain,
        _1_g = 1-gain,

        xgap = opt.xGap or 0,
        ygap = opt.yGap or 0,
        doRot = not opt.noRot,
        rstop = opt.rStop,
        rslow = opt.rSlow,
        spd0 = spd,
    }

    if chs.doRot and (dx0~=0 or dy0~=0) then
        self:setRot(atan2(dy0,dx0)*R2D + 90)
    end
    
    self.__chs = chs
    return self:__addUpd__(chaseUpd)
    
end

function Disp:stopChase()

    self.__chs = nil
    self:__rmUpd__(chaseUpd)

end
