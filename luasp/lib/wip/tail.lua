--------------------------------------------------------------------------------
-- 2020/06/16 tail effect 구현
-- 주의: tail에서는 strokecolor는 지정하지 않는 것이 좋다(경계선이 생기므로)
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
local Rawshape = _luasopia.Rawshape
local Disp = _luasopia.Display
local WHITE = Color.WHITE -- default stroke/fill color
--------------------------------------------------------------------------------
local tblin = table.insert
local tblrm = table.remove
local unpack = unpack
--[[ 
local function tmrf(self)

    Display.xy(self, self._fx, self._fy)
    local pxys, njnt, njnt1 = self._pxys, self._njnt, self._njnt1

    --tblin(pxys, {self:getXY()})
    tblin(pxys, {self._fx, self._fy})
    if #pxys>njnt1 then tblrm(pxys,1) end

    if pxys[njnt1] ~=nil then
        local x0, y0 = unpack(pxys[njnt1])
        local pts = {pxys[njnt][1]-x0, pxys[njnt][2]-y0}
        for k=njnt-1,1,-1 do
            tblin(pts, pxys[k][1]-x0)
            tblin(pts, pxys[k][2]-y0)
        end
        self:_redraw(pts)
    end
end
--]]
local function tmrf(self)
    local fx, fy = self._fx, self._fy

    Disp.xy(self, fx, fy)
    local pxys, njnt, njnt1 = self._pxys, self._njnt, self._njnt1

    tblin(pxys, {fx, fy})
    local np = #pxys
    if np>njnt1 then
        tblrm(pxys,1)
        np = njnt1
     end

    if np>0 then -- 점이 한 개 이상이라면
        local pts = {}
        for k = np-1,1,-1 do
            tblin(pts, pxys[k][1]-fx)
            tblin(pts, pxys[k][2]-fy)
        end
        self:_redraw(pts)
    end

    -- self:add( Circle(10):fill(Color.RED) )
end

local function tmrfrm(self)

    -- 점점 희미해지는 효과
    self:a(self:geta()-0.06) -- -0.065

    -- 꼬리가 마지막 지점으로 점차 짧아지는 효과
    local fx, fy = self._ffx, self._ffy

    local pxys =  self._pxys
    tblrm(pxys,1)
    local np = #pxys

    if np>0 then -- 점이 한 개 이상이라면
        local pts = {}
        for k = np-1,1,-1 do
            tblin(pts, pxys[k][1]-fx)
            tblin(pts, pxys[k][2]-fy)
        end
        self:_redraw(pts)
    else
        self:remove()
    end


end

--------------------------------------------------------------------------------
local Tail = class(Group)
lib.Tail = Tail
--[[----------------------------------------------------------------------------
opt = {
    joints (default=2) : number of joints of tail
    redrawtime (default=50) : redraw time interval
    decwidth (default=1) : decreasing rate of width
    decalpha (default=1) : decreasing rate of alpha
    yoffset

    strokeWidth
    strokeColor
    fillcolor
}
------------------------------------------------------------------------------]]

