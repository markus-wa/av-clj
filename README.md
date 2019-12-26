# av-clj

Audio Visual stuff with Shadertone / GLSL.

## Usage

1. Start SuperCollider server by running the following inside the SuperCollider IDE.

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

3. Connect to the SuperCollider server with `(connect)`

4. Start Shadertone with `(av)`
