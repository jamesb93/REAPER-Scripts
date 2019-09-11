-- First we require the utilities found in FluidUtils.lua
-- This is a horrible workaround specific to REAPER
-- It forms a manual path to the path of this script
-- It looks relative to this script and uses dofile to import
local info = debug.getinfo(1,'S');
script_path = info.source:match[[^@?(.*[\/])[^\/]-$]]
dofile(script_path .. "FluidUtils.lua")



sanity_check()
-- reaper.SetExtState("fluid", "testpath", "/usr/bin", 1)
-- local path = reaper.GetExtState("fluid", "testpath")
-- reaper.ShowConsoleMsg(path)
  
