--------------------------------------------------------------------------------
-- 2021/08/17:scale에 대해서 아래와 같이 정한다.
-- self.__bds, self.__bdxs, self.__bdys를 둔다
-- setScaleX(xs) 나 setYscale(ys)은 scale값도 (xs+ys)/2값으로 갱신한다.
--------------------------------------------------------------------------------
local Timer = Timer
local timers = Timer.__tmrs -- 2020/06/24:Disp:remove()함수 내에서 직접 접근
local luasp = _luasopia
local _nxt = next
local tIn, tRm = table.insert, table.remove

local int, min = math.floor, math.min
local rand = rand
--------------------------------------------------------------------------------
-- 2020/02/06: 모든 set함수는 self를 반환하도록 수정됨
-- 향후: 내부코드는 속도를 조금이라도 높이기 위해서 self.__bd객체를 직접 접근한다
----------------------------------------------------------------------------------
Display = virtualClass()
local Disp = Display
_luasopia.Display = Disp --2021/10/02 hide Disp into _luasopia
--------------------------------------------------------------------------------
-- static members of this class ------------------------------------------------
--------------------------------------------------------------------------------
local dobjs = {} -- Disp OBJectS
local dobjs2rm = {}
Disp.__dobjs = dobjs
Disp.__dobjs2rm = dobjs2rm

-- tagged display object (tdobj) 들의 객체를 저장하는 테이블
local tdobj = {}  -- Disp Tagged OBJect
Disp.__tdobj = tdobj
-------------------------------------------------------------------------------
-- static public method
-------------------------------------------------------------------------------
--2020/06/20 dobj[self]=self로 저장하기 때문에 self:remove()안에서 바로 삭제 가능
-- 따라서 updateAll()함수의 구조가 (위의 함수와 비교해서) 매우 간단해 진다
-- Disp.updateAll = function(isoddfrm, e)
Disp.updateAll = function(e) -- 2022/08/31 isoddfrm 파라메터제거

    -- 2022/09/07:이 반복문 안에서 dobjs의 요소가 삭제되면 안된다.
    for _, obj in _nxt, dobjs do

        if obj:__upd__(e) ~=true then -- remove 되지 않았다면

            -- 2022/09/07 추가/제거 대상으로 등록된 upd함수들을 처리한다
            -- local nUpdRm = #obj.__updRm
            local rmFn = tRm(obj.__updRm)
            while rmFn ~=nil do
                obj.__iupds[rmFn] = nil
                rmFn = tRm(obj.__updRm)
            end

            -- local nUpdNew =  #obj.__updNew
            local newFn = tRm(obj.__updNew)
            while newFn ~=nil do
                obj.__iupds[newFn] = newFn
                newFn = tRm(obj.__updNew)
            end
        
        end

    end

    -- 삭제할 객체들로 등록된 것들을 삭제한다.
    -- local n = #dobjs2rm;puts(n)
    local obj = tRm(dobjs2rm) --맨 마지막요소를 제거하고 그걸 반환
    while obj~=nil do -- obj==nil이라면 빈테이블이라는 의미이다.
        dobjs[obj] = nil
        obj = tRm(dobjs2rm)
    end

end


-------------------------------------------------------------------------------
-- public methods
-------------------------------------------------------------------------------

function Disp:init()

    --2020/02/16: screen에 add하는 경우 중앙에 위치시킨다.
    --2020/08/23: parent가 파라메터로 넘어오지 않게금 수정
    self.__pr = luasp.stage
    self.__pr:add(self)

    --2021/08/15:pixelmode에서 cx,cy값이 변하므로 luasp.centerX/Y값을 직접 읽어야 한다
    -- xy()메서드 안에서 self.__bdx, self.__bdy가 생성된다.
    self:setXY(luasp.centerX, luasp.centerY)

    self.__bd.__obj = self -- body에 원객체를 등록 (_Grp의 __del함수에서 사용)
    
    dobjs[self] = self
    self.__iupds = {} -- 내부 update함수들을 저장할 테이블(모든 frame에서 호출)

    self.__updNew = {} -- 2022/08/30:__iupds에 새로 포함할 함수들의 테이블
    self.__updRm = {}  -- 2022/08/30:__iupds에서 제거할 함수들의 테이블

    --2021/08/14:pixel모드에서 xy값을 정위치에 놓기위해
    -- __bdx,__bdy 저장된 (실수)값을 int()변환하여 설정한다.
    self.__bda = 1  -- alpha of the body
    self.__bdrd = 0 -- rotational angle in deg of the body
    self.__bds, self.__bdxs, self.__bdys = 1, 1, 1 -- scale, scaleX, scaleY

