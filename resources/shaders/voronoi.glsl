// Created by genis sole - 2016
// License Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International.

const float PI = 3.1416;

vec2 hash2( vec2 p )
{
    // procedural white noise
    return fract(sin(vec2(dot(p,vec2(127.1,311.7)),
    dot(p,vec2(269.5,183.3))))*43758.5453);
}

// From http://www.iquilezles.org/www/articles/voronoilines/voronoilines.htm
vec3 voronoi( in vec2 x )
{
    vec2 n = floor(x);
    vec2 f = fract(x);

    //----------------------------------
    // first pass: regular voronoi
    //----------------------------------
    vec2 mg, mr;

    float md = 8.0;
    for( int j=-1; j<=1; j++ )
    for( int i=-1; i<=1; i++ )
    {
        vec2 g = vec2(float(i),float(j));
        vec2 o = hash2( n + g );
        #ifdef ANIMATE
        o = 0.5 + 0.5*sin( iTime + 6.2831*o );
        #endif
        vec2 r = g + o - f;
        float d = dot(r,r);

        if( d<md )
        {
            md = d;
            mr = r;
            mg = g;
        }
    }

    //----------------------------------
    // second pass: distance to borders
    //----------------------------------
    md = 8.0;
    for( int j=-2; j<=2; j++ )
    for( int i=-2; i<=2; i++ )
    {
        vec2 g = mg + vec2(float(i),float(j));
        vec2 o = hash2( n + g );
        #ifdef ANIMATE
        o = 0.5 + 0.5*sin( iTime + 6.2831*o );
        #endif
        vec2 r = g + o - f;

        if( dot(mr-r,mr-r)>0.00001 )
        md = min( md, dot( 0.5*(mr+r), normalize(r-mr) ) );
    }

    return vec3( md, mr );
}


// Modified version of the above iq's voronoi borders.
// Returns the distance to the border in a given direction.
vec3 voronoi( in vec2 x, in vec2 dir)
{
    vec2 n = floor(x);
    vec2 f = fract(x);

    //----------------------------------
    // first pass: regular voronoi
    //----------------------------------
    vec2 mg, mr;

    float md = 8.0;
    for( int j=-1; j<=1; j++ )
    for( int i=-1; i<=1; i++ )
    {
        vec2 g = vec2(float(i),float(j));
        vec2 o = hash2( n + g );
        vec2 r = g + o - f;
        float d = dot(r,r);

        if( d<md )
        {
            md = d;
            mr = r;
            mg = g;
        }
    }

    //----------------------------------
    // second pass: distance to borders
    //----------------------------------
    md = 1e5;
    for( int j=-2; j<=2; j++ )
    for( int i=-2; i<=2; i++ )
    {
        vec2 g = mg + vec2(float(i),float(j));
        vec2 o = hash2( n + g );
        vec2 r = g + o - f;


        if( dot(r-mr,r-mr) > 1e-5 ) {

            vec2 f = r-mr;

            if (dot(dir, f) > 1e-5) {
                vec2 m = 0.5*(mr+r);
                float c = m.x*(m.y + f.x) - m.y*(m.x - f.y);
                float d = 1.0 / dot(dir, f);

                md = min(md, dot(dir, dir*c*d));
            }
        }

    }

    return vec3( md, n+mg);
}
float gridWidth = 1.25;
bool IRayAABox(in vec3 ro, in vec3 rd, in vec3 invrd, in vec3 bmin, in vec3 bmax,
out vec3 p0, out vec3 p1)
{
    vec3 orig = .5*bmin+.5*bmax+vec3(iTime*2.5,0,0);
    vec2 grid = (bmax.xz-bmin.xz)*gridWidth;
    vec3 plane = (orig.y-ro.y)*invrd.y*rd+ro;
    vec2 cell = floor((plane.xz+orig.xz)/grid+0.5);
    vec2 srcCell = floor((ro.xz+orig.xz)/grid+0.5);
    //vec2 m = cell*0.1;
    //mat3 rotX = mat3(1.0, 0.0, 0.0, 0.0, cos(m.y), sin(m.y), 0.0, -sin(m.y), cos(m.y));
    //mat3 rotY = mat3(cos(m.x), 0.0, -sin(m.x), 0.0, 1.0, 0.0, sin(m.x), 0.0, cos(m.x));
    bmin.xz+=cell*grid-vec2(iTime*2.5,0);
    bmax.xz+=cell*grid-vec2(iTime*2.5,0);
    //bmin.y+= floor(distance(cell,srcCell));
    //bmax.y+= floor(distance(cell,srcCell));

    //bmin.yzx*=rotY;
    //bmax.yzx*=rotY;
    //bmin.zyx*=rotX;
    //bmax.zyx*=rotX;

    vec3 t0 = (bmin - ro) * invrd;
    vec3 t1 = (bmax - ro) * invrd;

    vec3 tmin = min(t0, t1);
    vec3 tmax = max(t0, t1);

    float fmin = max(max(tmin.x, tmin.y), tmin.z);
    float fmax = min(min(tmax.x, tmax.y), tmax.z);

    p0 = ro + rd*fmin;
    p1 = ro + rd*fmax;

    //p0.y-= floor(distance(cell,srcCell));
    //p1.y-= floor(distance(cell,srcCell));
    return fmax >= fmin;
}

