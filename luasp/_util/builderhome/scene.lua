local luasp = _luasopia

local scene = Scene()


function scene:create(stage)

    Text('builderhome')

end

function scene:aftershow(stage)

    stage:add(luasp.btoolbar)

end


function scene:afterhide(stage) end

return scene