--------------------------------------------------------------------------------
local Timer = Timer
local timers = Timer.__tmrs -- 2020/06/24:Disp:remove()함수 내에서 직접 접근
local lsp = _luasopia
-- local cx, cy = lsp.centerx, lsp.centery -- 정수값들이다
local _nxt = next

local int = math.floor
--------------------------------------------------------------------------------
-- 2020/02/06: 모든 set함수는 self를 반환하도록 수정됨
-- 향후: 내부코드는 속도를 조금이라도 높이기 위해서 self.__bd객체를 직접 접근한다
----------------------------------------------------------------------------------
Display = class()
--------------------------------------------------------------------------------
-- static members of this class ------------------------------------------------
--------------------------------------------------------------------------------
local dobjs = {} -- Display OBJectS

-- tagged display object (tdobj) 들의 객체를 저장하는 테이블
Display.__tdobj = {}
local tdobj = Display.__tdobj -- Display Tagged OBJect
-- local ndobjs = 0
-------------------------------------------------------------------------------
-- static public method
-------------------------------------------------------------------------------
--2020/06/20 dobj[self]=self로 저장하기 때문에 self:remove()안에서 바로 삭제 가능
-- 따라서 updateAll()함수의 구조가 (위의 함수와 비교해서) 매우 간단해 짐
Display.updateAll = function()
    for _, obj in pairs(dobjs) do --for k = #dobjs,1,-1 do local obj = dobjs[k]
        obj:__upd__()
    end
end


-- debugmode 일 때만 사용되는 함수 (따라서 약간의 overhead는 상관없음)
Display.__getNumObjs = function() 

    local cnt = 0
    for _, _ in pairs(dobjs) do
        cnt = cnt + 1
    end
    return cnt - _luasopia.dcdobj - 1
    
end

-------------------------------------------------------------------------------
-- public methods
-------------------------------------------------------------------------------

function Display:init()

    --2020/02/16: screen에 add하는 경우 중앙에 위치시킨다.
    --2020/08/23: parent가 파라메터로 넘어오지 않게금 수정
    self.__pr = lsp.stage
    self.__pr:add(self)

    --2021/08/15:pixelmode에서 cx,cy값이 변하므로 lsp.centerx/y값을 직접 읽어야 한다
    self:xy(lsp.centerx, lsp.centery)

    self.__bd.__obj = self -- body에 원객체를 등록 (_Grp의 __del함수에서 사용)
    
    dobjs[self] = self
    self.__iupds = {} -- 내부 update함수들을 저장할 테이블
    
    --2021/08/14:pixel모드에서 xy값을 정위치에 놓기위해
    -- __bdx,__bdy 저장된 (실수)값을 int()변환하여 설정한다.
    self.__bda = 1

end


-- This function is called in every frames
function Display:__upd__()
    
    if self.ontouch and self.__tch==nil then self:__touchon() end
    if self.ontap and self.__tap==nil then self:__tapon() end

    if self.__noupd then return end -- self.__noupd==true이면 갱신 금지------------

    -- if self.__mv then self:__playmv__() end  -- move{}
    -- if self.__tr then self:__playtr__() end -- shift{}
    
    -- 2020/02/16 call user-defined update() if exists
    if self.update and self:update() then
        return self:remove() -- 꼬리호출로 즉시 종료
    end

    --2020/07/01 내부갱신함수들이 있다면 호출
    -- self.__iupds가 nil인지를 check하는 것이 성능에 별로 효과가 없을 것 같다
    for _, fn in _nxt, self.__iupds do
        if fn(self) then -- 만약 fn(self)==true 라면 곧바로 삭제하고 리턴
            return self:remove()
        end
    end

end


-- 2021/08/10: addtimer()로 이름을 바꿈
function Display:addtimer(...)

    self.__tmrs = self.__tmrs or {}
    local tmr = Timer(...)
    tmr.__dobj = self -- callback함수의 첫 번째 인자로 넘긴다.
    self.__tmrs[tmr] = tmr
    --return self
    return tmr -- 2020/03/27 수정