vec3 AABoxNormal(vec3 bmin, vec3 bmax, vec3 p)
{
    vec3 n1 = -(1.0 - smoothstep(0.0, 0.03, p - bmin));
    vec3 n2 = (1.0 -  smoothstep(0.0, 0.03, bmax - p));

    return normalize(n1 + n2);
}

const vec3 background = vec3(0.04);
const vec3 scmin = vec3(-2.0, -0.5, -2.0);
const vec3 scmax = vec3(+2.0, +1.5, +2.0);

vec3 frequency = vec3(1.0,0.7,0.4);
// From http://iquilezles.org/www/articles/palettes/palettes.htm
vec3 pal( in float t, in vec3 a, in vec3 b, in vec3 c, in vec3 d )
{
    return a + b*cos( 6.28318*(c*t+frequency*mod(t,10.0)+d) );
}
vec4 max2(float a, vec4 b){return max(vec4(a),b);}
vec4 sound(vec2 v) {
    vec4 bass = max2(0.02,log2(.5+texture(iChannel0, vec2(1./iChannelResolution[0].x,0))));
    vec4 treble = max2(0.02,texture(iChannel0, vec2(hash2(v).x, 0.0))*2.0-1.0);
    return treble+bass;
}
vec3 color(vec2 p) {
    //const float varia = 0.02;
    const float varia = 0.3;
    return pal(2.+iTime/3.434+hash2(p).x*varia,
    vec3(0.5,0.5,0.5),vec3(0.5,0.5,0.5),vec3(1.0,0.7,0.4),vec3(0.0,0.15,0.20)+(sound(p).x-0.5)*2.0  );
}

float disp(vec3 v) {
    return (0.0*smoothstep(0.05,0.08,v.x)+1.0)*(scmin.y + 0.5* (0.1 + hash2(v.yz).x * 0.5 + sound(v.yz).r*2.0));
}
vec4  saturate(vec4  a) { return clamp(a, 0.0, 1.0); }
vec3  saturate(vec3  a) { return clamp(a, 0.0, 1.0); }
vec2  saturate(vec2  a) { return clamp(a, 0.0, 1.0); }
float saturate(float a) { return clamp(a, 0.0, 1.0); }

vec4 doMap(vec3 voro) {
    vec3 v = voro*0.5;
    float height = 0.1+0.9*disp(v);
    //v.x=(-0.05+v.x);
    return vec4(v, height);
}
vec4 map(in vec2 p, in vec2 dir) {
    return doMap(voronoi(p*2.0, dir));
}
vec4 map(in vec2 p) {
    return doMap(voronoi(p*2.0));
}

