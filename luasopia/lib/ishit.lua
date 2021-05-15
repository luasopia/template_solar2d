local Disp = Display
local dtobj = Disp._dtobj -- Display Tagged OBJect
local emptyt = {} -- empty table
local tin = table.insert
local INF = math.huge
local abs = math.abs

--2020/03/03 추가
function Disp:tag(name)
    self._tag = name
    -- 2020/06/21 tagged객체는 아래와 같이 dtobj에 별도로 (중복) 저장
    if dtobj[name] == nil then dtobj[name] = {[self]=self}
    else dtobj[name][self] = self  end
    return self
end

--2020/06/21 dtobj에 tagged객체를 따로 저장하기 때문에
-- collect()함수에서 매번 for반복문으로 tagged객체를 모을 필요가 없어졌음
function Disp.collect(name)
    return dtobj[name] or emptyt
end

--------------------------------------------------------------------------------
-- 2021/05/09 분리축이론(SAT)를 이용한 충돌판정 구현
-- polygon  : __cpg__ ={x1,y1,len1, x2,y2,len2. ...}
-- circle   : __ccc__ = r
-- line     : __cln__ = {x1,y1, x2,y2, len}
-- point    : __cpt__ = {x, y}
--------------------------------------------------------------------------------

-- 2021/05/09: 꼭지점의 전역좌표(gpts)와 각 변의 단위법선벡터(vecs)를 계산
local function gvec_poly(self)

    local pts = self.__cpg__
    local gpts, vecs = {}, {}

    -- 첫 번째 점을 따로 저장한다
    local gx1, gy1 = self:getglobalxy(pts[1], pts[2])
    local len1 = pts[3] -- 이 점과 전 점간의 거리
    tin(gpts, gx1)
    tin(gpts, gy1)

    -- 점들을 순환하면서 단위벡터를 계산한다
    local gxk_1, gyk_1 = gx1, gy1  
    for k=4, #pts, 3 do -- {x,y,len}이므로 3씩 증가시킨다
        
        local gxk, gyk = self:getglobalxy(pts[k], pts[k+1])
        local lenk = pts[k+2] -- 이 점과 전 점간의 거리
        tin(gpts, gxk)
        tin(gpts, gyk)
    
        -- vector (k_1)->(k) 의 (도형 바깥 방향)법선벡터를 계산하여 저장
        tin(vecs, (gyk-gyk_1)*lenk ) -- vxk
        tin(vecs, (gxk_1-gxk)*lenk ) -- vyk
        --print(vxk, vyk)

        gxk_1, gyk_1 = gxk, gyk
    end
    tin(vecs, (gy1-gyk_1)*len1) -- vxn
    tin(vecs, (gxk_1-gx1)*len1) -- vyn
    --print(vecs[7], vecs[8])

    return gpts, vecs
end

-- 2021/05/11: 원에 대해서 폴리곤을 고려한 벡터생성
-- 원의 중심과 가장 가까운 꼭지점을 잇는 벡터를 생성한다
local function gvec_circ(circ, polygpts)
    
    local gpts, vecs = {}, {}

    -- 원의 중심점을 따로 저장한다
    local gx, gy = circ:getglobalxy()
    tin(gpts, gx)
    tin(gpts, gy)

    -- 가장 가까운 꼭지점을 찾는다
    local cx, cy
    local dmin = INF
    for k=1, #polygpts, 2 do
        local px, py = polygpts[k], polygpts[k+1]
        local d = (gx-px)*(gx-px) + (gy-px)*(gy-px)
        if d<dmin then
            dmin = d
            cx, cy = px, py
        end
    end
    -- 원중점에서 꼭지점을 향하는 단위벡터를 저장
    tin(vecs, (cx-gx)/dmin)
    tin(vecs, (cy-gy)/dmin)
    --print(vecs[7], vecs[8])

    return gpts, vecs
end

