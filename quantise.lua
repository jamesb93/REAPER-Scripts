local info = debug.getinfo(1,'S');
local script_path = info.source:match[[^@?(.*[\/])[^\/]-$]]
dofile(script_path .. "ReaCoMa/FluidPlumbing/FluidUtils.lua")

local num_selected_items = reaper.CountSelectedMediaItems(0)
if num_selected_items > 0 then
    local captions = "Spacing: "
    local caption_defaults = "100"
    local confirm, user_inputs = reaper.GetUserInputs("Quantise", 1, captions, caption_defaults)
    if confirm then
        reaper.Undo_BeginBlock()
        -- Algorithm Parameters
        local params = fluidUtils.commasplit(user_inputs)
        local spacing = tonumber(params[1])
        
        local points = fluidUtils.linspace(0, spacing * num_selected_items, num_selected_items)
        local items_t = {}
        local first_item_pos = reaper.GetMediaItemInfo_Value(reaper.GetSelectedMediaItem(0, 0), "D_POSITION")

        -- populate item table
        for i=2, num_selected_items do
            table.insert(
                items_t, 
                reaper.GetSelectedMediaItem(0, i-1)
            )
        end
    
        -- now iterate and remove the left most one after each iteration
        for i=1, #items_t do
            
            local offset = (points[i] / 1000)
            -- shift loop (each time move all items the same amount)
            for i=1, #items_t do
                local item = items_t[i]
                -- local pos = reaper.GetMediaItemInfo_Value(item, "D_POSITION")
            
                -- Set new position
                reaper.SetMediaItemInfo_Value(
                    item,
                    "D_POSITION",
                    first_item_pos + offset
                )
            end
            -- Remove the left most item
            table.remove(
                items_t, 
                ((#items_t + 1) - #items_t)
            )
        end

        reaper.UpdateArrange()
        reaper.Undo_EndBlock("Quantiser", 0)
    end
end