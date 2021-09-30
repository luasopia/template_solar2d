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
--------------------------------------------------------------------------------
--[[
    alert('string')
    alert('string', opt)
    alert('string', func)
    alert('string', func, opt)
    
    1st and 2nd parameters of onok() is button object itwnd(btn)
        and event argument (table)

    opt = {
        buttonText = string -- default:"OK"
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

    local buttonText = opt.buttonText or "OK"
    local fontSize = opt.fontSize or fontsize0
    local textColor = opt.textColor or textcolor0
    local fillcolor = opt.bgColor or fillcolor0
    local strokeColor = opt.strokeColor or strokecolor0
    local strokeWidth = opt.strokeWidth or fontSize*strokewidthratio0

    local popupTime = opt.popupTime or 150
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


    local function onPush(thisbtn, e)

        if popupTime > 0 then 
            wnd:addTimer(popupTime, function() wnd:remove() end)
        else
            wnd:remove()
        end
        wnd.onok()

    end

    
    local btn = Button(buttonText, onPush, {
        fontSize=fontSize,
    }):addTo(wnd)
    
    -- 2021/06/04 opt의 width/height가 사용자에게 주어졌다면 그것을 사용하고
    -- 아니라면 text의 폭과 높이값을 고려한 계산치를 사용한다.
    local btnhgt = btn:getHeight()
    local wdt = opt.width or (txt:getWidth()  + 2*sideMargin)
    local hgt = opt.height or (vertmargin*4 + txt:getHeight() + btnhgt)

    frame:width(wdt):height(hgt)
    txt:anchor(0.5, 0):y(-hgt*0.5 + vertmargin)
    btn:y(hgt*0.5-btnhgt*0.5-vertmargin)
    
    if popupTime>0 then
        wnd:setScale(0.01):shift{time=popupTime,scale=1}
    end

    wnd.button = btn -- 외부에서 button을 수정할 수 있도록 한다.
    return wnd

end