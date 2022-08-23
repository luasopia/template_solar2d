local luasp = _luasopia


local File = class()
function File:init(rname)

    self.req0name = rname -- 'root.data.alien(pxs)'
    
    local rootdot = luasp.root .. '.'
    local showname = string.gsub(rname, rootdot, '')
    self.dispname = string.gsub(showname, '%(pxs%)', '')


    local rnamelua = string.gsub(rname, '[.]', '/')..'.lua'
    self.abspath = luasp.resourceDir .. rnamelua

    
    self.pxshts = _require0(rname)

    print(self.req0name)
    print(self.dispname)
    print(self.abspath)

end



local fileset = LabelBox('files',1070,200):setXY(10,150)


function fileset:searchfiles()

    fileset:clear()

    local files = luasp.findfiles('pxs')
    
    local x,y = 150,50
    for _, file in ipairs(files) do

        local fobj = File(file)
        local btnfile = Button(fobj.dispname,{fontSize=40,height=50}):addTo(fileset)
        btnfile.file = fobj
        btnfile:setXY(x,y)

        function btnfile:onPush()
            luasp.pxbuilder.pxartset:setsheet(fobj.pxshts, fobj.dispname)
        end



        x=x+400
    end



end

fileset:searchfiles()






return fileset


