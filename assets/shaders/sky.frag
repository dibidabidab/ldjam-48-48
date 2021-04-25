precision mediump float;

in vec2 v_texCoords;

layout (location = 0) out vec4 colorOut;
#if BLOOM
layout (location = 1) out vec3 brightColor;
#endif

void main()
{
    colorOut = vec4(.4, 0, .3, 1);
    #if BLOOM
    brightColor = vec3(0);
    #endif
}