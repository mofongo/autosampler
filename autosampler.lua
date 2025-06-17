-- Initialize Softcut for Voice 1
audio.level_adc_cut(1)
audio.level_eng_cut(1)
voices = 3

function init_softcut()
  for i = 1, voices do
    softcut.buffer_clear()
    softcut.enable(i, 1) -- Enable voice i
    softcut.buffer(i, i) -- Assign buffer i to voice i (assuming one buffer per voice)
    softcut.level(i, 1.0) -- Set level for voice i
    softcut.rate(i, 1.0) -- Set playback rate for voice i
    softcut.loop(i, 1) -- Enable looping for voice i
    softcut.loop_start(i, 0) -- Set loop start for voice i
    softcut.loop_end(i, 1) -- Set loop end for voice i
    softcut.position(i,0)
    softcut.play(i,1)
    softcut.fade_time(i, 0.1) 
    -- set input rec level: input channel, voice, level
    softcut.level_input_cut(i,1,1.0)
    softcut.level_input_cut(i,1,1.0)
    softcut.rec_level(i,1)
    softcut.pre_level(i,1)
    softcut.level_slew_time(i,1,0.5)
  end
end


engine.name = 'PolyPerc'


_lfos = require 'lfo' -- assign the library to a general variable


local function stop_recording()
  softcut.rec(1, 0)  -- Stop recording for voice 1
end

-- Declare the metro variable outside init so it's accessible for stopping/starting if needed
local m

function timer()
  m = metro.init(randomize_voice1_pan_on_loop_start, 5, 1) -- Call randomize_voice1_pan_on_loop_start after 1 second()
  m:start()
end

function Record_new_segment()
  -- softcut.level_input_cut (1, 1, 0)
  -- softcut.level_input_cut (2, 1, 0)
  -- softcut.level_input_cut (1, 1, 1)
  -- softcut.level_input_cut (2, 1, 1)
  -- softcut.buffer_clear()
  -- softcut.position(1, 0) -- Reset the playhead position to the start
  -- softcut.rec(1,1)    -- Start recording for voice 1
  -- counter:start()     -- Start the metro to call stop_recording after a delay
  local current_time = util.time() -- Get the current time in seconds
  -- if current_time - last_onset_time >= onset_min_interval then
  --   last_onset_time = current_time
  --   print("Onset detected at: " .. current_time .. " seconds")
  --  -- record_new_segment() -- Call the function to record a new segment
  -- end
local chosen_voice = voices
  print("Record_new_segment: chosen_voice = " .. chosen_voice)

  -- Ensure input routing is active for the chosen voice (can be redundant if always on from init)
  softcut.level_input_cut (1, chosen_voice, 0) -- Briefly set to 0
  softcut.level_input_cut (2, chosen_voice, 0)
  softcut.level_input_cut (1, chosen_voice, 1.0) -- Set to 1 for recording
  softcut.level_input_cut (2, chosen_voice, 1.0)

  softcut.buffer_clear(chosen_voice) -- Clear the specific buffer for the chosen voice
  softcut.position(chosen_voice, 0) -- Reset the playhead position to the start for the chosen voice
  softcut.rec(chosen_voice, 1)    -- Start recording for the chosen_voice

  -- Configure and start the metro to stop recording for the chosen_voice
  if counter then
    counter.event = function()
      softcut.rec(chosen_voice, 0)
      print(string.format("Stopped recording voice %d into buffer %d.", chosen_voice, chosen_voice))
    end
    counter:start()     -- Start the metro (time and count are preset in init)
  end
end

local function randomize_voice1_pan_on_loop_start()
  -- local new_pan = (math.random() * 2) - 1
  local new_pan = (math.random(0, 1) * 2) - 1
  softcut.pan(1, new_pan)
  print(string.format("Softcut voice 1 pan randomized to: %.2f (on loop start)", new_pan))
end

Beat_sec = 0
rates = {2,4,8,16,32}

function forever()
  while true do
    clock.sync(1/1)
    softcut.loop(1, 1)
    softcut.play(1, 1)
    softcut.loop(1, 1)
    Record_new_segment()
   -- clock.sleep(2)
    -- softcut.play(1, 0)
    local random_number = math.random(1,2)
    --softcut.rate(1,random_number)
    softcut.pan(1,(math.random(0, 1) * 2) - 1)
    random_division = rates[math.random(#rates)]
    Beat_sec = clock.get_beat_sec()
    softcut.loop_end(1, Beat_sec / random_division) -- Set loop end to 4 beats
  end
end

function synth_trigger()
  while true do
    clock.sync(1/1)
    pitch = {60, 90, 220, 440, 880} -- Set pitch values for the PolyPerc engine
    freq = pitch[math.random(#pitch)]
    engine.hz(freq)
  end
end

function init()
  init_softcut()
  print("Script initialized. Waiting for onsets...")
  counter = metro.init(stop_recording, 1, 1) -- Call stop_recording after 1 second, once.
  p = poll.set("amp_in_l")
  p.callback = function(val)
    if val > 0.02 then Record_new_segment() end
  end
  p:start()


  clock_id = clock.run(forever)
  synth_clock = clock.run(synth_trigger)
  volume_lfo = _lfos.new()
  volume_lfo:set('shape', 'sine')
  volume_lfo:set('min', 0)
  volume_lfo:set('max', 1)
  volume_lfo:set('depth', 0.5)
  volume_lfo:set('mode', 'free')
  volume_lfo:set('period', 5)
  volume_lfo:set('action', function(scaled,raw) softcut.level(1, scaled) screen_dirty = true end)
  volume_lfo:start()
  print("Beat_sec initialized to: " .. Beat_sec)
end




function cleanup()
  if m then
    m.stop() -- Stop the metro when the script cleans up
  end
  print("Recorded times:")
  for i, time in ipairs(record_times) do
    print("- " .. time .. " seconds")
  end
end


function redraw()
  screen.clear()
  screen.move(64, 32)
  screen.text_center("Autosampler running")
  screen.update()
end
