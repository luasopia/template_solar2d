local luasp = _luasopia
local toolbar = luasp.btoolbar -- 툴바(그룹 객체)
-- luasp.pxgrid -- 픽셀그리드
-- luasp.pxcolor -- 팔레트에서 현재 선택된 색상
-- luasp.pxartset -- 픽셀아트들(모음)
-- luasp.pxshts -- 




--------------------------------------------------------------------------------
local scene = Scene()
--------------------------------------------------------------------------------


local function mk_palette_grid()


end




function scene:create(stage)

    Text('builder pixel sprite')

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

    _require0('luasputil.builderpxs.paletgrid')
    _require0('luasputil.builderpxs.pxart')
    _require0('luasputil.builderpxs.pxgrid')

end


function scene:afterhide(stage) end

return scene