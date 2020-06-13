// taken from the Shadertone example and added rotation
// https://github.com/overtone/shadertone/blob/master/examples/zoomwave.glsl
// licensed as part of Shadertone under these conditions: https://github.com/overtone/shadertone/blob/master/LICENSE

#ifdef GL_ES
precision mediump float;
#endif

#define ZOOM -0.035
#define PREV_FRAME_ALPHA 0.95

float smoothbump(float center, float width, float x) {
    float w2 = width/4.00;
    float cp = center+w2;
    float cm = center-w2;
    float c = smoothstep(cm, center, x) * (1.0-smoothstep(center, cp, x));
    return c;
}

vec3 hsv2rgb(float h, float s, float v) {
    return mix(vec3(1.), clamp((abs(fract(h+vec3(3., 2., 1.)/3.)*6.-3.)-1.), 0., 1.), s)*v;
}

// https://gist.github.com/ayamflow/c06bc0c8a64f985dd431bd0ac5b557cd
vec2 rotateUV(vec2 uv, float rotation)
{
    float mid = 0.5;
    return vec2(
    cos(rotation) * (uv.x - mid) + sin(rotation) * (uv.y - mid) + mid,
    cos(rotation) * (uv.y - mid) - sin(rotation) * (uv.x - mid) + mid
    );
}

void main()
{
    vec2  uvOrig = gl_FragCoord.xy/iResolution.xy;
    float rad    = iTime*-1.;// rotate clock-wise
    vec2 uv      = rotateUV(uvOrig, rad);

    // fix vertical position and scaling (only needed for shadertoy.com)
    //uv.y -= 0.5;
    //uv.y *= 2.;

    // fix diagonal wave lengths
    uv.x *= 0.5;
    uv.x += 0.2;

    float wave   = texture(iChannel0, vec2(uv.x, 0.75)).x;
    wave         = smoothbump(0.0, (6.0/iResolution.y), wave + uv.y - 0.5);
    vec3  wc     = wave*hsv2rgb(fract(iTime/2.0), 0.9, 0.9);

    // zoom into the previous frame
    float zf     = ZOOM;
    vec2  uv2    = (1.0+zf)*uvOrig-(zf/2.0, zf/2.0);
    vec3  pc     = PREV_FRAME_ALPHA*texture(iChannel1, uv2).rgb;

    // mix the two
    gl_FragColor = vec4(vec3(wc+pc), 1.0);
}
