local Delta = require("DeltaX")

local moduleState = Delta.MkSubDelta("moduleName")

function events.KEY_PRESS(key, state, modifiers)
    if key == 74 then
        if state == 1 then
            moduleState.Write("J", true, true)
        end
        if state == 0 then
            moduleState.Write("J", false, true)
        end
    end
end