local luasp = _luasopia
local print0 = luasp.print0


local fileurls = {
    ['sun.png'] = 'https://raw.githubusercontent.com/luasopia/data/master/png/sun.png',
    ['earth.png'] = 'https://raw.githubusercontent.com/luasopia/data/master/png/earth.png',
    ['moon.png'] = 'https://raw.githubusercontent.com/luasopia/data/master/png/moon.png',
    ['gear.png'] = 'https://raw.githubusercontent.com/luasopia/data/master/png/gear.png',
    ['star.png'] = 'https://raw.githubusercontent.com/luasopia/data/master/png/star.png',
    ['birdfly.png'] = 'https://raw.githubusercontent.com/luasopia/data/master/png/birdfly.png',
    ['girlrun.png'] = 'https://raw.githubusercontent.com/luasopia/data/master/png/girlrun.png',
    ['smoke.png'] = 'https://raw.githubusercontent.com/luasopia/data/master/png/smoke.png',
    ['pipe.png'] = 'https://raw.githubusercontent.com/luasopia/data/master/png/pipe.png',
    ['windbar.png'] = 'https://raw.githubusercontent.com/luasopia/data/master/png/windbar.png',
    ['windblade.png'] = 'https://raw.githubusercontent.com/luasopia/data/master/png/windblade.png',
    ['singleblade.png'] = 'https://raw.githubusercontent.com/luasopia/data/master/png/singleblade.png',
    
    ['bounce.wav'] = 'https://raw.githubusercontent.com/luasopia/data/master/wav/bounce.wav',
    ['pong.wav'] = 'https://raw.githubusercontent.com/luasopia/data/master/wav/pong.wav',
    ['up.wav'] = 'https://raw.githubusercontent.com/luasopia/data/master/wav/up.wav',
    ['warn.wav'] = 'https://raw.githubusercontent.com/luasopia/data/master/wav/warn.wav',
    ['zet.wav'] = 'https://raw.githubusercontent.com/luasopia/data/master/wav/zet.wav',
    ['clear.wav'] = 'https://raw.githubusercontent.com/luasopia/data/master/wav/clear.wav',
}

--------------------------------------------------------------------------------
luasp.allowGlobal() ------------------------------------------------------------
--------------------------------------------------------------------------------


function getfile(name)

    local url = fileurls[name]
    if url == nil then
        luasp.cli.print('Error: unknown file')
        return
    end

    local rootpath = luasp.resourceDir..'root/'

    local comm = 'curl -o "'..rootpath..name..'" "'..url..'"'

    --2021/09/14: gideros는 최소창으로 시작하라는 옵션을 앞에 붙여야 한다
    -- solar2d는 이 옵션을 붙이지 않아도 창이 뜨지 않는다.
    if _Gideros then
        comm = 'start /min '..comm
    end


    --print(comm)
    if 0== os.execute(comm ) then
        luasp.cli.print('download success!')
        -- print('download success!')
    else
        luasp.cli.print('Error: fail to download')
        -- print('Error: fail to download')
    end


end


_require0 'lfs' -- 이안에서 global변수 lfs가 생성되는 것 같다.

--------------------------------------------------------------------------------
luasp.banGlobal() ------------------------------------------------------------
--------------------------------------------------------------------------------




if _Corona then 


    -- 2021/09/07: 프로젝트폴더에 직접 파일을 생성하는 것은 불가능해서
    -- 시스템 tmp폴더에 일단 생성하고 그것을 프로젝트폴더에 copy하는 방식으로 해결
    function luasp.savefile(filename, contentStr)

        local path1 = system.pathForFile( filename, system.TemporaryDirectory )
        --print0(path1)
    
        local file, errormsg = io.open(path1,'w') -- 생성 혹은 덮어쓰기
        if not file then
            print0('File error:'..errmsg)
        
        else
            file:write(contentStr)
            io.close(file)
        end
    
    
        local path2 = system.pathForFile( "root\\main.lua", system.ResourceDirectory )
        path2 = string.gsub(path2,'main.lua','data\\')
    
        -- print0(path2)
    
        local cmd = 'copy /y "'..path1.. '" "'..path2..'"'
        -- print0( cmd )
        if 0 == os.execute(cmd) then
            print0(filename ..' is successfully created.')
        end
    
    end


elseif _Gideros then


    function luasp.savefile(filename, contentStr)

        local path1 = _Gideros.application:get("temporaryDirectory")

    end
    

end








local function getFileListR(path, cache, strtype)

    if cache == nil then cache = {} end

    local properPath = string.gsub(path, '[.]', '/')

    -- local sysPath = system.pathForFile(properPath, system.ResourceDirectory)
    local sysPath = luasp.resourceDir .. properPath
    print0(sysPath)

    for entry in lfs.dir(sysPath) do

        local mode = lfs.attributes(sysPath .. '/' .. entry, 'mode')
        if mode == 'file' then

            -- local name = string.match(entry, '(.*).lua')

            local strmatch = '(.*)%('..strtype..'%).lua'
            local name = string.match(entry, strmatch)

            if name then
                -- cache[#cache + 1] = path .. '.' .. name 
                cache[#cache + 1] = string.format('%s.%s(%s)',path,name,strtype)
            end

        elseif mode == 'directory' then

            if not string.match(entry, '^[.].*') then
                getFileListR(path .. '.' .. entry, cache, strtype) -- 재귀호출
            end

        end
    end

    return cache
end

-- --[[
function luasp.findfiles(strtype)

    return getFileListR(luasp.root,{},strtype)

end
--]]

