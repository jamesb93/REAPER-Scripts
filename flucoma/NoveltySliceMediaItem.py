from reaper_python import *
import os
import sys
import shutil
import tempfile as tf
import subprocess

def sampstos(samples, sample_rate):
  return float((samples / sample_rate))

cancel, _, _, captions, user_input, _ = RPR_GetUserInputs('Novelty Slice Parameters', 5, 'feature,threshold,kernelsize,filtersize,fftsettings', '0,0.5,3,1,1024 512 1024', 512)
# parse user input
if cancel != 0:
  params = user_input.split(',')
  
  feature = params[0]
  threshold = params[1]
  kernelsize = params[2]
  filtersize = params[3]
  fftsettings = params[4]
  
  temp_dir = tf.mkdtemp()
  temp_idx = os.path.join(temp_dir, 'fluid_novelty_slice_reaper.wav')

  # Each user MUST point this to their folder containing FluCoMa CLI executables
  cli_path = '/Users/jamesbradbury/dev/bin'
  # Then we form some calls to the tools that will live in that folder
  index_extractor_exe = os.path.join(cli_path, 'index_extractor')
  novelty_slice_exe = os.path.join(cli_path, 'noveltyslice')

  # Get info for item in REAPER
  item = RPR_GetSelectedMediaItem(0, 0)
  take = RPR_GetActiveTake(item)
  src = RPR_GetMediaItemTake_Source(take)
  sr = RPR_GetMediaSourceSampleRate(src)
  _, full_path, _ = RPR_GetMediaSourceFileName(src, '', 1024)
  item_pos = RPR_GetMediaItemInfo_Value(item, "D_POSITION")

  novelty_slice = subprocess.Popen([
    novelty_slice_exe, 
    '-source', full_path,
    '-indices', temp_idx,
    '-feature', feature,
    '-kernelsize', kernelsize,
    '-threshold', threshold,
    '-filtersize', filtersize,
    '-fftsettings', fftsettings[0], fftsettings[1], fftsettings[2]])
  novelty_slice.wait()

  idx_extract = subprocess.run([index_extractor_exe, temp_idx], stdout=subprocess.PIPE, stderr=subprocess.PIPE).stdout.decode('utf-8')

  slice_points = idx_extract.split()

  for i in range(1, len(slice_points)):
    slice_pos = sampstos(
      float(slice_points[i]),
      sr
    ) 
    item = RPR_SplitMediaItem(item, item_pos + slice_pos)
  RPR_UpdateArrange()

  # get track
  #track = RPR_GetSelectedTrack(0, 0)
  #track_number = RPR_GetMediaTrackInfo_Value(track, "IP_TRACKNUMBER")
  #new_track = RPR_InsertTrackAtIndex(int(track_number), True)

  shutil.rmtree(temp_dir)
