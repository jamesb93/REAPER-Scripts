local num_selected_items = reaper.CountSelectedMediaItems(0)

if num_selected_items > 0 then
    for i=1, num_selected_items do
        local item = reaper.GetSelectedMediaItem(0, i-1)
        local take = reaper.GetActiveTake(item)
        local source = reaper.GetMediaItemTake_Source(take)
        local path = reaper.GetMediaSourceFileName(source, "")
        local cmd = "open -R " .. doublequote(path)
        os.execute(cmd)
    end
end
