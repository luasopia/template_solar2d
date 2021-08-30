-- if not_required then return end -- This prevents auto-loading in Gideros

local Disp = Display

Group = class(Disp)
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
if _Gideros then
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
    --print('core.group(gid)')
    local Snew = _Gideros.Sprite.new


    function Group:init()

        self.__bd = Snew()
        self.__cpt = {x=0, y=0} -- 2021/08/30
        return Disp.init(self)

    end


    function Group:add(child)

        child.__pr = self
        self.__bd:addChild(child.__bd)
        child:setxy(0,0) --2021/08/14:__bdx,__bdy를 갱신하기 위해서 이렇게 해야함
        return self

    end


    -- Disp 베이스클래스의 remove()를 오버로딩
    function Group:remove()

        -- (1) child들은 소멸자 호출 (__obj는 __bd를 가지는 객체)
        -- 여기서 소멸자를 호출하여 그룹이 삭제되는 즉시 child들도 삭제토록 한다.
        for k = self.__bd:getNumChildren(),1,-1 do
            self.__bd:getChildAt(k).__obj:remove() -- 각 차일드의 소멸자 호출(즉시 삭제)
        end

        -- (2) 자신도 (부모그룹에서) 제거
        return Disp.remove(self) -- 부모의 소멸자 호출

    end


    -- Disp 베이스클래스의 pasuseTouch()를 오버로딩
    function Group:stoptouch()

        -- (1) child들은 소멸자 호출 (__obj는 body를 가지는 객체)
        for k = self.__bd:getNumChildren(),1,-1 do
            local obj = self.__bd:getChildAt(k).__obj
            obj:stoptouch() -- 차일드 각각의 touchOff() 호출
        end
        -- (2) 자신도 (부모그룹에서) 터치를 멈춤
        --return Disp.stoptouch(self)

    end


    -- Disp 베이스클래스의 pasuseTouch()를 오버로딩
    function Group:resumetouch() --print('---group enabletch')

        -- (1) child들은 소멸자 호출 (__obj는 body를 가지는 객체)
        for k = self.__bd:getNumChildren(),1,-1 do
            local obj = self.__bd:getChildAt(k).__obj
            obj:resumetouch() -- 차일드 각각의 소멸자 호출
        end
        -- (2) 자신도 (부모그룹에서) 터치를 멈춤
        --return Disp.resumetouch(self)

    end


    -- Disp 베이스클래스의 pasuseTouch()를 오버로딩
    function Group:stopupdate()

        -- (1) child들은 소멸자 호출 (__obj는 body를 가지는 객체)
        for k = self.__bd:getNumChildren(),1,-1 do
            local obj = self.__bd:getChildAt(k).__obj
            obj:stopupdate() -- 차일드 각각의 소멸자 호출
        end
        -- (2) 자신도 (부모그룹에서) 터치를 멈춤
        return Disp.stopupdate(self)

    end


    -- Disp 베이스클래스의 pasuseTouch()를 오버로딩
    function Group:resumeupdate()

        -- (1) child들은 소멸자 호출 (__obj는 body를 가지는 객체)
        for k = self.__bd:getNumChildren(),1,-1 do
            local obj = self.__bd:getChildAt(k).__obj
            obj:resumeupdate() -- 차일드 각각의 소멸자 호출
        end

        -- (2) 자신도 (부모그룹에서) 터치를 멈춤
        return Disp.resumeupdate(self)

    end


    --2020/06/15 : 그룹자체는 유지하고 내용물들만 삭제함
    function Group:clear()

        for k = self.__bd:getNumChildren(),1,-1 do
            self.__bd:getChildAt(k).__obj:remove()
        end

    end
  
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
elseif _Corona then
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

    -- print('core.group(cor)')  
  
    local Gnew = _Corona.display.newGroup
    
    function Group:init()

        self.__bd = Gnew()
        self.__cpt = {x=0, y=0} -- 2021/08/30
        return Disp.init(self) --return self:superInit()

    end


    function Group:add(child)

        child.__pr = self
        self.__bd:insert(child.__bd)
        child:setxy(0,0) --2021/08/14:__bdx,__bdy를 갱신 하기 위해서 이렇게 해야함
        return self
    
    end


    -- Disp 베이스클래스의 remove()를 오버로딩
    function Group:remove()

        -- (1) child들은 소멸자 호출 (__obj는 body를 가지는 객체)
        -- 여기서 소멸자를 호출하여 그룹이 삭제되는 즉시 child들도 삭제토록 한다.
        -- 2020/03/10:corona는 Group이 removeSelf()될 때 자식들의 removeSelf()도 같이 호출되는 것 같다.
        -- 따라서 여기서 자식들을 미리 삭제시켜야 한다.
        for k = self.__bd.numChildren, 1, -1 do
            self.__bd[k].__obj:remove() -- 차일드 각각의 소멸자 호출(즉시 삭제)
        end

        -- (2) 자신도 (부모그룹에서) 제거
        return Disp.remove(self) -- 부모의 소멸자 호출

    end


    function Group:stoptouch()

        for k = self.__bd.numChildren, 1, -1 do
            self.__bd[k].__obj:stoptouch()
        end

        return Disp.stoptouch(self)

    end


    function Group:resumetouch()

        for k = self.__bd.numChildren, 1, -1 do
            self.__bd[k].__obj:resumetouch()
        end

        return Disp.resumetouch(self)

    end


    function Group:stopupdate()

        for k = self.__bd.numChildren, 1, -1 do
            self.__bd[k].__obj:stopupdate()
        end

        return Disp.stopupdate(self)

    end


    function Group:resumeupdate()

        for k = self.__bd.numChildren, 1, -1 do
            self.__bd[k].__obj:resumeupdate()
        end

        return Disp.resumeupdate(self)

    end


    -- 2020/03/13: corona의 setFillColor()는 group에는 적용되지 않는다.
    -- 따라서 모든 child를 순회하여 tint()함수를 호출한다.
    -- (Gideros의 setColorTransform()은 그룹내 모든 객체에 적용된다)
    function Group:tint(...)

        for k = self.__bd.numChildren, 1, -1 do
            self.__bd[k].__obj:tint(...)
        end
        
        return self

    end

    
    --2020/06/15 : 그룹자체는 유지하고 내용물들만 삭제함
    function Group:clear()

        for k = self.__bd.numChildren, 1, -1 do
            self.__bd[k].__obj:remove()
        end
      
    end
    

end