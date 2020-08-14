local info = debug.getinfo(1,'S');
local script_path = info.source:match[[^@?(.*[\/])[^\/]-$]]
package.path = package.path .. ";" .. script_path .. "?.lua"
loadfile(script_path .. "ReaCoMa/lib/reacoma.lua")()

local random = math.random

math.randomseed(os.clock() * 100000000000) -- random seed

local num_selected_items = reaper.CountSelectedMediaItems(0)
if num_selected_items > 0 then
    local confirm, user_inputs = reaper.GetUserInputs("Decimator", 1, "percentage", "10")
    if confirm then
        reaper.Undo_BeginBlock()
        -- Algorithm Parameters
        local params = reacoma.utils.commasplit(user_inputs)
        local percentage = tonumber(params[1])
        local item_t = {}
        
        for i=1, num_selected_items do
            local item = reaper.GetSelectedMediaItem(0, i-1)
            table.insert(item_t, item)
        end
        
        for i=1, num_selected_items do
            local state = random() * 100.0 < percentage
            reaper.SetMediaItemSelected(item_t[i], state)
        end

        reaper.UpdateArrange()
        reaper.Undo_EndBlock("Decimator", 0)
    end
end