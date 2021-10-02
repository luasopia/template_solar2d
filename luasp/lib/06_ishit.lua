--------------------------------------------------------------------------------
-- 2021/05/08: created
-- 2021/05/09 분리축이론(SAT)를 이용한 충돌판정 구현
-- 2021/08/23:점간 거리를 실시간으로 계산하기로. (cpg에서 거리정보는 뺀다)
-- 2021/08/24:ishit는 두 프레임에 한 번씩만(30fps로) 검사하기로
--------------------------------------------------------------------------------
local luasp = _luasopia
local Disp = luasp.Display
local tins = table.insert
local inf, sqrt, min = math.huge, math.sqrt, math.min
local RED = Color.RED
local _nxt = next
--------------------------------------------------------------------------------
-- 객체의 모양은 다음과 같은 내부필드로 구분한다.
-- polygon  : __cpg = {x1,y1,  x2,y2,  x3,y3, ...} 꼭지점들의 좌표
-- circle   : __ccc = {x, y, r, r2, r0} -- (x,y)중심점 좌표, r2=r^2
-- point    : __cpt = {x, y}

-- line     : __cln = {x1,y1, x2,y2, len}, len은 선분의 길이
--------------------------------------------------------------------------------

-- (x1,y1)~(x2,y2) 간 거리의 역수를 구하는 함수
local function dist(x1,y1, x2,y2)

    local dx, dy = x1-x2, y1-y2
    return sqrt(dx*dx+dy*dy)

end


local function dist2(x1,y1, x2,y2)

    local dx, dy = x1-x2, y1-y2
    local d1 = dx*dx+dy*dy
    return sqrt(d1), d1

end


-- 2021/05/09: 꼭지점의 전역좌표(gpts)와 각 변의 단위법선벡터(vecs)를 계산
-- 2021/05/25: 충돌판정만 할 경우라도 반드시 *단위*법선벡터를 만들어야 한다.
-- (왜나면 원의 중심을 프로젝션할 때 반지름의 길이가 왜곡돼 판정오류가 나기 때문임)
-- 2021/08/23: 점간 거리는 실시간으로 구하기로
-- 만약 객체 a가 그룹g에 들어가 있고 g의 스케일이 변했다면 a객체의 스케일 정보만으로
-- 점간 거리를 구하는 것이 불가능하다. 따라서 점간 거리는 전역좌표를 이용해서 
-- 반드시 실시간으로 구해야 한다.
local function gvec_pg(self)

    local pts = self.__cpg
    local gpts, vecs = {}, {}

    -- 첫 번째 점을 따로 저장한다
    local gx1, gy1 = self:__getgxy__(pts[1], pts[2])
    -- local len1 = pts[3] -- 이 점과 전 점간의 거리의 역수
    gpts[1]=gx1 -- tins(gpts, gx1)
    gpts[2]=gy1 -- tins(gpts, gy1)

    -- 점들을 순환하면서 단위벡터를 계산한다
    local gxk_1, gyk_1 = gx1, gy1  
    for k=3, #pts, 2 do -- {x,y,len}이므로 3씩 증가시킨다
        
        local gxk, gyk = self:__getgxy__(pts[k], pts[k+1])
        local lenk = dist(gxk,gyk,  gxk_1,gyk_1) --pts[k+2] -- 이 점과 전 점간의 거리의 역수
        gpts[k] = gxk --  tins(gpts, gxk)
        gpts[k+1]= gyk -- tins(gpts, gyk)
    
        -- vector (k_1)->(k) 의 (도형 바깥 방향)법선벡터를 계산하여 저장
        tins(vecs, (gyk-gyk_1)/lenk ) -- vxk
        tins(vecs, (gxk_1-gxk)/lenk ) -- vyk
        --print(vxk, vyk)

        gxk_1, gyk_1 = gxk, gyk
    end

    local len = dist(gx1,gy1,  gxk_1,gyk_1)
    tins(vecs, (gy1-gyk_1)/len) -- vxn
    tins(vecs, (gxk_1-gx1)/len) -- vyn
    --print(vecs[7], vecs[8])

    return gpts, vecs

