# DeltaX (ΔX)
Configurable avatar state syncing solution, made because none of the other available solutions were to my liking.

## Installation
Drop `DeltaX.lua` into your avatar folder wherever, then import it as such: 

```lua
Delta = require("path.to.DeltaX")
-- OR
local Delta = require("path.to.DeltaX")
```

## Testing
If you want to test DeltaX, simply clone this repo into your avatar folder, and select "DeltaX Labs"


## Usage

```lua
-- State refers to the internal state of DeltaX (in other words, the internal table that holds your variables)
Delta = require("path.to.DeltaX")



---@param key string
---@return unknown
---Returns the value stored at "key" in State, nil if nothing is stored.
Delta.Read(key)

---@param key string
---@param value any
---@param ping boolean
---Stores "value" at "key" in State. if "ping" is true, it will immediately sync. 
---Otherwise, it will wait until the next periodic sync.
---Technically ping is optional to pass, but if you don't pass it Lua Language Server
---will curse upon you a thousand plagues.
Delta.Write(key, value, ping)


---@param deltaKey string
---@return { Read: fun(key: string), Write: fun(key: string, value: any, ping: boolean): nil }
---Makes a new Delta that reads/writes to/from State[deltaKey][key] instead of State[key]
local SubDelta = Delta.MkSubKey(deltaKey)

-- SubDelta.Read/Write are identical to Delta.Read/Write, just that the location in State it touches is slightly different.
-- Sub-Sub-Deltas are not supported in the current version of DeltaX. In the future, maybe.
```

## Configuration
Configuration keys, and their default values.

```lua
-- How often State will be synced, in ticks (1/20th of a second)
Delta.config.syncIntervalInTicks = 20 * 15

-- How much to delay between each packet, in the event a sync packet is split, in ticks.
Delta.config.splitPacketsIntervalInTicks = 20 * 1.1 

-- Setting this to true dumps State to world origin. It is adjusted for Figura Plaza's Origin room.
-- This debug panel shows for everyone.
Delta.config.debug = false 


-- I couldn't figure out a good compression method,
-- so this default compress/decompress just shaves two characters off of the sync packet.
-- It's in the config incase someone wants to pass their own compression functions.
Delta.config.compress_depress_funcs = {
    compress = function(state) return toJson(state):sub(2,-2) end,
    decompress = function(state) return parseJson("{" .. state .. "}") end
}

-- How large in total a split sync packet can add up to.
Delta.config.splitPacketsMaxBufferSize = math.round(avatar:getMaxBufferSize()/4)

-- How large each sync packet chunk is, in bytes.
Delta.config.splitPacketChunkSize = 512

```

## Contact
If something breaks, behaves weirdly, or you think a feature fits for DeltaX, or just want to say hi, feel free to reach out via one of the following mediums:
- Discord (`niko.oneshot.real`)
- Github Issues
- Pinging me in the figura assets-browser thread for this library
Just make sure to include the first line of your local copy of DeltaX.lua if you're reporting a bug. 

It should look something like this: 

```lua
-- Δ = ...
```