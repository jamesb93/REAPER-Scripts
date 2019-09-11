function sampstos(samples, sample_rate) return samples / sample_rate end

function rm_trailing_slash(s)
    -- Remove trailing slash from string. Will not remove slash if it is the
    -- only character in the string.
    return s:gsub('(.)%/$', '%1')
  end

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

function doublequote(input_string)
  return '"'..input_string..'"'
end

-- Functions pertaining to setting state --

function get_fluid_path()
    return reaper.GetExtState("flucoma", "exepath")
end

function file_exists(name)
    local f=io.open(name,"r")
    if f~=nil then io.close(f) return true else return false end
end

function is_path_valid()
    local fp = get_fluid_path()
    local ns = fp .. "/noveltyslice"
    if file_exists(ns) == true then
        reaper.ShowMessageBox("The path you set looks good!", "Path Configuration", 0)
    end
    if file_exists(ns) == false then
        reaper.ShowMessageBox("The path you set doesn't seem to contain the FluCoMa tools. Please try again.", "Path Configuration", 0)
        path_setter()
    end
end

function path_setter()
    local cancel, input = reaper.GetUserInputs("Set path to FluCoMa Executables", 1, "Path:, extrawidth=100", "/usr/local/bin")
    if cancel ~= false then
        local input_path = rm_trailing_slash(input)
        local sanitised_input_path = doublequote(input_path)
        reaper.SetExtState("flucoma", "exepath", sanitised_input_path, 1)
        is_path_valid()
    end
    if cancel == false then
        reaper.ShowMessageBox("Your path remains unconfigured. The script will now exit.", "Warning", 0)
    end
end

function set_fluid_path()
    path_setter()
end

function check_state()
    return reaper.HasExtState("flucoma", "exepath")
end

function sanity_check()
    if check_state() == false then
        reaper.ShowMessageBox("The path to the FluCoMa CLI tools is not set. Please follow the next prompt to configure it. Doing so remains persistent across projects and sessions of reaper. If you need to change it please use the FluidEditPath.lua script.", "Warning!", 0)
        set_fluid_path()
    end
end