end


-- This function is called in every frame
function Disp:__upd__(e)
    
    if self.__noupd then return end -- self.__noupd==true이면 갱신 금지------------

    -- 2020/02/16 call user-defined update() if exists
    if self.update and self:update(e) then

        return self:remove() -- 꼬리호출로 즉시 종료

    end

    -- remove를 원한다면 update()함수에서 true를 반환하면 된다.
    -- 만약 사용자가 실수로 update()함수 내에서 직접 self:remove()를 호출했더라도
    -- 여기서 바로 리턴해서 내부업뎃함수들이 실행되는 것을 막는다.
    if self.__bd == nil then return true end

    --2020/07/01 내부갱신함수들이 있다면 호출
    -- self.__iupds가 nil인지를 check하는 것이 성능에 별로 효과가 없을 것 같다
    -- 2022/08/30: fn() 내부에서 self.__iupds 요소를 변경(삭제)시키면
    -- invalid key to 'next' 오류발생
    for _, fn in _nxt, self.__iupds do

        if fn(self, e) then -- 만약 fn(self)==true 라면 곧바로 삭제하고 리턴
            return self:remove()
        end

    end

    if self.__isgrp then return end -- 2021/10/10:Group객체는 여기까지

    if self.onTouch and self.__tch==nil then self:__touchon() end
    if self.onTap and self.__tap==nil then self:__tapon() end

end


-- 2021/08/10: addTimer()로 이름을 바꿈
function Disp:addTimer(...)

    self.__tmrs = self.__tmrs or {}
    local tmr = Timer(...)
    tmr.__dobj = self -- callback함수의 첫 번째 인자로 넘긴다.
    self.__tmrs[tmr] = tmr
    --return self
    return tmr -- 2020/03/27 수정

end


function Disp:resumeUpdate()

    self.__noupd = false
    --타이머도 다시 시작해야 한다.(2020/07/01)
    return self

end


function Disp:stopUpdate()

    self.__noupd = true
    --타이머도 다 멈추어야 한다.(2020/07/01)
    return self

end


--2020/03/02: group:add(child) returns child
function Disp:addTo(group)

    group:add(self) -- this returns group object
    return self

end


--function Disp:remove() self.__rm = true end
function Disp:isRemoved() return self.__bd==nil end


--2020/06/12
function Disp:getParent() return self.__pr end


--2020/07/01 : handle Internal UPDateS (__iupds)
--2022/08/30 : update중에 __iupds 테이블이 갱신되지 않도록 개선
function Disp:__addUpd__(fn)

    --if fn ~= nil then
        tIn(self.__updNew,fn)
    --end

    return self

end


function Disp:__rmUpd__( fn )

    -- if fn ~= nil then
        if self.__iupds[fn] ~= nil then 
            tIn(self.__updRm, fn)
        end
    -- end

    return self

end

--[[
--2021/09/03 : 격프레임마다 호출되는 함수 등록
-- 홀수프레임, 짝수프레임 어느 쪽일지는 성능 분산을 위해서 임의로 정한다
function Disp:__addupd12__( fn )

    self.__iupd12[rand(2)==1][fn] = fn -- rand(2)는 1과 2중 하나만 발생
    return self

end

--2021/09/07
function Disp:__rmupd12__(fn)

    if fn==nil then return self end
    -- 어느 쪽일지 모르므로 둘 다 삭제한다
    self.__iupd12[true][fn] = nil
    self.__iupd12[false][fn] = nil
    return self

end
--]]


--2020/08/27: added
function Disp:getWidth()

    return self.__wdt or 0

end


function Disp:getHeight()

    return self.__hgt or 0

end


--2020/03/03 추가
function Disp:tag(name)

    -- 2021/05/25에 아래 if문 추가
    -- tag()메서드를 통해서 기존의 name을 바꿀 수 있다
    if self.__tag then -- 기존의 이름이 있다면 
        tdobj[self.__tag][self] = nil -- tdobj테이블에서 제거
    end

    self.__tag = name
    -- 2020/06/21 tagged객체는 아래와 같이 tdobj에 별도로 (중복) 저장
    if tdobj[name] == nil then
        tdobj[name] = {[self]=self}
    else
        tdobj[name][self] = self
    end
    return self

