--------------------------------------------------------------------------------
-- 2021/06/09: created
--------------------------------------------------------------------------------
-- default values
local strokewidthratio0 = 0.15 -- strokewidth == fontsize*strokewidthratio0
local fillcolor0 = Color.BLUE
local strokecolor0 = Color.ROYAL_BLUE
local fontsize0 = 50 -- the same as Text class default value
local textcolor0 = Color.WHITE
local nilfunc = function() end
--------------------------------------------------------------------------------
--[[
    alert('string')
    alert('string', opt)
    alert('string', func)
    alert('string', func, opt)
    
    1st and 2nd parameters of onok() is button object itwnd(btn)
        and event argument (table)

    opt = {
        buttontext = string -- default:"OK"
        fontsize = n,       -- default:50
        textcolor = color,  -- default: Color.WHITE
        bgcolor = color,       -- default: Color.GREEN
        strokecolor = color,-- default: Color.LIGHT_GREEN
        strokewidth = n,    -- in pixel, default:fontzise*0.15
        
        popuptime = n,      -- in millisecond (default:150)
        verticalmargin = n,
        sidemargin = n,
        
        width = n,
        height = n,
    }
--]]
--------------------------------------------------------------------------------
function alert(str, onok, opt)
    
    local wnd = Group()

    -- 2021/06/09 alert(str,fn), alert(str,fn,opt)
    if type(onok) == 'table' then
        opt = onok
        onok = nilfunc
    end
    wnd.onok = onok or nilfunc
    opt = opt or {}

    local buttontext = opt.buttontext or "OK"
    local fontsize = opt.fontsize or fontsize0
    local textcolor = opt.textcolor or textcolor0
    local fillcolor = opt.bgcolor or fillcolor0
    local strokecolor = opt.strokecolor or strokecolor0
    local strokewidth = opt.strokewidth or fontsize*strokewidthratio0

    local popuptime = opt.popuptime or 150
    local vertmargin = opt.verticalmargin or fontsize*0.7
    local sidemargin = opt.sidemargin or fontsize
    
    -- (1) background rect must be firsly generated
    local frame = Rect(3,3,{
        fill = fillcolor,
        fill = fillcolor,
        strokecolor = strokecolor,
        strokewidth = strokewidth,
    }):addto(wnd)

    -- (2) then, text object
    local txt = Text(str,{
        fontsize=fontsize,
        color=textcolor,
    }):addto(wnd)


    local function onpush(thisbtn, e)

        if popuptime > 0 then 
            wnd:timer(popuptime, function() wnd:remove() end)
        else
            wnd:remove()
        end
        wnd.onok()

    end

    
    local btn = Button(buttontext, onpush, {
        fontsize=fontsize,
    }):addto(wnd)
    
    -- 2021/06/04 opt의 width/height가 사용자에게 주어졌다면 그것을 사용하고
    -- 아니라면 text의 폭과 높이값을 고려한 계산치를 사용한다.
    local btnhgt = btn:getheight()
    local wdt = opt.width or (txt:getwidth()  + 2*sidemargin)
    local hgt = opt.height or (vertmargin*4 + txt:getheight() + btnhgt)

    frame:width(wdt):height(hgt)
    txt:anchor(0.5, 0):y(-hgt*0.5 + vertmargin)
    btn:y(hgt*0.5-btnhgt*0.5-vertmargin)
    
    if popuptime>0 then
        wnd:scale(0.01):shift{time=popuptime,scale=1}
    end

    wnd.button = btn -- 외부에서 button을 수정할 수 있도록 한다.
    return wnd

end