local info = debug.getinfo(1,'S');
local script_path = info.source:match[[^@?(.*[\/])[^\/]-$]]
package.path = package.path .. ";" .. script_path .. "?.lua"
loadfile(script_path .. "ReaCoMa/lib/reacoma.lua")()

local num_selected_items = reaper.CountSelectedMediaItems(0)

if num_selected_items > 0 then
    local captions = "max,min"
    local caption_defaults = "0,-60"
    local confirm, user_inputs = reaper.GetUserInputs("Texturiser", 2, captions, caption_defaults)
    if confirm then
        reaper.Undo_BeginBlock()

        local params = reacoma.utils.commasplit(user_inputs)
        local max_db = params[1]
        local min_db = params[2]
        math.randomseed(os.clock() * 100000000000) -- random seed

        for i=1, num_selected_items do
            local item = reaper.GetSelectedMediaItem(0, i-1)
            local take = reaper.GetActiveTake(item)
            local random_volume = math.random()
            reaper.SetMediaItemTakeInfo_Value(take, "D_VOL", random_volume)
        end
    end
end

reaper.Undo_EndBlock("texturise", 0)
