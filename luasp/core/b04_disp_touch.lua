
if _Gideros then

    local Event = _Gideros.Event


    local function tchBegin(self, event) --printf('%s touch begin', self.name)

        if self.__tch == nil then return end
        local t = event.touch
        if self.__bd:hitTestPoint(t.x, t.y) then
            self.__tch[t.id] = {id=t.id, phase='begin', x=t.x, y=t.y, dx=0, dy=0}
            self:ontouch(self.__tch[t.id])
            event:stopPropagation()
        end

    end


    local function tchMove(self, event) --printf('%s touch move', self.name)

        --printf('%d:move event(%d)',self.id,event.touch.id)
        -- move이벤트는 모든 touch 객체에 동시에 발생한다.
        -- 따라서 현재 begin or move 상태인 것만  처리한다.
        local t = event.touch
        if self.__tch==nil or self.__tch[t.id]==nil then return end
        local dx, dy = t.x-self.__tch[t.id].x, t.y-self.__tch[t.id].y
    
        if self.__bd:hitTestPoint(t.x, t.y) then
            self.__tch[t.id] = {id=t.id, phase='move', x=t.x, y=t.y, dx=dx, dy=dy}
            self:ontouch(self.__tch[t.id])
            event:stopPropagation()
        else -- 터치상태로 영역 밖으로 나가면 'cancel'을 발생시킨다.
            if self.__tch.phase =='cancel' then return end
            self:ontouch{id=t.id, phase='cancel', x=t.x, y=t.y, dx=0, dy=0}
            self.__tch[t.id] = nil
            event:stopPropagation()
        end
    
    end


    local function tchEnd(self, event) --printf('%s end event',self.name)

        local t = event.touch
        if self.__tch==nil or self.__tch[t.id]==nil then return end
  
        if self.__bd:hitTestPoint(t.x, t.y) then
            self:ontouch{id=t.id, phase='end', x=t.x, y=t.y, dx=0, dy=0}
            self.__tch[t.id] = nil
            event:stopPropagation()
        end

    end
      

    local function tchCancel(self, event)

        --printf('%d:cancel event(%d)',self.id, event.touch.id)
        local t = event.touch
        if self.__tch==nil or self.__tch[t.id]==nil then return end
  
        if self.__bd:hitTestPoint(t.x, t.y) then
          self.__tch = {id=event.touch.id, phase='cancelled', x=event.touch.x, y=event.touch.y,dx=0,dy=0}
            self:ontouch(self.__tch)
            self.__tch[t.id] = nil
            event:stopPropagation()
        end

    end


    function Display:__touchon() -- print('enable touch try')
        
        if self.ontouch then --printf('%s touch enabled',self.name)
            self.__bd:addEventListener(Event.TOUCHES_BEGIN, tchBegin, self)
            self.__bd:addEventListener(Event.TOUCHES_MOVE, tchMove, self)
            self.__bd:addEventListener(Event.TOUCHES_END, tchEnd, self)
            self.__bd:addEventListener(Event.TOUCHES_CANCEL, tchCancel, self)
            self.__tch = {}
            -- self.__noTch = false
        end

        return self
    end
    

    function Display:stoptouch() --print('try dt')

        if self.ontouch then --printf('%s touch disabled',self.name)
            -- 현재 begin된 터치가 있다면 end를 발생시키고 __tch를 비운다
            -- self.__tch 본체는 그대로 남겨두어야 __upd__()에서 __touchOn()이 안 호출됨
            if self.__tch then
                for k, t in pairs(self.__tch) do
                    self:ontouch{id=t.id, phase='end', x=t.x, y=t.y, dx=0, dy=0}
                    self.__tch[k] = nil
                end
            end
            
            -- 이벤트를 제거
            self.__bd:removeEventListener(Event.TOUCHES_BEGIN, tchBegin, self)
            self.__bd:removeEventListener(Event.TOUCHES_MOVE, tchMove, self)
            self.__bd:removeEventListener(Event.TOUCHES_END, tchEnd, self)
            self.__bd:removeEventListener(Event.TOUCHES_CANCEL, tchCancel, self)
            -- self.__noTch = true
        end

        return self

    end
    
