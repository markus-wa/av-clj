# av-clj

Audio Visual stuff with [Shadertone](https://github.com/overtone/shadertone) / [GLSL](https://learnopengl.com/Getting-started/Shaders).

## Usage

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

<p align="center">
  <img alt="Zoomwave Shader" src="https://raw.githubusercontent.com/markus-wa/av-clj/master/zoomwave.png" width="50%">
</p>
