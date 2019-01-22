deviceName = 'Logidy UMI3'
device = null

MIDI_MIN = 0
MIDI_MAX = 127

LogidyDevice = {switch1 = false, switch2 = false, switch3 = false, pedal = 0}

function LogidyDevice.handle (object, deviceName, commandType, description, metadata)

   local channel = metadata['channel']
   local midiValue  = tonumber(string.sub(metadata['data'], -2), 16)

   if commandType == 'controlChange' then
      switchOn = midiValue == MIDI_MAX
      if channel  == 0 then
         LogidyDevice.switch1 = switchOn
      elseif channel == 1 then
         LogidyDevice.switch2 = switchOn
      elseif channel == 2 then
         LogidyDevice.switch3 = switchOn
      elseif channel == 3 then
         if LogidyDevice.switch3 then
            -- vertical scroll
            hs.eventtap.scrollWheel({ 0, LogidyDevice.pedal - midiValue }, {})
         elseif LogidyDevice.switch2 then
            -- horizontal scroll
            hs.eventtap.scrollWheel({ LogidyDevice.pedal - midiValue, 0 }, {})
         end
         LogidyDevice.pedal = midiValue
      end
   end
end

hs.midi.deviceCallback(function(devices, virtualDevices)
      for k, v in pairs(devices) do
         if v == deviceName then
            device = hs.midi.new(v)
         end
      end
end)

if device then
   device:callback(LogidyDevice.handle)
end
