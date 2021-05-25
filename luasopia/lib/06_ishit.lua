--------------------------------------------------------------------------------
-- 2021/05/08: created
--------------------------------------------------------------------------------
local Disp = Display
local tins = table.insert
local INF, abs, sqrt = math.huge, math.abs, math.sqrt
--------------------------------------------------------------------------------
-- 2021/05/09 분리축이론(SAT)를 이용한 충돌판정 구현
-- 객체의 모양은 다음과 같은 내부필드로 구분한다.
-- polygon  : __cpg = {x1,y1,len1, x2,y2,len2. ...}
--            여기서 lenk는 (xk_1, yk_1)->(xk, yk) 벡터의 길이
-- circle   : __ccc = r
-- point    : __cpt = {x, y}
-- line     : __cln = {x1,y1, x2,y2, len}, len은 선분의 길이
--------------------------------------------------------------------------------

-- 2021/05/09: 꼭지점의 전역좌표(gpts)와 각 변의 단위법선벡터(vecs)를 계산
-- 2021/05/25: 충돌판정만 할 경우라도 반드시 *단위*법선벡터를 만들어야 한다.
local function gvec_poly(self)

    local pts = self.__cpg
    local gpts, vecs = {}, {}

    -- 첫 번째 점을 따로 저장한다
    local gx1, gy1 = self:getglobalxy(pts[1], pts[2])
    local len1 = pts[3] -- 이 점과 전 점간의 거리
    tins(gpts, gx1)
    tins(gpts, gy1)

    -- 점들을 순환하면서 단위벡터를 계산한다
    local gxk_1, gyk_1 = gx1, gy1  
    for k=4, #pts, 3 do -- {x,y,len}이므로 3씩 증가시킨다
        
        local gxk, gyk = self:getglobalxy(pts[k], pts[k+1])
        local lenk = pts[k+2] -- 이 점과 전 점간의 거리
        tins(gpts, gxk)
        tins(gpts, gyk)
    
        -- vector (k_1)->(k) 의 (도형 바깥 방향)법선벡터를 계산하여 저장
        tins(vecs, (gyk-gyk_1)*lenk ) -- vxk
        tins(vecs, (gxk_1-gxk)*lenk ) -- vyk
        --print(vxk, vyk)

        gxk_1, gyk_1 = gxk, gyk
    end
    tins(vecs, (gy1-gyk_1)*len1) -- vxn
    tins(vecs, (gxk_1-gx1)*len1) -- vyn
    --print(vecs[7], vecs[8])

    return gpts, vecs
end


-- 2021/05/11: 원에 대해서 폴리곤을 고려한 단위벡터 생성
-- 원의 중심과 가장 가까운 꼭지점을 잇는 벡터를 생성한다
local function gvec_circ(circ, pgpts)
    
    local gpts, vecs = {}, {}

    -- 원의 중심점을 따로 저장한다
    local gx, gy = circ:getglobalxy()
    tins(gpts, gx)
    tins(gpts, gy)
    tins(gpts, circ.__ccc)

    -- 원의 중심점에서 가장 가까운 꼭지점을 찾는다
    local cx, cy
    local dmin2 = INF
    for k=1, #pgpts, 2 do
        local px, py = pgpts[k], pgpts[k+1]
        local dx, dy = px-gx, py-gy
        local d = dx*dx + dy*dy
        if d<dmin2 then
            dmin2 = d
            cx, cy = px, py
        end
    end

    -- 원의 중심점에서 꼭지점을 향하는 벡터를 저장
    local dx, dy = cx-gx, cy-gy
    local len = sqrt(dmin2)
    tins(vecs, dx/len)
    tins(vecs, dy/len)

    return gpts, vecs
end

-------------------------------------------------------------------------------
-- projection functions
-------------------------------------------------------------------------------
-- 2021/05/09 법선벡터(vecs)방향으로 점들(gpts1, gpts2)을 프로젝션한후
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

