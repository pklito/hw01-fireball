out vec4 out_Col;
in vec2 fs_Pos;
uniform mat4 u_ViewProjInv;
uniform mat4 u_ViewProj;

void main()
{
    vec2 uv = .8 * fs_Pos;
    vec3 frwd = normalize(vec3(uv, sqrt(max(0., 1.0 - dot(uv, uv)))));

    frwd = normalize((u_ViewProjInv * vec4(frwd, 0.)).xyz);    

    float bg = worley_noise_frag(frwd);
    vec3 color = 0.6*mix(vec3((0.9 - 0.2*frwd.z)*0.4,0.1,(0.9 - 0.4*frwd.z)*0.1), vec3((0.9 + 0.2*frwd.z)*0.6,0.8,(0.9 + 0.2*frwd.z)*0.7), bg);
    out_Col = vec4(color , 1.);
}
