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
local oktext0 = "Tap if OK"
--------------------------------------------------------------------------------
--[[
    alert('string')
    alert('string', opt)
    alert('string', func)
    alert('string', func, opt)
    
    1st and 2nd parameters of onok() is button object itwnd(btn)
        and event argument (table)

    opt = {
        oktext = string -- default:"Tap if OK"
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

    local oktext = opt.oktext or oktext0
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

    local txtok = Text(oktext, {
        fontsize = fontsize*0.7,
        color = Color.POWDER_BLUE
    }):addto(wnd):anchor(1,1)


    function frame:ontap(self)

        if popuptime > 0 then

            wnd:shift{
                time=popuptime*0.7,
                scale=0.1,
                onend = function()
                    wnd:remove()
                    wnd.onok()
                end
            }

        else
            wnd:remove()
            wnd.onok()
        end
        

    end
    
    -- 2021/06/04 opt의 width/height가 사용자에게 주어졌다면 그것을 사용하고
    -- 아니라면 text의 폭과 높이값을 고려한 계산치를 사용한다.
    local wdt = opt.width or (txt:getwidth()  + 2*sidemargin)
    local hgt = opt.height or (vertmargin*4 + txt:getheight() + fontsize)

    frame:width(wdt):height(hgt)
    txt:y(-fontsize)
    txtok:xy(wdt*0.5-fontsize*0.5,hgt*0.5-fontsize*0.5)

    if popuptime>0 then
        wnd:scale(0.01):shift{time=popuptime,scale=1}
    end

    return wnd

end