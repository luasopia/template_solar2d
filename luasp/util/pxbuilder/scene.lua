--------------------------------------------------------------------------------
local scene = Scene() --<= 가장 위에 있어야 아래의 객체가 이 scene에 포함된다
--------------------------------------------------------------------------------


local luasp = _luasopia
-- luasp.pxbuilder.files
-- luasp.pxbuilder.pxgrid -- 픽셀그리드
-- luasp.pxbuilder.idColor -- 팔레트에서 현재 선택된 색상의 인덱스
-- luasp.pxbuilder.arts -- 픽셀아트들(모음)
-- luasp.pxbuilder.sheets -- 


luasp.pxbuilder = {}


local toolbarfillc = Color(4,85,138)
local toolbarheight = 80


local toolbar = Group():setxy(0,0)
toolbar.__nocnt = true
toolbar.height = toolbarheight
toolbar.bg = Rect(screen.width0, toolbarheight):setanchor(0,0):addto(toolbar)
toolbar.bg:fill(toolbarfillc)


local btnsave = Button("save",{height=50,strokewidth=3}):addto(toolbar):setxy(200,40)
--[[
function btnsave:onpush() 

    local str='return {\n'

    for k, pxsht in ipairs(luasp.pxshts) do

        str = str .. string.format('[%d]={\n',k)

        for _, row in ipairs(pxsht) do

            str = str .. '        {'

            for _,col in ipairs(row) do
                str = str .. tostring(col) .. ', '
            end

            str = str .. '},\n'
        end
        str = str .. string.format('      },\n',k)
    end
    str = str..'}'
    _print0(str)
    luasp.savefile('test(pxs).lua',str)
end
--]]



--[[

function scene:aftershow(stage)

    stage:add(toolbar) -- 툴바를 이 scene에 표시
    
    luasp.pxshts={
        {
            {0,0,8,0,0,0,0,0,8,0,0},
            {0,0,0,8,0,0,0,8,0,0,0},
            {0,0,8,8,8,8,8,8,8,0,0},
            {0,8,8,0,8,8,8,0,8,8,0},
            {8,8,8,8,8,8,8,8,8,8,8},
            {8,0,8,8,8,8,8,8,8,0,8},
            {8,0,8,0,0,0,0,0,8,0,8},
            {0,0,0,8,8,0,8,8,0,0,0},
            width=11,
            height=8,
        },
        {
            {0,0,8,0,0,0,0,0,8,0,0},
            {8,0,0,8,0,0,0,8,0,0,8},
            {8,0,8,8,8,8,8,8,8,0,8},
            {8,8,8,0,8,8,8,0,8,8,8},
            {0,8,8,8,8,8,8,8,8,8,0},
            {0,0,8,8,8,8,8,8,8,0,0},
            {0,0,0,8,0,0,0,8,0,0,0},
            {0,0,8,0,0,0,0,0,8,0,0},
            width=11,
            height=8,
        }
    }

    _require0('luasp.util.builderpxs.paletgrid')
    _require0('luasp.util.builderpxs.pxgrid')
    _require0('luasp.util.builderpxs.pxartset')

end


function scene:afterhide(stage) end

--]]

return scene