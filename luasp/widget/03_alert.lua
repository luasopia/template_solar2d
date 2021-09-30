--------------------------------------------------------------------------------
-- 2021/06/09: created
--------------------------------------------------------------------------------
-- default values
local strokewidthratio0 = 0.15 -- strokeWidth == fontSize*strokewidthratio0
local fillcolor0 = Color.BLUE
local strokecolor0 = Color.ROYAL_BLUE
local fontsize0 = 50 -- the same as Text class default value
local textcolor0 = Color.WHITE
local nilfunc = function() end
local oktext0 = "Tap if OK"
local popuptime0 = 100
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
        fontSize = n,       -- default:50
        textColor = color,  -- default: Color.WHITE
        bgColor = color,       -- default: Color.GREEN
        strokeColor = color,-- default: Color.LIGHT_GREEN
        strokeWidth = n,    -- in pixel, default:fontzise*0.15
        
        popupTime = n,      -- in millisecond (default:150)
        verticalMargin = n,
        sideMargin = n,
        
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
    local fontSize = opt.fontSize or fontsize0
    local textColor = opt.textColor or textcolor0
    local fillcolor = opt.bgColor or fillcolor0
    local strokeColor = opt.strokeColor or strokecolor0
    local strokeWidth = opt.strokeWidth or fontSize*strokewidthratio0

    local popupTime = opt.popupTime or  popuptime0
    local vertmargin = opt.verticalMargin or fontSize*0.7
    local sideMargin = opt.sideMargin or fontSize
    
    -- (1) background rect must be firsly generated
    local frame = Rect(3,3,{
        fill = fillcolor,
        fill = fillcolor,
        strokeColor = strokeColor,
        strokeWidth = strokeWidth,
    }):addTo(wnd)

    -- (2) then, text object
    local txt = Text(str,{
        fontSize=fontSize,
        color=textColor,
    }):addTo(wnd)

    local txtok = Text(oktext, {
        fontSize = fontSize*0.7,
        color = Color.POWDER_BLUE
    }):addTo(wnd):setAnchor(1,1)


    function frame:onTap(self)

        if popupTime > 0 then

            wnd:shift{
                time=popupTime*0.7,
                scale=0.1,
                onEnd = function()
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
    local wdt = opt.width or (txt:getWidth()  + 2*sideMargin)
    local hgt = opt.height or (vertmargin*4 + txt:getHeight() + fontSize)

    frame:setWidth(wdt):setHeight(hgt)
    txt:setY(-fontSize)
    txtok:setXY(wdt*0.5-fontSize*0.5,hgt*0.5-fontSize*0.5)

    if popupTime>0 then
        wnd:setScale(0.01):shift{time=popupTime,scale=1}
    end

    return wnd

end