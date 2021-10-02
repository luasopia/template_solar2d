-------------------------------------------------------------------------------
-- 2021/05/25 created
-------------------------------------------------------------------------------
local Disp = _luasopia.Display
local tins = table.insert
local INF, abs, sqrt = math.huge, math.abs, math.sqrt
local tdobj = Disp.__tdobj
-------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- 2021/05/09 분리축이론(SAT)를 이용한 충돌판정 구현
-- 객체의 모양은 다음과 같은 내부필드로 구분한다.
-- polygon  : __cpg = {x1,y1,1/len1, x2,y2,2/len2. ...}
--            여기서 1/lenk는 (xk_1, yk_1)->(xk, yk) 벡터의 길이의 역수
--            (dobule형의 곱셈보다 나눗셈이 시간이 더 걸리므로 역수를 미리 계산해둔다)
-- circle   : __ccc = r
-- point    : __cpt = {x, y}
-- line     : __cln = {x1,y1, x2,y2, len}, len은 선분의 길이
--------------------------------------------------------------------------------
-- 2021/05/09: 다각형 꼭지점의 전역좌표(gpts)와
-- 각 변의 *단위*법선벡터(vecs)를 계산
local function gvec_pg(self)

    local pts = self.__cpg
    local gpts, vecs = {}, {}

    -- 첫 번째 점을 따로 저장한다
    local gx1, gy1 = self:__getgxy__(pts[1], pts[2])
    local _1_len1 = pts[3] -- 이 점과 전 점간의 거리의 역수
    tins(gpts, gx1)
    tins(gpts, gy1)

    -- 점들을 순환하면서 단위벡터를 계산한다
    local gxk_1, gyk_1 = gx1, gy1  
    for k=4, #pts, 3 do -- {x,y,1/len}이므로 3씩 증가시킨다
        
        local gxk, gyk = self:__getgxy__(pts[k], pts[k+1])
        local _1_lenk = pts[k+2] -- 이 점과 전 점간의 거리의 역수
        tins(gpts, gxk)
        tins(gpts, gyk)
    
        -- vector (k_1)->(k) 의 (도형 바깥 방향)법선벡터를 계산하여 저장
        tins(vecs, (gyk-gyk_1)*_1_lenk ) -- vxk
        tins(vecs, (gxk_1-gxk)*_1_lenk ) -- vyk

        gxk_1, gyk_1 = gxk, gyk
    end
    tins(vecs, (gy1-gyk_1)*_1_len1) -- vxn
    tins(vecs, (gxk_1-gx1)*_1_len1) -- vyn

    return gpts, vecs
end


-- 2021/05/11: 원에 대해서 폴리곤을 고려한 벡터생성
-- 원의 중심과 가장 가까운 꼭지점을 잇는 벡터를 생성한다
local function gvec_circ(circ, pgpts)
    
    local gpts, vecs = {}, {}

    -- 원의 중심점을 따로 저장한다
    local gx, gy = circ:__getgxy__()
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

    -- 원의 중심점에서 꼭지점을 향하는 *단위*벡터를 저장
    local dx, dy = cx-gx, cy-gy
    local _1_len = 1/sqrt(dmin2)
    tins(vecs, dx*_1_len)
    tins(vecs, dy*_1_len)
    --print(vecs[7], vecs[8])

    return gpts, vecs
end

-------------------------------------------------------------------------------
-- projection functions
-------------------------------------------------------------------------------
-- 2021/05/09 법선벡터(vecs)방향으로 점들(gpts1, gpts2)을 프로젝션한후
-- 두 투영선이 겹쳐지지 않으면 false를 바로 반환. 모두 겹친다면 그중
-- overlap 길이가 가장 짧은 것의 법선벡터x겹친길이 벡터를 구한다.
-- obj2를 밀어내는 데 필요한 push벡터를 계산하여 반환
local function proj_pg2pg2(tvecs, gpts1, gpts2)

    local push = {}
    local minol = INF -- minimum overlap

    for _, vecs in pairs(tvecs) do

        for k=1,#vecs,2 do

            local vx, vy = vecs[k], vecs[k+1]
            local min1, max1, min2, max2 = INF, -INF, INF, -INF

            for i=1, #gpts1, 2 do
                local prj1 = vx*gpts1[i] + vy*gpts1[i+1] -- vx*px + vy*py
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

            
            if abs(c1-c2)>d1+d2 then
                return
            -- 가장 짧게 겹치는 길이와 그 방향벡터를 구한다
            else -- if abs(c1-c2)<=d1+d2 
                local overlap = (d1+d2)-abs(c1-c2) -- 항상 음이 아닌 값임
                if minol > overlap then
                    minol = overlap
                    push = {vx*overlap, vy*overlap}
                end
            end
        end
    end

    return push

end

-- 2021/05/18 법선벡터(vecs)방향으로 점들(gpts, gcc)을 프로젝션한후
-- 두 투영선이 겹쳐지지 않으면 false를 바로 반환
-- gpt:폴리곤 꼭지점의 전역좌표들, gcc={cx,cy,r}: circle center의 전역좌표와 반지름
local function proj_pg2cc2(vecs, pgpts, ccpt)

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
--2021/05/26 updpush()함수 작성
-- 이것을 Display:push() 메서드 내에서 __addupd__()메서드로 등록한다.
-------------------------------------------------------------------------------

