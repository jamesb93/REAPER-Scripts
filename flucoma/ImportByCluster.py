from reaper_python import *
from datamosh.variables import unique_audio_folder
import json
import os

valid_files = [
  '.aif',
  '.wav',
  '.aiff',
]

def read_json(json_file):
    with open(json_file, 'r') as fp:
        data = json.load(fp)
        return data

cancel, _, _, captions, user_input, two = RPR_GetUserInputs('Provide JSON info', 2, 'JSON Path:, Cluster Number:', '', 1024)

if cancel != 0 and len(user_input) != 0:
  input_list = user_input.split(',', 1)
  json_path = input_list[0]
  cluster_number = input_list[1]

  json_file = read_json(json_path)

  cluster = json_file[cluster_number]
  
  for x in cluster:
    if os.path.splitext(x)[1] in valid_files:
      RPR_InsertMedia(
        os.path.join(unique_audio_folder, x),
        1
      )
