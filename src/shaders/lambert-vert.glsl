//139

//This is a vertex shader. While it is called a "shader" due to outdated conventions, this file
//is used to apply matrix transformations to the arrays of vertex data passed to it.
//Since this code is run on your GPU, each vertex is transformed simultaneously.
//If it were run on your CPU, each vertex would have to be processed in a FOR loop, one at a time.
//This simultaneous transformation allows your program to run much faster, especially when rendering
//geometry with millions of vertices.

uniform float u_Temperature;
uniform float u_Wobble;
//149
uniform mat4 u_Model;       // The matrix that defines the transformation of the
                            // object we're rendering. In this assignment,
                            // this will be the result of traversing your scene graph.

uniform mat4 u_ModelInvTr;  // The inverse transpose of the model matrix.
                            // This allows us to transform the object's normals properly
                            // if the object has been non-uniformly scaled.

uniform mat4 u_ViewProj;    // The matrix that defines the camera's transformation.
                            // We've written a static matrix for you to use for HW2,
                            // but in HW3 you'll have to generate one yourself

in vec4 vs_Pos;             // The array of vertex positions passed to the shader

in vec4 vs_Nor;             // The array of vertex normals passed to the shader

in vec4 vs_Col;             // The array of vertex colors passed to the shader.

out vec4 fs_Nor;            // The array of normals that has been transformed by u_ModelInvTr. This is implicitly passed to the fragment shader.
out vec4 fs_LightVec;       // The direction in which our virtual light lies, relative to each vertex. This is implicitly passed to the fragment shader.
out vec4 fs_Col;            // The color of each vertex. This is implicitly passed to the fragment shader.
out vec4 fs_Pos;

out float fs_Noise;
out float fs_Wobble;
const vec4 lightPos = vec4(5, 5, 3, 1); //The position of our virtual light, which is used to compute the shading of
                                        //the geometry in the fragment shader.

float wobbleAmount(vec4 pos){
    return sin(3.*u_Time + 0.4*(pos.x + pos.y + pos.z));
}

vec4 wobblePosition(vec4 pos){
    float amount = wobbleAmount(pos);
    pos += vec4(u_Wobble * normalize(pos.xyz)*amount, 0.0);
    return pos;
}

vec4 movePosition(vec4 pos, float amount){
    return pos + vec4(normalize(pos.xyz)*amount, 0.0);
}

vec4 moveCurved(vec4 pos, float amount ,vec3 dir){
    float modifier = min(0.5,0.3 + dot(normalize(pos.xyz),dir));
    return pos + vec4( modifier * normalize(pos.xyz)*amount, 0.0);

}

vec4 displaceVertex(vec4 pos){
    vec4 modifiedposition = movePosition(pos, u_Wobble * wobbleAmount(vs_Pos));
    modifiedposition += vec4(0.,0.,0.4 * pos.z, 0.);
    modifiedposition = moveCurved(modifiedposition, 0.7*user_chosen_noise(vs_Pos.xyz), vec3(0.,0.,1.));  //200
    return modifiedposition;
}

vec4 inverseDisplacement(vec4 pos){
    return pos - vec4(0.,0.,0.4 * pos.z, 0.);
}


vec3 directions[] = vec3[](
vec3(-1,0,0),
vec3(1,0,0),
vec3(0,-1,0),
vec3(0,1,0),
vec3(0,0,-1),
vec3(0,0,1)
);

vec4 displaceNormal(vec4 pos, vec4 normal){
    float eplsilon = 0.05;

    vec3 gradient = vec3(0.);
    for(int i = 0; i < 3; i ++){
        vec3 p1 = directions[2*i + 1];
        float f1 = length(displaceVertex(vec4(pos.xyz + eplsilon * p1,1.0)).xyz - (pos.xyz + eplsilon * p1));
        vec3 p2 = directions[2*i];
        float f2 = length(displaceVertex(vec4(pos.xyz + eplsilon * p2,1.0)).xyz - (pos.xyz + eplsilon * p2));
        gradient[i] = (f2-f1)/(2.*eplsilon);
    }
    
    return vec4(gradient, 1.);
}

void main()
{
    fs_Col = vs_Col;                         // Pass the vertex colors to the fragment shader for interpolation

    mat3 invTranspose = mat3(u_ModelInvTr);
    fs_Nor = vec4(invTranspose * vec3(vs_Nor), 0);          // Pass the vertex normals to the fragment shader for interpolation.
                                                            // Transform the geometry's normals by the inverse transpose of the
                                                            // model matrix. This is necessary to ensure the normals remain
                                                            // perpendicular to the surface after the surface is transformed by
                                                            // the model matrix.

    fs_Wobble = wobbleAmount(vs_Pos);
    fs_Noise = user_chosen_noise(inverseDisplacement(vs_Pos).xyz);

    float amount_forward = gain(0.1,triangle(clamped_remap(u_Temperature, 7000., 35000., 0.5, 4.)*u_Time));
    
    float x = u_Time - u_ShootTime;

    float isShooting = (1. - step(1.,x));
    float y = clamped_remap(u_Temperature, 1000., 35000., 0.8, 4.) * x;
    float evil_quint = y *(-1. + y*(1. + y*(10. + y*(0. + 10.*y))));
    amount_forward += 10.*(evil_quint)*isShooting;

    float size = (1. - pow(10., -30.*(x - 1.)*(x - 1.)));
    vec3 moving_position = vec3(0.,0.,0.8*amount_forward);
    vec4 modelposition = u_Model * displaceVertex(vec4(vec3(size), 1.)*vs_Pos) + vec4(moving_position,0.);   // Temporarily store the transformed vertex positions for use below
    


    fs_LightVec = lightPos - modelposition;  // Compute the direction in which the light source lies

    fs_Pos = modelposition;
    gl_Position = u_ViewProj * modelposition;// gl_Position is a built-in variable of OpenGL which is
                                             // used to render the final positions of the geometry's vertices
}
