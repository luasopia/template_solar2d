----------------------------------------------------------------------------------
----------------------------------------------------------------------------------
-- lib for shift{} method
-- 2021/08/10 shift 메서드를 __iupd 테이블에 추가/삭제하는 방식으로 변경
----------------------------------------------------------------------------------
local tmgapf = 1000/_luasopia.fps
local int = math.floor
----------------------------------------------------------------------------------
-- shift테이블에 여러 지점을 등록할 수 있다.
-- tr = {time=ms, x=n, y=n, rot=n,...
--		loops(=1), -- 반복 회수, INF이면 무한반복
--		onend = function(self) ... end, --모든 tr이 종료될 때 실행되는 함수
--		{time(필수), x, y, rot, xscale, yscale, scale, alpha},
--		{time(필수), x, y, rot, xscale, yscale, scale, alpha},
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
    if sh.x then tr.dx = (sh.x-self:getx())/fc end
    if sh.y then tr.dy = (sh.y-self:gety())/fc end
    if sh.rot then tr.dr = (sh.rot-self:getrot())/fc end
    if sh.scale then tr.ds = (sh.scale-self:getscale())/fc end
    if sh.alpha then tr.da = (sh.alpha-self:getalpha())/fc end

    local xs = sh.xscale
    if xs then tr.dxs = (xs-self:getxscale())/fc end

    local ys = sh.yscale
    if ys then tr.dys = (ys-self:getyscale())/fc end

    tr.dest = sh
    tr.__to = sh.__to
    tr.__to1 = sh.__to1
    return tr

end


-- 2021/08/10: self.__iupds 테이블에 추가할 지역함수
local function shift(self) -- tr == self.__trInfo

    -- 2021/08/11:shift를 완전히 종료시키는 함수
    local endshift = function()
        self.__tr = nil
        self.__iupds[shift] = nil --return self:__rmupd__(shift)
        -- onend()함수가 있다면 그것을 실행시키고 종료
        -- onend()가 혹시 nil이 아니더라도 확실하게 nil을 반환
        return self.__sh.onend and (self.__sh.onend(self) and nil) --(1)
    end

    local tr = self.__tr
    tr.framecnt = tr.framecnt + 1
    if tr.framecnt == tr.endcnt then

        self:set(tr.dest) -- 정확하게 지정된 위치로 set

        if tr.__to1 then -- tr.__to1 이 있다는 것은 마지막 위치테이블이라는 의미

            -- loops에 저장된 횟수만큼 반복이 끝나면 tr 종료
            self.__sh.__loopcnt = self.__sh.__loopcnt + 1
            if self.__sh.loops == self.__sh.__loopcnt then
                return endshift()
            end

            -- 그렇지 않다면 처음부터 다시 반복
            self.__tr = calcTr(self, tr.__to1)
        
        elseif tr.__to then -- 마지막은 아니고 그 다음 위치테이블이 있는 경우

            self.__tr = calcTr(self, tr.__to)

        else -- 단독테이블인 경우

            return endshift()

        end
    
    else

        if tr.dx then self:x(self:getx()+tr.dx) end
        if tr.dy then self:y(self:gety()+tr.dy) end
        if tr.dr then self:rot(self:getrot()+tr.dr) end
        if tr.ds then self:scale(self:getscale()+tr.ds) end
        if tr.dxs then self:xscale(self:getxscale()+tr.dxs) end
        if tr.dys then self:yscale(self:getyscale()+tr.dys) end
        if tr.da then self:alpha(self:getalpha()+tr.da) end
    
    end

end


local function makeTr(self, sh)

    sh.loops = sh.loops or 1
    sh.__loopcnt = 0

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
-- 2021/08/10:self.__tr 테이블을 생성 -> shift함수를 __iupds 테이블에 등록
function Display:shift(sh)

    self.__sh = sh
    self.__tr = makeTr(self, sh)
    self.__iupds[shift] = shift --  self:__addupd__(shift)

    return self

end

function Display:stopshift()

    self.__tr=nil
    return self
    
end