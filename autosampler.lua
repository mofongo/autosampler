-- Initialize Softcut for Voice 1
audio.level_adc_cut(1)
softcut.buffer_clear()
softcut.enable(1,1)
softcut.buffer(1,1)
softcut.level(1,1.0)
softcut.rate(1,1.0)
softcut.loop(1,1)
softcut.loop_start(1,1)
softcut.loop_end(1,0.7)
softcut.position(1,1)
softcut.play(1,1)
softcut.fade_time(1, 0.1) 
 -- set input rec level: input channel, voice, level
softcut.level_input_cut(1,1,1.0)
softcut.level_input_cut(2,1,1.0)
softcut.rec_level(1,1)
softcut.pre_level(1,1)
softcut.level_slew_time(1,0.5)

local function record_new_segment()
  softcut.level_input_cut (1, 1, 0)
  softcut.level_input_cut (2, 1, 0)
  softcut.level_input_cut (1, 1, 1)
  softcut.level_input_cut (2, 1, 1)
  softcut.buffer_clear()
  softcut.position(1, 0) -- Reset the playhead position to the start
  softcut.rec(1,1)    -- Start recording for voice 1
  counter:start()     -- Start the metro to call stop_recording after a delay
end

local function stop_recording()
  softcut.rec(1, 0)  -- Stop recording for voice 1
end

function timer()
  m = metro.init(randomize_voice1_pan_on_loop_start, 5, 1) -- Call randomize_voice1_pan_on_loop_start after 1 second()
  m:start()
end


local function randomize_voice1_pan_on_loop_start()
  -- local new_pan = (math.random() * 2) - 1
  local new_pan = (math.random(0, 1) * 2) - 1
  softcut.pan(1, new_pan)
  print(string.format("Softcut voice 1 pan randomized to: %.2f (on loop start)", new_pan))
end

-- Declare the metro variable outside init so it's accessible for stopping/starting if needed
local m

function init()
  print("Script initialized. Waiting for onsets...")
  counter = metro.init(stop_recording, 1, 1) -- Call stop_recording after 1 second, once.
  p = poll.set("amp_in_l")
  p.callback = function(val) 
   if val > 0.02 then triggerEvent() end
  end
  p:start()
end

function triggerEvent()
  local current_time = util.time() -- Get the current time in seconds
  record_new_segment()
  if current_time - last_onset_time >= onset_min_interval then
    last_onset_time = current_time
    print("Onset detected at: " .. current_time .. " seconds")
   -- record_new_segment() -- Call the function to record a new segment
  end
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
