-- Initialize Softcut for Voice 1
audio.level_adc_cut(1)
softcut.buffer_clear()
softcut.enable(1,1)
softcut.buffer(1,1)
softcut.level(1,1.0)
softcut.rate(1,1.0)
softcut.loop(1,1)
softcut.loop_start(1,1)
softcut.loop_end(1,0.5)
softcut.position(1,1)
softcut.play(1,1)
 -- set input rec level: input channel, voice, level
softcut.level_input_cut(1,1,1.0)
softcut.level_input_cut(2,1,1.0)
-- set voice 1 record level 
softcut.rec_level(1,1)
-- set voice 1 pre level
softcut.pre_level(1,1)
-- set record state of voice 1 to 1
 -- -- osc input
osc.event = osc_in

engine.name="SimpleDelay"





-- Function to record a new audio segment
local function record_new_segment()
  -- Get the current time in seconds since Norns started (or a relevant timestamp)
  local current_time = util.time() -- Norns provides util.time() for this purpose

  -- Start recording to the buffer for voice 1
  softcut.rec(1,1)    -- Start recording at the current playhead position for voice 1

  -- Store the start time of the new recording
--  table.insert(record_times, current_time)

  --print("New audio segment recorded at: " .. current_time .. " seconds")
end

local function stop_recording()
  softcut.rec(voice, 0)     -- Start recording at the current playhead position for voice 1
end
---




-- Variables for simulating onset detection
local last_onset_time = 0
local onset_min_interval = 1 -- Minimum time between onsets in seconds

-- Declare the metro variable outside init so it's accessible for stopping/starting if needed
local m

function init()
  print("Script initialized. Waiting for onsets...")

	engine.threshold(0.01)

  -- -- Initialize and configure the metro for periodic onset checks
  counter = metro.init(record_new_segment,0.5,-1) -- arguments are (event, time, count)
  counter:start()
  -- reset_counter = metro.init(reset_buffer,5,-1) -- arguments are (event, time, count)
  -- reset_counter:start()
  randomize_reset_counter = metro.init(reset_buffer,math.random(1,2),-1) -- arguments are (event, time, count)
  randomize_reset_counter:start()
end

function reset_buffer()
  -- print("Resetting buffer...")
   softcut.buffer_clear()
   softcut.position(1, 0) -- Reset the playhead position to the start
  -- print("Buffer reset complete.")
 end


function osc_in(path, args, from)
  if path == "onset" then
    print("Onset detected!")
    print("incoming signal = "..val)
-- tape_rec(i)
  end
  redraw()
end

function onset()
  print("Onset detected!")
  record_new_segment()
end

-- To view the recorded times (e.g., when the script stops or on demand)
function cleanup()
  if m then
    m.stop() -- Stop the metro when the script cleans up
  end
  print("Recorded times:")
  for i, time in ipairs(record_times) do
    print("- " .. time .. " seconds")
  end
end

---

function save_record_times_to_file(filename)
  local file = io.open(_ENV.norns.script.data_path .. "/" .. filename, "w")
  if file then
    for i, time in ipairs(record_times) do
      file:write(string.format("%.3f\n", time))
    end
    file:close()
    print("Recorded times saved to: " .. _ENV.norns.script.data_path .. "/" .. filename)
  else
    print("Error: Could not open file for saving.")
  end
end





function redraw()
  screen.clear()
  screen.move(64, 32)
  screen.text_center("Autosampler running")
  screen.update()
end

