local info = debug.getinfo(1,'S');
local script_path = info.source:match[[^@?(.*[\/])[^\/]-$]]
package.path = package.path .. ";" .. script_path .. "?.lua"
loadfile(script_path .. "ReaCoMa/lib/reacoma.lua")()

local utils = require("utils")

local num_selected_items = reaper.CountSelectedMediaItems(0)

if num_selected_items > 0 then
    for i=1, num_selected_items do
        local item = reaper.GetSelectedMediaItem(0, i-1)
        local take = reaper.GetActiveTake(item)
        local source = reaper.GetMediaItemTake_Source(take)
        local path = reaper.GetMediaSourceFileName(source, "")
        os.execute(
            "open -R " .. utils.doublequote(path)
        )
    end
end
