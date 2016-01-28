#! /usr/bin/env lua

--
-- Sample GStreamer application, port of public Vala GStreamer Audio
-- Stream Example (http://live.gnome.org/Vala/GStreamerSample)
--

local lgi = require 'lgi'
local GLib = lgi.GLib
local Gst = lgi.Gst

local main_loop = GLib.MainLoop()

local function bus_callback(bus, message)
   if message.type.ERROR then
      print('Error:', message:parse_error().message)
      main_loop:quit()
   elseif message.type.EOS then
      print 'end of stream'
      main_loop:quit()
   elseif message.type.STATE_CHANGED then
      local old, new, pending = message:parse_state_changed()
      print(string.format('state changed: %s->%s:%s', old, new, pending))
   elseif message.type.TAG then
      message:parse_tag():foreach(
	 function(list, tag)
	    print(('tag: %s = %s'):format(tag, tostring(list:get(tag))))
	 end)
   end

   return true
end

local play = Gst.ElementFactory.make('playbin', 'play')
play.uri = 'file:///home/dr/data/ICE2015_led.mov'
play.flags=0x253
play["video-sink"]="cluttersink"
--play.uri = 'http://www.cybertechmedia.com/samples/raycharles.mov'
play.bus:add_watch(GLib.PRIORITY_DEFAULT, bus_callback)
play.state = 'PLAYING'

-- Run the loop.
main_loop:run()
play.state = 'NULL'
