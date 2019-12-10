local info = debug.getinfo(1,'S');
local script_path = info.source:match[[^@?(.*[\/])[^\/]-$]]
dofile(script_path .. "_utils.lua")


local reaper = reaper
local num_selected_items = reaper.CountSelectedMediaItems(0)

if num_selected_items > 0 then
    local captions = "max,min"
    local caption_defaults = "0,-60"
    local confirm, user_inputs = reaper.GetUserInputs("Texturiser", 2, captions, caption_defaults)
    if confirm then
        reaper.Undo_BeginBlock()
        -- Do
        local params = commasplit(user_inputs)
        local max_db = params[1]
        local min_db = params[2]
        math.randomseed(os.time()) -- need to seed or we will get the same numbers :)

        local item_t = {}
        local take_t = {}

        for i=1, num_selected_items do
            local item = reaper.GetSelectedMediaItem(0, i-1)
            local take = reaper.GetActiveTake(item)
            -- local random_volume = 
            reaper.SetMediaItemTakeInfo_Value(take, "D_VOL", 0.25)
        end
    end
end

reaper.Undo_EndBlock("texturise", 0)
