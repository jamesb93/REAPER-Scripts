local info = debug.getinfo(1,'S');
local script_path = info.source:match[[^@?(.*[\/])[^\/]-$]]
dofile(script_path .. "ReaCoMa/FluidPlumbing/FluidUtils.lua")

local confirm, user_input = reaper.GetUserInputs('Provide Folder Path', 1, 'Folder Path:', '')
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

  -- parse user input --
  local fields = fluidUtils.commasplit(user_input)
  local folder = fields[1]
  local sanitised_folder = fluidUtils.rm_trail_slash(folder)

  -- Do folder processing --
  local cmd = "ls " .. fluidUtils.doublequote(folder)
  local files = os.stdin(cmd)
  local split_files = fluidUtils.spacesplit(files)
  for k, p in ipairs(split_files) do
    reaper.InsertMedia(
      fluidUtils.doublequote(folder .. "/" .. p), 
      0
    )
  end
  reaper.SetEditCurPos(0.0, false, false)

  
end
  
  
