//https://tannerhelland.com/2012/09/18/convert-temperature-rgb-algorithm-code.html
float remap(float x, float in1, float in2, float out1, float out2) {
    float t = (x - in1)/(in2 - in1);
    return mix(out1, out2, t);
}
float clamped_remap(float x, float in1, float in2, float out1, float out2){
    return clamp(remap(x, in1, in2, out1, out2), out1, out2);
}
vec3 kelvinToColor(float k){
    //1k - 40k
    k /= 100.;
    float r = mix(255., 329.698727446 * pow(k - 60., -0.1332047592) , step(66., k));
    float g = mix(99.4708025*log(k) - 161.119581, 288.1221695283 * pow(k-60., -0.0755148492) , step(66., k));
    float b = 138.517731221 * (log(k-10.) - 305.0447927307);
    b = mix(0., mix(b, 255., step(66., k)), step(19., k));

    vec3 color = vec3(r,g,b)/255.;
    color = clamp(color,vec3(0.), vec3(1.));

    return color;
}    