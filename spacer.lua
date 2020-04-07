local info = debug.getinfo(1,'S');
local script_path = info.source:match[[^@?(.*[\/])[^\/]-$]]
dofile(script_path .. "ReaCoMa/FluidPlumbing/FluidUtils.lua")

math.randomseed(os.clock() * 100000000000) -- random seed

local num_selected_items = reaper.CountSelectedMediaItems(0)
if num_selected_items > 0 then
    local captions = "min,max,noise factor (ms),exponent"
    local caption_defaults = "10,50,0.0,1.0"
    local confirm, user_inputs = reaper.GetUserInputs("Time Shift", 4, captions, caption_defaults)
    if confirm then
        reaper.Undo_BeginBlock()
        -- Algorithm Parameters
        local params = fluidUtils.commasplit(user_inputs)
        local min = tonumber(params[1])
        local max = tonumber(params[2])
        local noise_factor = tonumber(params[3])
        local exponent = tonumber(params[4])
        
        local points = fluidUtils.linspace(min, max, num_selected_items)
        local items_t = {}

        -- populate item table
        for i=2, num_selected_items do
            table.insert(
                items_t, 
                reaper.GetSelectedMediaItem(0, i-1)
            )
        end
    
        -- Now reverse iterate
        for i=1, #items_t do
            
            local offset = (points[i] / 1000)
            -- shift loop (each time move all items the same amount)
            for i=1, #items_t do
                local item = items_t[i]
                local pos = reaper.GetMediaItemInfo_Value(item, "D_POSITION")
                local noise = ((math.random()*2-1) * noise_factor) / 1000
            
                -- Set new position
                reaper.SetMediaItemInfo_Value(
                    item,
                    "D_POSITION",
                    pos + offset + noise
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