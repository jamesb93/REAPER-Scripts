-- LOAD ALL THE DEPENDENCIES FOR THIS SCRIPT --
local info = debug.getinfo(1,'S');
local script_path = info.source:match[[^@?(.*[\/])[^\/]-$]]
dofile(script_path .. "_utils.lua")

local lib_path = reaper.GetExtState("Lokasenna_GUI", "lib_path_v2")
if not lib_path or lib_path == "" then
    reaper.MB("Couldn't load the Lokasenna_GUI library. Please run 'Set Lokasenna_GUI v2 library path.lua' in the Lokasenna_GUI folder.", "Whoops!", 0)
    return
end
loadfile(lib_path .. "Core.lua")()

GUI.req("Classes/Class - Slider.lua")()
GUI.req("Classes/Class - Label.lua")()
if missing_lib then return 0 end -- If any of the requested libraries weren't found, abort the script.

-- DEFINE INTERFACE --
GUI.New("quantise_amt", "Slider", {
    z = 1,
    x = 10,
    y = 20,
    w = 400,
    min = 1,
    max = 2000,
    defaults = 100,
})

GUI.New("quantise_label", "Label", {
    z = 2,
    x = 420,
    y = 20,
    font = 3,
    caption = "quantise",
    shadow = 0
})

GUI.x, GUI.y, GUI.w, GUI.h = 200, 200, 500, 70

-- DEFINE LOGIC
previous_spacing = GUI.Val("quantise_amt")
function do_loop()
    local spacing = GUI.Val("quantise_amt")
    if previous_spacing ~= spacing then
        previous_spacing = spacing
        reaper.Undo_BeginBlock()
        local num_selected_items = reaper.CountSelectedMediaItems(0)
        if num_selected_items > 0 then
            -- Algorithm Parameters

            local points = linspace(0, spacing * num_selected_items, num_selected_items)
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
end

GUI.version = 0
GUI.func = do_loop
GUI.freq = 0


GUI.Init()
GUI.Main()