end
Display.timer = Display.addtimer -- will be deprecaed in future


--2020/06/26 refactoring removeafter() method
function Display:removeafter(ms)

    self:addtimer(ms, self.remove)
    return self

end


function Display:resumeupdate()

    self.__noupd = false
    --타이머도 다시 시작해야 한다.(2020/07/01)
    return self

end


function Display:stopupdate()

    self.__noupd = true
    --타이머도 다 멈추어야 한다.(2020/07/01)
    return self

end


--2020/03/02: group:add(child) returns child
function Display:addto(group)

    group:add(self) -- this returns group object
    return self

end


--function Display:remove() self.__rm = true end
function Display:isremoved() return self.__bd==nil end


--2020/06/12
function Display:getparent() return self.__pr end


--2020/07/01 : handle Internal UPDateS (__iupds)
function Display:__addupd__( fn )

    -- self.__iupds = self.__iupds or {}
    self.__iupds[fn] = fn

end


--2021/08/09 : remove internal update function
function Display:__rmupd__( fn )

    -- if self.__iupds == nil or fn==nil then return end
    if fn==nil then return end
    self.__iupds[fn] = nil

    -- if self.__iupds is empty then set that nil
    -- if _nxt(self.__iupds) == nil then  self.__iupds = nil  end

end


--2020/08/27: added
function Display:getwidth() return self.__wdt or 0 end
function Display:getheight() return self.__hgt or 0 end


--2020/03/03 추가
function Display:tag(name)

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
function Display.collect(name)

    return tdobj[name] or {}

end

--2021/05/25 added : 기존의 tag를 제거
function Display:detag()

    if self.__tag then -- 기존의 이름이 있다면 
        tdobj[self.__tag][self] = nil -- tdobj테이블에서 제거
        self.__tag = nil
    end
    return self

end


-- 2021/08/14
function Display:getanchor()
    -- return self.__bd:getAnchorPosition()
    -- return self.__bd.anchorX, self.__bd.anchorY --solar2d
    return self.__apx, self.__apy
end


function Display:getx()
    -- return self.__bd:getX() -- gid
    -- return self.__bd.x --solar2d
    return self.__bdx
end


function Display:gety()
    -- return self.__bd:getY() --gid
     -- return self.__bd.y --solar2d
    return self.__bdy
end


function Display:getxy()
    -- return self.__bd:getPosition() --gid
    -- return self.__bd.x, self.__bd.y --solar2d
    return self.__bdx, self.__bdy
end


