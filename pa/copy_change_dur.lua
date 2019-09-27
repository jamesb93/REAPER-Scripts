-- this script will append to an item a duplicate of this item with the duration amended by the ratio.
-- Originally crafted by Pierre-Alexandre Tremblay at the University of Huddersfield
-- it was made possible through the FluCoMa project (European Union’s Horizon 2020 research and innovation programme, grant #725899)

function commasplit(input_string)
    -- splits by , and returns a table
    local t = {}
    for word in string.gmatch(input_string, '([^,]+)') do
        table.insert(t, word)
    end
    return t
end

local num_selected_items = reaper.CountSelectedMediaItems(0)
if num_selected_items > 0 then
    local captions = "Stretch Ratio,Number of Repetitions"
    local caption_defaults = "0.75, 2"
    local confirm, user_inputs = reaper.GetUserInputs("", 2, captions, caption_defaults)
    if confirm then 
        reaper.Undo_BeginBlock()
        local params = commasplit(user_inputs)
        local ratio = params[1]
        local times = params[2]

        -- Tables for storing stuff --
        local item_t = {}

        -- Calculate all the info in advance --
        for i=1, num_selected_items do
            local item = reaper.GetSelectedMediaItem(0, i-1)
            local take = reaper.GetActiveTake(item)
            local src = reaper.GetMediaItemTake_Source(take)
            local sr = reaper.GetMediaSourceSampleRate(src)
            local full_path = reaper.GetMediaSourceFileName(src, '')
            table.insert(item_t, item)
        end

        -- Process --
        for i=1, num_selected_items do
            local item_cpy = item_t[i]
            for j=1, times do

                local duration = reaper.GetMediaItemInfo_Value(item_cpy, "D_LENGTH")
                local start_time = reaper.GetMediaItemInfo_Value(item_cpy, "D_POSITION")
                local start_offset =  reaper.GetMediaItemTakeInfo_Value(reaper.GetActiveTake(item_cpy), "D_STARTOFFS")
    
                -- 
                reaper.SetMediaItemInfo_Value(item_cpy, "D_LENGTH", (duration * (1+ratio)))
                new_item = reaper.SplitMediaItem(item_cpy, (duration + start_time))
                reaper.SetMediaItemSelected(item_cpy, false)

                if new_item == 'NULL' then
                    reaper.ShowConsoleMsg("Error Splitting\n")
                    goto exit
                end
                reaper.SetMediaItemTakeInfo_Value(reaper.GetActiveTake(new_item), "D_STARTOFFS", start_offset)
                item_cpy = new_item
            end
        end

    end
    ::exit::
    reaper.Undo_EndBlock("CopyChangeDur", 0)
end