local info = debug.getinfo(1,'S');
script_path = info.source:match[[^@?(.*[\/])[^\/]-$]]
dofile(script_path .. "FluidUtils.lua")

------------------------------------------------------------------------------------
--   Each user MUST point this to their folder containing FluCoMa CLI executables --
if sanity_check() == false then goto exit; end
local cli_path = get_fluid_path()
--   Then we form some calls to the tools that will live in that folder --
local ie_suf = cli_path .. "/index_extractor"
local ie_exe = doublequote(ie_suf)
local ns_suf = cli_path .. "/noveltyslice"
local ns_exe = doublequote(ns_suf)
------------------------------------------------------------------------------------

num_selected_items = reaper.CountSelectedMediaItems(0)
if num_selected_items > 0 then
    local cancel, user_inputs = reaper.GetUserInputs("Novelty Slice Parameters", 5, "feature,threshold,kernelsize,filtersize,fftsettings", "0,0.5,3,1,1024 512 1024")

    -- Algorithm Parameters
    local params = commasplit(user_inputs)
    local feature = params[1]
    local threshold = params[2]
    local kernelsize = params[3]
    local filtersize = params[4]
    local fftsettings = params[5]

    full_path_t = {}
    item_pos_t = {}
    item_len_t = {}
    item_pos_samples_t = {}
    item_len_samples_t = {}
    ns_cmd_t = {}
    ie_cmd_t = {}
    slice_points_string_t = {}
    tmp_file_t = {}
    tmp_idx_t = {}
    item_t = {}

    for i=1, num_selected_items do
        tmp_file = os.tmpname()
        tmp_idx = doublequote(tmp_file .. ".wav")
        table.insert(tmp_file_t, tmp_file)
        table.insert(tmp_idx_t, tmp_idx)

        item = reaper.GetSelectedMediaItem(0, i-1)
        table.insert(item_t, item)
        take = reaper.GetActiveTake(item)
        src = reaper.GetMediaItemTake_Source(take)
        sr = reaper.GetMediaSourceSampleRate(src)
        full_path = reaper.GetMediaSourceFileName(src, '')
        table.insert(full_path_t, full_path)

        item_pos = reaper.GetMediaItemInfo_Value(item, "D_POSITION")
        item_len = reaper.GetMediaItemInfo_Value(item, "D_LENGTH")
        table.insert(item_pos_t, item_pos)
        table.insert(item_len_t, item_len)
        item_pos_samples = stosamps(item_pos, sr)
        item_len_samples = stosamps(item_len, sr)
        table.insert(item_pos_samples_t, item_pos_samples)
        table.insert(item_len_samples_t, item_len_samples)

        ns_cmd = ns_exe .. " -source " .. full_path .. " -indices " .. tmp_idx .. " -feature " .. feature .. " -kernelsize " .. kernelsize .. " -threshold " .. threshold .. " -filtersize " .. filtersize .. " -fftsettings " .. fftsettings .. " -numframes " .. item_len_samples .. " -startframe " .. item_pos_samples
        ie_cmd = ie_exe .. " " .. tmp_idx
        table.insert(ns_cmd_t, ns_cmd)
        table.insert(ie_cmd_t, ie_cmd)
    end

    -- Fill the table with slice points
    for i=1, num_selected_items do
        os.execute(ns_cmd_t[i])
        table.insert(slice_points_string_t, capture(ie_cmd_t[i], false))
    end

    -- Execution
    for i=1, num_selected_items do
        local slice_points = spacesplit(slice_points_string_t[i])
        for j=2, #slice_points do
            slice_pos = sampstos(
                tonumber(slice_points[j]), sr
            )
            item_t[i] = reaper.SplitMediaItem(item_t[i], item_pos_t[i] + slice_pos)
        end
    end
    reaper.UpdateArrange()

    for i=1, num_selected_items do
        remove_file(tmp_idx_t[i])
        remove_file(tmp_file_t[i])
    end
end
::exit::
