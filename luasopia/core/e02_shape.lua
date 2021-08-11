--[[---------------------------------------------------------------------------
-- 2020/06/15 created, 2020/06/02  totally refactored
-------------------------------------------------------------------------------
점들 (x1,y1)-(x2,y2)- ... -(xn,yn)-(x1,y1) 을 연결한 폐곡면을 그린다.
(주의) 아래 pts 테이블에는 x1,y1 부터 ** xn,yn 까지만 ** 저장되어 있어야 한다.
pts = {x1,y1, x2,y2, ..., xn,yn } 
opt = {
    sw -- (required) strokewidth
    sc -- (required) strokecolor
    fc -- (required) fillcolor
}
The anchor point is initially located at the center of the shape.

-- 2021/05/30 getsheet.lua와 shape.lua 파일들을 병합함
Group에 shape를 생성해서 집어넣는다. 이유는 shape를 runtime에서 변형가능하게 하고
anchor point의 위치를 gideros와 solar2d 상에서 정확하게 일치시키기 위해서임.
------------------------------------------------------------------------------]]
local Disp = Display
local WHITE = Color.WHITE -- default stroke/fill color
local emptycolor = Color(0,0,0,0)
local newgroup
local sqrt = math.sqrt
local tins = table.insert
local inv255 = 1/255 --
-- local mkshp -- Rawshape클래스(맨 하단)에서도 사용하기 위해서 바깥에서 정의
-- local Rawshape = _luasopia.Rawshape
--------------------------------------------------------------------------------
Shape = class(Disp)
--------------------------------------------------------------------------------
if _Gideros then
--------------------------------------------------------------------------------
    newgroup = _Gideros.Sprite.new    
    local GShape = _Gideros.Shape

    --[[
    function Shape:__mkshp__()

        local pts, opt = self.__pts, self.__sopt

        -- 원좌표계에서의 중심점의 좌표와 너비/2, 높이/2를 구한다
        local xmn, xmx, ymn, ymx = pts[1], pts[1], pts[2], pts[2]
        for k=3, #pts, 2 do
            local x, y = pts[k], pts[k+1]
            if x>xmx then xmx = x elseif x<xmn then xmn = x end
            if y>ymx then ymx = y elseif y<ymn then ymn = y end
        end
        local ctx, cty = (xmx+xmn)*0.5, (ymx+ymn)*0.5
                
        -- solar2d와 동일한 원점을 가지게끔 하기 위해서
        -- pts좌표들을 중심점이 원점이 되도록 이동시킨다.
        -- (solar2d는 이 연산이 내부적으로 수행되므로 따로 할 필요가 없음)
        for k=1, #pts, 2 do
            pts[k], pts[k+1] = pts[k]-ctx, pts[k+1]-cty
        end
        
        -- 폴리곤이라면 cpg좌표를 수정한다.
        if self.__cpg then
            local ctx, cty = (xmx+xmn)*0.5, (ymx+ymn)*0.5
            local cpg = self.__cpg
            for k=1,#cpg,3 do
                cpg[k], cpg[k+1] = cpg[k]-ctx, cpg[k+1]-cty
            end
        end
        
        -----------------------------------------------------------------------
        -- 2021/06/02 gideros에서 shp(내부)와 strk(외곽선)을 분리함

        local shp =  GShape.new() -- 내부
        local strk = GShape.new() -- 외곽선
        
        shp:setFillStyle(GShape.SOLID, opt.fc.hex, opt.fc.a)
        strk:setLineStyle(opt.sw, opt.sc.hex, opt.sc.a) -- width, color, alpha
        
        shp:beginPath(); shp:moveTo(pts[1], pts[2]) -- starting at upmost point
        strk:beginPath(); strk:moveTo(pts[1], pts[2]) -- starting at upmost point
        for k=3,#pts,2 do
            shp:lineTo(pts[k], pts[k+1])
            strk:lineTo(pts[k], pts[k+1])
        end
        shp:lineTo(pts[1], pts[2]); shp:endPath() -- ending at the starting point
        strk:lineTo(pts[1], pts[2]); strk:endPath() -- ending at the starting point
        
        -- gideros의 shape는 자동으로 원점(0,0)이 anchor point가 된다
        self.__bd:addChild(shp) 
        self.__bd:addChild(strk) --외곽선을 나중에 add해야 shp의 위에 그려진다.
        ------------------------------------------------------------------------
        
        -- anchor point의 위치를 shp의 xy위치를 조절하여 설정
        self.__hwdt, self.__hhgt = (xmx-xmn)*0.5, (ymx-ymn)*0.5
        shp:setX( self.__hwdt*(1-2*self.__apx) )
        shp:setY( self.__hhgt*(1-2*self.__apy) )

        self.__shp = shp
        self.__strk = strk
        return self

    end
    --]]

    -- 2021/06/02 : 외곽선만 다시 그려주는 함수
    -- 외곽선에는 setColorTransform()함수가 듣지 않아서 지우고 다시 그려야한다
    -- shp는 1번, strk는 2번자리에 넣는다 (addChildAt()메서드 이용)
    function Shape:__mkstrk__()

        local opt = self.__sopt

        -- print("sw", opt.sw)
        -- strokewidth==0 인 경우는 기존의 strk를 삭제(2번자리)하고 리턴
        if opt.sw == 0 then

            if self.__strk then
                self.__bd:getChildAt(2):removeFromParent()
            end
            self.__strk = nil
            return self
    
        end

        local pts = self.__pts
        local strk = GShape.new() -- 외곽선
        strk:setLineStyle(opt.sw, opt.sc.hex, opt.sc.a) -- width, color, alpha
        
        strk:beginPath(); strk:moveTo(pts[1], pts[2]) -- starting at upmost point
        for k=3,#pts,2 do
            strk:lineTo(pts[k], pts[k+1])
        end
        strk:lineTo(pts[1], pts[2]); strk:endPath() -- ending at the starting point
        
        
        if self.__strk then
            self.__bd:getChildAt(2):removeFromParent()
        end

        self.__bd:addChildAt(strk,2)
        self.__strk = strk
        
        strk:setX( self.__hwdt*(1-2*self.__apx) )
        strk:setY( self.__hhgt*(1-2*self.__apy) )

        return self

    end


    -- 2021/05/07 : add clear and add in one method
    function Shape:__redraw__()

        --(1) (clear) 그룹 내의 모든 객체는 지운다
        -- 생성자에서 호출시에는 clear가 실행되지 않는다.
        -- for k=self.__bd:getNumChildren(),1,-1 do
        --     self.__bd:getChildAt(k):removeFromParent()
        -- end
        if self.__shp then
            self.__bd:getChildAt(1):removeFromParent()
        end

        -- (2) (add new) 새로운 shp/strk를 생성해서 추가한다
        local pts, opt = self.__pts, self.__sopt

        --[[
        -- 원좌표계에서의 중심점의 좌표와 너비/2, 높이/2를 구한다
        local xmn, xmx, ymn, ymx = pts[1], pts[1], pts[2], pts[2]
        for k=3, #pts, 2 do
            local x, y = pts[k], pts[k+1]
            if x>xmx then xmx = x elseif x<xmn then xmn = x end
            if y>ymx then ymx = y elseif y<ymn then ymn = y end
        end
        local ctx, cty = (xmx+xmn)*0.5, (ymx+ymn)*0.5
        self.__hwdt, self.__hhgt = (xmx-xmn)*0.5, (ymx-ymn)*0.5
        --]]

        -- solar2d와 동일한 원점을 가지게끔 하기 위해서
        -- pts좌표들을 중심점이 원점이 되도록 이동시킨다.
        -- (solar2d는 이 연산이 내부적으로 수행되므로 따로 할 필요가 없음)
        local ctx, cty = self.__sctx, self.__scty
        for k=1, #pts, 2 do
            pts[k], pts[k+1] = pts[k]-ctx, pts[k+1]-cty
        end
        
        -- 폴리곤이라면 cpg좌표를 수정한다.
        if self.__cpg then
            local cpg = self.__cpg
            for k=1,#cpg,3 do
                cpg[k], cpg[k+1] = cpg[k]-ctx, cpg[k+1]-cty
            end
        end
        
        -----------------------------------------------------------------------
        -- 2021/06/02 gideros에서 shp(내부)와 strk(외곽선)을 분리함

        local shp = GShape.new() -- 내부
        shp:setFillStyle(GShape.SOLID, opt.fc.hex, opt.fc.a)
        shp:beginPath()
        shp:moveTo(pts[1], pts[2]) -- starting at upmost point
        for k=3,#pts,2 do
            shp:lineTo(pts[k], pts[k+1])
        end
        shp:lineTo(pts[1], pts[2])
        shp:endPath() -- ending at the starting point
        
        -- gideros의 shape는 자동으로 원점(0,0)이 anchor point가 된다
        -- shp는 1번 자리, strk는 2번자리에 고정시킨다
        self.__bd:addChildAt(shp, 1) 
        self.__shp = shp

        -- anchor point의 위치를 shp의 xy위치를 조절하여 설정
        shp:setX( self.__hwdt*(1-2*self.__apx) )
        shp:setY( self.__hhgt*(1-2*self.__apy) )

        -- strk(stroke)를 생성한다.
        return self:__mkstrk__()

    end


    --2021/05/31 : Shpae객체의 anchor point를 변경하기 위한 메서드들
    -- self.__shp의 (parent group내에서의) 위치를 바꿔주는 방식으로 변경
    function Shape:setanchor(apx, apy)

        self.__apx, self.__apy = apx, apy

        self.__shp:setX( self.__hwdt*(1-2*self.__apx) )
        self.__shp:setY( self.__hhgt*(1-2*self.__apy) )
        
        if self.__strk then
            self.__strk:setX( self.__hwdt*(1-2*self.__apx) )
            self.__strk:setY( self.__hhgt*(1-2*self.__apy) )
        end

        return self

    end


    -- 2021/05/31: globalxy는 __bd가 아니라 __shp에서 구해야 한다
    -- 따라서 Display의 그것을 override해야 한다.
    function Shape:getglobalxy(x,y)

        return self.__shp:localToGlobal(x or 0,y or 0)

    end


    function Shape:fill(fc)

        --2021/06/21: 현재 fillcolor와 변경하려는 것이 같다면 그냥 리턴
        if self.__sopt.fc:isequal(fc) then return self end

        self.__sopt.fc = fc
        self.__shp:setColorTransform(
            fc.__r*inv255,
            fc.__g*inv255,
            fc.__b*inv255,
            fc.a
        )
        return self
    
    end


    function Shape:setstrokecolor(sc)

        --2021/06/21: strk가 없거나 strokecolor가 이전 것과 같다면 그냥 리턴
        if self.__strk == nil or self.__sopt.sc:isequal(sc) then
            return self
        end
        
        self.__sopt.sc = sc
        return self:__mkstrk__()
    
    end
    
    function Shape:setstrokewidth(sw)

        -- print('setstrkwdt(',sw)

        -- width가 기존의 것과 같다면 그냥 리턴
        if self.__sopt.sw == sw then
            return self
        end

        self.__sopt.sw = sw
        return self:__mkstrk__()
    
    end
    
    