local function updpush(self)

    for key, obj in pairs(self.__push) do --print(key)
        
        if obj.__bd==nil then -- if object had already removed

            self.__push[key] = nil --table.remove(self.__push, key) 
        
        else

            if self == obj then return end 
        
            --(1) 둘 다 폴리곤(Rect포함)일 경우
            if self.__cpg and obj.__cpg then

                -- 만약 hit 상태라면 밀어낼 벡터<pushx,pushy>를 구한다
                local gpts1, vecs1 = gvec_pg(self)
                local gpts2, vecs2 = gvec_pg(obj)

                local push = proj_pg2pg2({vecs1, vecs2}, gpts1, gpts2)

                if push then -- 겹친다면(push는 nil이 아니라 테이블)
                    
                    -- <self의 중심 -> obj의 중심>  방향의 벡터 계산
                    local x1, y1 = self:__getgxy__()
                    local x2, y2 = obj:__getgxy__()
                    local outerx, outery = x2-x1, y2-y1

                    local pushx, pushy = unpack(push)
                    -- <pushx, pushy>가 self의 바깥방향으로의 벡터라면 더한다
                    if (outerx*pushx+outery*pushy>=0) then
                        obj:xy(obj:getX()+pushx, obj:getY()+pushy)
                    else -- <pushx, pushy>가 self의 안쪽 방향으로의 벡터라면 뺀다.
                        obj:xy(obj:getX()-pushx, obj:getY()-pushy)
                    end

                end


            --(2b) 원(self)과 폴리곤(obj)일 경우
            elseif self.__ccc and obj.__cpg then

                local pgpts, pgvecs = gvec_pg(obj)
                local ccpt, ccvec = gvec_circ(self, pgpts)

                return proj_pg2cc(pgvecs, pgpts, ccpt) and proj_pg2cc(ccvec, pgpts, ccpt)

            --(2a) 폴리곤(Rect포함)과 원일 경우
            elseif self.__cpg and obj.__ccc then

                local pgpts, pgvecs = gvec_pg(self)
                local ccpt, ccvec = gvec_circ(obj, pgpts)
                return proj_pg2cc(pgvecs, pgpts, ccpt) and proj_pg2cc(ccvec, pgpts, ccpt)

            
            --(3) 둘 다 원일 경우
            elseif self.__ccc and obj.__ccc then
                -- print('ishit')
                local gcx1, gcy1 = self:__getgxy__()
                local gcx2, gcy2 = obj:__getgxy__()
                local dx, dy = gcx1-gcx2, gcy1-gcy2
                local len = sqrt(dx*dx+dy*dy)
                return len <= self.__ccc + obj.__ccc
            end
        end
    end
end

function Disp:push(obj)
    self.__push = self.__push or {}
    self.__push[obj] = obj

    -- updpush함수가 아직 등록이 안되어 있다면 등록한다.
    if not self.__iupds[updpush] then
        -- print('addpush')
        self.__iupds[updpush] = updpush
    end
    -- print(#self.__push, #self.__iupds)
end

function Disp:pushtag(name)
    
    self.__push = tdobj[name]

    -- updpush함수가 아직 등록이 안되어 있다면 등록한다.
    if not self.__iupds[updpush] then
        -- print('addpush')
        self.__iupds[updpush] = updpush
    end
    -- print(#self.__push, #self.__iupds)
end

-------------------------------------------------------------------------------
-- tag된 객체들끼리 서로 밀어내도록 하는 함수들
-------------------------------------------------------------------------------
local function updreact(self)

    for key, obj in pairs(self.__push) do --print(key)
        
        if obj.__bd==nil then -- if object had already removed

            self.__push[key] = nil --table.remove(self.__push, key) 
        
        else

            if self == obj then return end 
        
            --(1) 둘 다 폴리곤(Rect포함)일 경우
            if self.__cpg and obj.__cpg then

                -- 만약 hit 상태라면 밀어낼 벡터<pushx,pushy>를 구한다
                local gpts1, vecs1 = gvec_pg(self)
                local gpts2, vecs2 = gvec_pg(obj)

                local push = proj_pg2pg2({vecs1, vecs2}, gpts1, gpts2)

                if push then -- 겹친다면(push는 nil이 아니라 테이블)
                    
                    -- <self의 중심 -> obj의 중심>  방향의 벡터 계산
                    local x1, y1 = self:__getgxy__()
                    local x2, y2 = obj:__getgxy__()
                    local outerx, outery = x2-x1, y2-y1

                    local pushx, pushy = unpack(push)
                    -- <pushx, pushy>가 self의 바깥방향으로의 벡터라면 더한다
                    if (outerx*pushx+outery*pushy>=0) then
                        self:xy(self:getX()-pushx*0.5, self:getY()-pushy*0.5)
                        obj:xy(obj:getX()+pushx*0.5, obj:getY()+pushy*0.5)
                    else -- <pushx, pushy>가 self의 안쪽 방향으로의 벡터라면 뺀다.
                        self:xy(self:getX()+pushx*0.5, self:getY()+pushy*0.5)
                        obj:xy(obj:getX()-pushx*0.5, obj:getY()-pushy*0.5)
                    end

                end
            end
        end
    end

end

function Disp:react(name)

    self.__push = tdobj[name]

    -- updpush함수가 아직 등록이 안되어 있다면 등록한다.
    if not self.__iupds[updreact] then
        -- print('addpush')
        self.__iupds[updreact] = updreact
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
        local gx, gy = self:__getgxy__(pts1[k], pts1[k+1])
        tins(gpts1, gx)
        tins(gpts1, gy)
    end

    -- (2) obj의 각 꼭지점이 self안에 포함되는지 체크
    for k=1, #pts2, 2 do
        local gx2, gy2 = obj:__getgxy__(pts2[k], pts2[k+1])
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