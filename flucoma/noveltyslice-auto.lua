-- local info = debug.getinfo(1,'S');
-- local script_path = info.source:match[[^@?(.*[\/])[^\/]-$]]
-- dofile(script_path .. "FluidUtils.lua")

-- ------------------------------------------------------------------------------------
-- --   Each user MUST point this to their folder containing FluCoMa CLI executables --
-- if sanity_check() == false then goto exit; end
-- local cli_path = get_fluid_path()
-- --   Then we form some calls to the tools that will live in that folder --
-- local ie_suf = cli_path .. "/index_extractor"
-- local ie_exe = doublequote(ie_suf)
-- local ns_suf = cli_path .. "/noveltyslice"
-- local ns_exe = doublequote(ns_suf)
-- ------------------------------------------------------------------------------------

-- local num_selected_items = reaper.CountSelectedMediaItems(0)
-- if num_selected_items > 0 then
--     local confirm, user_inputs = reaper.GetUserInputs("Novelty Slice Parameters", 5, "feature,threshold,kernelsize,filtersize,fftsettings", "0,0.5,3,1,1024 512 1024")
--     if confirm then
--         reaper.Undo_BeginBlock()
--         -- Algorithm Parameters
--         local params = commasplit(user_inputs)
--         local feature = params[1]
--         local threshold = params[2]
--         local kernelsize = params[3]
--         local filtersize = params[4]
--         local fftsettings = params[5]

--         local full_path_t = {}
--         local item_pos_t = {}
--         local item_len_t = {}
--         local item_pos_samples_t = {}
--         local item_len_samples_t = {}
--         local ns_cmd_t = {}
--         local ie_cmd_t = {}
--         local slice_points_string_t = {}
--         local tmp_file_t = {}
--         local tmp_idx_t = {}
--         local item_t = {}
--         local sr_t = {}
--         local take_ofs_t = {}
--         local take_ofs_samples_t = {}

--         for i=1, num_selected_items do
--             local tmp_file = os.tmpname()
--             local tmp_idx = doublequote(tmp_file .. ".wav")
--             table.insert(tmp_file_t, tmp_file)
--             table.insert(tmp_idx_t, tmp_idx)

--             local item = reaper.GetSelectedMediaItem(0, i-1)
--             local take = reaper.GetActiveTake(item)
--             local src = reaper.GetMediaItemTake_Source(take)
--             local sr = reaper.GetMediaSourceSampleRate(src)
--             local full_path = reaper.GetMediaSourceFileName(src, '')
--             table.insert(item_t, item)
--             table.insert(sr_t, sr)
--             table.insert(full_path_t, full_path)
            
--             local take_ofs = reaper.GetMediaItemTakeInfo_Value(take, "D_STARTOFFS")
--             local item_pos = reaper.GetMediaItemInfo_Value(item, "D_POSITION")
--             local item_len = reaper.GetMediaItemInfo_Value(item, "D_LENGTH")
--             table.insert(take_ofs_t, take_ofs)
--             table.insert(item_pos_t, item_pos)
--             table.insert(item_len_t, item_len)
        
--             -- Convert everything to samples for CLI --
--             local take_ofs_samples = stosamps(take_ofs, sr)
--             local item_pos_samples = stosamps(item_pos, sr)
--             local item_len_samples = stosamps(item_len, sr)
--             table.insert(take_ofs_samples_t, take_ofs_samples)
--             table.insert(item_pos_samples_t, item_pos_samples)
--             table.insert(item_len_samples_t, item_len_samples)

--             local ns_cmd = ns_exe .. " -source " .. doublequote(full_path) .. " -indices " .. doublequote(tmp_idx) .. " -feature " .. feature .. " -kernelsize " .. kernelsize .. " -threshold " .. threshold .. " -filtersize " .. filtersize .. " -fftsettings " .. fftsettings .. " -numframes " .. item_len_samples .. " -startframe " .. take_ofs_samples
--             local ie_cmd = ie_exe .. " " .. tmp_idx
--             table.insert(ns_cmd_t, ns_cmd)
--             table.insert(ie_cmd_t, ie_cmd)
--         end

--         -- Fill the table with slice points
--         for i=1, num_selected_items do
--             os.execute(ns_cmd_t[i])
--             table.insert(slice_points_string_t, capture(ie_cmd_t[i], false))
--         end

--         -- Execution
--         for i=1, num_selected_items do
--             local slice_points = spacesplit(slice_points_string_t[i])
--             for j=2, #slice_points do
--                 slice_pos = sampstos(
--                     tonumber(slice_points[j]), sr_t[i]
--                 )
--                 item_t[i] = reaper.SplitMediaItem(item_t[i], item_pos_t[i] + (slice_pos - take_ofs_t[i]))
--             end
--         end
--         reaper.UpdateArrange()
--         reaper.Undo_EndBlock("noveltyslice", 0)
--         for i=1, num_selected_items do
--             remove_file(tmp_idx_t[i])
--             remove_file(tmp_file_t[i])
--         end
--     end
-- end
-- ::exit::

-------------------- WORKING OUT -------------------------
function capture(cmd, raw)
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

function doublequote(input_string)
  return '"'..input_string..'"'
end

function spacesplit(input_string)
    local t = {}
    for word in input_string:gmatch("%w+") do table.insert(t, word) end
    return t
end

function noveltyslice(source, indices, feature, threshold, kernelsize, filtersize, fftsettings)
    os.execute(
        "/Users/jamesbradbury/dev/bin/noveltyslice" ..
        " -source " .. source ..
        " -indices " .. indices ..
        " -feature " .. feature .. 
        " -threshold " .. threshold .. 
        " -kernelsize " .. kernelsize .. 
        " -filtersize " .. filtersize .. 
        " -fftsettings " .. fftsettings)
end

function tablelen(t)
  local count = 0
  for _ in pairs(t) do count = count + 1 end
  return count
end

function slice(thresh)
    noveltyslice(src, idx, "0", thresh, "7", "3", "2048 -1 -1")
end


-------- WORKING PROTOTYPE --------
start = os.clock()
math.randomseed(os.clock() * 100000000000)

src = "/Users/jamesbradbury/Desktop/auto_thresh/aswine.wav"
idx = "/Users/jamesbradbury/Desktop/auto_thresh/out1.wav"
target_slices = tonumber(arg[1])
print(target_slices)
max_iter = 100
iter = 0
init_thresh = 0.1
curr_thresh = 0.0
read_cmd = "/Users/jamesbradbury/dev/bin/index_extractor" .. " " .. idx
local num_slices = 0
while iter ~= max_iter do
    if iter == 0 then -- on our first loop we have to initialise
        slice(tostring(curr_thresh))
        num_slices = tablelen(spacesplit(capture(read_cmd, false)))
        curr_thresh = init_thresh
    else
        if num_slices == target_slices then goto exit end

        if num_slices > target_slices then 
            curr_thresh = curr_thresh * (1.23 + (math.random() * 0.05))
            slice(tostring(curr_thresh))
            num_slices = tablelen(spacesplit(capture(read_cmd, false)))
        end
        if num_slices < target_slices then
            curr_thresh = curr_thresh * (0.8 + (math.random() * 0.05))
            slice(tostring(curr_thresh))
            num_slices = tablelen(spacesplit(capture(read_cmd, false)))
        end
    end
    iter = iter + 1 -- move forward in our iterations
end
::exit::
print(curr_thresh)



