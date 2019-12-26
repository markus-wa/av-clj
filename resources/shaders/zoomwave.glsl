// taken from the Shadertone example and added rotation

float smoothbump(float center, float width, float x) {
  float w2 = width/2.0;
  float cp = center+w2;
  float cm = center-w2;
  float c = smoothstep(cm, center, x) * (1.0-smoothstep(center, cp, x));
  return c;
}

vec3 hsv2rgb(float h,float s,float v) {
  return mix(vec3(1.),clamp((abs(fract(h+vec3(3.,2.,1.)/3.)*6.-3.)-1.),0.,1.),s)*v;
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

vec2 rotateUV(vec2 uv, float rotation, vec2 mid)
{
    return vec2(
      cos(rotation) * (uv.x - mid.x) + sin(rotation) * (uv.y - mid.y) + mid.x,
      cos(rotation) * (uv.y - mid.y) - sin(rotation) * (uv.x - mid.x) + mid.y
    );
}

vec2 rotateUV(vec2 uv, float rotation, float mid)
{
    return vec2(
      cos(rotation) * (uv.x - mid) + sin(rotation) * (uv.y - mid) + mid,
      cos(rotation) * (uv.y - mid) - sin(rotation) * (uv.x - mid) + mid
    );
}

void main(void)
{
    vec2 fragCoord = gl_FragCoord.xy;

    vec2  uvOrig = fragCoord/iResolution.xy;
    float rad    = iChannelTime[0]*-0.5;
	vec2 uv      = rotateUV(uvOrig, rad)/1.4+.15; // TODO: improve/remove this /1.4+.2 hack
    float wave   = texture2D(iChannel0,vec2(uv.x,0.75)).x;
    wave         = smoothbump(0.0,(6.0/iResolution.y), wave + uv.y - 0.5);
    vec3  wc     = wave*hsv2rgb(fract(iGlobalTime/2.0),0.9,0.9);

    // zoom into the previous frame
    float zf     = -0.05;
    vec2  uv2    = (1.0+zf)*uvOrig-(zf/2.0,zf/2.0);
    vec3  pc     = 0.95*texture2D(iChannel1,uv2).rgb;

    // mix the two
    gl_FragColor = vec4(vec3(wc+pc),1.0);
}
