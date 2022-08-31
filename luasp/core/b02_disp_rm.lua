--------------------------------------------------------------------------------
-- 2021/08/30: remove 관련 메서드들을 파일로 따로 묶었다.
--------------------------------------------------------------------------------

local luasp = _luasopia
local Timer = Timer
local timers = Timer.__tmrs -- 2020/06/24:Disp:remove()함수 내에서 직접 접근
local Disp = luasp.Display
local dobjs = Disp.__dobjs
local tdobj = Disp.__tdobj

--------------------------------------------------------------------------------


--2020/06/26: refactoring removeAfter() method
--2021/08/21: self.remove can be changed after rmafter() called
local function rmNow(self) self:remove() end


function Disp:removeAfter(ms)

    -- self:removeAfter()호출 이후 self.remove() 함수가 변경됐다면 아래는
    -- self:addTimer(ms, self.remove) 
    -- 변경되기 전의 self.remove가 호출돼 버린다.
    -- 따라서 소멸해야 되는 시점의 remove()메서드를 호출하기 위해서
    -- 아래와 같이 수정

    self:addTimer(ms, rmNow) -- Timer객체를 반환한다
    return self

end


--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

local x0, y0 = luasp.x0, luasp.y0
local endX, endY = luasp.endX, luasp.endY

--2021/08/30:added 객체가 화면 밖으로 나갔는지를 체크한다.
local function isOut(self, e)

    if e.isNotFrm10 then return end -- 2022/08/31:매10프레임마다 아래를 실행

    local cpg = self.__orct -- 외곽사각형(outer rect)의 꼭지점 정보

    for k=1,#cpg,2 do

        local x, y = self:__getgxy__(cpg[k], cpg[k+1])

        if x0<=x and x<=endX and y0<=y and y<=endY then
            return false -- (네)꼭지점 중 하나라도 영역 안쪽이면 false반환
        end
        
    end
    
    return true -- 점들이 다 영역 밖이면 true반환 -> remove된다

end


local function add_isOut(self)

    self:__addUpd__(isOut) 

end


--2021/08/30: delay(ms) 이후부터 화면밖으로 나갔는지 체크한다
function Disp:removeIfOut(delay)

    -- 외각사각형의 대각선의 길이를 미리 계산하여 저장한다.
    local cpg = self.__orct
    local dx, dy = cpg[1]-cpg[3], cpg[2]-cpg[4]
    self.__lenDg2 = dx^2+dy^2

    if delay then -- delay가 있다면 그 시간 이후에 isOut 등록
        self:addTimer(delay, add_isOut)
    else -- delay가 없다면 즉시 isOut 등록
        self:__addUpd__(isOut)
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

        if self.__tmrs then -- 이 시점에서는 이미 죽은 timer도 있을 것

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
        if self.onRemove then self:onRemove() end -- 2021/08/30

    end
        
    
--------------------------------------------------------------------------------
elseif _Corona then
--------------------------------------------------------------------------------


    -- solar2d destructor
    function Disp:remove() --print('disp_del_') 

        if self.__bd == nil then return end -- 2021/09/24

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