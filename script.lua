-- Auto generated script file --
vanilla_model.PLAYER:setVisible(false)
models.model:setPrimaryRenderType("END_PORTAL")
nameplate.ENTITY:setText("${badges} Test Avatar")

local Delta = require("DeltaX")
require("script_somemodule")

function events.WORLD_TICK()
    if host:isHost() then
        local time = ""
        local _time = client:getDate()
        time = tostring(_time.hour) .. tostring(_time.minute) .. tostring(_time.second)
        Delta.Write("Time", time, false)
    end
end

function events.CHAR_TYPED(char)
    Delta.Write("LastTypedChar", char, false)
    if char:match("%d") then
        Delta.Write("HeldItem", player:getHeldItem():getName(), true)
    end
end

function Delta.events.beforeSyncValue(key, value)
    print("bSV", key, value)
end

function Delta.events.beforeSyncValue(key, value)
    print("bSV2!!!! YAY! ", key, value)
end

function Delta.events.afterSyncValue(key, value)
    print("aSV", key, value)
end

function Delta.events.beforeSyncStructure(state)
    print("bSS!", state)
end

function Delta.events.afterSyncStructure(state)
    print("aSS!", state)
end