-- 2021/05/18 법선벡터(vecs)방향으로 점들(gpts, gcc)을 프로젝션한후
-- 두 투영선이 겹쳐지지 않으면 false를 바로 반환
-- gpt:폴리곤 꼭지점의 전역좌표들, gcc={cx,cy,r}: circle center의 전역좌표와 반지름
local function proj_pg2cc(vecs, pgpts, ccpt)

    for k=1,#vecs,2 do

        local vx, vy = vecs[k], vecs[k+1]
        local min1, max1, min2, max2 = INF, -INF, INF, -INF

        for i=1, #pgpts, 2 do
            local prj1 = vx*pgpts[i] + vy*pgpts[i+1] -- vx*px + vy*py
            if min1>prj1 then min1 = prj1 end
            if max1<prj1 then max1 = prj1 end
            -- print(prj1)
        end

        -- 원의 투영은 중심점을 투영한 값에서 반지름(r)을 더하고 빼면 된다.
        local prj2 = vx*ccpt[1] + vy*ccpt[2]
        local r = ccpt[3]
        min2, max2 = prj2 - r, prj2 + r
        -- print(prj2)

        local c1, c2 = (max1+min1)/2, (max2+min2)/2
        local d1, d2 = (max1-min1)/2, (max2-min2)/2

        if abs(c1-c2)>d1+d2 then return false end
    end

    return true

end

-------------------------------------------------------------------------------
-- 2021/05/09 폴리곤-폴리곤의 충돌판정 작성
-- 2021/05/18 폴리곤-원/원-폴리곤/원-원 들의 충돌판정 작성
-------------------------------------------------------------------------------
function Disp:ishit(obj)
    -- (1) 모든 꼭지점의 전역좌표값을 먼저 구해서 저장한다.
    -- print(self.__cpg, obj.__cpg)
    
    --(1) 둘 다 폴리곤(Rect포함)일 경우
    if self.__cpg and obj.__cpg then

        local gpts1, vecs1 = gvec_poly(self)
        local gpts2, vecs2 = gvec_poly(obj)
        return proj_pg2pg(vecs1, gpts1, gpts2) and proj_pg2pg(vecs2, gpts2, gpts1)

    --(2b) 원(self)과 폴리곤(obj)일 경우
    elseif self.__ccc and obj.__cpg then

        local pgpts, pgvecs = gvec_poly(obj)
        local ccpt, ccvec = gvec_circ(self, pgpts)

        return proj_pg2cc(pgvecs, pgpts, ccpt) and proj_pg2cc(ccvec, pgpts, ccpt)

    --(2a) 폴리곤(Rect포함)과 원일 경우
    elseif self.__cpg and obj.__ccc then

        local pgpts, pgvecs = gvec_poly(self)
        local ccpt, ccvec = gvec_circ(obj, pgpts)
        return proj_pg2cc(pgvecs, pgpts, ccpt) and proj_pg2cc(ccvec, pgpts, ccpt)

    
    --(3) 둘 다 원일 경우
    elseif self.__ccc and obj.__ccc then
        -- print('ishit')
        local gcx1, gcy1 = self:getglobalxy()
        local gcx2, gcy2 = obj:getglobalxy()
        local dx, dy = gcx1-gcx2, gcy1-gcy2
        local len = sqrt(dx*dx+dy*dy)
        return len <= self.__ccc + obj.__ccc
    end

end
--------------------------------------------------------------------------------

--[[
--2021/05/08 : gpts는 apex의 전역좌표값들의 집합
-- gpts점들로 구성된 convex의 내부에 (gx,gy)가 포함된다면 true를 반환
local function isptin(gpts, gx, gy)

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
        tins(gpts1, gx)
        tins(gpts1, gy)
    end

    -- (2) obj의 각 꼭지점이 self안에 포함되는지 체크
    for k=1, #pts2, 2 do
        local gx2, gy2 = obj:getglobalxy(pts2[k], pts2[k+1])
        tins(gpts2, gx2)
        tins(gpts2, gy2)

        if isin(gpts1, gx2, gy2) then return true end
    end

    for k=1, #gpts1, 2 do
        local gx1, gy1 = gpts1[k], gpts1[k+1]
        if isin(gpts2, gx1, gy1) then return true end
    end

    return false
end
--]]