function Tail:init(width, opt)
    Group.init(self)
    -- --[[
    opt = opt or {}
    opt.sw = opt.strokeWidth or 0
    opt.sc = opt.strokeColor or WHITE
    opt.fc = opt.fillcolor or WHITE

    self._opt = opt 
    self._pxys = {} -- past xy's
    self._wdt = width/2 -- 2로나눠야 실제 폭이 width가 된다
    self._njnt = opt.joints or 2
    self._njnt1 = self._njnt+1
    -- self._rftm = opt.redrawtime or 35
    local delay = opt.redrawtime or 34
    self._dwr = opt.decwidth or 1
    self._dar = opt.decalpha or 1
    self._yofs = opt.yoffset or 0
    self._fx, self._fy = 0,0

    self._tltmr = self:timer(delay, tmrf, INF)
    
    -- self.update = tmrf
end

function Tail:removeout()
    -- 마지막 위치를 저장한다.
    self._ffx, self._ffy = self._fx, self._fy
    self._tltmr.__fn = tmrfrm
    -- self:da(-0.06) -- -0.065
end

-- (중요)갱신시간 사이에 위치가 변경되는 것을 막고 저장만 시켜둔다.
-- 이렇게 하지 않으면 꼬리 전체가 흔들린다.
-- 2020/06/27 회전은 막는다
function Tail:xy(x, y)
    self._fx, self._fy = x, y
    return self
end

-- 2020/06/28 초기 발생지점이 정확해야 하는 경우 사용한다.
function Tail:initxy(x, y)
    self._pxys = {{x,y}}
    self._fx, self._fy = x, y
    return self
end


function Tail:xyrot(x, y, r)
    self._fx, self._fy = x, y
    return self
end

function Tail:x(x) self._fx = x;return self end
function Tail:y(x) self._fy = y;return self end
function Tail:rot(r) return self end

function Tail:getXY() return self._fx, self._fy end
function Tail:getX() return self._fx end
function Tail:getY() return self._fy end


function Tail:fill(color)
    self._opt.fc = color
    return self
end

function Tail:strokeColor(color)
    self._opt.sc = color
    return self
end

function Tail:strokeWidth(w)
    self._opt.sw = w
    return self
end

--------------------------------------------------------------------------------
local sqrt = math.sqrt

function Tail:_redraw(pts)
    --self:fill(Color.rand())
    self:clear()

    local npts = #pts
    local h, w0 = hgt, self._wdt
    local xk_1, yk_1 = 0,0

    local fc = self._opt.fc
    local fca = fc.a -- backup original fillcolor alpha

    local q1xp, q1yp, q2xp, q2yp

    for k=1,npts,2 do

        local x, y = pts[k]-xk_1, pts[k+1]-yk_1
        --[[
        local r = sqrt(x*x+y*y)
        local w0r = w0/r
        local xw0r, yw0r = x*w0r, y*w0r
        local q1x, q1y = -yw0r,  xw0r 
        local q2x, q2y = yw0r, -xw0r
        --]]
        local w0r = w0/sqrt(x*x+y*y)  -- w0/r
        local q1x, q1y = -y*w0r, x*w0r
        local q2x, q2y = -q1x, -q1y
        
        Rawshape({
            q1x,q1y,
            q2x,q2y,
            x,y
        },self._opt):addTo(self):xy(xk_1, yk_1)
-- --[[
        if k>1 then
            Rawshape({
                xk_1-q1xp, yk_1-q1yp, --pts[k-2]-q1xp, pts[k-1]-q1yp,
                q1x+ xk_1-q1xp, q1y+ yk_1-q1yp, 
                0,0
            },self._opt):addTo(self):xy(q1xp, q1yp)

            Rawshape({
                xk_1-q2xp, yk_1-q2yp, --pts[k-2]-q2xp, pts[k-1]-q2yp,
                q2x+ xk_1-q2xp, q2y+ yk_1-q2yp,
                0, 0
            },self._opt):addTo(self):xy(q2xp, q2yp)
        end
    --]]    
        q1xp, q1yp = q1x+xk_1, q1y+yk_1
        q2xp, q2yp = q2x+xk_1, q2y+yk_1

        xk_1, yk_1 = pts[k], pts[k+1]

        w0 = w0*self._dwr -- 꼬리로 갈수록 점점 폭이 좁아진다.
        fc.a = fc.a*self._dar -- 꼬리로 갈수록 점점 희미해진다.
    end

    fc.a = fca -- 원래 알파값 복원
end
--]]
--------------------------------------------------------------------------------


--[[
--------------------------------------------------------------------------------
local sqrt = math.sqrt
local hgt = 0 -- 꼬리가 시작되는 지점


function Tail:_redraw(pts)
    --self:fill(Color.rand())
    self:clear()

    local npts = #pts
    local h, w0 = hgt, self._wdt
    local xk_1, yk_1 = 0,0

    local fc = self._opt.fc
    local fca = fc.a -- backup original fillcolor alpha

    local q1xp, q1yp, q2xp, q2yp
    local xo, yo

    for k=1,npts,2 do

        local x, y = pts[k]-xk_1, pts[k+1]-yk_1
        local r = sqrt(x*x+y*y) 
        if k==1 then 
            xo, yo = x/r*self._yofs, y/r*self._yofs
        end
        
        --local r = sqrt(x*x+y*y)
        --local w0r = w0/r
        --local xw0r, yw0r = x*w0r, y*w0r
        --local q1x, q1y = -yw0r,  xw0r 
        --local q2x, q2y = yw0r, -xw0r
        
        local w0r = w0/r -- w0/r
        local q1x, q1y = -y*w0r, x*w0r
        local q2x, q2y = -q1x, -q1y
        
        Rawshape({
            q1x,q1y,
            q2x,q2y,
            x,y
        --},self._opt):addTo(self):xy(xk_1, yk_1)
        },self._opt):addTo(self):xy(xk_1 + xo,yk_1 + yo)

        if k>1 then
            Rawshape({
                xk_1-q1xp, yk_1-q1yp, --pts[k-2]-q1xp, pts[k-1]-q1yp,
                q1x+ xk_1-q1xp, q1y+ yk_1-q1yp, 
                0,0
            --},self._opt):addTo(self):xy(q1xp, q1yp)
            },self._opt):addTo(self):xy(q1xp+xo, q1yp+yo)

            Rawshape({
                xk_1-q2xp, yk_1-q2yp, --pts[k-2]-q2xp, pts[k-1]-q2yp,
                q2x+ xk_1-q2xp, q2y+ yk_1-q2yp,
                0, 0
            --},self._opt):addTo(self):xy(q2xp, q2yp)
            },self._opt):addTo(self):xy(q2xp+xo, q2yp+yo)
        end

        q1xp, q1yp = q1x+xk_1, q1y+yk_1
        q2xp, q2yp = q2x+xk_1, q2y+yk_1

        xk_1, yk_1 = pts[k], pts[k+1]

        w0 = w0*self._dwr -- 꼬리로 갈수록 점점 폭이 좁아진다.
        fc.a = fc.a*self._dar -- 꼬리로 갈수록 점점 희미해진다.
    end

    fc.a = fca -- 원래 알파값 복원
end
--]]
--------------------------------------------------------------------------------
