// Created by inigo quilez - iq/2013
// License Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License.


// See also:
//
// Input - Keyboard    : https://www.shadertoy.com/view/lsXGzf
// Input - Microphone  : https://www.shadertoy.com/view/llSGDh
// Input - Mouse       : https://www.shadertoy.com/view/Mss3zH
// Input - Sound       : https://www.shadertoy.com/view/Xds3Rr
// Input - SoundCloud  : https://www.shadertoy.com/view/MsdGzn
// Input - Time        : https://www.shadertoy.com/view/lsXGz8
// Input - TimeDelta   : https://www.shadertoy.com/view/lsKGWV
// Inout - 3D Texture  : https://www.shadertoy.com/view/4llcR4


void main()
{
    vec2 fragCoord = gl_FragCoord.xy;
    // create pixel coordinates
    vec2 uv = fragCoord.xy / iResolution.xy;

    uv.y -= 0.5;

    // the sound texture is 512x2
    int tx = int(uv.x*1024);

    // first row is frequency data (48Khz/4 in 512 texels, meaning 23 Hz per texel)
    float fft  = texelFetch( iChannel0, ivec2(tx,0), 0 ).x;

    // second row is the sound wave, one texel is one mono sample
    float wave = texelFetch( iChannel0, ivec2(tx,1), 0 ).x;

    // convert frequency to colors
    vec3 col = vec3( fft, 4.0*fft*(1.0-fft), 1.0-fft ) * fft;

    // add wave form on top
    col += 1.0 -  smoothstep( 0.0, 0.15, abs(wave - uv.y) );

    // output final color
    gl_FragColor = vec4(col,1.0);
}