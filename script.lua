-- Auto generated script file --
vanilla_model.PLAYER:setVisible(false)
models.model:setPrimaryRenderType("END_PORTAL")
nameplate.ENTITY:setText("${badges} Test Avatar")

local Delta = require("DeltaX")

function events.WORLD_TICK()
    local time = ""
    local _time = client:getDate()
    time = tostring(_time.hour) .. tostring(_time.minute) .. tostring(_time.second)
    Delta.Write("Time", time, false)
end

function events.CHAR_TYPED(char)
    Delta.Write("LastTypedChar", char, false)
    if char:match("%d") then
        Delta.Write("HeldItem", player:getHeldItem():getName(), true)
    end
end