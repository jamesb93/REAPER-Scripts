function commasplit(input_string)
    -- splits by ,
    local t = {}
    for word in string.gmatch(input_string, '([^,]+)') do
        table.insert(t, word)
    end
    return t
end

math.randomseed(os.clock() * 100000000000) -- random seed

local num_selected_items = reaper.CountSelectedMediaItems(0)
if num_selected_items > 0 then
    local confirm, user_inputs = reaper.GetUserInputs("Time Shift", 2, "min, max", "10, 50")
    if confirm then
        reaper.Undo_BeginBlock()
        -- Algorithm Parameters
        local params = commasplit(user_inputs)
        local min = tonumber(params[1])
        local max = tonumber(params[2])

        local item_t = {}
        local offset_t = {}
        local offset_accum = 0
        local tail_accum = 0
        
        for i=2, num_selected_items do
            -- Current Item
            local prev_item = reaper.GetSelectedMediaItem(0, i-2)
            local prev_item_pos = reaper.GetMediaItemInfo_Value(prev_item, "D_POSITION")
            local prev_item_len = reaper.GetMediaItemInfo_Value(prev_item, "D_LENGTH")
            local item = reaper.GetSelectedMediaItem(0, i-1)
            table.insert(item_t, item)
            
            -- Now calculate offsets
            -- The offset is calculated in seconds
            local random_offset = ((math.random() * ((max-min)+0.000000000001) + min)) / 1000.0
            local new_position = prev_item_pos + prev_item_len + random_offset
            
            -- Set new position
            reaper.SetMediaItemInfo_Value(
                item_t[i-1],
                "D_POSITION",
                new_position
            )
        end

        reaper.UpdateArrange()
        reaper.Undo_EndBlock("Spacer", 0)
    end
end
::exit::