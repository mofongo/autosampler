# autosampler

This is my first attempt at writing a Norns script. I'm mostly focused on learning to use [Softcut](https://monome.org/docs/norns/softcut/) and getting familiar with the Lua scripting launguage. The script uses a poll to track the volume of the incoming audio and records to a softcut buffer whenever the input audio passes a specified threshold. 

There are no visuals yet. 

TODO's
1. Add sync
2. add function do identify amp difference which can then be used for tempo sync, if tempo is below a certain threshhold that could change the division of the tap tempo trigger. It could be an approximation of the initial detected tempo.
3. Add LFO to control softcut amp
4. Screen design
5. Try https://monome.org/docs/norns/reference/lib/timeline
