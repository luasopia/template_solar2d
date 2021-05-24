local Disp = Display
local sqrt, atan2 = math.sqrt, math.atan2
local _R2D = 180/math.pi -- radian to degree constant
local dtobj = Disp._dtobj
--------------------------------------------------------------------------------

local function upd(self)

    -- 타겟이 없거나 삭제되었다면 직전의 방향으로 계속 진행한다.
    if self._trgt == nil or self._trgt.__bd == nil then
        local x, y = self:getxy()
        self:xy(x+self._pdx*self._lspd, y+self._pdy*self._lspd)
        return
    end

    local ga = self._rspd

    -- 타겟을 향하는 단위벡터 계산
    local x, y = self:getxy()
    local dx, dy = self._trgt:getxy()
    dx, dy = dx-x, dy-y
    local dist = sqrt(dx*dx + dy*dy)
    dx, dy = dx/dist, dy/dist

    -- 1st order filtering (for smooth following)
    local dxk = ga*self._pdx + (1-ga)*dx
    local dyk = ga*self._pdy + (1-ga)*dy
    local rot = atan2(dyk,dxk)*_R2D + 90 

    self:xyr(x+dxk*self._lspd, y+dyk*self._lspd, rot)
    self._pdx, self._pdy = dxk, dyk
end

function Disp:follow(target,opt) -- oncotact
    self._trgt = target
    opt = opt or {}
    self._pdx = opt.initdx or 0
    self._pdy = opt.initdy or 0
    self._lspd = (opt.speed or 1)*20 -- 선속도 (따라가는 속도)
    self._rspd = opt.rotspeed or 0.9 -- 0.8<rs<1,(각속도) 작을수록 회전이 빠르다.

    -- self:__addupd__(upd)
    self.__iupds[upd] = upd
end

--------------------------------------------------------------------------------

local function newtrgt(self)
    local trgt1 = nil
    local trgts = dtobj[self._ttag] or {}
    for _, obj in pairs(trgts) do
        if trgt1 == nil then trgt1 = obj end -- 첫 번째 객체를 저장
        if obj._lckd == nil then
            self._trgt = obj
            obj._lckd = self
            return
        end
    end

    -- 만약 위에서 trgt가 선택이 안 되었다면 첫 번째 것을 지정
    self._trgt = trgt1

    -- 따라서 self._trgt==nil 일 수도 있다.
end

local function updtag(self)
    if self._trgt==nil or self._trgt.__bd == nil then -- 타겟이 삭제되었다면
        newtrgt(self)
    end
    upd(self)
end


function Disp:followtag(name, opt) -- oncotact
    self._ttag = name -- target tag
    newtrgt(self)

    opt = opt or {}
    self._pdx = opt.initdx or 0
    self._pdy = opt.initdy or 0
    self._lspd = (opt.speed or 1)*20 -- 선속도
    self._rspd = opt.rotspeed or 0.9 -- 0.8<rs<1,(각속도) 작을수록 회전이 빠르다.

    self:__addupd__(updtag)
end