end

--2020/06/21 tdobj에 tagged객체를 따로 저장하기 때문에
-- collect()함수에서 매번 for반복문으로 tagged객체를 모을 필요가 없어졌음
function Disp.collect(name)

    return tdobj[name] or {}

end

--2021/05/25 added : 기존의 tag를 제거
function Disp:detag()

    if self.__tag then -- 기존의 이름이 있다면 
        tdobj[self.__tag][self] = nil -- tdobj테이블에서 제거
        self.__tag = nil
    end
    return self

end


-- 2021/08/14
function Disp:getAnchor()
    -- return self.__bd:getAnchorPosition()
    -- return self.__bd.anchorX, self.__bd.anchorY --solar2d
    return self.__apx, self.__apy
end


function Disp:getAnchorX()
    return self.__apx
end


function Disp:getAnchorY()
    return self.__apy
end


function Disp:getX()
    -- return self.__bd:getX() -- gid
    -- return self.__bd.x --solar2d
    return self.__bdx
end


function Disp:getY()
    -- return self.__bd:getY() --gid
     -- return self.__bd.y --solar2d
    return self.__bdy
end


function Disp:getXY()
    -- return self.__bd:getPosition() --gid
    -- return self.__bd.x, self.__bd.y --solar2d
    return self.__bdx, self.__bdy
end


function Disp:getAlpha()
    -- return self.__bd:getAlpha() -- gideros
    -- return self.__bd.alpha -- solar2d
    return self.__bda
end


function Disp:getRot()
    -- return self.__bd:getRotation() end -- gideros(2020/02/26)
    -- return self.__bd.rotation --solar2d
    return self.__bdrd
end


function Disp:getScaleX()

    -- return self.__bd:getScaleX() -- gideros
    -- return self.__bd.xScale -- solar2d
    return self.__bdxs

end


function Disp:getScaleY()

    -- return self.__bd:getScaleY() -- gideros
    -- return self.__bd.yScale -- gideros
    return self.__bdys

end


function Disp:getScaleXY()

    return self.__bdxs, self.__bdys

end


function Disp:getScale()

    return self.__bds

end

-- 2020/02/04:args.init을 제거하고 대신 set()메서드 추가
-- 2021/08/17:set()메서드를 공통으로 변경
function Disp:set(arg)
    
    if arg.x        then self:setX(arg.x) end
    if arg.y        then self:setY(arg.y) end
    if arg.rot      then self:setRot(arg.rot) end
    if arg.scale    then self:setScale(arg.scale) end
    if arg.alpha    then self:setAlpha(arg.alpha) end
    if arg.scaleX   then self:setScaleX(arg.scaleX) end
    if arg.scaleY   then self:setScaleY(arg.scaleY) end

    if arg.dx        then self:setDx(arg.dx) end
    if arg.dy        then self:setDy(arg.dy) end
    if arg.drot      then self:setDrot(arg.drot) end
    if arg.dalpha    then self:setDalpha(arg.dalpha) end
    if arg.dscaleX   then self:setDscaleX(arg.dscaleX) end
    if arg.dscaleY   then self:setDscaleY(arg.dscaleY) end
    if arg.dscale    then self:setDscale(arg.dscale) end

    return self

