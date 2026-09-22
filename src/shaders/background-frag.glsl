out vec4 out_Col;
in vec2 fs_Pos;
uniform mat4 u_ViewProjInv;
uniform mat4 u_ViewProj;
uniform vec2 u_Resolution;

uniform float u_Temperature;
void main()
{
    vec2 uv = vec2(u_Resolution.x / u_Resolution.y ,1.) * 0.5 * fs_Pos;
    vec3 frwd = normalize(vec3(uv, sqrt(max(0., 1.0 - dot(uv, uv)))));

    frwd = normalize((u_ViewProjInv * vec4(frwd, 0.)).xyz);    

    float bg = worley_noise_frag(frwd + vec3(0.,0.,0.1*u_Time));
    bg *= (0.4 + 0.5 * fbm_perlin(frwd + vec3(0.,0.,0.1*u_Time)));
    vec3 color =bg * mix(vec3(1.0,0.,0.), vec3(0.7,0.5,0.8), 0.5*(frwd.z + 1.));

    float x = u_Time - u_ShootTime;
    float isShooting = (1. - step(1.,x));
    float explosionTiming = smoothstep(0.5, 0.9, x) * (1. - smoothstep(0.9, 4., x));
    float explosionHeat = u_Temperature * remap(x, 0.6, 1.2, 4., 1.);
    float explosion = max(0., clamped_remap(sqrt(explosionHeat), sqrt(6000.), sqrt(70000.), 0., 0.4) + dot(frwd, vec3(0.,0.,explosionTiming)));
    explosion *= explosion;
    explosion *= (explosion - fbm_worley(frwd + vec3(0.,0.,0.1*u_Time)));
    color += kelvinToColor(u_Temperature * explosion);
    out_Col = vec4(color , 1.);
}
