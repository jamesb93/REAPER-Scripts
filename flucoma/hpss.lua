local info = debug.getinfo(1,'S');
local script_path = info.source:match[[^@?(.*[\/])[^\/]-$]]
dofile(script_path .. "FluidUtils.lua")

------------------------------------------------------------------------------------
--   Each user MUST point this to their folder containing FluCoMa CLI executables --
if sanity_check() == false then goto exit; end
local cli_path = get_fluid_path()
--   Then we form some calls to the tools that will live in that folder --
local hpss_suf = cli_path .. "/hpss"
local hpss_exe = doublequote(hpss_suf)
------------------------------------------------------------------------------------

local num_selected_items = reaper.CountSelectedMediaItems(0)
if num_selected_items > 0 then
    local captions = "harmfiltersize,percfiltersize,maskingmode,fftsettings,harmthresh,percthresh"
    local caption_defaults = "17, 31, 0 , 1024 512 1024, 0.0 1.0 1.0 1.0, 0.0 1.0 1.0 1.0"
    local confirm, user_inputs = reaper.GetUserInputs("HPSS Parameters", 6, captions, caption_defaults)
    if confirm then 
        reaper.Undo_BeginBlock()
        -- Algorithm Parameters
        local params = commasplit(user_inputs)
        local hfs = params[1]
        local pfs = params[2]
        local maskingmode = params[3]
        local fftsettings = params[4]
        local hthresh = params[5]
        local pthresh = params[6]

        local item_t = {}
        local sr_t = {}
        local full_path_t = {}
        local take_ofs_t = {}
        local take_ofs_samples_t = {}
        local item_pos_t = {}
        local item_len_t = {}
        local item_pos_samples_t = {}
        local item_len_samples_t = {}
        local hpss_cmd_t = {}
        local harm_t = {}
        local perc_t = {}
        local resi_t = {}

        for i=1, num_selected_items do
            local item = reaper.GetSelectedMediaItem(0, i-1)
            local take = reaper.GetActiveTake(item)
            local src = reaper.GetMediaItemTake_Source(take)
            local sr = reaper.GetMediaSourceSampleRate(src)
            local full_path = reaper.GetMediaSourceFileName(src, '')
            table.insert(item_t, item)
            table.insert(sr_t, sr)
            table.insert(full_path_t, full_path)
        
            local take_ofs = reaper.GetMediaItemTakeInfo_Value(take, "D_STARTOFFS")
            local item_pos = reaper.GetMediaItemInfo_Value(item, "D_POSITION")
            local item_len = reaper.GetMediaItemInfo_Value(item, "D_LENGTH")
            table.insert(take_ofs_t, take_ofs)
            table.insert(item_pos_t, item_pos)
            table.insert(item_len_t, item_len)

            -- Now make the name for the separated parts using the offset to create a unique id --
            -- Using the offset means that slices won't share names at the output in the situation where you nmf on segments --
            table.insert(harm_t, basename(full_path) .. "_hpss-h_" .. tostring(take_ofs) .. ".wav")
            table.insert(perc_t, basename(full_path) .. "_hpss-p_" .. tostring(take_ofs) .. ".wav")
            table.insert(resi_t, basename(full_path) .. "_hpss-r_" .. tostring(take_ofs) .. ".wav")

            local take_ofs_samples = stosamps(take_ofs, sr)
            local item_pos_samples = stosamps(item_pos, sr)
            local item_len_samples = stosamps(item_len, sr)
            table.insert(take_ofs_samples_t, take_ofs_samples)
            table.insert(item_pos_samples_t, item_pos_samples)
            table.insert(item_len_samples_t, item_len_samples)
            
            -- Form the commands to shell and store in a table --
            table.insert(hpss_cmd_t, hpss_exe .. " -source " .. doublequote(full_path) .. 
                " -harmonic " .. doublequote(harm_t[i]) .. 
                " -percussive " .. doublequote(perc_t[i]) .. 
                " -residual " .. doublequote(resi_t[i]) .. 
                " -harmfiltersize " .. hfs .. " -percfiltersize " .. pfs .. 
                " -maskingmode " .. maskingmode .. " -harmthresh " .. hthresh .. " -percthresh " .. pthresh ..
                " -fftsettings " .. fftsettings .. " -numframes " .. item_len_samples .. " -startframe " .. take_ofs_samples)
        end
        -- Execute NMF Process
        for i=1, num_selected_items do
            os.execute(hpss_cmd_t[i])
        end
        reaper.SelectAllMediaItems(0, 0)
        for i=1, num_selected_items do
            if i > 1 then reaper.SetMediaItemSelected(item_t[i-1], false) end
            reaper.SetMediaItemSelected(item_t[i], true)
            reaper.InsertMedia(harm_t[i],3)
            reaper.InsertMedia(perc_t[i],3)    
            reaper.InsertMedia(resi_t[i],3)    
        end
        reaper.UpdateArrange()
        reaper.Undo_EndBlock("HPSS", 0)
    end
end
::exit::