end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
if _Gideros then -- gideros
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
    
    function Disp:isVisible()

        return self.__bd:isVisible()

    end


    -- 2020/02/18 (Gideros), 2021/04/22 다시 정리 ##################################
    function Disp:setX(v)

        self.__bdx = v
        self.__bd:setX(int(v))
        return self

    end


    function Disp:setY(v)

        self.__bdy = v
        self.__bd:setY(int(v))
        return self

    end


    function Disp:setXY(x,y)

        self.__bdx, self.__bdy = x, y
        self.__bd:setPosition(int(x),int(y))
        return self

    end


    -- Gideros는 1이 넘으면 이미지가 열화(?)되고, Solar2D는 자동으로 1로 세팅됨
    function Disp:setAlpha(v)

        self.__bda = v>1 and 1 or v
        self.__bd:setAlpha(self.__bda)
        return self

    end


    function Disp:setRot(deg) -- gideros

        self.__bdrd = deg
        self.__bd:setRotation(deg)
        return self

    end -- 2020/02/26


    -- gid는 setScale(v)라고 하면 scaleX, scaleY(, scaleZ)에 모두 v가 적용됨
    function Disp:setScale(s)

        self.__bds, self.__bdxs, self.__bdys = s, s, s
        self.__bd:setScale(s)


        -- -- setScale()메서드가 호출되었을 때만 hit.r을 재조정한다.
        -- if self.__ccc then -- 2021/08/21:added
        --     local r = self.__ccc.r0*s
        --     self.__ccc.r = r
        --     self.__ccc.r2 = r, r*r
        -- end

        return self

    end


    function Disp:setScaleXY(xs, ys)

        self.__bds, self.__bdxs, self.__bdys = (xs+ys)*0.5, xs, ys
        self.__bd:setScale(xs, ys)

        -- -- setScale()메서드가 호출되었을 때만 hit.r을 재조정한다.
        -- -- xscale과 yscale가 다를 경우에는 작은 값을 기준으로 한다.
        -- if self.__ccc then -- 2021/08/21:added
        --     local mins = min(xs, ys)
        --     local r = self.__ccc.r0*mins
        --     self.__ccc.r = r
        --     self.__ccc.r2 = r, r*r
        -- end

        return self

    end


    -- 2020/04/26 : alpha가 1초과면 1로 세팅한다.
    -- xs()와 ys()는 x and scale, y and scale로 혼동할 여지가 있어서 삭제
    function Disp:setScaleX(xs)

        self.__bdxs = xs
        self.__bds = (xs+self.__bdys)*0.5 --2021/08/17
        self.__bd:setScaleX(xs)

        -- -- setScale()메서드가 호출되었을 때만 hit.r을 재조정한다.
        -- -- xscale과 yscale가 다를 경우에는 작은 값을 기준으로 한다.
        -- if self.__ccc then -- 2021/08/21:added
        --     local mins = min(xs, self.__bdys)
        --     local r = self.__ccc.r0*mins
        --     self.__ccc.r = r
        --     self.__ccc.r2 = r, r*r
        -- end

        return self

    end

    function Disp:setScaleY(ys)

        self.__bdys = ys
        self.__bds = (self.__bdxs+ys)*0.5 --2021/08/17
        self.__bd:setScaleY(ys)

        -- -- setScale()메서드가 호출되었을 때만 hit.r을 재조정한다.
        -- -- xscale과 yscale가 다를 경우에는 작은 값을 기준으로 한다.
        -- if self.__ccc then -- 2021/08/21:added
        --     local mins = min(self.__bdxs, ys)
        --     local r = self.__ccc.r0*mins
        --     self.__ccc.r = r
        --     self.__ccc.r2 = r, r*r
        -- end

        return self

    end
    

    --[[
    function Disp:setxyrot(x,y,deg)

        self.__bdx, self.__bdy, self.__bdrd = x,y,deg
        self.__bd:setPosition(x,y)
        self.__bd:setRotation(deg)
        return self

    end
    --]]


    -- setAnchor()는 각각의 클래스에서 별도로 오버로딩된다
    function Disp:setAnchor(ax, ay)

        self.__apx, self.__apy = ax, ay
        self.__bd:setAnchorPoint(ax, ay)
        return self

    end
    
    -- 2020/02/18 ---------------------------------------------------------
    
    function Disp:hide() self.__bd:setVisible(false); return self end
    function Disp:show() self.__bd:setVisible(true); return self end
    function Disp:setVisible(v) self.__bd:setVisible(v); return self end

    function Disp:tint(r,g,b,a)

        if isObject(r, Color) then
            self.__bd:setColorTransform(r.r, r.g, r.b, r.a)
        else
            self.__bd:setColorTransform(r, g ,b, a or 1)
        end
        return self

    end
    

    -- 2020/06/08 : 추가 
    function Disp:getGlobalXY(x,y)

        return self.__bd:localToGlobal(x or 0,y or 0)
        
    end

