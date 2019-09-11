-- First we require the utilities found in FluidUtils.lua
-- This is a horrible workaround specific to REAPER
-- It forms a manual path to the path of this script
-- It looks relative to this script and uses dofile to import
local info = debug.getinfo(1,'S');
script_path = info.source:match[[^@?(.*[\/])[^\/]-$]]
dofile(script_path .. "FluidUtils.lua")

------------------------------------------------------------------------------------
--   Each user MUST point this to their folder containing FluCoMa CLI executables --
sanity_check()
local cli_path = get_fluid_path()
--   Then we form some calls to the tools that will live in that folder --
local ie_exe = cli_path .. '/index_extractor '
local ns_exe = cli_path .. '/noveltyslice '
------------------------------------------------------------------------------------

local num_selected_items = reaper.CountSelectedMediaItems(0)
if cancel ~= false and num_selected_items > 0 then
    local cancel, user_inputs = reaper.GetUserInputs("Novelty Slice Parameters", 5, "feature,threshold,kernelsize,filtersize,fftsettings", "0,0.5,3,1,1024 512 1024")
    local items = {}
    for x=0, num_selected_items-1 do
      table.insert(items, reaper.GetSelectedMediaItem(0, x))
    end
    for k=1, #items do
        local item = items[k]
        --local proj_path = reaper.GetProjectPath(0, "")
        --proj_path = doublequote(proj_path)
        tmp_file = os.tmpname() .. ".wav"
        temp_idx = doublequote(tmp_file)
      
        local params = commasplit(user_inputs)
        local feature = params[1]
        local threshold = params[2]
        local kernelsize = params[3]
        local filtersize = params[4]
        local fftsettings = params[5]
        
        -- Get info for item in REAPER
        local take = reaper.GetActiveTake(item)
        local src = reaper.GetMediaItemTake_Source(take)
        local sr = reaper.GetMediaSourceSampleRate(src)
        local full_path = reaper.GetMediaSourceFileName(src, '')
        full_path = doublequote(full_path)
        local item_pos = reaper.GetMediaItemInfo_Value(item, "D_POSITION")
        local ns_cmd = ns_exe .. " -source " .. full_path .. " -indices " .. temp_idx .. " -feature " .. feature .. " -kernelsize " .. kernelsize .. " -threshold " .. threshold .. " -filtersize " .. filtersize .. " -fftsettings " .. fftsettings
        local ie_cmd = ie_exe .. " " .. temp_idx

        os.execute(ns_cmd)
        local slice_points_string = capture(ie_cmd, false)
        local slice_points = spacesplit(slice_points_string)
        for i=2, #slice_points do
            local t_conversion = tonumber(slice_points[i])
            local slice_pos = sampstos(t_conversion, sr)
            item = reaper.SplitMediaItem(item, item_pos + slice_pos)
        end

        local kill_cmd = "rm -rf " .. temp_idx
        os.execute(kill_cmd)
    end
    reaper.UpdateArrange()
end
