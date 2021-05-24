--2020/06/13
--------------------------------------------------------------------------------
local sqrt, atan2 = math.sqrt, math.atan2
local R2D = 180/math.pi
local Disp = Display
--------------------------------------------------------------------------------

local function upd(self)

    self._frmc = self._frmc + 1
    local pt = self._pth[self._frmc]
    --self:set{x=pt.sx, y=pt.sy, r=pt.rot, s=pt.z}
    self:set{x=pt.sx, y=pt.sy, r=pt.rot, s=pt.z}
    if pt.rm then return true end

end

function Disp:followpath(path)

    self._frmc = 0 -- frame count
    self._pth = path
    self:__addupd__( upd )
    return self
    
end

--------------------------------------------------------------------------------
-- Path class
--------------------------------------------------------------------------------

local function add(pt1, pt2)
    return {
        x = pt1.x + pt2.x,
        y = pt1.y + pt2.y,
        z = pt1.z + pt2.z
    }
end

local function add3(n1, pt1, n2, pt2, n3, pt3)
    return {
        x=n1*pt1.x + n2*pt2.x + n3*pt3.x,
        y=n1*pt1.y + n2*pt2.y + n3*pt3.y,
        z=n1*pt1.z + n2*pt2.z + n3*pt3.z,
    }
end

local function add4(n1, pt1, n2, pt2, n3, pt3, n4, pt4)
    return {
        x=n1*pt1.x + n2*pt2.x + n3*pt3.x + n4*pt4.x,
        y=n1*pt1.y + n2*pt2.y + n3*pt3.y + n4*pt4.y,
        z=n1*pt1.z + n2*pt2.z + n3*pt3.z + n4*pt4.z,
    }
end

local function sub(pt1, pt2)
    return {
        x = pt1.x - pt2.x,
        y = pt1.y - pt2.y,
        z = pt1.z - pt2.z
    }
end

-- y축의 1은 16/9 이므로 (1920:1080=16:9=1.7777..) dy에 이 비율을 곱한다.
--local widht, height = 1080, 1920
local width = screen.endx - screen.x0 + 1
local height = screen.endy - screen.y0 + 1
local yratio = height/width
local function dist(pt1, pt2)
    local dx, dy, dz = pt1.x-pt2.x, yratio*(pt1.y-pt2.y), pt1.z-pt2.z
    return sqrt(dx*dx+dy*dy+dz*dz)
end
------------------------------------------------------------
Path = class() -- Hermite Spline3
------------------------------------------------------------
--[[
function Path.wh(w, h)
    width, height = w, h
    yratio = w/h
end
--]]
------------------------------------------------------------
-- 전체적으로 속도를 일정하게 맞추기 위해서 점간의 거리 비율을 구한다.
-- 2020/06/13 원본을 보존하기 위해서 카피본을 만들어 사용한다.
local copy = _luasopia.copytable
local function getdists(ptsr, opt)
    -- opt가 nil이면 ptsr원본을 이용하고 (원본을 보존할 필요가 없다)
    if opt == nil then

        for k=2, #ptsr do
            ptsr[k].len = dist(ptsr[k], ptsr[k-1])
        end
        return ptsr

    else -- opt가 nil이 아니면 ptsr의 복사본을 이용한다.(원본 보존)

        local pts = {[1]=copy(ptsr[1])}
        for k=2, #ptsr do
            pts[k] = copy(ptsr[k])
            pts[k].len = dist(pts[k], pts[k-1])
        end

        if opt == 'flipv' then
            for k=1, #pts do
                pts[k].x = 1-pts[k].x
            end
        elseif opt == 'fliph' then
            for k=1, #pts do
                pts[k].y = 1-pts[k].y
            end
        end
        
        return pts
    end
end

-- (정규값)0.5를 1초에 이동하는 속도를 기준속도(speed = 1)로 잡는다.
-- 따라서 점간거리를 5로 나누면 60frame일 경우 프레임별로 위치할 점의 수가 계산된다.
local distPerSec = 0.5 -- 0.5

