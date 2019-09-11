from reaper_python import *
import os

valid_files = [
  '.wav',
  '.aiff',
  '.aif'
]

cancel, _, _, captions, user_input, two = RPR_GetUserInputs('Provide a folder name', 1, 'Folder Path:', '', 1024)

if cancel != 0 and len(user_input) != 0:
  files = os.listdir(user_input)
  
  
  for x in files:
    if os.path.splitext(x)[1] in valid_files:
      RPR_InsertMedia(
        os.path.join(user_input, x),
        1
      )
  
  
