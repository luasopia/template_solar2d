local tIn, tRm = table.insert, table.remove
local int = math.floor
--------------------------------------------------------------------------------
local linespace = 1.2 -- 줄간격을 0.3으로 설정(너무 붙으면 가독성이 떨어짐)
local botmargin = 20 -- gap from bottom and last line
local leftmargin = 10 
--------------------------------------------------------------------------------
local loglayer = _luasopia.loglayer
local txtobjs = {}

local lineHeight =  Text1.getfontsize0()*linespace

-- local maxlines = int(screen.height0 / lineHeight)
local maxlines = 20

local numlines = maxlines-3
local cursorY = screen.height0 + lineHeight - botmargin --lineHeight*maxlines


local logf = setmetatable({},{__call=function(_, str,...)

    local strf = string.format(str,...)
    local txtobj = Text1(strf):addto(loglayer)
    txtobj.__nocnt = true
    txtobj:setxy(leftmargin, cursorY)
    tIn(txtobjs, txtobj)
    cursorY = cursorY + lineHeight


    if cursorY > maxlines*lineHeight then

        for k=#txtobjs,1,-1 do

            local v = txtobjs[k]

            v:sety(v:gety()-lineHeight)

            if v:gety() < lineHeight*(maxlines-numlines) then

                tRm(txtobjs,k)
                v:remove()

            end

        end

        cursorY = cursorY - lineHeight

    end

    return txtobj

end})


logf.clear = function()

    for k=#txtobjs,1,-1 do local v = txtobjs[k]

        tRm(txtobjs,k)
        v:remove()

    end
    
    cursorY = 0

end


logf.setnumlines = function(n)

    if n == INF then numlines = maxlines
    else numlines = n end

end


-- logf.__getNumObjs = function() return #txtobjs end


return logf