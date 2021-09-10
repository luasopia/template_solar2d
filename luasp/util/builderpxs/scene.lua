local luasp = _luasopia
local toolbar = luasp.btoolbar -- 툴바(그룹 객체)
-- luasp.pxgrid -- 픽셀그리드
-- luasp.pxidcolor -- 팔레트에서 현재 선택된 색상의 인덱스
-- luasp.pxartset -- 픽셀아트들(모음)
-- luasp.pxshts -- 




--------------------------------------------------------------------------------
local scene = Scene()
--------------------------------------------------------------------------------


local btnsave = Button("SAVE"):setxy(950,300)
function btnsave:onpush() 

    local str='return _luasopia._getpxs0{\n'

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
    luasp.savefile('testpxs.lua',str)
end



function scene:create(stage)

    --Text('builder pixel sprite')

    

end

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

return scene