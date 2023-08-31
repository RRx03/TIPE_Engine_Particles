
#include <metal_stdlib>
#include<metal_math>
#import "../Common.h"
using namespace metal;



struct VertexIn
{
    float4 position [[attribute(0)]];
    float3 normal [[attribute(1)]];
};

struct VertexOut
{
    float4 position [[position]];
    float3 normal;

};

vertex VertexOut vertex_main(const VertexIn vertexIn [[stage_in]],
                             device Particle *particles [[buffer(1)]],
                             constant Uniforms &uniforms [[buffer(11)]],
                             uint instanceid [[instance_id]])
{
    
    VertexOut out;
    Particle particle = particles[instanceid];
    out.position = uniforms.projectionMatrix * uniforms.viewMatrix * particle.modelMatrix * vertexIn.position;
    out.normal = vertexIn.normal;
    
    
    
    
    particle.modelMatrix[3] = float4(position, 1);
    particles[instanceid] = particle;
    
    return out;
}

fragment float4 fragment_main(VertexOut vertexIn [[stage_in]], constant Params &params [[buffer(12)]])
{
    #define minLighting 0.1
    float3 light = float3(0, -1, 1);
    float iso = max(minLighting, dot(vertexIn.normal, -light));
    return float4(float3(1)*iso, 1);
}
