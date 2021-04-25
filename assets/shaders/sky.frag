precision mediump float;

in vec2 v_texCoords;

layout (location = 0) out vec4 colorOut;
#if BLOOM
layout (location = 1) out vec3 brightColor;
#endif

uniform float time;

// 2D Random
float random(vec2 st)
{
    return fract(sin(dot(st.xy,
        vec2(12.9898,78.233)))
        * 43758.5453123);
}

float noise(vec2 st)
{
    vec2 i = floor(st);
    vec2 f = fract(st);

    // Four corners in 2D of a tile
    float a = random(i);
    float b = random(i + vec2(1., 0.));
    float c = random(i + vec2(0., 1.));
    float d = random(i + vec2(1., 1.));

    // Smooth Interpolation
    vec2 u = smoothstep(0., 1., f);

    // Mix 4 coorners percentages
    return mix(a, b, u.x) +
        (c - a) * u.y * (1. - u.x) +
        (d - b) * u.x * u.y;
}

void main()
{
    vec3 ray = vec3(v_texCoords * 2. - 1., 1.);
    ray.y += .2;

    float offset = time * .05;
    float speed2 = .4;
    float speed = speed2 + .1;

    vec3 col = vec3(.4, 0, .3);

    vec3 step = ray / max(abs(ray.x), abs(ray.y));

    vec3 pos = 2.0 * step + .5;

    #if BLOOM
    brightColor = vec3(0);
    #endif

    for (int i = 0; i < 3; i++)
    {
        float z = noise(vec2(ivec2(pos.xy)));
        z = fract(z - offset);

        float d = 10. * z - pos.z;

        float w = pow(max(0., 1. - 8. * length(fract(pos.xy) - .5)), 2.);
        vec3 c = max(vec3(0),
            vec3(
                1. - abs(d + speed2 * .3) / speed,
                1. - abs(d) / speed,
                1. - abs(d - speed2 * .3) / speed
            )
        );
        c *= vec3(.1, .8, .8) * 2.;
        col += (1. - z) * c * w;
        pos += step;
    }

    colorOut = vec4(col, 1) * (length(ray.xy) * .8 + .2);
}