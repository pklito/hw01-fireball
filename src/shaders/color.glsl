//https://tannerhelland.com/2012/09/18/convert-temperature-rgb-algorithm-code.html
float remap(float x, float in1, float in2, float out1, float out2) {
    float t = (x - in1)/(in2 - in1);
    return mix(out1, out2, t);
}
float clamped_remap(float x, float in1, float in2, float out1, float out2){
    return clamp(remap(x, in1, in2, out1, out2), min(out1, out2), max(out2, out1));
}
vec3 kelvinToColor(float k){
    // valid range: 1000K - 40000K
    k /= 100.;

    float r = mix(
        255.,
        329.698727446 * pow(max(k - 60., 0.0001), -0.1332047592),
        step(66., k)
    );

    float g = mix(
        99.4708025861 * log(max(k, 0.0001)) - 161.1195681661,
        288.1221695283 * pow(max(k - 60., 0.0001), -0.0755148492),
        step(66., k)
    );

    float b = 138.5177312231 * log(max(k - 10., 0.0001)) - 305.0447927307;
    b = mix(0., mix(b, 255., step(66., k)), step(15., k));

    float factor = 255. - (k-15.)*(k-15.);
    factor /= 255.;
    vec3 color = vec3(r, g, b) / 255.;
    
    if(k <= 0.){
        color *= (20. + (10./(k*k +1.))) / 255.;
    }else if (k <= 15.){
        color *= factor;
    }
    color = clamp(color, vec3(0.), vec3(1.));

    return color;
}