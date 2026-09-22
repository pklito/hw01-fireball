out vec4 out_Col;

uniform mat4 u_ViewProj;

void main()
{

    out_Col = vec4(vec3(0.1) + dot((u_ViewProj*(vec4(0.,0.,1.,0.))).xyz, vec3(0.,0.,1.)), 1.);
}
