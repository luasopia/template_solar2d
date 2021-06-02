--[[---------------------------------------------------------------------------
-- 2020/06/15 created, 2020/06/23 refactored
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
--------------------------------------------------------------------------------
local Rawshape = _luasopia.Rawshape
local WHITE = Color.WHITE -- default stroke/fill color
local Disp = Display
local newGrp
local mkshp -- Rawshape클래스(맨 하단)에서도 사용하기 위해서 바깥에서 정의
local sqrt = math.sqrt
local tins = table.insert
local inv255 = 1/255 --
local emptycolor = Color(0,0,0,0)
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
Shape = class(Disp)
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
if _Gideros then
--------------------------------------------------------------------------------
    newGrp = _Gideros.Sprite.new    
    local GShape = _Gideros.Shape

    -- mkshp = function(pts, opt)
    local cnt = 0
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
        print(cnt);cnt=cnt+1;print(ctx,cty)
                
        -- pts좌표들을 중심점이 원점이 되도록 이동시킨다.
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
    

    -- 2021/05/07 : add clear and add in one method
    function Shape:__redraw__()

        --(1) (clear) 그룹 내의 모든 객체는 지운다
        -- 생성자에서 호출시에는 clear가 실행되지 않는다.
        for k=self.__bd:getNumChildren(),1,-1 do -- shape이 딱 하나일 경우
            self.__bd:getChildAt(k):removeFromParent()
        end

        -- (2) (add new)
        return self:__mkshp__()

    end


    --2021/05/31 : Shpae객체의 anchor point를 변경하기 위한 메서드들
    -- self.__shp의 (parent group내에서의) 위치를 바꿔주는 방식으로 변경
    -- (Shape객체는) self.__xmn, __xmx, __ymn, __ymx값들이 반드시 필요하다.
    function Shape:setanchor(apx, apy)

        self.__apx, self.__apy = apx, apy

        self.__shp:setX( self.__hwdt*(1-2*self.__apx) )
        self.__shp:setY( self.__hhgt*(1-2*self.__apy) )
        
        self.__strk:setX( self.__hwdt*(1-2*self.__apx) )
        self.__strk:setY( self.__hhgt*(1-2*self.__apy) )

        return self

    end

    -- 2021/05/31: globalxy는 __bd가 아니라 __shp에서 구해야 한다
    function Display:getglobalxy(x,y)

        return self.__shp:localToGlobal(x or 0,y or 0)

    end


    function Shape:fill(fc)

        --2021/06/21: 현재 fillcolor와 변경하려는 것이 같다면 그냥 리턴
        if self.__sopt.fc:isequal(fc) then return end

        print('fillchange')

        self.__sopt.fc = fc
        self.__shp:setColorTransform(
            fc.__r*inv255,
            fc.__g*inv255,
            fc.__b*inv255,
            fc.a
        )
        return self
    
    end


    -- 2021/06/02 : 외곽선만 다시 그려주는 함수
    -- 외곽선에는 setColorTransform()함수가 듣지 않아서 지우고 다시 그려야한다
    function Shape:__mkstrk__()

        local strk = GShape.new() -- 외곽선
        local pts, opt = self.__pts, self.__sopt
        strk:setLineStyle(opt.sw, opt.sc.hex, opt.sc.a) -- width, color, alpha
        
        strk:beginPath(); strk:moveTo(pts[1], pts[2]) -- starting at upmost point
        for k=3,#pts,2 do
            strk:lineTo(pts[k], pts[k+1])
        end
        strk:lineTo(pts[1], pts[2]); strk:endPath() -- ending at the starting point
        
        
        self.__bd:getChildAt(2):removeFromParent()
        self.__bd:addChild(strk)
        strk:setX( self.__hwdt*(1-2*self.__apx) )
        strk:setY( self.__hhgt*(1-2*self.__apy) )

        self.__strk = strk

        return self

    end


    function Shape:setstrokecolor(sc)

        --2021/06/21: 현재 strokecolor와 변경하려는 것이 같다면 그냥 리턴
        if self.__sopt.sc:isequal(sc) then return end
        
        self.__sopt.sc = sc
        return self:__mkstrk__()
    
    end
    
    function Shape:setstrokewidth(sw)

        if self.__sopt.sw == sw then return end

        self.__sopt.sw = sw
        return self:__mkstrk__()
    
    end
    
    
--------------------------------------------------------------------------------
elseif _Corona then
--------------------------------------------------------------------------------

    local newPoly = _Corona.display.newPolygon
    newGrp = _Corona.display.newGroup

    --mkshp = function(pts, opt)
    local cnt=0
    function Shape:__mkshp__()

        local pts, opt = self.__pts, self.__sopt

        -- solar2d는 shape의 중심점으로 원점이 자동으로 설정된다 
        -- shp의 원점(0,0)-중심점이 group(self.__bd)의 원점에 위치됨
        local shp = newPoly(0, 0, pts)
        self.__bd:insert(shp) 
        
        -- 원좌표계에서의 중심점의 좌표와 너비/2, 높이/2를 구한다
        local xmn, xmx, ymn, ymx = pts[1], pts[1], pts[2], pts[2]
        for k=3, #pts, 2 do
            local x, y = pts[k], pts[k+1]
            if x>xmx then xmx = x elseif x<xmn then xmn = x end
            if y>ymx then ymx = y elseif y<ymn then ymn = y end
        end
        
        -- 폴리곤이라면 cpg좌표를 수정한다.
        if self.__cpg then
            local ctx, cty = (xmx+xmn)*0.5, (ymx+ymn)*0.5
            local cpg = self.__cpg
            for k=1,#cpg,3 do
                cpg[k], cpg[k+1] = cpg[k]-ctx, cpg[k+1]-cty
            end
        end
        print(cnt);cnt=cnt+1
        -- anchor point의 위치를 shp의 xy위치를 조절하여 설정
        self.__hwdt, self.__hhgt = (xmx-xmn)*0.5, (ymx-ymn)*0.5
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

    --[[
    function Shape:__mkshp__()

        local pts, opt = self.__pts, self.__sopt

        for k=3, #pts, 2 do
            local x, y = pts[k], pts[k+1]
            if x>xmx then xmx = x elseif x<xmn then xmn = x end
            if y>ymx then ymx = y elseif y<ymn then ymn = y end
        end

        -- 2021/06/01: shape의 중심점을 원점으로 만든다
        local cx, cy = (xmn+xmx)*0.5, (ymn+ymx)*0.5
        for k=1,#pts,2 do
            pts[k], pts[k+1] = pts[k]-cx, pts[k+1]-cy
        end

        if self.__cpg then
            local cpg = {}
            local px1, py1 = pts[1], pts[2]
            for k=3,#pts,2 do
                local px2, py2 = pts[k], pts[k+1]
                local dx, dy = px2-px1, py2-py1
                local len = sqrt(dx*dx+dy*dy)
                tins(cpg, px2)
                tins(cpg, py2)
                tins(cpg, 1/len)

                px1, py1 = px2, py2
            end

            local dx, dy = pts[1]-px1, pts[2]-py1
            local len = sqrt(dx*dx+dy*dy)
            tins(cpg, pts[1])
            tins(cpg, pts[2])
            tins(cpg, 1/len)

            self.__cpg = cpg
        end

        -- shp의 원점(0,0)-중심점이 group(self.__bd)의 원점에 위치됨
        local shp = newPoly(0, 0, pts)
        self.__bd:insert(shp) 
        
        -- anchor point의 위치를 shp의 xy위치를 조절하여 설정
        local hwdt, hhgt = (xmx-xmn)*0.5, (ymx-ymn)*0.5
        shp.x = hwdt*(1-2*self.__apx)
        shp.y = hhgt*(1-2*self.__apy)
        
        local sc, fc = opt.sc, opt.fc
        shp.strokeWidth = opt.sw
        shp:setStrokeColor(sc.r, sc.g, sc.b, sc.a)
        shp:setFillColor(fc.r, fc.g, fc.b, fc.a)
        ------------------------------------------------------------------------
        self.__hwdt, self.__hhgt = hwdt, hhgt -- anchor point 갱신에 필요한 정보
        self.__shp = shp
        return self

    end
    --]]


    --[[
    mkshp = function(pts, opt)

        local x, y = pts[1], pts[2]
        local xmin,ymin,  xmax,ymax = x,y,  x,y
        for k=3,#pts,2 do
            x, y = pts[k], pts[k+1]
            if x<xmin then xmin = x elseif x>xmax then xmax = x end
            if y<ymin then ymin = y elseif y>ymax then ymax = y end
        end
        
        local s = newPoly(0, 0, pts)
        -- solar2d의 폴리곤은 자동으로 중심점에 anchor가 위치한다.
        -- 그래서 아래와 같이 anchor point를 원점(0,0)으로 만든다.
        s.anchorX = -xmin/(xmax-xmin) --(0-xmin)/(xmax-xmin)
        s.anchorY = -ymin/(ymax-ymin) --(0-ymin)/(ymax-ymin)
        
        local sc = opt.sc
        local fc = opt.fc
        s.strokeWidth = opt.sw
        s:setStrokeColor(sc.r, sc.g, sc.b, sc.a)
        s:setFillColor(fc.r, fc.g, fc.b, fc.a)
        ------------------------------------------------------------------------
        return s
    end
    --]]

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
    function Display:getglobalxy(x,y)

        return self.__shp:localToContent(x or 0, y or 0)

    end

    function Shape:fill(fc)

        --2021/06/21: 현재 fillcolor와 변경하려는 것이 같다면 그냥 리턴
        if self.__sopt.fc:isequal(fc) then return end

        print("fillchange")

        self.__sopt.fc = fc
        self.__shp:setFillColor(fc.r, fc.g, fc.b, fc.a)
        return self
    
    end
    
    function Shape:setstrokecolor(sc)

        --2021/06/21: 현재 fillcolor와 변경하려는 것이 같다면 그냥 리턴
        if self.__sopt.sc:isequal(sc) then return end

        self.__sopt.sc = sc
        self.__shp:setStrokeColor(sc.r, sc.g, sc.b, sc.a)
        return self
    
    end
    
    function Shape:setstrokewidth(sw)

        if self.__sopt.sw == sw then return end

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

    self.__bd = newGrp()
    self:__redraw__()

    return Disp.init(self)
    
end









function Shape:empty()

    -- self.__sopt.fc = Color(0,0,0,0)
    -- return self:__redraw__()

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

--------------------------------------------------------------------------------
-- 2020/06/13 Rawshape 클래스는 lib.Tail 클래스에서 사용됨
--------------------------------------------------------------------------------
local Disp = Display

_luasopia.Rawshape = class(Disp)

function _luasopia.Rawshape:init(pts, opt)

    self.__bd = mkshp(pts, opt)
    return Disp.init(self)

end