function Display:getalpha()
    -- return self.__bd:getAlpha() -- gideros
    return self.__bda
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
if _Gideros then -- gideros
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------


    function Display:getrot() return self.__bd:getRotation() end -- 2020/02/26
    -- gideros getScale() returns xScale, yScale, and zScale
    function Display:getscale() local sx, sy = self.__bd:getScale(); return (sx+sy)/2 end
    
    function Display:getxscale() return self.__bd:getScaleX() end
    function Display:getyscale() return self.__bd:getScaleY() end

    
    function Display:isvisible() return self.__bd:isVisible() end

    
    -- 2020/02/04 args.init을 제거하고 대신 set()메서드 추가
    function Display:set(arg)
        
        if arg.x then
            self.__bdx = arg.x
            self.__bd:setX(int(arg.x))
        end

        if arg.y then
            self.__bdy = arg.y
            self.__bd:setY(int(arg.y))
        end

        if arg.alpha then
            self.__bda = arg.alpha
            self.__bd:setAlpha(arg.alpha)
        end

        if arg.scale then
            self.__bd:setScale(arg.scale)
        end

        if arg.rot then
            self.__bd:setRotation(arg.rot)
        end

        if arg.xscale then
            self.__bd:setScaleX(arg.xscale)
        end

        if arg.yscale then
            self.__bd:setScaleY(arg.yscale)
        end

        return self

    end

    
    -- 2020/02/18 (Gideros), 2021/04/22 다시 정리 ##################################
    function Display:setx(v)
        self.__bdx = v
        self.__bd:setX(int(v))
        return self
    end


    function Display:sety(v)
        self.__bdy = v
        self.__bd:setY(int(v))
        return self
    end

    function Display:setxy(x,y)
        self.__bdx, self.__bdy = x, y
        self.__bd:setPosition(int(x),int(y))
        return self
    end


    -- Gideros는 1이 넘으면 이미지가 열화(?)되고, Solar2D는 자동으로 1로 세팅됨
    function Display:setalpha(v)
        -- self.__bd:setAlpha(v>1 and 1 or v)
        self.__bda = v>1 and 1 or v
        self.__bd:setAlpha(self.__bda)
        return self
    end


    function Display:setrot(v) self.__bd:setRotation(v); return self end -- 2020/02/26
    -- gid는 setScale(v)라고 하면 scaleX, scaleY(, scaleZ)에 모두 v가 적용됨
    function Display:setscale(x,y) self.__bd:setScale(x,y); return self end
    -- 2020/04/26 : alpha가 1초과면 1로 세팅한다.
    -- xs()와 ys()는 x and scale, y and scale로 혼동할 여지가 있어서 삭제
    function Display:setxscale(v) self.__bd:setScaleX(v); return self end
    function Display:setyscale(v) self.__bd:setScaleY(v); return self end
    

    function Display:setxyrot(x,y,r)
        self.__bd:setPosition(x,y)
        self.__bd:setRotation(r);
        return self
    end
    
    function Display:setanchor(x,y)
        self.__bd:setAnchorPoint(x,y)
        return self
    end
    
    -- 2020/02/18 ---------------------------------------------------------
    
    function Display:hide() self.__bd:setVisible(false); return self end
    function Display:show() self.__bd:setVisible(true); return self end
    function Display:setvisible(v) self.__bd:setVisible(v); return self end

    function Display:tint(r,g,b)
        self.__bd:setColorTransform(r, g ,b)
    return self
    end
    
    --------------------------------------------------------------------------------
    -- 2020/01/17, 2020/01/27
    -- 외부에서 객체를 제거하려면 소멸자 remove()메서드를 호출한다.
    -- remove()함수가 호출된 즉시 내부 타이머가 실행되지 않는다
    --------------------------------------------------------------------------------

    function Display:remove()

        if self.__tmrs then -- 이 시점에서는 이미 죽은 timer도 있을 것
            -- __rm == true/false 상관없이 무조건 true로 만들면 살아있는 것만 죽을 것임
            -- for k=1,#self.__tmrs do self.__tmrs[k]:remove() end
            for _, tmr in pairs(self.__tmrs) do
                timers[tmr] = nil --tmr:remove() 
            end
        end

        if self.__tch then self:stoptouch() end
        if self.__tap then self:stoptap() end

        self.__bd:removeFromParent()
        self.__bd = nil -- remove()가 호출되어 삭제되었음을 이것으로 확인

        --2020/06/20 dobj[self]=self로 저장하기 때문에 삭제가 아래에서 바로 가능해짐
        dobjs[self] = nil
        if self.__tag ~=nil then tdobj[self.__tag][self] = nil end
        -- ndobjs = ndobjs - 1

    end


    -- 2020/06/08 : 추가 
    function Display:getglobalxy(x,y)

        return self.__bd:localToGlobal(x or 0,y or 0)
        
    end