float wrappedDiffuse(vec3 N, vec3 L, float w, float n) {
    return pow(saturate((dot(N, L)+ w)/ (1.0+ w)), n)* (1.0+ n)/ (2.0* (1.0+ w));
}
float ShadowFactor(in vec3 ro, in vec3 rd) {
    vec3 p0 = vec3(0.0);
    vec3 p1 = vec3(0.0);

    IRayAABox(ro, rd, 1.0/rd, scmin, scmax, p0, p1);
    vec2 dir = normalize(rd.xz);
    float rs = map(ro.xz, dir).x;
    p0 = ro + rd*0.02;

    float sf = rd.y / length(rd.xz);

    float m = -1e5;

    vec4 v;
    const int max_steps = 32;
    for (int i = max_steps; i > 0; --i) {

        if (dot((p1 - p0), rd) < 0.0) return 1.0;

        v = map(p0.xz, dir);

        m = v.w;
        if (p0.y < m) break;// return 0.0;

        p0 += rd*(length(vec2(v.x, v.x*sf)) + 0.01);
    }
    vec3 i1 = vec3(1,0,0);
    vec3 i2 = vec3(0,1,0);
    vec3 j1 = (p1 - p0);
    return (1.0-smoothstep(1.5,0.1,v.x));

}

vec3 Shade(in vec3 p, in vec3 n, in vec3 ld, in vec2 c) {
    vec3 col = color(c);
    return col *
    (
    0.15 +
    (0.85+0.95*wrappedDiffuse(n,ld,1.,35.0)) *
    (0.05+0.95*smoothstep(0.0,0.5,(p.y-scmin.y)/(scmax.y-scmin.y))) *
    (0.25+0.75*ShadowFactor(p, ld)) *
    0.85
    )
    // * 3.5
    ;
}

