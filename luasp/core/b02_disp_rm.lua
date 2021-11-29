--------------------------------------------------------------------------------
-- 2021/08/30: remove 관련 메서드들을 파일로 따로 묶었다.
--------------------------------------------------------------------------------

local luasp = _luasopia
local Timer = Timer
local timers = Timer.__tmrs -- 2020/06/24:Disp:remove()함수 내에서 직접 접근
local Disp = luasp.Display
local dobjs = Disp.__dobjs
local tdobj = Disp.__tdobj

-- 아래는 pixelmode가 아닐 경우에 화면바깥으로 나갔다고 판단되는
-- 경계값이다. 약간의 갭을 둔다
local xgap, ygap = 100, 150
local out_x0, out_y0 = luasp.x0-xgap, luasp.y0-ygap
local out_endx, out_endy = luasp.endX+xgap, luasp.endY+ygap

-- pixelmode 일 경우 위의 값들을 다시 계산해야 한다.
--------------------------------------------------------------------------------


--2020/06/26: refactoring removeAfter() method
--2021/08/21: self.remove can be changed after rmafter() called
local function rmnow(self) self:remove() end
function Disp:removeAfter(ms)

    -- rmafter()호출 이후 self.remove가 변경됬다면 아래는
    -- self:addTimer(ms, self.remove) 
    -- 변경되기 전의 self.remove가 호출되 버린다.
    -- 따라서 소멸해야 되는 시점의 remove()메서드를 호출하기 위해서
    -- 아래와 같이 수정

    self:addTimer(ms, rmnow) -- Timer객체를 반환한다
    return self

end


--2021/08/30:added 객체가 화면 밖으로 나갔는지를 체크한다.
local function isout(self)

    local x0, y0 = out_x0, out_y0
    local endX, endY = out_endx, out_endy
    local cpg = self.__orct

    for k=1,#cpg,2 do

        local x, y = self:__getgxy__(cpg[k], cpg[k+1])

        if x0<=x and x<=endX and y0<=y and y<=endY then
            return false -- 점들 중 하나라도 영역 안쪽이면 false반환
        end
        
    end
    
    return true -- 점들이 다 영역 밖이면 true반환

end


local function add_isout(self)

    -- self.__iupds[isout] = isout
    self:__addupd12__(isout) -- 격프레임마다 체크한다.

end


--2021/08/30: delay(ms) 이후부터 화면밖으로 나갔는지 체크한다
function Disp:removeIfOut(delay)
    
    if delay then -- delay가 있다면 그 시간 이후에 isout 등록

        self:addTimer(delay, add_isout)

    else -- delay가 없다면 즉시 isout 등록

        --self.__iupds[isout] = isout
        self:__addupd12__(isout) -- 격프레임마다 체크한다.

    end

    return self

end

--------------------------------------------------------------------------------
-- 2020/01/17, 2020/01/27
-- 외부에서 객체를 제거하려면 소멸자 remove()메서드를 호출한다.
-- remove()함수가 호출된 즉시 내부 타이머가 실행되지 않는다
--------------------------------------------------------------------------------


if _Gideros then


    -- gideros desctructor
    function Disp:remove()

        if self.__bd == nil then return end -- 2021/09/24

        if self.onremove then self:onremove() end -- 2021/08/30

        if self.__tmrs then -- 이 시점에서는 이미 죽은 timer도 있을 것
            -- __rm == true/false 상관없이 무조건 true로 만들면 살아있는 것만 죽을 것임
            -- for k=1,#self.__tmrs do self.__tmrs[k]:remove() end
            for _, tmr in pairs(self.__tmrs) do
                timers[tmr] = nil --tmr:remove() 
            end
        end

        if self.__tch then self:stopTouch() end
        if self.__tap then self:stopTap() end

        self.__bd:removeFromParent()
        self.__bd = nil -- remove()가 호출되어 삭제되었음을 이것으로 확인
        
        --2020/06/20 dobj[self]=self로 저장하기 때문에 삭제가 아래에서 바로 가능해짐
        dobjs[self] = nil
        if self.__tag ~=nil then tdobj[self.__tag][self] = nil end
        -- self.__pr.__chld[self] = nil -- 2021/09/24:부모에서 삭제

    end
        
    
--------------------------------------------------------------------------------
elseif _Corona then
--------------------------------------------------------------------------------


    -- solar2d destructor
    function Disp:remove() --print('disp_del_') 

        if self.__bd == nil then return end -- 2021/09/24

        -- 2021/11/15:added
        self:stopMove()
        self:stopShift()


        if self.__tmrs then -- 이 시점에서는 이미 죽은 timer도 있을 것

            for _, tmr in pairs(self.__tmrs) do

                timers[tmr] = nil -- tmr:remove()

            end

        end

        if self.__tch then self:stopTouch() end
        if self.__tap then self:stopTap() end

        self.__bd:removeSelf()
        self.__bd = nil -- self:isRemoved()에서 return self.__bd==nil 으로 이용됨
        
        --2020/06/20 소멸자안에서 dobjs 테이블의 참조를 삭제한다
        dobjs[self] = nil
        if self.__tag ~=nil then tdobj[self.__tag][self] = nil end
        -- self.__pr.__chld[self] = nil -- 2021/09/24:부모에서 삭제


        if self.onRemove then self:onRemove() end -- 2021/08/30
        
    end
    
    

end


-- 2021/Nov/29: added
function Disp:removeAll(tag)

    if tag==nil then

        luasp.stage:clear()

    else

        local tdobjs = Disp.__tdobj[tag]
        if tdobjs ~=nil then
            for key, dobj in pairs(tdobjs) do
                dobj:remove()
                tdobjs[key]=nil
            end
            Disp.__tdobj[tag] = nil
        end

    end

end