#! /usr/bin/env lua

--
-- Sample GStreamer application, port of public Vala GStreamer Audio
-- Stream Example (http://live.gnome.org/Vala/GStreamerSample)
--

local lgi = require 'lgi'
local GLib = lgi.GLib
local Gst = lgi.Gst
local GObject=lgi.GObject
--local gpb=lgi.Gst.Element.Pipeline.PlayBin
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

local dh=require"dumphash"
local play = Gst.ElementFactory.make('playbin', 'playbin')
local sink = Gst.ElementFactory.make('cluttersink', 'sink')
--play.uri = 'file:///home/dr/data/ICE2015_led.mov'
play.uri = 'udp://239.255.12.42:5004'
--play._property.flags=595
print(play)
play.video_sink=sink
Gst.util_set_object_arg(play,"flags",'deinterlace+native-video+soft-volume+audio+video')
--play.flags=0x253 == GST_PLAY_FLAG_DEINTERLACE|GST_PLAY_FLAG_NATIVE_VIDEO|GST_PLAY_FLAG_SOFT_VOLUME|GST_PLAY_FLAG_AUDIO|GST_PLAY_FLAG_VIDEO
--play.flags={'GST_PLAY_FLAG_DEINTERLACE','GST_PLAY_FLAG_NATIVE_VIDEO','GST_PLAY_FLAG_SOFT_VOLUME','GST_PLAY_FLAG_AUDIO','GST_PLAY_FLAG_VIDEO'}
play.bus:add_watch(GLib.PRIORITY_DEFAULT, bus_callback)
play.state = 'PLAYING'
--print("meeh")
--dh.dumphash(Gst.BinFlags:_resolve(true))
--print("moeh")
----dh.dumphash(GObject:_resolve(true))

-- Run the loop.
main_loop:run()
play.state = 'NULL'
