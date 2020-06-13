void main()
{
    vec2 fragCoord  = gl_FragCoord.xy;

    // create pixel coordinates
    vec2 uv = fragCoord.xy / iResolution.xy;

    // quantize coordinates
    const float bands = 1080.0;
    const float segs = 1920.0;
    vec2 p;
    p.x = floor(uv.x*bands)/bands;
    p.y = floor(uv.y*segs)/segs;

    // read frequency data from first row of texture
    float fft  = texture( iChannel0, vec2(p.x,0.0) ).x;

    // led color
    vec3 color = mix(vec3(0.0, 2.0, 0.0), vec3(2.0, 0.0, 0.0), sqrt(uv.y));

    // mask for bar graph
    float mask = (p.y < fft) ? 1.0 : 0.1;

    // led shape
    //vec2 d = fract((uv - p) *vec2(bands, segs)) - 0.5;
    //float led = smoothstep(0.5, 0.35, abs(d.x)) *
    //            smoothstep(0.5, 0.35, abs(d.y));
    vec3 ledColor = color*mask;

    // output final color
    gl_FragColor = vec4(ledColor,1.0);
}
