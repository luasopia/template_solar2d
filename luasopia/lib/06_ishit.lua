--------------------------------------------------------------------------------
-- 2021/05/08: created
--------------------------------------------------------------------------------
local Disp = Display
local tins = table.insert
local INF, abs, sqrt = math.huge, math.abs, math.sqrt
--------------------------------------------------------------------------------
-- 2021/05/09 분리축이론(SAT)를 이용한 충돌판정 구현
-- 객체의 모양은 다음과 같은 내부필드로 구분한다.
-- polygon  : __cpg = {x1,y1,_1_len1, x2,y2,_1_len2. ...}
--            여기서 _1_lenk는 (xk_1, yk_1)->(xk, yk) 벡터의 길이의 역수
--            (곱셈이 나눗셈보다 시간이 덜 걸리므로 미리 역수를 계산해둔다)
-- circle   : __ccc = {x, y, r} -- x,y is the coordinates of center point
-- point    : __cpt = {x, y}

-- line     : __cln = {x1,y1, x2,y2, len}, len은 선분의 길이
--------------------------------------------------------------------------------



-- 2021/05/09: 꼭지점의 전역좌표(gpts)와 각 변의 단위법선벡터(vecs)를 계산
-- 2021/05/25: 충돌판정만 할 경우라도 반드시 *단위*법선벡터를 만들어야 한다.
-- (왜나면 원의 중심을 프로젝션할 때 반지름의 길이가 왜곡되 판정오류가 나기 때문임)
local function gvec_pg(self)

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
local function gvec_cc(circ, pgpts)
    
    local gpts, vecs = {}, {}

    -- 원의 중심점을 따로 저장한다
    local ccc = circ.__ccc
    local gx, gy = circ:getglobalxy(ccc[1], ccc[2])
    tins(gpts, gx)
    tins(gpts, gy)
    tins(gpts, ccc[3]) -- gpts[3]에는 반지름을 저장한다.

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
-- 2021/05/29 projection functions refactored
-------------------------------------------------------------------------------
-- 2021/05/09 법선벡터(vect)방향으로 점들(gpts1, gpts2)을 프로젝션한후
-- 두 투영선이 겹쳐지지 않으면 false를 바로 반환
local function proj_pg2pg(pg1, pg2)

    local gpts1, vecs1 = gvec_pg(pg1)
    local gpts2, vecs2 = gvec_pg(pg2)

    for _, vecs in ipairs{vecs1, vecs2} do

        for k=1,#vecs,2 do

            local vx, vy = vecs[k], vecs[k+1]
            local min1, max1, min2, max2 = INF, -INF, INF, -INF

            for i=1, #gpts1, 2 do
                local prj1 = vx*gpts1[i] + vy*gpts1[i+1] -- vx*px + vy*py
                -- i==1일때 아래 두 개의 if문이 모두 true이므로
                -- if~elseif로 구조를 잡으면 안된다.
                if min1>prj1 then min1 = prj1 end
                if max1<prj1 then max1 = prj1 end
            end

            for i=1, #gpts2, 2 do
                local prj2 = vx*gpts2[i] + vy*gpts2[i+1]
                -- i==1일때 아래 두 개의 if문이 모두 true이므로
                -- if~elseif로 구조를 잡으면 안된다.
                if min2>prj2 then  min2 = prj2 end
                if max2<prj2 then  max2 = prj2 end
            end


            -- 2021/05/28: 비충돌 조건을 아래와 같이 수정함
            if max1<min2 or max2<min1 then return false end

        end

    end
    
    return true

end

-- 2021/05/18 법선벡터(vecs)방향으로 점들(gpts, gcc)을 프로젝션한후
-- 두 투영선이 겹쳐지지 않으면 false를 바로 반환
-- gpt:폴리곤 꼭지점의 전역좌표들, gcc={cx,cy,r}: circle center의 전역좌표와 반지름
local function proj_pg2cc(pg, cc)

    local pgpts, pgvecs = gvec_pg(pg)
    local ccpt, ccvec = gvec_cc(cc, pgpts)

    for _, vecs in ipairs{pgvecs, ccvec} do

        for k = 1,#vecs,2 do

            local vx, vy = vecs[k], vecs[k+1]
            local min1, max1 = INF, -INF

            for i=1, #pgpts, 2 do
                local prj1 = vx*pgpts[i] + vy*pgpts[i+1] -- vx*px + vy*py
                if min1>prj1 then min1 = prj1 end
                if max1<prj1 then max1 = prj1 end
                -- print(prj1)
            end

            -- 원의 투영은 중심점을 투영한 값에서 반지름(r)을 더하고 빼면 된다.
            local prj2 = vx*ccpt[1] + vy*ccpt[2]
            local r = ccpt[3]
            local min2, max2 = prj2 - r, prj2 + r
            -- print(prj2)

            -- 2021/05/28: 비충돌 조건을 아래와 같이 수정함
            if max1<min2 or max2<min1 then return false end

        end
    
    end

    return true

end