--------------------------------------------------------------------------------    
--------------------------------------------------------------------------------    
elseif _Corona then -- if coronaSDK
--------------------------------------------------------------------------------    
--------------------------------------------------------------------------------    
    

    function Display:getrot()
        return self.__bd.rotation
    end -- 2020/02/26


    function Display:getscale()
        return (self.__bd.xScale + self.__bd.yScale)/2
    end

    
    function Display:getxscale() return self.__bd.xScale end
    function Display:getyscale() return self.__bd.yScale end
    
    
    function Display:isvisible() return self.__bd.isVisible end


    -- 2020/02/04 args.init을 제거하고 대신 set()메서드 추가
    function Display:set(arg)

        if arg.x then
            self.__bdx = arg.x
            self.__bd.x = int(arg.x)
        end

        if arg.y then
            self.__bdy = arg.y
            self.__bd.y = int(arg.y)
        end
        
        if arg.alpha then
            self.__bda, self.__bd.alpha = arg.alpha, arg.alpha
        end

        if arg.rot then
            self.__bd.rotation = arg.rot
        end

        if arg.scale then
            self.__bd.xScale, self.__bd.yScale = arg.scale, arg.scale
        end

        if arg.xscale then
            self.__bd.xScale = arg.xscale
        end

        if arg.yscale then
            self.__bd.yScale = arg.yscale
        end

        return self

    end


    -- 2020/02/18 시험메서드 (Solar2D)###############################################
    function Display:setx(v)

        self.__bdx = v
        self.__bd.x = int(v)
        return self

    end
    
    function Display:sety(v)

        self.__bdy = v
        self.__bd.y = int(v)
        return self

    end

    function Display:setxy(x,y)

        self.__bdx, self.__bdy = x, y
        self.__bd.x, self.__bd.y = int(x), int(y)
        return self

    end


    function Display:setrot(v) self.__bd.rotation = v; return self end -- 2020/02/25
    -- setscale(v) 는 xScale, yScale 둘 다 v로;setscale(x,y)는 xScale=x, yScale=y로 설정
    
    
    function Display:setscale(x, y)
        self.__bd.xScale, self.__bd.yScale = x, y or x
        return self
    end

    function Display:setalpha(v)
        -- self.__al, self.__bd.alpha = v,v
        self.__bda, self.__bd.alpha = v, v
        return self
    end

    function Display:setxscale(v) self.__bd.xScale = v; return self end
    function Display:setyscale(v) self.__bd.yScale = v; return self end
    
    function Display:setxyrot(x,y,r) 
        self.__bd.x, self.__bd.y, self.__bd.rotation = x, y, r
        return self
    end

    function Display:setanchor(x,y)
        self.__bd.anchorX, self.__bd.anchorY = x,y
        return self
    end

    -- 2020/02/18 ---------------------------------------------------------

    function Display:hide() self.__bd.isVisible = false; return self end
    function Display:show() self.__bd.isVisible = true; return self end
    function Display:setvisible(v) self.__bd.isVisible = v;return self end
    

    function Display:remove() --print('disp_del_') 

        if self.__tmrs then -- 이 시점에서는 이미 죽은 timer도 있을 것
            for _, tmr in pairs(self.__tmrs) do
                timers[tmr] = nil --tmr:remove()
            end
        end

        if self.__tch then self:stoptouch() end
        if self.__tap then self:stoptap() end

        self.__bd:removeSelf()
        self.__bd = nil -- __del__()이 호출되었음을 표시하는 역할도 함

        --2020/06/20 소멸자안에서 dobjs 테이블의 참조를 삭제한다
        dobjs[self] = nil
        -- ndobjs = ndobjs - 1
        if self.__tag ~=nil then tdobj[self.__tag][self] = nil end
    end

    

    -- 2020/06/08 : 추가 
    function Display:getglobalxy(x,y)
        return self.__bd:localToContent(x or 0,y or 0)
    end

end -- elseif _Corona then

--2021/04/21 :set메서드의 축명함수들 추가
-- (set method는 혼동을 줄이기위해서 아래의 두 개만으로 정리)
Display.x = Display.setx
Display.y = Display.sety
Display.rot = Display.setrot
Display.scale = Display.setscale
Display.alpha = Display.setalpha
Display.xscale = Display.setxscale
Display.yscale = Display.setyscale

Display.xy = Display.setxy
Display.xyrot = Display.setxyrot
Display.anchor = Display.setanchor

--2021/04/22 :get메서드의 축명함수들 추가
--Display.getr = Display.getrot
--Display.gets = Display.getscale
--Display.geta = Display.getalpha
--Display.getxs = Display.getxscale
--Display.getys = Display.getyscale