vec3 Render(in vec3 ro, in vec3 rd, in vec3 ld) {
    vec3 p0 = vec3(0.0);
    vec3 p1 = vec3(0.0);

    if (!IRayAABox(ro, rd, 1.0/rd, scmin, scmax, p0, p1)) return background;

    vec2 dir = normalize(rd.xz);
    float sf = rd.y / length(rd.xz);

    vec2 lvp = vec2(0);
    vec2 vp = p0.xz;

    float m = -1e5;

    const int max_steps = 32;
    for (int i = max_steps; i > 0; --i) {
        if (p0.y < m) {
            p0 += rd * (-p0.y + m)/rd.y;
            if (dot((p1 - p0), rd) < 0.0) return background;
            break;
        }

        if (dot((p1 - p0), rd) < 0.0) return background;

        vec4 v = map(p0.xz, dir);

        lvp = vp;
        vp = v.yz;

        m = v.w;
        if (p0.y < m) break;

        p0 += rd*(length(vec2(v.x, v.x*sf)) + 0.01);
    }


    vec2 eps = vec2(0,.1);
    vec4 voro00 = map(p0.xz);
    vec4 voro01 = map(p0.xz+eps.yx);
    vec4 voro10 = map(p0.xz+eps);
    float dist = voro00.x;
    float p2x = voro01.x;
    float p2y = voro10.x;

    vec2 side = normalize(vec2(p2x,p2y)-dist);
    dist=clamp(dist*10.0,0.0,1.0);
    vec3 sideN = vec3((1.0-dist)*side, dist).xzy;
    vec3 n = normalize(sideN);
    if (all(equal(p0.xz, lvp))) {
        n = AABoxNormal(scmin, scmax, p0);
    }
    vec3 col = Shade(p0, n, ld, vp);
    return col;
}
mat3 fromEuler(vec3 ang) {
    #ifdef EULER_2
    vec3 s = sin(ang);
    vec3 c = cos(ang);
    mat3 m = mat3(
    c.x* c.z+ s.x* s.y* s.z,c.x* s.y* s.z+ c.z* s.x,-c.y* s.z,
    -c.y* s.x,c.x* c.y,s.y,
    c.z* s.x* s.y+ c.x* s.z,s.x* s.z- c.x* c.z* s.y,c.y* c.z);
    return m;
    #else
    vec2 a1 = vec2(sin(ang.x),cos(ang.x));
    vec2 a2 = vec2(sin(ang.y),cos(ang.y));
    vec2 a3 = vec2(sin(ang.z),cos(ang.z));
    mat3 m;
    m[0] = vec3(a1.y* a3.y+ a1.x* a2.x* a3.x,a1.y* a2.x* a3.x+ a3.y* a1.x,-a2.y* a3.x);
    m[1] = vec3(-a2.y* a1.x,a1.y* a2.y,a2.x);
    m[2] = vec3(a3.y* a1.x* a2.x+ a1.y* a3.x,a1.x* a3.x- a1.y* a3.y* a2.x,a2.y* a3.y);
    return m;
    #endif
}
float rotating = 0.0;
void CameraOrbitRay(in vec2 fragCoord, in float n, in vec3 c, in float d,
out vec3 ro, out vec3 rd, out mat3 t)
{
    float a = 1.0/max(iResolution.x, iResolution.y);
    rd = normalize(vec3((fragCoord - iResolution.xy*0.5)*a, n));

    ro = vec3(0.0, 0.0, -d);

    vec2 iM = vec2(iTime*5.0+mod(iTime,10.0)*rotating,iResolution.y*.8);
    float ff = min(1.0, step(0.001, iM.x) + step(0.001, iM.y));
    vec2 m = PI*ff + vec2(((iM.xy + 0.1) / iResolution.xy) * (PI*2.0));
    m.y = -m.y;
    m.y = sin(m.y*0.5)*0.6 + 0.6;

    mat3 rotX = mat3(1.0, 0.0, 0.0, 0.0, cos(m.y), sin(m.y), 0.0, -sin(m.y), cos(m.y));
    mat3 rotY = mat3(cos(m.x), 0.0, -sin(m.x), 0.0, 1.0, 0.0, sin(m.x), 0.0, cos(m.x));

    t = rotY * rotX;

    ro = t * ro;
    ro = c + ro;

    rd = t * rd;

    rd = normalize(rd);
}

