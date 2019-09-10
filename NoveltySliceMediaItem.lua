function os.capture(cmd, raw)
    -- How to use
    -- local output = os.capture("ls", false)
    local f = assert(io.popen(cmd, 'r'))
    local s = assert(f:read('*a'))
    f:close()
    if raw then return s end
    s = string.gsub(s, '^%s+', '')
    s = string.gsub(s, '%s+$', '')
    s = string.gsub(s, '[\n\r]+', ' ')
    return s
end

function commasplit(input_string)
    -- splits by ,
    local t = {}
    for word in string.gmatch(input_string, '([^,]+)') do
        table.insert(t, word)
    end
    return t
end

function spacesplit(input_string)
    local t = {}
    for word in input_string:gmatch("%w+") do table.insert(t, word) end
    return t
end

function tablelen(t)
  local count = 0
  for _ in pairs(t) do count = count + 1 end
  return count
end

function sampstos(samples, sample_rate) return samples / sample_rate end

local num_selected_items = reaper.CountSelectedMediaItems(0)
if cancel ~= false and num_selected_items > 0 then
    local cancel, user_inputs = reaper.GetUserInputs("Novelty Slice Parameters", 5, "feature,threshold,kernelsize,filtersize,fftsettings", "0,0.5,3,1,1024 512 1024")
    local item = reaper.GetSelectedMediaItem(0, 0)
    local proj_path = reaper.GetProjectPathEx(0, "")
    local proj_name = reaper.GetProjectName(0, "")

    local params = commasplit(user_inputs)
    local feature = params[1]
    local threshold = params[2]
    local kernelsize = params[3]
    local filtersize = params[4]
    local fftsettings = params[5]
    
    local temp_idx = proj_path .. "/fluid_novelty_slice_reaper.wav"

    --   Each user MUST point this to their folder containing FluCoMa CLI executables
    local cli_path = '/Users/jamesbradbury/dev/bin'
    --   Then we form some calls to the tools that will live in that folder
    local ie_exe = cli_path .. '/index_extractor '
    local ns_exe = cli_path .. '/noveltyslice '

    --   Get info for item in REAPER
    local take = reaper.GetActiveTake(item)
    local src = reaper.GetMediaItemTake_Source(take)
    local sr = reaper.GetMediaSourceSampleRate(src)
    local full_path = reaper.GetMediaSourceFileName(src, '')
    local item_pos = reaper.GetMediaItemInfo_Value(item, "D_POSITION")
    local ns_cmd = ns_exe .. " -source " .. full_path .. " -indices " .. temp_idx .. " -feature " .. feature .. " -kernelsize " .. kernelsize .. " -threshold " .. threshold .. " -filtersize " .. filtersize .. " -fftsettings " .. fftsettings
    local ie_cmd = ie_exe .. " " .. temp_idx

    os.execute(ns_cmd)
    local slice_points_string = os.capture(ie_cmd, false)
    local slice_points = spacesplit(slice_points_string)

    for i=2, #slice_points do
    local t_conversion = tonumber(slice_points[i])
    local slice_pos = sampstos(t_conversion, sr)
    item = reaper.SplitMediaItem(item, item_pos + slice_pos)
    end
    local kill_cmd = "rm -rf " .. temp_idx
    os.execute(kill_cmd)
    reaper.UpdateArrange()
end
