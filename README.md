# DeltaX (ΔX)
Configurable avatar state syncing solution, made because none of the other available solutions were to my liking.

## Installation
Drop `DeltaX.lua` into your avatar folder wherever, then import it as such: 

```lua
local Delta = require("path.to.DeltaX")
```

## Usage

```lua
---@param key string
---@return unknown
---Returns the value stored at "key", nil if nothing is stored.
Delta.Read(key)

---@param key string
---@param value any
---@param ping boolean
---Stores "value" at "key". if "ping" is true, it will immediately sync. 
---Otherwise, it will wait until the next periodic sync.
---Technically ping is optional to pass, but if you don't pass it I
---will curse upon you a thousand plagues.
Delta.Write(key, value, ping)


---@param deltaKey string
---@return { Read: fun(key: string), Write: fun(key: string, value: any, ping: boolean): nil }
Delta.MkSubKey(deltaKey)
```