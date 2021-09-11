local luasp = _luasopia


local fileurls = {
    ['moon.png'] = 'https://raw.githubusercontent.com/luasopia/data/master/png/moon.png',
    ['star.png'] = 'https://raw.githubusercontent.com/luasopia/data/master/png/star.png',
    ['bird.png'] = 'https://raw.githubusercontent.com/luasopia/data/master/png/bird.png',
    
    ['bounce.wav'] = 'https://raw.githubusercontent.com/luasopia/data/master/wav/bounce.wav',
}

--------------------------------------------------------------------------------
luasp.allowGlobal() ------------------------------------------------------------
--------------------------------------------------------------------------------


function getfile(name)

    local url = fileurls[name]
    if url == nil then
        luasp.console.cli.print('Error: unknown file')
        return
    end


    local rootpath
    if _Gideros then
        --gideros는 rootpath에 한글(utf8)이 들어가면 안된다
        --(solar2d는 상관없음)
        rootpath='E:/coding/__luasopia/_template_gideros/assets/'
        --rootpath='C:/Users/sales/'


    elseif _Corona then

        rootpath = system.pathForFile( "root/main.lua", system.ResourceDirectory )
        rootpath = string.gsub(rootpath, 'main.lua','')
        print(rootpath)
    
    end

    -- print( os.execute('cd/d "'..rootpath..'" && curl -LJO "'..dataurls[name]..'"')
    -- if 0== os.execute( 'cd/d "'..rootpath..'" && curl -LJO "'..url..'"') then
    local comm = 'curl -o "'..rootpath..name..'" "'..url..'"'
    print(comm)
    if 0== os.execute(comm ) then
        luasp.console.cli.print('download success!')
        -- print('download success!')
    else
        luasp.console.cli.print('Error: fail to download')
        -- print('Error: fail to download')
    end


end


_require0 'lfs' -- 이안에서 global변수가 생성되는 것 같다.

--------------------------------------------------------------------------------
luasp.banGlobal() ------------------------------------------------------------
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
        if 0 == os.execute(cmd) then
            _print0(filename ..' is successfully created.')
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
    _print0(sysPath)

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

local files = luasp.findfiles('pxs')
luasp.util.showt(files)
