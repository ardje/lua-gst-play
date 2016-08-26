#! /usr/bin/env lua

--
-- Sample GStreamer application, port of public Vala GStreamer Audio
-- Stream Example (http://live.gnome.org/Vala/GStreamerSample)
--

local lgi = require 'lgi'
local GLib = lgi.GLib
local Gst = lgi.Gst
local Enum=require'lgi.enum'


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
local sink = Gst.ElementFactory.make('cluttersink', 'sink')
--play.uri = 'file:///home/dr/data/ICE2015_led.mov'
play.uri = 'file:////home/ard/ICE2015_led.mov'
play.video_sink=sink
print('play:',play['flags'])
--play.flags:set(0x253)
--print(play.flags)
--play.flags=595
--play.flags=0x253 == GST_PLAY_FLAG_DEINTERLACE|GST_PLAY_FLAG_NATIVE_VIDEO|GST_PLAY_FLAG_SOFT_VOLUME|GST_PLAY_FLAG_AUDIO|GST_PLAY_FLAG_VIDEO

--play.flags={'GST_PLAY_FLAG_DEINTERLACE','GST_PLAY_FLAG_NATIVE_VIDEO','GST_PLAY_FLAG_SOFT_VOLUME','GST_PLAY_FLAG_AUDIO','GST_PLAY_FLAG_VIDEO'}
--play.flags='GST_PLAY_FLAG
--play.uri = 'http://www.cybertechmedia.com/samples/raycharles.mov'
play.bus:add_watch(GLib.PRIORITY_DEFAULT, bus_callback)
play.state = 'PLAYING'

-- Run the loop.
main_loop:run()
play.state = 'NULL'