end


-- 2021/05/11: 원에 대해서 폴리곤을 고려한 단위벡터 생성
-- 원의 중심과 가장 가까운 꼭지점을 잇는 벡터를 생성한다
local function gvec_cc(circ, pgpts)
    
    local gpts, vecs = {}, {}

    -- 원의 중심점을 따로 저장한다
    local ccc = circ.__ccc
    local gx, gy = circ:__getgxy__(ccc.x, ccc.y)
    tins(gpts, gx)
    tins(gpts, gy)

    ----------------------------------------------------------------------
    --[[
    --2021/08/24:반지름도 실시간 계산하는 방식으로 변경
    local gx1, gy1 = circ:__getgxy__(ccc.x+ccc.r0, ccc.y)
    local gx2, gy2 = circ:__getgxy__(ccc.x, ccc.y+ccc.r0)
    local rx, rx2 = dist2(gx,gy,  gx1,gy1)
    local ry, ry2 = dist2(gx,gy,  gx2,gy2)
    local minr, minr2 = min(rx,ry),  min(rx2,ry2)
    ccc.r, ccc.r2 = minr, minr2
    tins(gpts, minr) -- gpts[3]에는 반지름을 저장한다.
    --]]
    tins(gpts, ccc.r) -- gpts[3]에는 반지름을 저장한다.
    ----------------------------------------------------------------------

    -- 원의 중심점에서 가장 가까운 꼭지점을 찾는다
    local cx, cy
    local dmin2 = inf
    for k=1, #pgpts, 2 do
        local px, py = pgpts[k], pgpts[k+1]
        local dx, dy = px-gx, py-gy
        local d = dx*dx + dy*dy
        if d<dmin2 then
            dmin2 = d
            cx, cy = px, py
        end
    end

    -- 원의 중심점에서 가장가까운 꼭지점을 향하는 벡터를 저장
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
            local min1, max1, min2, max2 = inf, -inf, inf, -inf

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
            local min1, max1 = inf, -inf

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
-- 점이 폴리곤 내부에 있는지 여부를 판단하는 알고리듬은 아래 사이트 참조.
-- https://demonstrations.wolfram.com/AnEfficientTestForAPointToBeInAConvexPolygon/
local function proj_pg2pt(pg, pt)

    -- (1) pg 꼭지점들의 전역좌표를 구한다.
    local pts, gpts = pg.__cpg, {}
    for k=1, #pts, 2 do -- 2021/08/23:{x,y}이므로 2씩 증가시킨다
        local gxk, gyk = pg:__getgxy__(pts[k], pts[k+1])
        tins(gpts, gxk)
        tins(gpts, gyk)
    end

    --(2) pt의 전역좌표를 구한다
    local gx, gy = pt:__getgxy__(pt.__cpt.x, pt.__cpt.y)

    --(3) 내부여부 판단
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

    local cc1, cc2 = circ1.__ccc, circ2.__ccc -- {r,x,y} circle table

    local r12 = cc1.r + cc2.r
    local gcx1, gcy1 = circ1:__getgxy__(cc1.x,cc1.y)
    local gcx2, gcy2 = circ2:__getgxy__(cc2.x,cc2.y)
    local dx, dy = gcx1-gcx2, gcy1-gcy2
    return dx*dx+dy*dy <= r12*r12

end


local function proj_cc2pt(circ, point)

    local ccc = circ.__ccc -- {r,x,y} circle table
    local cpt = point.__cpt -- {x,y} point table
    local gcx1, gcy1 = circ:__getgxy__(ccc.x, ccc.y)
    local gcx2, gcy2 = point:__getgxy__(cpt.x, cpt.y)
    local dx, dy = gcx1-gcx2, gcy1-gcy2
    return dx*dx+dy*dy <= ccc.r2

end

