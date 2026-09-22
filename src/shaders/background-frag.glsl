out vec4 out_Col;
in vec2 fs_Pos;
uniform mat4 u_ViewProj;

void main()
{
    vec2 uv = 0.7 * fs_Pos;
    vec3 dir =normalize( (u_ViewProj*vec4(0., sin(u_Time) ,cos(u_Time),0.)).xyz);
    vec3 frwd = normalize(vec3(uv, sqrt(max(0., 1.0 - dot(uv, uv)))));
    // vec3 frwd = normalize(vec3(uv, 1.0 - (max(abs(uv.x), abs(uv.y)))));
    float amount = step(0.995,dot(dir, frwd));
    float drop = step( dot(uv, uv), 1.);
    out_Col = vec4(vec3(0.1 + drop * amount) , 1.);
}
