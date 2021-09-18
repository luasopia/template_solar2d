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

    _print0(self.req0name)
    _print0(self.dispname)
    _print0(self.abspath)

end



local fileset = Labelbox('files',1070,200):setxy(10,150)


function fileset:searchfiles()

    fileset:clear()

    local files = luasp.findfiles('pxs')
    
    local x,y = 150,50
    for _, file in ipairs(files) do

        local fobj = File(file)
        local btnfile = Button(fobj.dispname,{fontsize=40,height=50}):addto(fileset)
        btnfile.file = fobj
        btnfile:setxy(x,y)

        function btnfile:onpush()
            luasp.pxbuilder.pxartset:setsheet(fobj.pxshts, fobj.dispname)
        end



        x=x+400
    end



end

fileset:searchfiles()






return fileset


