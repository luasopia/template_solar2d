
if _Gideros then

    local Event = _Gideros.Event

    local function tapfn(self, event) --printf('%s touch begin', self.name)
        local t = event.touch
        if self.__bd:hitTestPoint(t.x, t.y) and self.tap~=nil then
            self:tap{id=t.id, x=t.x, y=t.y}
            event:stopPropagation()
        end
    end

    function Display:__tapon() --print('try tap')
        if self.tap and not self.__tap then
            self.__bd:addEventListener(Event.TOUCHES_BEGIN, tapfn, self)
            self.__tap = true
        end
        return self
    end
    
----[[
    function Display:stoptap()
        if self.tap and self.__tap then
            self.__bd:removeEventListener(Event.TOUCHES_BEGIN, tapfn, self)
            self.__tap = false
        end
        return self
    end

    Display.resumetap = Display.__tapon
--]]

elseif _Corona then ---------------------------------------

    local function tapfn(e)
        local self = e.target.__obj
        
        --2020/05/16 'ended' 이벤트는 처리하지 않는다.
        if e.phase=='ended' or self.tap==nil then return true end

        --print(string.format('%s tap event:%s',self.name, e.phase))
        local dx, dy = 0, 0
  
        -- 2020/02/17 : 'ended'이벤트를 self.tap()호출하기 전 강제로 발생시켜
        -- 터치이벤트를 시작하자마자 종료시킨다.
        if e.phase=='began' then --logf('tap begin')
            
            -- 아래는 'end' 이벤트를 발생시켜서 터치이벤트를 강제종료하려는 의도인데
            -- self.__bd:dispatchEvent{name='touch',id=e.id, phase='ended', target=self.__bd}
            -- 이렇게 해도 어차피 터치를 뗄 때 'end'이벤트가 또 발생한다.

            self:tap{id = e.id, x=e.x, y=e.y}
            return true
          
        elseif e.phase == 'ended' then logf('tap end')
            return true
  
        else -- if  event.phase =='cancelled' then
            return true
        end
  
    end
    -- 2020/02/17 누르는 순간에 tap이벤트를 발생시키기 위해서
    -- 코로나의 'tap'이벤트가 아니라 'touch'이벤트를 이용한다.
    
    function Display:__tapon()
        if self.tap and not self.__tap then --print('enable tap')
            self.__bd:addEventListener('touch', tapfn)
            self.__tap = true
        end
        return self
    end
----[[

    function Display:stoptap()
        if self.tap and self.__tap then 
            self.__bd:removeEventListener('touch', tapfn)
            self.__tap = false
        end
        return self
    end

    Display.resumetap = Display.__tapon
--]]
end