--------------------------------------------------------------------------------    
--------------------------------------------------------------------------------    
elseif _Corona then -- if coronaSDK
--------------------------------------------------------------------------------    
--------------------------------------------------------------------------------    
    
    function Disp:isVisible()
        return self.__bd.isVisible
    end


    -- 2020/02/18 시험메서드 (Solar2D)###############################################
    function Disp:setX(v)

        self.__bdx = v
        self.__bd.x = int(v)
        return self

    end
    
    function Disp:setY(v)

        self.__bdy = v
        self.__bd.y = int(v)
        return self

    end

    function Disp:setXY(x,y)

        self.__bdx, self.__bdy = x, y
        self.__bd.x, self.__bd.y = int(x), int(y)
        return self

    end


    function Disp:setRot(deg) -- solar2d

        self.__bdrd = deg
        self.__bd.rotation = deg
        return self

    end

    
    function Disp:setScale(s)

        self.__bds, self.__bdxs, self.__bdys = s, s, s
        self.__bd.xScale, self.__bd.yScale = s, s

        -- -- setScale()메서드가 호출되었을 때만 hit.r을 재조정한다.
        -- -- xscale과 yscale가 틀릴 경우에는 ccc.r을 조정하지 않는다.
        -- if self.__ccc then -- 2021/08/21:added
        --     local r = self.__ccc.r0*s
        --     self.__ccc.r = r
        --     self.__ccc.r2 = r, r*r
        -- end

        return self

    end


    function Disp:setScaleXY(xs, ys)

        self.__bds, self.__bdxs, self.__bdys = (xs+ys)*0.5, xs, ys
        self.__bd.xScale, self.__bd.yScale = xs, ys

        -- -- setScale()메서드가 호출되었을 때만 hit.r을 재조정한다.
        -- -- xscale과 yscale가 다를 경우에는 작은 값을 기준으로 한다.
        -- if self.__ccc then -- 2021/08/21:added
        --     local mins = min(xs, ys)
        --     local r = self.__ccc.r0*mins
        --     self.__ccc.r = r
        --     self.__ccc.r2 = r, r*r
        -- end


        return self

    end


    function Disp:setAlpha(v)
        
        self.__bda = v
        self.__bd.alpha = v, v
        return self

    end

    
    function Disp:setScaleX(xs)

        self.__bdxs = xs
        self.__bds = (xs+self.__bdys)*0.5 --2021/08/17
        self.__bd.xScale = xs

        -- -- setScale()메서드가 호출되었을 때만 hit.r을 재조정한다.
        -- -- xscale과 yscale가 다를 경우에는 작은 값을 기준으로 한다.
        -- if self.__ccc then -- 2021/08/21:added
        --     local mins = min(xs, self.__bdys)
        --     local r = self.__ccc.r0*mins
        --     self.__ccc.r = r
        --     self.__ccc.r2 = r, r*r
        -- end


        return self

    end


    function Disp:setScaleY(ys)

        self.__bdys = ys
        self.__bds = (self.__bdxs+ys)*0.5 --2021/08/17
        self.__bd.yScale = ys

        -- -- setScale()메서드가 호출되었을 때만 hit.r을 재조정한다.
        -- -- xscale과 yscale가 다를 경우에는 작은 값을 기준으로 한다.
        -- if self.__ccc then -- 2021/08/21:added
        --     local mins = min(self.__bdxs, ys)
        --     local r = self.__ccc.r0*mins
        --     self.__ccc.r = r
        --     self.__ccc.r2 = r, r*r
        -- end

        return self

    end


    --[[ will be deprecated
    function Disp:setxyrot(x,y,deg)

        self.__bdx, self.__bdy, self.__bdrd = x,y,deg
        self.__bd.x, self.__bd.y = x, y
        self.__bd.rotation = deg
        return self

    end
    --]]

    
    -- 추상메서드:차일드에서 각자 구현해야한다
    function Disp:setAnchor(x, y)

        self.__apx, self.__apy = ax, ay
        self.__bd.anchorX, self.__bd.anchorY = x,y
        return self

    end

    -- 2020/02/18 ---------------------------------------------------------

    function Disp:hide() self.__bd.isVisible = false; return self end
    function Disp:show() self.__bd.isVisible = true; return self end
    function Disp:setVisible(v) self.__bd.isVisible = v;return self end
    

    -- 2020/06/08 : 추가 
    function Disp:getGlobalXY(x,y)

        return self.__bd:localToContent(x or 0,y or 0)
        
    end


    function Disp:tint(r,g,b,a)

        if isObject(r, Color) then
            self.__bd:setFillColor(r.r, r.g, r.b, r.a)
        else
            self.__bd:setFillColor(r, g, b, a or 1)
        end
        return self
        
    end


end -- elseif _Corona then

Disp.setxy = Disp.setXY -- will be removed