--------------------------------------------------------------------------------
elseif _Corona then
--------------------------------------------------------------------------------

    local newPoly = _Corona.display.newPolygon
    newgroup = _Corona.display.newGroup


    function Shape:__mkshp__()

        local pts, opt = self.__pts, self.__sopt

        -- gideros와 달리 solar2d는 생성된 shape의 중심점으로 원점이 자동으로 이동됨
        -- 따라서 중심점을 원점으로 만드는 pts변환(pts.x-ctx, pts.y-cty)이 불필요함
        -- 아래는 shp의 (0,0)원점(중심점)이 group(self.__bd)의 원점에 위치됨
        local shp = newPoly(0, 0, pts)
        self.__bd:insert(shp) 
        
        --[[
        -- 원좌표계에서의 중심점의 좌표와 너비/2, 높이/2를 구한다
        local xmn, xmx, ymn, ymx = pts[1], pts[1], pts[2], pts[2]
        for k=3, #pts, 2 do
            local x, y = pts[k], pts[k+1]
            if x>xmx then xmx = x elseif x<xmn then xmn = x end
            if y>ymx then ymx = y elseif y<ymn then ymn = y end
        end
        --]]
        
        -- solar2d는 pts 좌표들을 직접 변경시켜줄 필요가 없다.
        -- 자동적으로 원점을 중심점으로 변경시켜주기 때문이다.

        -- 폴리곤이라면 cpg좌표를 수정한다.
        if self.__cpg then
            local ctx, cty = self.__sctx, self.__scty
            local cpg = self.__cpg
            for k=1,#cpg,3 do
                cpg[k], cpg[k+1] = cpg[k]-ctx, cpg[k+1]-cty
            end
        end

        -- anchor point의 위치를 shp의 xy위치를 조절하여 설정
        shp.x = self.__hwdt*(1-2*self.__apx)
        shp.y = self.__hhgt*(1-2*self.__apy)
        
        local sc, fc = opt.sc, opt.fc
        shp.strokeWidth = opt.sw
        shp:setStrokeColor(sc.r, sc.g, sc.b, sc.a)
        shp:setFillColor(fc.r, fc.g, fc.b, fc.a)
        ------------------------------------------------------------------------
        self.__shp = shp

        return self

    end


    -- 2021/05/07 : add clear and add in one method
    function Shape:__redraw__()

        --(1) 그룹 내의 모든 객체는 지운다(clear)
        -- 생성자에서 호출된 경우에는 clear가 안된다.
        if self.__bd.numChildren == 1 then -- shape이 딱 하나일 경우
            self.__bd[1]:removeSelf()
        end

        --(2) 새로운 shape를 생성한 후 그룹에 추가한다.
        return self:__mkshp__()

    end


    --2021/05/31 : Shpae객체의 anchor point를 변경하기 위한 메서드들
    -- self.__shp의 (parent group내에서의) 위치를 바꿔주는 방식으로 변경
    function Shape:setanchor(apx, apy)

        self.__apx, self.__apy = apx, apy
        self.__shp.x = self.__hwdt*(1-2*apx)
        self.__shp.y = self.__hhgt*(1-2*apy)
        return self

    end


    -- 2021/05/31: globalxy는 self.__bd가 아니라 self.__shp에서 구해야 한다
    function Shape:getglobalxy(x,y)

        return self.__shp:localToContent(x or 0, y or 0)

    end

    function Shape:fill(fc)

        --2021/06/21: 현재 fillcolor와 변경하려는 것이 같다면 그냥 리턴
        if self.__sopt.fc:isequal(fc) then return self end

        self.__sopt.fc = fc
        self.__shp:setFillColor(fc.r, fc.g, fc.b, fc.a)
        return self
    
    end
    
    function Shape:setstrokecolor(sc)

        --2021/06/21: 현재 fillcolor와 변경하려는 것이 같다면 그냥 리턴
        if self.__sopt.sc:isequal(sc) then return self end

        self.__sopt.sc = sc
        self.__shp:setStrokeColor(sc.r, sc.g, sc.b, sc.a)
        return self
    
    end
    
    function Shape:setstrokewidth(sw)

        if self.__sopt.sw == sw then return self end
        self.__sopt.sw = sw
        self.__shp.strokeWidth = sw
        return self
    
    end
    

