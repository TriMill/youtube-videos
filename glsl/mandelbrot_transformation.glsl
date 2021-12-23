precision highp float;

#define MAX_ITERS 500

uniform vec2 resolution;
uniform float time;

uniform vec2 pmin;
uniform vec2 pmax;

vec2 map(vec2 value, vec2 inMin, vec2 inMax, vec2 outMin, vec2 outMax) {
  return outMin + (outMax - outMin) * (value - inMin) / (inMax - inMin);
}

vec3 hue2rgb(float hue) {
    vec4 K = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
    vec3 p = abs(fract(hue + K.xyz) * 6.0 - K.www);
    return mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), K.xxx);
}

float color_of(float x) {
	return clamp(mod(x,9.)*(9. - mod(x,9.))*7./81. - 0.75, 0., 1.);
}

vec3 mbrot(vec2 z, vec2 c) {
    int i = 0;
    for(; i < MAX_ITERS && z.x*z.x + z.y*z.y < 64; i += 1) {
        z = vec2(z.x*z.x - z.y*z.y + c.x, 2*z.x*z.y + c.y);
    }
    return vec3(i, z);
}

vec3 color_for(vec2 pt) {
    vec2 z = pt*time;
    vec2 c = pt;
    vec3 res = mbrot(z, c);
    float iters = res.x;
    vec2 zn = res.yz;
    if(iters == MAX_ITERS) {
        return vec3(0,0,0);
    } else {
        float smth = iters + .5 - log2(log(zn.x*zn.x + zn.y*zn.y));
        float v = smth/3 - 2;
        float r = color_of(v);
        float g = color_of(v+3);
        float b = color_of(v+6);
        return vec3(r,g,b);
    }
}


void main() {
    vec2 pos = map(gl_FragCoord.xy, vec2(0), resolution, pmin, pmax);
    vec2 pixsize = (pmax - pmin)/resolution;
    float delta = (pixsize.x + pixsize.y)/10;
    vec3 total = vec3(0);
    for(int dx = -1; dx <= 1; dx++) {
        for(int dy = -1; dy <= 1; dy++) {
            total += color_for(pos + vec2(dx, dy)*delta);
        }
    }
    gl_FragColor = vec4(total/9,1);
}