-------------------------------------------------------------------------------
-- 2021/05/09 폴리곤-폴리곤의 충돌판정 작성
-- 2021/05/18 폴리곤-원/원-폴리곤/원-원 들의 충돌판정 작성
-- 2021/05/28 유형별로 메서드를 분리하고 isHit()메서드 내에서 자신을 오버라이딩
-------------------------------------------------------------------------------

-- self가 폴리곤(사각형포함)인 경우의 isHit()메서드
local function ishit_pg(self, obj)

    if self.__nohit  then return end

    if obj.__cpg then return proj_pg2pg(self, obj)
    elseif obj.__ccc then return proj_pg2cc(self, obj)
    elseif obj.__cpt then return proj_pg2pt(self, obj)
    end
    
end


-- self가 원인 경우의 isHit()메서드
local function ishit_cc(self, obj)

    if self.__nohit then return end

    if obj.__ccc then return proj_cc2cc(self, obj)
    elseif obj.__cpg then return proj_pg2cc(obj, self)
    elseif obj.__cpt then return proj_cc2pt(self, obj)
    end
end


-- self가 점인 경우의 isHit()메서드
local function ishit_pt(self, obj)

    if self.__nohit then return end

    if obj.__cpg then return proj_pg2pt(obj, self)
    elseif obj.__ccc then return proj_cc2pt(obj, self)
    end

end

--------------------------------------------------------------------------------
-- external user mehtods
--------------------------------------------------------------------------------

-- 2021/05/28 에 추가: 충돌판정 영역을 점으로 set한다
function Disp:setHitPoint(x,y)

    self.__cpg, self.__ccc, self.__cln = nil, nil, nil
    self.__cpt = {x=x or 0, y=y or 0}
    self.isHit = ishit_pt
    return self

end


--2021/08/20:scale이 변할때마다 ccc.r, ccc.r2값은 변경시켜야 한다.
-- 그래서 처음부터 ccc0 (원정보)는 보관해 두어야 한다.
function Disp:setHitCircle(r, x, y)

    self.__cpg, self.__cpt, self.__cln = nil, nil, nil
    
    -- r2는 점과 원의 충돌판정할 때 사용된다.
    -- r0는 원값이고 변하지 않는다. x/yscale이 변할 때 r값 재계산에 사용된다.
    self.__ccc = {r=r, x=x or 0, y=y or 0,r2=r*r, r0=r}

    self.isHit = ishit_cc
    return self

end


function Disp:isHit(obj)
    --[[
    isHit()메서드를 이전에 한 번도 호출하지 않았다면 이것이 실행된다.
    하지만 한 번이라도 실행된 이후에는 ishit_pg/ishit_cc/ishit_pt 중 하나가 실행된다.
    이렇게 함으로써 Display.init() 생성자 내에서 사용을 안할 수도 있는
     isHit()메서드를 매 객체마다 정의해 주는 것을 피할 수 있다.
    (루아라서 isHit()메서드 내에서 자신을 오버라이딩할 수 있음)
    --]]

    if self.__cpg then

        self.isHit = ishit_pg -- isHit()메서드 overriding
        return ishit_pg(self, obj)

    elseif self.__ccc then

        self.isHit = ishit_cc -- isHit()메서드 overriding
        return ishit_cc(self, obj)

    elseif self.__cpt then

        self.inshit = ishit_pt
        return ishit_pt(self, obj)

    else

        return false

    end

end


--2021/08/24: 작성. tag가 붙은 모든 객체와 isHit()체크를 해서
--충돌판정난 것을 모아서 테이블로 반환
function Disp:collectHit(tag)

    if self.__nohit then return end

    local allt = Disp.__tdobj[tag] -- Display Tagged OBJect
    if allt==nil then return end

    local hit = {}

    for _, obj in _nxt, allt do

        if self:isHit(obj) then -- isHit()메서드 내에서 __nohit 플래그를 검사한다
            tins(hit, obj)
        end

    end

    if #hit==0 then return end
    return hit

end


function Disp:noHit()

    self.__nohit = true
    return self
    
end