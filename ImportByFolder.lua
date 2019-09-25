function commasplit(input_string)
  -- splits by ,
  local t = {}
  for word in string.gmatch(input_string, '([^,]+)') do
      table.insert(t, word)
  end
  return t
end

function doublequote(input_string)
  return '"'..input_string..'"'
end

function os.stdin(cmd, raw)
  -- How to use
  -- local output = capture("ls", false)
  local f = assert(io.popen(cmd, 'r'))
  local s = assert(f:read('*a'))
  f:close()
  if raw then return s end
  s = string.gsub(s, '^%s+', '')
  s = string.gsub(s, '%s+$', '')
  s = string.gsub(s, '[\n\r]+', ' ')
  return s
end

function rm_trail_slash(s)
  return s:gsub('(.)%/$', '%1')
end

function spacesplit(s)
  local t = {}
  for w in s:gmatch("%S+") do table.insert(t, w) return t end
end

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
  local fields = commasplit(user_input)
  local folder = fields[1]
  local sanitised_folder = rm_trail_slash(folder)

  -- Do folder processing --
  local cmd = "ls" .. " " .. doublequote(folder)
  local files = os.stdin(cmd)
  local split_files = spacesplit(files)
  for k, p in ipairs(split_files) do
    reaper.InsertMedia(doublequote(folder .. "/" .. p), 0)
  end
  reaper.SetEditCurPos(0.0, false, false)

  
end
  
  
