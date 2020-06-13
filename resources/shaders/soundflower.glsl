// Created by inigo quilez - iq/2013
// License Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License.

void main()
{
  vec2 fragCoord  = gl_FragCoord.xy;

	vec2 uv = -1.0+2.0*fragCoord.xy/iResolution.xy;
	uv.x *= iResolution.x/iResolution.y;
	
	float r = length( uv );
	float a = atan( uv.x, uv.y );

	float w = texture( iChannel0, vec2( abs(a)/3.14, 1.0) ).x;
	
	float t = 3.5*sqrt(abs(w-0.5));

	float f = 0.0;
	if( r<t ) f = (1.0-r/t);
	vec3 col = pow( vec3(f), vec3(1.5,1.1,0.8) );

  gl_FragColor = vec4( col, 1.0 );
}