end -- elseif _Corona then

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
function Shape:init(pts, opt)

    self.__apx, self.__apy = 0.5, 0.5 -- AnchorPointX, AnchorPointY
    self.__pts = pts

    if opt == nil then
        self.__sopt = {sw=0, sc=WHITE, fc=WHITE}
    else
        self.__sopt = {
            sw = opt.strokewidth or 0,
            sc = opt.strokecolor or WHITE,
            fc = opt.fill or opt.fillcolor or WHITE,
        }
    end

    self.__bd = newgroup()
    self:__redraw__()
    return Disp.init(self)
    
end


function Shape:empty()

    return self:fill(emptycolor)

end


function Shape:getanchor()

    return self.__apx, self.__apy

end


-- 2021/05/04에 추가

Shape.strokewidth = Shape.setstrokewidth
Shape.strokecolor = Shape.setstrokecolor
Shape.anchor = Shape.setanchor

Shape.fillcolor = Shape.fill -- 삭제예정


--[[
--------------------------------------------------------------------------------
-- 2020/06/13 Rawshape 클래스는 lib.Tail 클래스에서 사용됨
--------------------------------------------------------------------------------
local Disp = Display

_luasopia.Rawshape = class(Disp)

function _luasopia.Rawshape:init(pts, opt)

    self.__bd = mkshp(pts, opt)
    return Disp.init(self)

end
--]]