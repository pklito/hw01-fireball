
//149

in vec4 vs_Pos;             // The array of vertex positions passed to the shader
out vec2 fs_Pos;
void main()
{
    fs_Pos = vs_Pos.xy;
    vec4 modelposition = vs_Pos;   // Temporarily store the transformed vertex positions for use below

    gl_Position = modelposition;// gl_Position is a built-in variable of OpenGL which is
    gl_Position.zw = vec2(0.999, 1.);
}