-- 2021/05/09 법선벡터(vecs1)방향으로 점들(gpts1, gpts2)을 프로젝션한후
-- 두 투영선이 겹쳐지지 않으면 false를 바로 반환
local function proj_pg2pg(vecs, gpts, gpts2)

    for k=1,#vecs,2 do

        local vx, vy = vecs[k], vecs[k+1]
        local min1, max1, min2, max2 = INF, -INF, INF, -INF

        for i=1, #gpts, 2 do
            local prj1 = vx*gpts[i] + vy*gpts[i+1] -- vx*px + vy*py
            if min1>prj1 then min1 = prj1 end
            if max1<prj1 then max1 = prj1 end
            -- print(prj1)
        end

        for i=1, #gpts2, 2 do
            local prj2 = vx*gpts2[i] + vy*gpts2[i+1]
            if min2>prj2 then min2 = prj2 end
            if max2<prj2 then max2 = prj2 end
            -- print(prj2)
        end

        local c1, c2 = (max1+min1)/2, (max2+min2)/2
        local d1, d2 = (max1-min1)/2, (max2-min2)/2

        if abs(c1-c2)>d1+d2 then return false end
    end

    return true

end

function Disp:ishit(obj)
    -- (1) 모든 꼭지점의 전역좌표값을 먼저 구해서 저장한다.
    -- print(self.__cpg__, obj.__cpg__)
    
    --(1) 둘 다 폴리곤(Rect포함)일 경우
    if self.__cpg__ and obj.__cpg__ then

        local gpts1, vecs1 = gvec_poly(self)
        local gpts2, vecs2 = gvec_poly(obj)
        return proj_pg2pg(vecs1, gpts1, gpts2) and proj_pg2pg(vecs2, gpts2, gpts1)

    --(2b) 원(self)과 폴리곤(obj)일 경우
    elseif self.__ccc__ and obj.__cpg__ then

        local gpts1, vecs1 = gvec_poly(obj)
        local gpts2, vecs2 = gvec_circ(self, gpts1)
        

    --(2a) 폴리곤(Rect포함)과 원일 경우
    elseif self.__cpg__ and obj.__ccc__ then

    
    --(3) 둘 다 원일 경우
    elseif self.__ccc___ and self.__ccc__ then

    end

end


--------------------------------------------------------------------------------

--[[
--2021/05/08 : gpts는 apex의 전역좌표값들의 집합
-- gpts점들로 구성된 convex의 내부에 (gx,gy)가 포함된다면 true를 반환
local function isin(gpts, gx, gy)

    local x0, y0 = gpts[1]-gx, gpts[2]-gy

    local x1, y1 = x0, y0
    local x2, y2 = gpts[3]-gx, gpts[4]-gy
    local sgn = x2*y1 > x1*y2
    x1, y1 = x2, y2

    for k=5, #gpts, 2 do
        x2, y2 = gpts[k]-gx, gpts[k+1]-gy
        if sgn ~= (x2*y1 > x1*y2) then return false end
        x1, y1 = x2, y2
    end

    x2, y2 = x0, y0
    if sgn ~= (x2*y1 > x1*y2) then
        return false 
    else 
        return true
    end

end

-- 아래 함수로는 충돌여부를 완벽히 검출할 수 없다.
function Disp:ishit0(obj)
    local pts1, pts2 = self.__cpts__, obj.__cpts__
    
    -- (1) 모든 꼭지점의 전역좌표값을 먼저 구해서 저장한다.
    local gpts1, gpts2 = {}, {}

    for k=1, #pts1, 2 do
        local gx, gy = self:getglobalxy(pts1[k], pts1[k+1])
        tin(gpts1, gx)
        tin(gpts1, gy)
    end

    -- (2) obj의 각 꼭지점이 self안에 포함되는지 체크
    for k=1, #pts2, 2 do
        local gx2, gy2 = obj:getglobalxy(pts2[k], pts2[k+1])
        tin(gpts2, gx2)
        tin(gpts2, gy2)

        if isin(gpts1, gx2, gy2) then return true end
    end

    for k=1, #gpts1, 2 do
        local gx1, gy1 = gpts1[k], gpts1[k+1]
        if isin(gpts2, gx1, gy1) then return true end
    end

    return false
end
--]]