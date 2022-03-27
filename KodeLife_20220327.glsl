#version 150

uniform float time;
uniform vec2 resolution;
uniform vec2 mouse;
uniform vec3 spectrum;

uniform sampler2D texture0;
uniform sampler2D texture1;
uniform sampler2D texture2;
uniform sampler2D texture3;
uniform sampler2D prevFrame;
uniform sampler2D prevPass;

in VertexData
{
    vec4 v_position;
    vec3 v_normal;
    vec2 v_texcoord;
} inData;

out vec4 fragColor;

#define rot(a) mat2(cos(a),sin(a),-sin(a),cos(a))
#define TAU (atan(1.)*8)
#define PI acos(-1.)

vec2 pmod(vec2 p,float n)
{
    float a=mod(atan(p.y,p.x),TAU/n)-.5*TAU/n;
    return length(p)*vec2(sin(p.x),cos(p.y));
}

float sdCircle(vec2 p,float r)
{
    return length(p)-r;
}

float sdSphere(vec3 p,float r)
{
    return length(p)-r;
}

float sdBox(vec3 p,vec3 s)
{
    vec3 q=abs(p)-s;
    return length(max(q,0))+min(max(max(q.y,q.z),q.x),0);
}

float map(vec3 p)
{
    p.xy*=rot(time);
    //p.xz*=rot(time);
    p.xy=vec2(atan(p.x,p.y)/PI*3.,length(p.xy)-2.);
    p.x=mod(p.x,1.)-.5;
    return sdBox(p,vec3(.3));
}

vec3 makeN(vec3 p)
{
    vec2 eps=vec2(.001,0);
    return normalize(vec3(map(p+eps.xyy)-map(p-eps.xyy),
                          map(p+eps.yxy)-map(p-eps.yxy),
                          map(p+eps.yyx)-map(p-eps.yyx)));
}

void main(void)
{
    vec2 uv = (gl_FragCoord.xy*2-resolution.xy)/resolution.y;
    float dist,hit,i=0;
    vec3 ro=vec3(0,0,5),
         rd=normalize(vec3(uv,-1)),
         rp=ro+rd*dist,
         col=vec3(0),
         L=normalize(vec3(1));
    for(;i<128;i++)
    {
        dist=map(rp);
        hit+=dist;
        rp=ro+rd*hit;
        if(dist<.001)
        {
            vec3 N=makeN(rp);
            float diff=dot(N,L);
            col=vec3(1)*diff;
        }
    }
    fragColor = vec4(col,1);
}