--------------------------------------------------------------------------------
elseif _Corona then
--------------------------------------------------------------------------------

      -- touch handling functions
    
    -- 터치점이 bd 내부에 들어있는 지를 체크하는 함수
    -- 이를 위해서 corona 의 dobj:localToContent() 메서드 이용
    -- bd가 몇 단계든지 (중첩된) 그룹 안에 포함되었어도 이 메서드는 스크린xy값을 반환
    local function hitTestFunction(bd, tx, ty)
        local sx, sy = bd:localToContent(0,0) -- (0,0)은 bd의 중심점
        local hw, hh = bd.width*bd.xScale/2, bd.height*bd.yScale/2
        return (sx-hw<tx and tx<sx+hw) and (sy-hh<ty and ty<sy+hh)
    end
  

    local function tch(e)

        local self = e.target.__obj
        -- printf('%s tch event:%s',self.name, e.phase)
        local dx, dy = 0, 0
  
        -- 2020/02/07 : gideros와 반대로 move/end/cancel 이벤트가
        -- dobj위에서만 일어난다. 아래 focus 관련 두 줄은 이 이벤트들이 began 이후에
        -- dobj밖에서도 발생하도록 하는 것이다.
        if e.phase=='began' then --print('tch begin')

            _Corona.display.getCurrentStage():setFocus(self.__bd)
            self.__bd.isFocus = true
            self.__tch[e.id] = {id = e.id, phase="begin", x=e.x, y=e.y, dx=dx, dy=dy}
            self:ontouch(self.__tch[e.id])
            return true
          
        elseif e.phase == 'moved' then --print('tch move event')

            if self.__tch[e.id] == nil then return end

            if hitTestFunction(self.__bd, e.x, e.y) then
                dx, dy = e.x - self.__tch[e.id].x, e.y - self.__tch[e.id].y
                self.__tch[e.id]={id=e.id, phase='move', x=e.x, y=e.y, dx=dx, dy=dy}
                self:ontouch(self.__tch[e.id])
                return true
            else 
                -- if self.__tch.phase == 'cancel' then return end
                _Corona.display.getCurrentStage():setFocus(nil)
                self.__bd.isFocus = false
                self:ontouch{id=e.id, phase='cancel', x=e.x, y=e.y, dx=dx, dy=dy}
                self.__tch[e.id] = nil
                return true
            end
        
        elseif e.phase == 'ended' then --print('tch end')

            _Corona.display.getCurrentStage():setFocus(nil)
            self.__bd.isFocus = false
            self:ontouch{id=e.id, phase='end', x=e.x, y=e.y, dx=0, dy=0}
            self.__tch[e.id] = nil
            return true
  
        else -- if  event.phase =='cancelled' then

            _Corona.display.getCurrentStage():setFocus(nil)
            self.__bd.isFocus = false
            self:ontouch{id=e.id, phase='cancel', x=e.x, y=e.y, dx=dx, dy=dy}
            self.__tch[e.id] = nil
            return true

        end
  
    end
  

    function Display:__touchon() --print('tch on')

        if self.ontouch then
            self.__bd:addEventListener('touch', tch)
            self.__tch = {}
            --print('resume touch')
        end

        return self
    end


    function Display:stoptouch() --print('try dt')

        if self.ontouch then
            -- 현재 begin된 터치가 있다면 강제로 end를 발생
            -- self.__tch는 그대로 남겨두어야 __upd__()에서 __touchOn()이 안 호출됨
            if self.__tch then
                for k, t in pairs(self.__tch) do
                    self.__bd:dispatchEvent{name='touch',id=t.id, phase='ended', target=self.__bd, x=t.x, y=t.y}
                end
            end

            self.__bd:removeEventListener('touch', tch)
        end

        return self

    end
  
end

Display.resumetouch = Display.__touchon