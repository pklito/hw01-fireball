uniform vec4 u_Color; // The color with which to render this instance of geometry.
uniform int u_Noise;

// These are the interpolated values out of the rasterizer, so you can't know
// their specific values without knowing the vertices that contributed to them
in vec4 fs_Nor;
in vec4 fs_LightVec;
in vec4 fs_Col;
in vec4 fs_Pos;

in float fs_Wobble;

out vec4 out_Col; // This is the final output color that you will see on your
                  // screen for the pixel that is currently being processed.

void main()
{
        float noise = 0.95;
        vec3 heat = kelvinToColor(clamped_remap(fs_Pos.z, -1.5, 1., 1000., 40000.));
        vec4 diffuseColor = vec4(noise * heat, u_Color.a);

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
