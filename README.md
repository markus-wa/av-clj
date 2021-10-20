# av-clj

Audio Visual stuff with [Shadertone](https://github.com/overtone/shadertone) / [GLSL](https://learnopengl.com/Getting-started/Shaders).

<p align="center">
  <img alt="Voronoi Shader" src="https://raw.githubusercontent.com/markus-wa/av-clj/master/voronoi.png" width="90%">
</p>

## License

For the licenses of the shaders please check each shader in `resources/shaders/*.glsl`.

Where not stated otherwise in the file header, other parts are licensed under the MIT license.

## Usage

### Linux

1. `lein deps`

2. install Jack (https://jackaudio.org/)

3. configure PulseAudio sink for Jack

        sudo apt install pulseaudio-module-jack

  in Jack, open the Settings menu, go to Options and enter the following under `Execute script after Startup`: `pacmd set-default-sink jack_out`

4. run `lein run`

5. in Jack, connect the sound source you want to use for Overtone

### Windows

For windows you'll need a fix for Shadertone that's not yet merged into the upstream repo. It's available on https://github.com/markus-wa/shadertone, just run `lein install` in that repo and you'll be good to go.

1. Start a [SuperCollider](https://supercollider.github.io/) server by running the following inside the SuperCollider IDE.

```
o = Server.default.options;

o.inDevice_("Windows WASAPI : Wave"); // we really only need the input device
o.outDevice_("Windows WASAPI : Headset"); // route it to some output
//o.device_("ASIO : Essence STX II ASIO(64)");
//o.sampleRate = 48000; // may need to adjust sample rates in device settings.
o.maxLogins = 2;

Server.default.reboot;
```

2. Run the REPL with `lein repl`

3. Start Shadertone with `(av)`

4. Play some music and enjoy

## Fake video device for GLMixer

1. Install https://github.com/umlaeute/v4l2loopback according to instructions

2. `xid=$(wmctrl -l | grep "av-clj-output" | cut -f 1 -d' ')`

3. `gst-launch-1.0 -v ximagesrc xid=$xid use-damage=false ! videoconvert ! videoscale ! "video/x-raw,width=1280,height=720,framerate=30/1,format=YUY2" ! v4l2sink device=/dev/video4`

## Streaming notes

### Simple network streaming of a single window

```
imgsrc=xid=0x05800018
gst-launch-1.0 -v ximagesrc $imgsrc ! video/x-raw,framerate=20/1 ! videoscale ! videoconvert ! x264enc tune=zerolatency bitrate=500 speed-preset=superfast ! rtph264pay ! queue ! udpsink host=127.0.0.1 port=5001

gst-launch-1.0 -v udpsrc port=5001 caps = "application/x-rtp, media=(string)video, clock-rate=(int)90000, encoding-name=(string)H264, payload=(int)96" ! rtph264depay ! decodebin ! videoconvert ! autovideosink
```
