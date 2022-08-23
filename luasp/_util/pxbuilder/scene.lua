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


local toolbar = Group():setXY(0,0)
toolbar.height = toolbarheight
toolbar.bg = Rect(screen.width0, toolbarheight):setAnchor(0,0):addTo(toolbar)
toolbar.bg:fill(toolbarfillc)


local btnSave = Button("save",{height=50,strokeWidth=3,fontSize=40}):addTo(toolbar):setXY(200,40)

--[[
function btnSave:onPush() 

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
    print(str)
    luasp.savefile('test(pxs).lua',str)
end
--]]


local btnNewFile = Button("new file",{height=50,strokeWidth=3,fontSize=40}):addTo(toolbar):setXY(400,40)


--------------------------------------------------------------------------------
-- luasp.pxbuilder.toolbar = toolbar
luasp.pxbuilder.fileset = _require0('luasp._util.pxbuilder.fileset')
luasp.pxbuilder.pxartset = _require0('luasp._util.pxbuilder.pxartset')

-- --[[

function scene:aftershow(stage)

    -- fileset:findfiles()

    -- _require0('luasp._util.builderpxs.paletgrid')
    -- _require0('luasp._util.builderpxs.pxgrid')
    -- _require0('luasp._util.builderpxs.pxartset')

end


function scene:afterhide(stage) end

--]]

return scene