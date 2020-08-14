local info = debug.getinfo(1,'S');
local script_path = info.source:match[[^@?(.*[\/])[^\/]-$]]
package.path = package.path .. ";" .. script_path .. "?.lua"
loadfile(script_path .. "ReaCoMa/lib/reacoma.lua")()

local json = require 'json'

local confirm, user_input = reaper.GetUserInputs('Provide JSON info', 2, 'JSON Path:, Cluster Number:, extrawidth=100', '')

if confirm then
    reaper.Undo_BeginBlock()

    -------- start processing --------
    reaper.SetEditCurPos(0.0, false, false)
    reaper.InsertTrackAtIndex(0, true)

    -- In the situation that this is the first track --
    if reaper.CountTracks(0) <= 1 then
        local tr = reaper.GetTrack(0, 0)
        reaper.SetTrackSelected(tr, true)
    end

    -- Parse user input --
    local fields = reacoma.utils.commasplit(user_input)
    local json_path = fields[1]
    local cluster_num = fields[2]

    -- Do json parsing --
    local file_in = assert(io.open(json_path, "r"))
    local content = file_in:read("*all")
    local cluster_data = json.decode(content)
    for k, p in ipairs(cluster_data[cluster_num]) do
        reaper.InsertMedia(p, 0)
    end
    reaper.SetEditCurPos(0.0, false, false)
    reaper.Undo_EndBlock("Insert Media Cluster", 0)
end