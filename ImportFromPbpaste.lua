local info = debug.getinfo(1,'S');
local script_path = info.source:match[[^@?(.*[\/])[^\/]-$]]
package.path = package.path .. ";" .. script_path .. "?.lua"
loadfile(script_path .. "ReaCoMa/lib/reacoma.lua")()

local json = require 'json'

reaper.Undo_BeginBlock()
local cap = reacoma.utils.capture("pbpaste")
local split = reacoma.utils.commasplit(cap)
local json_path = split[1]
local cluster_num = split[2]
cluster_num = cluster_num:gsub("%s+", "")

-------- start processing --------
reaper.SetEditCurPos(0.0, false, false)
reaper.InsertTrackAtIndex(0, true)

-- In the situation that this is the first track --
if reaper.CountTracks(0) <= 1 then
    local tr = reaper.GetTrack(0, 0)
    reaper.SetTrackSelected(tr, true)
end

-- Do json parsing --
local file_in = assert(io.open(json_path, "r"))
local content = file_in:read("*all")
local cluster_data = json.decode(content)
for k, p in ipairs(cluster_data[cluster_num]) do
    reaper.InsertMedia(p, 0)
end
reaper.SetEditCurPos(0.0, false, false)
reaper.Undo_EndBlock("Insert Media Cluster", 0)