void main()
{
    vec2 fragCoord = gl_FragCoord.xy;
    vec3 ro;
    vec3 rd;
    mat3 t = mat3(1.0);
    float dur = 5.0;
    float segment = mod(floor(iTime/dur*2.5),12.0);
    float segs = mod(iTime,dur)/dur*5.0;
    float swapA = smoothstep(0.0,1.0,-0.5+segs);
    float swapB = smoothstep(0.0,1.0,-2.0+segs);
    float swapC = smoothstep(0.0,1.0,-3.5+segs);

    float row0 = step(fragCoord.y,iResolution.y/4.0);
    float row3 = step(iResolution.y*3.0/4.0,fragCoord.y);
    float col3 = step(iResolution.x*3.0/4.0,fragCoord.x);
    float col7 = step(iResolution.x*7.0/8.0,fragCoord.x);
    float col6 = col3-col7;
    float seg0 = float(segment==0.0);
    float seg1 = float(segment==1.0);
    float seg2 = float(segment==2.0);
    float seg4 = float(segment==4.0);
    float seg5 = float(segment==5.0);
    float seg7 = float(segment==7.0);
    float seg9 = float(segment==9.0);
    float seg11 = float(segment==11.0);
    float t1 = seg2*swapB+seg7*swapB+seg11*swapB;
    float t2 = seg4*swapB+seg9*swapB;
    float t3 = float(mod(segment+0.0,3.0)==0.0)*swapA;
    float t4 = seg0*swapB+seg1+seg5*swapB+seg9*swapC;
    float t5 = seg0*swapC+seg1+seg5*swapB+seg9*swapC;

    vec2 frag = mod(fragCoord,iResolution.xy/(1.0+3.0*t1));
    frag.x = mod(frag.x+iResolution.x/(1.0-0.5*t2),iResolution.x/(1.0+3.0*t2));
    frag.x = mix(frag.x, mod(frag.x, iResolution.x/8.0), col3*t3);
    frag.y = mix(frag.y, iResolution.y*3.0/4.0+mod(frag.y-iResolution.y*2.0*t4*seg9, iResolution.y/4.0), row3*t4);
    frag.y = mix(frag.y, mod(frag.y-iResolution.y*7.0/4.0*t5*seg9, iResolution.y/4.0), row0*t5);

    float zooming = 1.0;
    float near = 7.0;
    float far = 7.0;
    float turner = 0.0;
    frequency = vec3(vec2(1.0,0.7)*floor(fragCoord/(iResolution.xy/(1.0+3.0*t1)))*0.25*t1,0.4)*t1;
    frequency = mix(frequency, vec3(0.4,1.0,0.7), fragCoord.y/iResolution.y*col3*t3);
    gridWidth = mix(gridWidth,0.25,step(0.1,t1+col3*t3));
    near = mix(near, near+20.0, floor(fragCoord.x/(iResolution.x/(1.0+3.0*t1)))*0.25*t1);
    zooming = mix(zooming, zooming*0.25, row3*t4);
    zooming = mix(zooming, zooming*0.25, row0*t5);
    zooming = mix(zooming, zooming*8.0*(1.5*col6+col7), col3*t3);
    zooming = mix(zooming, zooming*0.1, floor(fragCoord.y/(iResolution.y/(1.0+3.0*t1)))*0.25*t1);
    near = mix(near, near+3.0, row3*t4);
    near = mix(near, near+180.0*col6+280.0*col7, col3*t3);
    near = mix(near, near+8.0, row0*t5);
    rotating = mix(rotating, -15.0, col3*t3);
    turner = mix(turner, 0.25, (1.0-floor(fragCoord.y/(iResolution.y/(1.0+3.0*t1)))*0.25)*t2);

    float borders = float(frag.x>=5.0&&frag.x<iResolution.x-5.0&&frag.y>=5.0&&frag.y<iResolution.y-5.0);//sign(1.0-dot(vec2(1),step(frag,vec2(5))+step(iResolution.xy-5.0,frag))));
    borders *= mix(1.0,clamp(abs(iResolution.y/4.0-frag.y)-2.5,0.0,1.0),t5);
    borders *= mix(1.0,clamp(abs(iResolution.y*3.0/4.0-frag.y)-2.5,0.0,1.0),t4);
    borders *= mix(1.0,clamp(abs(iResolution.x*3.0/4.0-fragCoord.x)-2.5,0.0,1.0),t3);
    borders *= mix(1.0,clamp(abs(iResolution.x*3.0/4.0-frag.x)-2.5,0.0,1.0),t2);
    borders *= mix(1.0,clamp(abs(iResolution.x*2.0/4.0-frag.x)-2.5,0.0,1.0),t2);
    borders *= mix(1.0,clamp(abs(iResolution.x*1.0/4.0-frag.x)-2.5,0.0,1.0),t2);
    float circling = segment*10.0*0.5+segs*(0.5+turner);
    CameraOrbitRay(frag, zooming, vec3(0.0), near+far*(1.0+cos(circling)), ro, rd, t);
    vec3 ld = normalize(vec3(4,4,-1)*fromEuler(vec3(0,0,5)*circling-4.0*turner));
    gl_FragColor = vec4(pow(mix(background,Render(ro, rd, ld),borders), vec3(0.5454)), 1.0);
}