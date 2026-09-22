out vec4 out_Col;
in vec2 fs_Pos;
uniform mat4 u_ViewProjInv;
uniform mat4 u_ViewProj;
uniform vec2 u_Resolution;

void main()
{
    vec2 uv = vec2(u_Resolution.x / u_Resolution.y ,1.) * 0.5 * fs_Pos;
    vec3 frwd = normalize(vec3(uv, sqrt(max(0., 1.0 - dot(uv, uv)))));

    frwd = normalize((u_ViewProjInv * vec4(frwd, 0.)).xyz);    

    float bg = worley_noise_frag(frwd);
    vec3 color =bg * mix(vec3(1.0,0.,0.), vec3(0.7,0.5,0.8), 0.5*(frwd.z + 1.));
    out_Col = vec4(color , 1.);
}
