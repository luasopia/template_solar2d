-- if not_required then return end -- This prevents auto-loading in Gideros
local luasp = _luasopia
local Disp = luasp.Display

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
        self.__isgrp = true -- Disp.__upd__()에서 onTap, onTouch를 건너뛴다
        return Disp.init(self)

    end


    function Group:add(...)

        local childs = {...}
        
        for _,child in ipairs(childs) do

            child.__pr = self
            self.__bd:addChild(child.__bd)
            child:setXY(0,0) --2021/08/14:__bdx,__bdy를 갱신하기 위해서 이렇게 해야함

        end
        
        return self

    end


    --2020/06/15 : 그룹자체는 유지하고 내용물들만 삭제함
    function Group:clear()

        for k = self.__bd:getNumChildren(),1,-1 do
            self.__bd:getChildAt(k).__obj:remove()
        end

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
    

    function Group:getChild(k)

        return self.__bd:getChildAt(k).__obj
        
    end


    function Group:getNumChildren()

        return self.__bd:getNumChildren()

    end


    --[[
    -- Disp 베이스클래스의 pasuseTouch()를 오버로딩
    function Group:stopTouch()

        -- (1) child들은 소멸자 호출 (__obj는 body를 가지는 객체)
        for k = self.__bd:getNumChildren(),1,-1 do
            local obj = self.__bd:getChildAt(k).__obj
            obj:stopTouch() -- 차일드 각각의 touchOff() 호출
        end
        -- (2) 자신도 (부모그룹에서) 터치를 멈춤
        --return Disp.stopTouch(self)

    end


    -- Disp 베이스클래스의 pasuseTouch()를 오버로딩
    function Group:resumeTouch() --print('---group enabletch')

        -- (1) child들은 소멸자 호출 (__obj는 body를 가지는 객체)
        for k = self.__bd:getNumChildren(),1,-1 do
            local obj = self.__bd:getChildAt(k).__obj
            obj:resumeTouch() -- 차일드 각각의 소멸자 호출
        end
        -- (2) 자신도 (부모그룹에서) 터치를 멈춤
        --return Disp.resumeTouch(self)

    end


    -- Disp 베이스클래스의 pasuseTouch()를 오버로딩
    function Group:stopUpdate()

        -- (1) child들은 소멸자 호출 (__obj는 body를 가지는 객체)
        for k = self.__bd:getNumChildren(),1,-1 do
            local obj = self.__bd:getChildAt(k).__obj
            obj:stopUpdate() -- 차일드 각각의 소멸자 호출
        end
        -- (2) 자신도 (부모그룹에서) 터치를 멈춤
        return Disp.stopUpdate(self)

    end


    -- Disp 베이스클래스의 pasuseTouch()를 오버로딩
    function Group:resumeUpdate()

        -- (1) child들은 소멸자 호출 (__obj는 body를 가지는 객체)
        for k = self.__bd:getNumChildren(),1,-1 do
            local obj = self.__bd:getChildAt(k).__obj
            obj:resumeUpdate() -- 차일드 각각의 소멸자 호출
        end

        -- (2) 자신도 (부모그룹에서) 터치를 멈춤
        return Disp.resumeUpdate(self)

    end
    --]]




  
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
elseif _Corona then
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
    local Gnew = _Corona.display.newGroup

    
    function Group:init()

        self.__bd = Gnew()
        self.__cpt = {x=0, y=0} -- 2021/08/30
        self.__isgrp = false -- 2021/10/10: Disp.__upd__()에서 onTap/onTouch를 건너뛴다
        return Disp.init(self) --return self:superInit()

    end


    --[[
    function Group:add(child)

        child.__pr = self
        self.__bd:insert(child.__bd)
        child:setXY(0,0) --2021/08/14:__bdx,__bdy를 갱신 하기 위해서 이렇게 해야함
        return self
    
    end
    --]]

    --2021/10/17: add()메서드에 두 개 이상의 child를 지정할 수 있도록 수정
    function Group:add(...)

        local childs = {...}
        
        for _ , child in ipairs(childs) do

            child.__pr = self
            self.__bd:insert(child.__bd)
            child:setXY(0,0) --2021/08/14:__bdx,__bdy를 갱신 하기 위해서 이렇게 해야함
            
        end

        return self
    
    end


    -- Disp 베이스클래스의 remove()를 오버로딩
    function Group:remove()

        -- --[[
        -- (1) child들은 소멸자 호출 (__obj는 body를 가지는 객체)
        -- 여기서 소멸자를 호출하여 그룹이 삭제되는 즉시 child들도 삭제토록 한다.
        -- 2020/03/10:corona는 Group이 removeSelf()될 때
        -- 자식들의 removeSelf()도 같이 호출되는 것 같다.
        -- 따라서 여기서 자식들을 미리 삭제시켜야 한다.
        for k = self.__bd.numChildren, 1, -1 do
            self.__bd[k].__obj:remove() -- 차일드 각각의 소멸자 호출(즉시 삭제)
        end
        --]]
        
        --[[
        for _, child in pairs(self.__chld) do
            if child.__bd ~=nil then child:remove() end
            self.__chld[child] = nil
        end
        --]]


        -- (2) 자신도 (부모그룹에서) 제거
        return Disp.remove(self) -- 부모의 소멸자 호출

    end
    
    
    --2020/06/15 : 그룹자체는 유지하고 내용물들만 삭제함
    function Group:clear()

        for k = self.__bd.numChildren, 1, -1 do
            self.__bd[k].__obj:remove()
        end
      
        return self
        
    end


    function Group:getNumChildren()

        return self.__bd.numChildren

    end


    function Group:getChild(k)

        return self.__bd[k].__obj

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



    --[[
    function Group:stopTouch()

        for k = self.__bd.numChildren, 1, -1 do
            self.__bd[k].__obj:stopTouch()
        end

        return Disp.stopTouch(self)

    end


    function Group:resumeTouch()

        for k = self.__bd.numChildren, 1, -1 do
            self.__bd[k].__obj:resumeTouch()
        end

        return Disp.resumeTouch(self)

    end


    function Group:stopUpdate()

        for k = self.__bd.numChildren, 1, -1 do
            self.__bd[k].__obj:stopUpdate()
        end

        return Disp.stopUpdate(self)

    end


    function Group:resumeUpdate()

        for k = self.__bd.numChildren, 1, -1 do
            self.__bd[k].__obj:resumeUpdate()
        end

        return Disp.resumeUpdate(self)

    end
    --]]

end

Group.__getgxy__ = Disp.getGlobalXY -- 2022/09/13 추가