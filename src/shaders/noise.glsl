float noise1(vec3 point){
    return fract(sin(dot(point, vec3(12.9898, 78.233, 193.31419))) * 43758.5453);
}

float noise1(vec2 point){
    return fract(sin(dot(point, vec2(12.9898, 78.233))) * 43758.5453);
}

float noise1(float x, float y){
    return noise1(vec2(x,y));
}

//credit: xor_dev, https://mini.gmshaders.com/p/gm-shaders-mini-noise-1437243
vec2 noise2(vec2 p){
    return fract(sin(p * mat2(0.129898, 0.78233, 0.81314, 0.15926)) * 43758.5453);
}

vec2 noise2(float x, float y){ return noise2(vec2(x,y));}

//
vec3 noise3(vec3 p) {
    return fract(sin(p * mat3(
        127.135, 311.7931,  74.7391,
        269.591, 183.3459, 246.1109,
        113.520, 271.9018, 124.6345
    )) * 43758.5453123);
}

vec3 nearest_rng_point(vec3 point){
    //Random grid originating point, used for voronoi and worley shaders.
    //For every integer vec3, hashes an offset from 0-1 in all 3 axes.
    float min_dist = 10000000.0;
    vec3 min_point = vec3(0.1,0.,0.);//for some reason putting a 0.1 here changes something.
    for(int i = -1; i <= 1; i++){
        for(int j = -1; j <= 1; j++){
            for(int k = -1; k <= 1; k++){
                //Sample an offset consistent to all frag neighbors ( because of floor(`) )
                vec3 ivec = floor(point + vec3(i,j,k));
                float pz = noise1(ivec.x,ivec.y);
                float py = noise1(ivec.z,ivec.x);
                float px = noise1(ivec.y,ivec.z);
                vec3 worley_point = ivec + vec3(px,py,pz);
                //The min dist for worley noise
                float worley_dist = distance(point, worley_point);
                if(worley_dist < min_dist){
                    min_dist = worley_dist;
                    min_point = worley_point;
                }

            }
        }   
    }
    return min_point;
}

float worley_noise_frag(vec3 point){
    //the distance to the point is worley noise.
    return distance(nearest_rng_point(point), point);
}

float voronoi_noise_frag(vec3 point){
    //A hash of the point creates a voronoi pattern.
    //TODO: floating point errors should affect this hash.
    //Not sure why they dont.
    vec3 rng_point = 1.*nearest_rng_point(point);
    return 0.8 * noise1(rng_point) + 0.2; //Ranged 0.2-1.0 because it looks better
}

float white_noise_frag(vec3 point){
    float scale = 4.0;
    vec3 ivec = floor(point * scale);
    return noise1(ivec);
}

vec3 quint(vec3 p){
    return p*p*p*(10. + p*(-15. + 6. * p));
}

vec3 corners[] = vec3[](
vec3(0,0,0),
vec3(1,0,0),
vec3(0,1,0),
vec3(1,1,0),
vec3(0,0,1),
vec3(1,0,1),
vec3(0,1,1),
vec3(1,1,1)
);

float perlin_noise(vec3 point){
    vec3 corner = floor(point);
    vec3 offset = fract(point);
    float gradient0 = dot(offset - corners[0], normalize(noise3(corner + corners[0])-0.5));
    float gradient1 = dot(offset - corners[1], normalize(noise3(corner + corners[1])-0.5));
    float gradient2 = dot(offset - corners[2], normalize(noise3(corner + corners[2])-0.5));
    float gradient3 = dot(offset - corners[3], normalize(noise3(corner + corners[3])-0.5));
    float gradient4 = dot(offset - corners[4], normalize(noise3(corner + corners[4])-0.5));
    float gradient5 = dot(offset - corners[5], normalize(noise3(corner + corners[5])-0.5));
    float gradient6 = dot(offset - corners[6], normalize(noise3(corner + corners[6])-0.5));
    float gradient7 = dot(offset - corners[7], normalize(noise3(corner + corners[7])-0.5));

    float m1 = mix(gradient0, gradient1, quint(offset).x);
    float m2 = mix(gradient2, gradient3, quint(offset).x);
    float m3 = mix(gradient4, gradient5, quint(offset).x);
    float m4 = mix(gradient6, gradient7, quint(offset).x); //sic seben
    float m5 = mix(m1, m2, quint(offset).y);
    float m6 = mix(m3, m4, quint(offset).y);
    float m7 = mix(m5,m6,quint( offset).z);
    return m7 + 0.5;
}

float fbm_perlin(vec3 point){
    float total = 0.;
    float persistence = 0.5f;
    int octaves = 8;
    float freq = 2.f;
    float amp = 0.5f;
    for(int i = 1; i <= octaves; i++) {
        total += perlin_noise(point * freq) * amp;
        freq *= 2.f;
        amp *= persistence;
    }
    return total;
}

float fbm_worley(vec3 point){
    float total = 0.;
    float persistence = 0.5;
    int octaves = 8;
    float freq = 2.;
    float amp = 0.5;
    for(int i = 1; i <= octaves; i++) {
        total += worley_noise_frag(point * freq) * amp;
        freq *= 2.f;
        amp *= persistence;
    }
    return total;
}