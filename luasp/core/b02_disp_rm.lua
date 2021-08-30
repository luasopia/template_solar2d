--------------------------------------------------------------------------------
-- 2021/08/30: remove 관련 메서드들을 파일로 따로 묶었다.
--------------------------------------------------------------------------------

local Timer = Timer
local timers = Timer.__tmrs -- 2020/06/24:Disp:remove()함수 내에서 직접 접근
local luasp = _luasopia
local Disp = Display
local dobjs = Disp.__dobjs
local tdobj = Disp.__tdobj

-- 아래는 pixelmode가 아닐 경우에 화면바깥으로 나갔다고 판단되는
-- 경계값이다. 약간의 갭을 둔다
local xgap, ygap = 100, 150
luasp.out_x0, luasp.out_y0 = luasp.x0-xgap, luasp.y0-ygap
luasp.out_endx, luasp.out_endy = luasp.endx+xgap, luasp.endy+ygap
-- luasp.out_endx, luasp.out_endy = luasp.endx+xgap, 1000

-- pixelmode 일 경우 위의 값들을 다시 계산해야 한다.
--------------------------------------------------------------------------------


--2020/06/26: refactoring removeafter() method
--2021/08/21: self.remove can be changed after rmafter() called
local function rmnow(self) self:remove() end
function Display:removeafter(ms)

    -- rmafter()호출 이후 self.remove가 변경됬다면 아래는
    -- self:addtimer(ms, self.remove) 
    -- 변경되기 전의 self.remove가 호출되 버린다.
    -- 따라서 소멸해야 되는 시점의 remove()메서드를 호출하기 위해서
    -- 아래와 같이 수정

    self:addtimer(ms, rmnow) -- Timer객체를 반환한다
    return self

end


--2021/08/30:added 객체가 화면 밖으로 나갔는지를 체크한다.
local function isout(self)

     -- 궂이 매 프레임에 체크할 필요가 없을 것 같다.
    if luasp.isoddfrm then return end

    local x0, y0 = luasp.out_x0, luasp.out_y0
    local endx, endy = luasp.out_endx, luasp.out_endy

    if self.__cpg then

        local cpg = self.__cpg

        for k=1,#cpg,2 do

            local x, y = self:__getgxy__(cpg[k], cpg[k+1])

            if x0<=x and x<=endx and y0<=y and y<=endy then

                return false
                
            end
            
        end
        
        return true

    elseif self.__ccc then

        -- 원주위의 네 점의 좌표가 하나로도 화면 안에 있다면 false반환
        local ccc = self.__ccc
        local offs = {-ccc.r,0,  ccc.r,0,  0,-ccc.r,  0,ccc.r}
        for k=1,#offs,2 do

            local x, y = self:__getgxy__(ccc.x+offs[k], ccc.y+offs[k+1])

            if x0<=x and x<=endx and y0<=y and y<=endy then

                return false
                
            end
            
        end
        
        return true


    elseif self.__cpt then

        local cpt=self.__cpt
        local x, y = self:__getgxy__(ccc.x+offs[k], ccc.y+offs[k+1])

        if x0<=x and x<=endx and y0<=y and y<=endy then

            return false

        end
        
        return true
    
    end

end


local function add_isout(self)

    self.__iupds[isout] = isout

end

--2021/08/30: delay(ms) 이후부터 화면밖으로 나갔는지 체크한다
function Disp:removeifout(delay)
    
    if delay then -- delay가 있다면 그 시간 이후에 isout 등록

        self:addtimer(delay, add_isout)

    else -- delay가 없다면 즉시 isout 등록

        self.__iupds[isout] = isout

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
    function Display:remove()

        if self.onremove then self:onremove() end -- 2021/08/30

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
    
    

elseif _Corona then


    -- solar2d destructor
    function Disp:remove() --print('disp_del_') 

        if self.onremove then self:onremove() end -- 2021/08/30

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
    
    

end