-----------------------------------------------------------------------
-- speed : speed rate (defaut:1.0)
-- opt : 'fliph', 'flipv'
-----------------------------------------------------------------------
function Path:init(ptsr, speed, opt)
    speed = speed or 1
    local pts = getdists(ptsr, opt)

    self[1] = pts[1]-- self[1] = pts[1]:append{isGiven = true}
    self[1]._nspd = pts[2]._spd -- 06/Aug/2016 aburn의 속도를 제어하기 위해 주가


    --dp[k]는 pt[k]점으로의 진입 벡터(나가는 방향이 아님)를 의미한다.
    --local dp = {[1] = pts[2]-pts[1]}
    local dp = { [1] = sub(pts[2], pts[1]) }

    for k = 2,#pts do
        -- 진입각을 인전점에서 다음점을 향하는 벡터로 설정한다.
        -- 이렇게 하면 보간의 역할을 해서 곡선을 부드럽게 만드는데 도움이 된다.
        if k == #pts then
            -- dp[k] = pts[k] - pts[k-1]
            dp[k] = sub(pts[k], pts[k-1])
        else -- 이전각도보다 다음 각도의 비중을 더 높인다 3:7
            -- 21/July/2016 : 35:65 비율이 가장 부드러운 곡선을 만드는 것 같다.
            -- dp[k] = 0.35*dp[k-1] + 0.65*(pts[k+1]-pts[k])
            dp[k] = add3(0.35,dp[k-1], 0.65,pts[k+1], -0.65,pts[k])
        end

        -- local pta = 2*pts[k-1] - 2*pts[k] + dp[k-1] + dp[k]
        local pta = add4( 2,pts[k-1],  -2,pts[k],  1,dp[k-1],  1,dp[k] )
        -- local ptb = -3*pts[k-1] + 3*pts[k] -2*dp[k-1] - dp[k]
        local ptb = add4(-3,pts[k-1],  3,pts[k],  -2,dp[k-1],  -1,dp[k])
        local ptc = dp[k-1]
        local ptd = pts[k-1]

        -- local speedRate = pts[k]._spd or 1
        -- 2020/06/13 speed(전체적인 속도)추가
        local speedRate = (pts[k]._spd or 1)*speed 
        local divd = distPerSec*speedRate/screen.fps
        -- local interval = 1/(pts[k].len/divd)
        local interval = divd/pts[k].len
        for t = interval, 1, interval do
            local t2=t*t
            self[#self+1] = add4( t*t2,pta,  t2,ptb,   t,ptc,  1,ptd )
        end

        self[#self+1] = pts[k]-- self[#self+1] = pts[k]:append{isGiven = true}

        -- 06/Aug/2016 aburn의 크기를 제어하기 위해 다음점의 속도를 추가
        if k<#pts then self[#self]._nspd = pts[k+1]._spd end
    end

    -- rotational angle calculation
    -- 2020/06/11 : 원본이미지가 아래방향을 향한다고 가정한 경우의 회전각
    --[[
    for k=1,#self-1 do
        local rad =  atan2( self[k+1].y-self[k].y, self[k+1].x-self[k].x )
        self[k].rot = rad * R2D -90
    end
    self[#self].rot = self[#self-1].rot -- 마지막 각도는 직전의 각도와 같게
    --]]
    local pt, rad
    for k=1,#self-1 do
        pt = self[k]
        rad =  atan2( self[k+1].y-pt.y, self[k+1].x-pt.x )
        pt.rot = rad * R2D -90
        -- 2020/06/12 : screen xy를 계산
        pt.sx = pt.x*width
        pt.sy = pt.y*height
    end
    pt = self[#self]
    pt.rot = self[#self-1].rot -- 마지막 각도는 직전의 각도와 같게
    pt.sx = pt.x*width
    pt.sy = pt.y*height
end
--------------------------------------------------------------------------------
--lib.Path = Path