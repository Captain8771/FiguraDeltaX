--[[
MIT License

Copyright (c) 2024 Captain8771 (aka NikoOneshotReal)

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
--]]

-- DeltaX / ΔX, the most cursed State Change Sync Solution System (SΔSS)
local Delta = {
    config = {
        syncIntervalInTicks = 20 * 5, -- The amount of ticks between syncs.
        debug = false, -- Shows you the internal state by looking up
        compress_depress_funcs = { -- fuck you im not doing compression. have this very lightweight byte shaving instead.
            compress = function(state) return toJson(state):sub(3,-2) end,
            decompress = function(state) return parseJson("{\"" .. state .. "}") end
        }
    }
}
local _state = {}

local DeltaInternals = {
    __TickCounter = 1
}

function DeltaInternals.__WORLD_TICK()
    if DeltaInternals.__TickCounter == Delta.config.syncIntervalInTicks then
        local stateC = Delta.config.compress_depress_funcs.compress(_state)
        pings.___DeltaX_SyncStructure(stateC)
        DeltaInternals.__TickCounter = 0
    end
    DeltaInternals.__TickCounter = DeltaInternals.__TickCounter + 1

    if Delta.config.debug then--and host:isHost() then
        if DeltaInternals.__DebugPanel == nil then
            local worldModel = models:newPart("___DELTAX_WORLD_PART", "WORLD")
            local text = worldModel:newText("___DELTAX_DEBUG_PANEL")
            text:setPos(0,5*16,(10 * 16)-0.01)
            text:setRot(0,0,0)
            text:setBackground(true)
            text:backgroundColor(vec(0,0,0,1))
            text:setAlignment("CENTER")
            text:setWidth(16 * 16)

            DeltaInternals.__DebugPanel = text
        end

        DeltaInternals.__DebugPanel:setText(toJson(_state))

    end
end

events.WORLD_TICK:register(DeltaInternals.__WORLD_TICK, "___DELTAX_WORLD_TICK")

function pings.___DeltaX_SyncStructure(state)
    _state = Delta.config.compress_depress_funcs.decompress(state)
end

function pings.___DeltaX_SyncVar(key, value, parentKey)
    if parentKey ~= nil then
        if _state[parentKey] == nil then
            _state[parentKey] = {}
        end
        _state[parentKey][key] = value
    else
        _state[key] = value
    end
end

---@param key string # The key the value is stored under. Does not support nested keys. For that, see `.MkSubDelta`.
---@return unknown # The value stored at that key. `nil` if not found.
function Delta.Read(key)
    return _state[key] -- probably the simplest function in the lib lmao
end

---@param key string # The key the value is stored under. Does not support nested keys. For that, see `.MkSubDelta`.
---@param value any # The value to store.
---@param ping boolean # Whether or not to propagate the change immediately. Note that all changes are eventually synced. This is just to prevent ping spam in constantly-called functions.
---Note that the key should be unique when you strip all lowercase characters. This is for compression purposes.
function Delta.Write(key, value, ping)
    if ping == nil then ping = true end
    if ping == true then
        pings.___DeltaX_SyncVar(key, value)
    else
        _state[key] = value
    end
end

---Makes a subkey in the state.
---@param deltaKey string
---@return { Read: fun(key: string), Write: fun(key: stringlib, value: any, ping: boolean): nil }
function Delta.MkSubDelta(deltaKey)
    if _state[deltaKey] == nil then _state[deltaKey] = {} end
    return {
        Read = function(key)
            return _state[deltaKey][key]
        end,
        Write = function(key, value, ping)
            if ping == nil then ping = true end
            if ping == true then
                pings.___DeltaX_SyncVar(key, value, deltaKey)
            else
                _state[deltaKey][key] = value
            end
        end
    }
end

-- load = function(self)
--     -- some things shouldn't be saved.
--     self:set("AFK", false, false)
--     self:set("Name", self.Name, false)
--     self:set("OverrideName", "", false)
--     self:set("NameColor", self.NameColor, false)
--     local _vars = player:getVariable()
--     for key, value in pairs(_vars) do
--         if self[key] ~= nil and key:sub(1,1) ~= "_" then
--             self[key] = value
--         else
--             self["__UNKNOWN_" .. key] = value
--         end
--     end
-- end,
-- set = function(self, x, y, ping, MV)
--     if ping == nil then
--         ping = true
--     end
--     if MV == nil then
--         self[x] = y
--     else
--         if self["ModuleVariables"][MV] == nil then
--             self["ModuleVariables"][MV] = {}
--         end
--         self["ModuleVariables"][MV][x] = y
--     end
--     if ping then
--         pings.NA_Variables__SetKeyVal(x,y, MV)
--     end
-- end,
-- MkGlobalSet = function(self, moduleKey)
--     local func = function(key, value, ping)
--         return self:set(key, value, ping, moduleKey)
--     end
--     return func
-- end


-- local tickstamp = 0
-- function events.WORLD_TICK()
--     if tickstamp == 20 * 15 then
--         tickstamp = 0
--         pings.NA_Variables__SyncEntireStructure(Minify(Globals))
--     else
--         tickstamp = tickstamp + 1
--     end
-- end

-- function pings.NA_Variables__SyncEntireStructure(table)
--     table = DecompressTable(table)
--     for key, value in pairs(table) do
--         Globals[key] = value
--     end
-- end

-- function Minify(table)
--     local finalTable = {}
--     for key, value in pairs(table) do
--         local syncThisValue = true
--         if key:sub(1,1) == "_" then
--             syncThisValue = false
--             -- break
--         end
--         for index, protectedKey in ipairs(Globals.Protected) do
--             if protectedKey == key then
--                 syncThisValue = false
--                 -- break
--             end
--         end
--         if syncThisValue then
--             finalTable[key] = value
--         end
--     end
--     finalTable = CompressTable(finalTable)
--     return finalTable
-- end

-- function CompressTable(table)
--     return table -- TODO: table compression
-- end
-- function DecompressTable(table)
--     return table -- TODO: table compression
-- end

-- function pings.NA_Variables__SetKeyVal(key, value, MV)
--     Globals:set(key, value, false, MV)
-- end

return Delta