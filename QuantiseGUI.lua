local info = debug.getinfo(1,'S');
local script_path = info.source:match[[^@?(.*[\/])[^\/]-$]]
dofile(script_path .. "utilities.lua")

local libPath = reaper.GetExtState("Scythe v3", "libPath")
if not libPath or libPath == "" then
    reaper.MB("Couldn't load the Scythe library. Please install 'Scythe library v3' from ReaPack, then run 'Script: Scythe_Set v3 library path.lua' in your Action List.", "Whoops!", 0)
    return
end
loadfile(libPath .. "scythe.lua")()
local GUI = require("gui.core")

local window = GUI.createWindow({
    name = "Quantise contiguous items",
    w = 500,
    h = 100,
  })

local layer = GUI.createLayer({name = "Layer1"})

layer:addElements(GUI.createElements(
    {
        name = "amount",
        type = "Slider",
        x = 10,
        y = 30,
        w = 400,
        min = 1,
        max = 2000,
        defaults = 100,
        caption = "Amount"
    },
    {
        name = "noise",
        type = "Slider",
        x = 10,
        y = 70,
        w = 400,
        min = 0,
        max = 100,
        defaults = 0,
        caption = "Noise"
    }
))

-- DEFINE LOGIC
previous_spacing = GUI.Val("amount")
previous_noise_factor   = GUI.Val("noise")
reaper.Undo_BeginBlock()

local function Main()
    local spacing = GUI.Val("amount")
    local noise_factor = GUI.Val("noise")
    local num_selected_items = reaper.CountSelectedMediaItems(0)
    if num_selected_items > 0 and previous_noise_factor ~= noise_factor or previous_spacing ~= spacing then
        math.randomseed(os.clock() * 100000000000) -- random seed

        previous_spacing = spacing
        previous_noise_factor = noise_factor


        local points = utils.linspace(0, spacing * num_selected_items, num_selected_items)
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
            for j=1, #items_t do
                local item = items_t[j]
                local noise_offset = ((math.random()*2-1) * noise_factor) / 1000
                -- Set new position
                reaper.SetMediaItemInfo_Value(
                    item,
                    "D_POSITION",
                    first_item_pos + offset + noise_offset
                )
            end
            -- Remove the left most item
            table.remove(
                items_t, 
                ((#items_t + 1) - #items_t)
            )
        end
        
        reaper.UpdateArrange()
        
    end
end
reaper.Undo_EndBlock("Quantiser", 0)
  
window:addLayers(layer)
window:open()

GUI.func = Main
GUI.funcTime = 0
GUI.Main()
