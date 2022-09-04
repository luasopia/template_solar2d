----------------------------------------------------------------------------------
----------------------------------------------------------------------------------
-- lib for shift{} method
-- 2021/08/10 shift 메서드를 __iupd 테이블에 추가/삭제하는 방식으로 변경
----------------------------------------------------------------------------------
local tmgapf = 1000/_luasopia.fps
local int = math.floor
local Disp = _luasopia.Display
----------------------------------------------------------------------------------
-- shift테이블에 여러 지점을 등록할 수 있다.
-- tr = {time=ms, x=n, y=n, rot=n,...
--		loops(=1), -- 반복 회수, INF이면 무한반복
--		onEnd = function(self) ... end, --모든 tr이 종료될 때 실행되는 함수
--		{time(필수), x, y, rot, scaleX, scaleY, scale, alpha},
--		{time(필수), x, y, rot, scaleX, scaleY, scale, alpha},
--		...
-- } 
----------------------------------------------------------------------------------

-- 이 함수가 반환하는 tr테이블은 미리 계산될 수가 없다.
-- 현재의 위치를 참조하여 계산되기 때문이다.
local function calcTr(self, sh)

    local tr = {}
    local fc = int(sh.time/tmgapf)+1
    tr.endcnt = fc -- final count
    tr.framecnt = 0

    if sh.x then       tr.dx  = (sh.x      - self.__bdx)/fc end
    if sh.y then       tr.dy  = (sh.y      - self.__bdy)/fc end
    if sh.rot then     tr.dr  = (sh.rot    - self.__bdrd)/fc end
    if sh.scale then   tr.ds  = (sh.scale  - self.__bds)/fc end
    if sh.alpha then   tr.da  = (sh.alpha  - self.__bda)/fc end
    if sh.scaleX then  tr.dxs = (sh.scaleX - self.__bdxs)/fc end
    if sh.scaleY then  tr.dys = (sh.scaleY - self.__bdys)/fc end

    tr.dest = sh
    tr.__to = sh.__to
    tr.__to1 = sh.__to1

    return tr

end


local shift 


-- 2021/08/11:shift를 완전히 종료시키는 함수
-- 2022/08/30: shift()함수 밖으로 빼냄
local function endShift(self)

    self.__tr = nil
    self:__rmUpd__(shift)
    -- onEnd()함수가 있다면 그것을 실행시키고 종료
    -- return self.__sh.onEnd and (self.__sh.onEnd(self) and nil) --(1)
    if self.__sh.onEnd then
        self.__sh.onEnd(self)
    end

end


-- 2021/08/10: 내부업데이트 테이블에 추가할 지역함수
shift = function(self) -- tr == self.__trInfo

    local tr = self.__tr
    if tr==nil then return end

    tr.framecnt = tr.framecnt + 1
    if tr.framecnt == tr.endcnt then

        self:set(tr.dest) -- 정확하게 지정된 위치로 set

        if tr.__to1 then -- tr.__to1 이 있다는 것은 마지막 위치테이블이라는 의미

            -- loops에 저장된 횟수만큼 반복이 끝나면 tr 종료
            self.__trloopcnt = self.__trloopcnt + 1
            if self.__sh.loops == self.__trloopcnt then
                return endShift(self)
            end

            -- 그렇지 않다면 처음부터 다시 반복
            self.__tr = calcTr(self, tr.__to1)
        
        elseif tr.__to then -- 마지막은 아니고 그 다음 위치테이블이 있는 경우

            self.__tr = calcTr(self, tr.__to)

        else -- 단독테이블인 경우

            return endShift(self)

        end
    
    else

        if tr.dx  then self:setX(     self.__bdx  + tr.dx) end
        if tr.dy  then self:setY(     self.__bdy  + tr.dy) end
        if tr.dr  then self:setRot(   self.__bdrd + tr.dr) end
        if tr.ds  then self:setScale( self.__bds  + tr.ds) end
        if tr.dxs then self:setScaleX(self.__bdxs + tr.dxs) end
        if tr.dys then self:setScaleY(self.__bdys + tr.dys) end
        if tr.da  then self:setAlpha( self.__bda  + tr.da) end
    
    end

end


local function makeTr(self, sh)

    sh.loops = sh.loops or 1
    self.__trloopcnt = 0 --SHiftLooPCouNT

    local tr, lastk = nil, 0

    if sh.time then
        sh.__to = sh[1] -- sh[1]==nil 이라면 종료
        tr = calcTr(self, sh)
    end

    for k, v in ipairs(sh) do
        v.__to = sh[k+1]
        if k==1 and tr==nil then -- k==1 and sh.time==nil
            tr = calcTr(self, v)
        end
        lastk = k
    end
    --print('lastk:'..tostring(lastk))
    if lastk>1 then sh[lastk].__to1 = sh[1] end

    return tr

end


-- 외부 사용자 함수
-- 2021/08/10:self.__tr 테이블을 생성 -> shift함수를 내부업데이트 테이블에 등록
function Disp:shift(sh)

    self.__sh = sh
    self.__tr = makeTr(self, sh)
    self:__addUpd__(shift)

    return self

end

function Disp:stopShift()

    self.__sh = nil
    self.__tr=nil
    self.__rmUpd__(shift)
    return self
    
end


function Disp:pauseShift()

    self.__rmUpd__(shift)
    return self
    
end


function Disp:resumeShift()

    self:__addUpd__(shift)
    return self
    
end