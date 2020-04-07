local info = debug.getinfo(1,'S');
local full_script_path = info.source
local script_path = full_script_path:sub(2,-5) -- remove "@" and "file extension" from file name
if reaper.GetOS() == "Win64" or reaper.GetOS() == "Win32" then
  package.path = package.path .. ";" .. script_path:match("(.*".."\\"..")") .. "?.lua"
else
  package.path = package.path .. ";" .. script_path:match("(.*".."/"..")") .. "?.lua"
end
dofile(script_path .. "ReaCoMa/FluidPlumbing/FluidUtils.lua")

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
    local fields = commasplit(user_input)
    local json_path = fields[1]
    local cluster_num = fields[2]

    -- Do json parsing --
    local file_in = assert(io.open(json_path, "r"))
    local content = file_in:read("*all")
    local cluster_data = json.decode(content)
    for k, p in ipairs(cluster_data[cluster_num]) do
        reaper.InsertMedia('/Users/james/dev/data_bending/DataAudioUnique/' .. p, 0)
    end
    reaper.SetEditCurPos(0.0, false, false)
    -------- end processing --------
    reaper.Undo_EndBlock("Insert Media Cluster", 0)
end