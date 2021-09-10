local luasp = _luasopia


local toolbarfillc = Color(4,85,138)
local toolbarheight = 140

-- local ps=getpixels('0GG00GG0:0GGGGGG0:0G0GG0G0:0GGGGGG0:00GGGG00:00G00G00')
local ps=luasp._getpxs0{
    {
        {0,12,12,0,0,12,12,0},
        {0,12,12,12,12,12,12,0},
        {0,12,0,12,12,0,12,0},
        {0,12,12,12,12,12,12,0},
        {0,0,12,12,12,12,0,0},
        {0,0,12,0,0,12,0,0},
    }
}

-- local hm=getpixels('00GG:0GGGG:GGGGGG:0GGGG:0G00G:0G00G')
local hm = luasp._getpxs0{
    {
        {0,0,12,12},
        {0,12,12,12,12},
        {12,12,12,12,12,12},
        {0,12,12,12,12},
        {0,12,0,0,12},
        {0,12,0,0,12},
    }
}

local toolbar = Group():setxy(0,0)
toolbar.height = toolbarheight
toolbar.bg = Rect(screen.width, toolbarheight):setanchor(0,0):addto(toolbar)
toolbar.bg:fill(toolbarfillc)

-- button pixel sprite
toolbar.btnpxs = Button('',{width=100,height=100}):setanchor(0,0):addto(toolbar)
toolbar.btnpxs:setxy(screen.endx-120,20)
Pixels(ps):addto(toolbar.btnpxs):setanchor(0,0):setscale(11):setxy(7,14)
function toolbar.btnpxs:onpush()
    Scene.__goto0('luasp.util.builderpxs.scene')
end

--[[
-- button home
toolbar.btnhome = Button('',{width=100,height=100}):setanchor(0,0):addto(toolbar)
toolbar.btnhome:setxy(20,20)
Pixels(hm):addto(toolbar.btnhome):setanchor(0,0):setscale(11):setxy(15,15)
function toolbar.btnhome:onpush()
    Scene.__goto0('luasp.util.builderhome.scene')
end
--]]

luasp.btoolbar = toolbar
--------------------------------------------------------------------------------

if _Corona then 


    -- 2021/09/07: 프로젝트폴더에 직접 파일을 생성하는 것은 불가능해서
    -- 시스템 tmp폴더에 일단 생성하고 그것을 프로젝트폴더에 copy하는 방식으로 해결
    function luasp.savefile(filename, contentStr)

        local path1 = system.pathForFile( filename, system.TemporaryDirectory )
        --_print0(path1)
    
        local file, errormsg = io.open(path1,'w') -- 생성 혹은 덮어쓰기
        if not file then
            _print0('File error:'..errmsg)
        
        else
            file:write(contentStr)
            io.close(file)
        end
    
    
        local path2 = system.pathForFile( "root\\main.lua", system.ResourceDirectory )
        path2 = string.gsub(path2,'main.lua','data\\')
    
        -- _print0(path2)
    
        local cmd = 'copy /y "'..path1.. '" "'..path2..'"'
        --_print0( cmd )
        if os.execute(cmd) == 0 then
            _print0(filename ..' is successfully created.')
        end
    
    end


elseif _Gideros then


    function luasp.savefile(filename, contentStr)

        local path1 = _Gideros.application:get("temporaryDirectory")

    end
    

end

--------------------------------------------------------------------------------

Scene.__goto0('luasp.util.builderhome.scene')