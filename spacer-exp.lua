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

        local items_t = {}

        -- populate item table
        for i=2, num_selected_items do
            table.insert(
                items_t, 
                reaper.GetSelectedMediaItem(0, i-1)
            )
        end
        
        -- Now reverse iterate
        while #items_t > 0 do
            -- local random_offset = 0.3
            local random_offset = ((math.random() * (max - min)) + min) / 1000
            -- shift loop (each time move all items the same amount)
            for i=1, #items_t do
                local item = items_t[i]
                local pos = reaper.GetMediaItemInfo_Value(item, "D_POSITION")
                
                -- Set new position
                reaper.SetMediaItemInfo_Value(
                    item,
                    "D_POSITION",
                    pos + random_offset
                )
            end
            -- Remove the left most item
            table.remove(
                items_t, 
                ((#items_t + 1) - #items_t)
            )
        end

        reaper.UpdateArrange()
        reaper.Undo_EndBlock("Spacer", 0)
    end
end
::exit::