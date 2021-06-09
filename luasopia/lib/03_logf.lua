local tIn, tRm = table.insert, table.remove
local int = math.floor
--------------------------------------------------------------------------------
local txtobjs = {}
local linespace = 1.3 -- 줄간격을 0.3으로 설정(너무 붙으면 가독성이 떨어짐)
local yoff = 0 --; if _Gideros then yoff = 50 end
local numlines = 15
local leftmargin = 10
local loglayer = _luasopia.loglayer

--local function initlog()

--local txtobj = Text("logf() ready.", _luasopia.loglayer):anchor(0,0) --:xy(0,cursorY+yoff)
local txtobj = Text(""):anchor(0,1):addto(loglayer) --:xy(0,cursorY+yoff)
local fontSize =  txtobj:getfontsize()*linespace
local maxlines = int(screen.height / fontSize)
txtobj:xy(leftmargin, fontSize*(maxlines-1)+yoff) -- 맨 마지막줄부터 출력 시작
local cursorY = fontSize*maxlines
tIn(txtobjs, txtobj)
--print('maxlines:'..maxlines)
_luasopia.dcdobj = _luasopia.dcdobj + 1

--end

--initlog()

local logf = setmetatable({},{__call=function(_, str,...)

    local strf = string.format(str,...)
    local txtobj = Text(strf):anchor(0,1):addto(loglayer)
    txtobj:xy(leftmargin, cursorY+yoff)
    tIn(txtobjs, txtobj)
    cursorY = cursorY + fontSize
    _luasopia.dcdobj = _luasopia.dcdobj + 1

    if cursorY > maxlines*fontSize then
        for k=#txtobjs,1,-1 do local v = txtobjs[k]
            v:y(v:gety()-fontSize)
            if v:gety() < fontSize*(maxlines-numlines) then
                tRm(txtobjs,k)
                v:remove()
                _luasopia.dcdobj = _luasopia.dcdobj - 1
            end
        end
        cursorY = cursorY - fontSize
    end

    return txtobj
end})


logf.clear = function()
    for k=#txtobjs,1,-1 do local v = txtobjs[k]
        tRm(txtobjs,k)
        v:remove()
        _luasopia.dcdobj = _luasopia.dcdobj - 1
    end
    cursorY = 0
end

logf.setnumlines = function(n)
    if n == INF then numlines = maxlines
    else numlines = n end
end

logf.__getNumObjs = function() return #txtobjs end

return logf