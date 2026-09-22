uniform float u_Temperature;
// These are the interpolated values out of the rasterizer, so you can't know
// their specific values without knowing the vertices that contributed to them
in vec4 fs_Nor;
in vec4 fs_LightVec;
in vec4 fs_Col;
in vec4 fs_Pos;

in float fs_Wobble;
in float fs_Noise;
out vec4 out_Col; // This is the final output color that you will see on your
                  // screen for the pixel that is currently being processed.

void main()
{

        float chosen_noise = fs_Noise;

        vec3 heat = kelvinToColor((remap( chosen_noise, 0., 1., u_Temperature, -1000.)));
        vec4 diffuseColor = vec4(0.95 * heat, 1.);

        // Calculate the diffuse term for Lambert shading
        float diffuseTerm = dot(normalize(fs_Nor), normalize(fs_LightVec));
        // Avoid negative lighting values
        // diffuseTerm = clamp(diffuseTerm, 0, 1);

        float ambientTerm = 1.;
        diffuseTerm = 0.;
        float lightIntensity = max(0.,diffuseTerm) + ambientTerm;   //Add a small float value to the color multiplier
                                                            //to simulate ambient lighting. This ensures that faces that are not
                                                            //lit by our point light are not completely black.

        // Compute final shaded color
        out_Col = vec4(diffuseColor.rgb * lightIntensity, diffuseColor.a);
}
