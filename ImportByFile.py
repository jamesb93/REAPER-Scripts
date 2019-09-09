from reaper_python import *
import os


#spine_folder = '/Users/jamesbradbury/dev/data_bending/groupings/spines/spines_short'
#files = os.listdir(spine_folder)

cancel, _, _, captions, user_input, two = RPR_GetUserInputs('Provide a folder name', 1, 'Folder Path:', '', 1024)

if cancel != 0 and len(user_input) != 0:
  files = os.listdir(user_input)
  
  for x in files:
    RPR_InsertMedia(
      os.path.join(user_input, x),
      1
    )
  
  
