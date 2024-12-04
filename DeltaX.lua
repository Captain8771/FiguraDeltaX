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

-- DeltaX / ΔX, the most cursed Change-Sync Solution System (ΔSS)
local Delta = {
    config = {
        syncIntervalInTicks = 20 * 15, -- The amount of ticks between syncs.
        splitPacketsIntervalInTicks = 20 * 1.1, -- The amount of time between "split" packets.
        debug = true, -- Shows you the internal state
        compress_depress_funcs = { -- fuck you im not doing compression. have this very lightweight byte shaving instead.
            compress = function(state) return toJson(state):sub(2,-2) end,
            decompress = function(state) return parseJson("{" .. state .. "}") end
        },
        splitPacketsMaxBufferSize = math.round(avatar:getMaxBufferSize()/4), -- TODO: figure out better default
        splitPacketChunkSize = 512
    }
}
local _state = {}
--- @type Buffer
local _splitPingTMP = nil
--- @type Buffer
local _splitPingSendTMP = nil

local DeltaInternals = {
    __TickCounter = 1,
    __SyncTickCounter = 1,
    __CurrentlySplitSyncing = false
}

function DeltaInternals.__WORLD_TICK()
    if DeltaInternals.__TickCounter == Delta.config.syncIntervalInTicks then
        if _splitPingSendTMP == nil then
            local stateC = Delta.config.compress_depress_funcs.compress(_state)
            local _tempBuffer = data:createBuffer(#stateC * 2) -- can probably just do #stateC but i dont trust my code
            _tempBuffer:writeByteArray(stateC)
            _tempBuffer:setPosition(0)
            if _tempBuffer:available() <= Delta.config.splitPacketChunkSize then
                pings.___DeltaX_SyncStructure(stateC, false)
                DeltaInternals.__TickCounter = 0
            else
                -- too long for a packet according to config. begin splitting.
                DeltaInternals.__CurrentlySplitSyncing = true
                _splitPingSendTMP = _tempBuffer
                pings.___DeltaX_SyncStructure("CH1" .. _splitPingSendTMP:readByteArray(Delta.config.splitPacketChunkSize-3), true)
            end
        else
            if DeltaInternals.__SyncTickCounter == Delta.config.splitPacketsIntervalInTicks then
                DeltaInternals.__SyncTickCounter = 0
                if _splitPingSendTMP:available() == 0 then
                    _splitPingSendTMP:close()
                    DeltaInternals.__CurrentlySplitSyncing = false
                    DeltaInternals.__TickCounter = 0
                    pings.___DeltaX_SyncStructure("END", true)
                    return
                end
                pings.___DeltaX_SyncStructure("sPS" .. _splitPingSendTMP:readByteArray(Delta.config.splitPacketChunkSize), true)
            end
        end
    end
    if not DeltaInternals.__CurrentlySplitSyncing then 
        DeltaInternals.__TickCounter = DeltaInternals.__TickCounter + 1
        DeltaInternals.__SyncTickCounter = 1
    else
        DeltaInternals.__SyncTickCounter = DeltaInternals.__SyncTickCounter + 1
    end

    if Delta.config.debug then
        if DeltaInternals.__DebugPanel == nil then
            local worldModel = models:newPart("___DELTAX_WORLD_PART", "WORLD")
            local text = worldModel:newText("___DELTAX_DEBUG_PANEL")
            text:setPos(0,5*16,(10 * 16)-0.01)
            text:setRot(0,0,0)
            text:setBackground(true)
            text:backgroundColor(vec(0,0,0,1))
            text:setAlignment("CENTER")
            text:setWidth(16 * 16)
            text:setScale(0.1,0.1,0.1)

            DeltaInternals.__DebugPanel = text
        end

        DeltaInternals.__DebugPanel:setText(toJson(_state))

    end
end

events.WORLD_TICK:register(DeltaInternals.__WORLD_TICK, "___DELTAX_WORLD_TICK")

--- @param state Buffer | unknown
--- @param split boolean | nil
function pings.___DeltaX_SyncStructure(state, split)
    if split ~= true then
        _state = Delta.config.compress_depress_funcs.decompress(state)
        return
    end
    
    if _splitPingTMP == nil then
        -- it's our very first packet received.
        local _tBuffer = data:createBuffer(Delta.config.splitPacketChunkSize)
        _tBuffer:writeByteArray(state)
        if _tBuffer:readByteArray(3) == "CH1" then
            _splitPingTMP = data:createBuffer(Delta.config.splitPacketsMaxBufferSize)
            _splitPingTMP:setPosition(0)
            _tBuffer:close()
        else
            _tBuffer:close()
            return -- we do not have all the data. ignore this sync packet.
        end
    end
    _splitPingTMP:writeByteArray(state:readByteArray(Delta.config.splitPacketChunkSize))
    state:setPosition(0)
    if state:readByteArray(3) == "END" then
        state:close()
        _splitPingTMP:setPosition(0)
        local finalPacket = _splitPingTMP:readByteArray(Delta.config.splitPacketsMaxBufferSize)
        _state = Delta.config.compress_depress_funcs.decompress(finalPacket)
    end
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
---@return { Read: fun(key: string), Write: fun(key: string, value: any, ping: boolean): nil }
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

return Delta