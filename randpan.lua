local info = debug.getinfo(1,'S');
local script_path = info.source:match[[^@?(.*[\/])[^\/]-$]]
package.path = package.path .. ";" .. script_path .. "?.lua"
loadfile(script_path .. "ReaCoMa/lib/reacoma.lua")()

local random = math.random
math.randomseed(os.clock() * 100000000000) -- random seed

local num_selected_items = reaper.CountSelectedMediaItems(0)
if num_selected_items > 0 then
    local confirm, user_inputs = reaper.GetUserInputs("Random Pan", 2, "min,max", "0, 1")
    if confirm then
        reaper.Undo_BeginBlock()
        -- Algorithm Parameters
        local params = reacoma.utils.commasplit(user_inputs)
        local min = tonumber(params[1])
        local max = tonumber(params[2])

        -- edit pan position
        for i = 1, num_selected_items do
            local item = reaper.GetSelectedMediaItem(0, i - 1)
            local take = reaper.GetActiveTake(item)
            local pan_pos = random() * (max - min) + min
            local pan_pos = pan_pos * 2 - 1 -- scale to -1, 1
            reaper.SetMediaItemTakeInfo_Value(take, "D_PAN", pan_pos)
        end
        
        reaper.UpdateArrange()
        reaper.Undo_EndBlock("RandPan", 0)
    end
end