--2021/05/08 : gpts는 apex의 전역좌표값들의 집합
-- gpts점들로 구성된 convex의 내부에 (gx,gy)가 포함된다면 true를 반환
local function proj_pg2pt(pg, pt)

    -- (1) pg 꼭지점들의 전역좌표를 구한다.
    local pts, gpts = pg.__cpg, {}
    for k=1, #pts, 3 do -- {x,y,len}이므로 3씩 증가시킨다
        local gxk, gyk = pg:getglobalxy(pts[k], pts[k+1])
        tins(gpts, gxk)
        tins(gpts, gyk)
    end

    --(2) pt의 전역좌표를 구한다
    local gx, gy = pt:getglobalxy(pt.__cpt[1], pt.__cpt[2])

    --(3) 내부여부 판단. 알고리듬은 아래 사이트 참조.
    -- https://demonstrations.wolfram.com/AnEfficientTestForAPointToBeInAConvexPolygon/
    local x0, y0 = gpts[1]-gx, gpts[2]-gy

    local x1, y1 = x0, y0
    local x2, y2 = gpts[3]-gx, gpts[4]-gy
    local sgn = x2*y1 > x1*y2 -- 첫 번째 부호를 구한다
    x1, y1 = x2, y2

    for k=5, #gpts, 2 do
        x2, y2 = gpts[k]-gx, gpts[k+1]-gy
        if (x2*y1 > x1*y2) ~= sgn  then return false end
        x1, y1 = x2, y2
    end

    x2, y2 = x0, y0
    
    --if (x2*y1 > x1*y2) ~= sgn  then  return false 
    --else return true end

    -- 2021/05/28: 아래와 같이 반환값을 더 간략히 변경
    return (x2*y1 > x1*y2) == sgn

end

local function proj_cc2cc(circ1, circ2)

    local c1, c2 = circ1.__ccc, circ2.__ccc

    local r12 = c1[3] + c2[3]
    local gcx1, gcy1 = circ1:getglobalxy(c1[1],c1[2])
    local gcx2, gcy2 = circ2:getglobalxy(c2[1],c2[2])
    local dx, dy = gcx1-gcx2, gcy1-gcy2
    return dx*dx+dy*dy <= r12*r12

end

local function proj_cc2pt(cc, pt)

    local r = cc.__ccc
    local gcx1, gcy1 = cc:getglobalxy()
    local gcx2, gcy2 = pt:getglobalxy(pt.__cpt[1], pt.__cpt[2])
    local dx, dy = gcx1-gcx2, gcy1-gcy2
    return dx*dx+dy*dy <= r*r

end

-------------------------------------------------------------------------------
-- 2021/05/09 폴리곤-폴리곤의 충돌판정 작성
-- 2021/05/18 폴리곤-원/원-폴리곤/원-원 들의 충돌판정 작성
-- 2021/05/28 유형별로 메서드를 분리하고 ishit()메서드네에서 자신을 오버라이딩함
-------------------------------------------------------------------------------
-- self가 폴리곤(사각형포함)인 경우의 ishit()메서드
-- function _luasopia.ishitpg(self, obj)
local function ishit_pg(self, obj)
    if obj.__cpg then return proj_pg2pg(self, obj)
    elseif obj.__ccc then return proj_pg2cc(self, obj)
    elseif obj.__cpt then return proj_pg2pt(self, obj)
    end
end

-- self가 원인 경우의 ishit()메서드
local function ishit_cc(self, obj)

    if obj.__ccc then return proj_cc2cc(self, obj)
    elseif obj.__cpg then return proj_pg2cc(obj, self)
    elseif obj.__cpt then return proj_cc2pt(self, obj)
    end
end

-- self가 점인 경우의 ishit()메서드
local function ishit_pt(self, obj)

    if obj.__cpg then return proj_pg2pt(obj, self)
    elseif obj.__ccc then return proj_cc2pt(obj, self)
    end

end

-- 2021/05/28 에 추가: 충돌판정 영역을 점으로 set한다
function Disp:sethitpoint(x,y)

    local x, y = x or 0, y or 0
    self.__cpg, self.__ccc, self.__cln = nil, nil, nil
    self.__cpt, self.ishit = {x,y}, ishit_pt
    return self

end
Disp.hitpoint = Disp.sethitpoint

function Disp:sethitcircle(r, x, y)

    self.__cpg, self.__cpt, self.__cln = nil, nil, nil
    self.__ccc, self.ishit = {x or 0, y or 0, r}, ishit_cc
    return self

end
Disp.hitcircle = Disp.sethitcircle

function Disp:ishit(obj)
    --[[
    ishit()메서드를 이전에 한 번도 호출하지 않았다면 이것이 실행된다.
    하지만 한 번이라도 실행된 이후에는 ishitpg/ishitcc 중 하나가 실행된다.
    이렇게 함으로써 Display.init() 생성자 내에서 사용을 안할 수도 있는
     ishit()메서드를 매 객체마다 정의해 주는 것을 피할 수 있다.
    (루아라서 ishit()메서드 내에서 자신을 오버라이딩할 수 있음)
    --]]

    if self.__cpg then
        self.ishit = ishit_pg -- ishit()메서드 overriding
        return ishit_pg(self, obj)
    elseif self.__ccc then
        self.ishit = ishit_cc -- ishit()메서드 overriding
        return ishit_cc(self, obj)
    elseif self.__cpt then
        self.inshit = ishit_pt
        return ishit_pt(self, obj)
    else
        return false
    end

end