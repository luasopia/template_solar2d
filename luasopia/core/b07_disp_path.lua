local Disp = Display

local function upd(self)
    self._frmc = self._frmc + 1
    local pt = self._pth[self._frmc]
    --self:set{x=pt.sx, y=pt.sy, r=pt.rot, s=pt.z}
    self:set{x=pt.sx, y=pt.sy, r=pt.rot, s=pt.z}
    if pt.rm then return true end
end

function Disp:path(path)
    self._frmc = 0 -- frame count
    self._pth = path
    self:addupdate( upd )
    return self
end
