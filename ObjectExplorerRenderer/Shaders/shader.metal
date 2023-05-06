//
//  shader.metal
//  ObjectExplorerRenderer
//
//  Created by Jinwoo Kim on 5/5/23.
//

#include <metal_stdlib>
#import <ObjectExplorerRenderer/common.hpp>
#import <ObjectExplorerRenderer/Math.hpp>
using namespace metal;

struct VertexIn {
    float4 position [[attribute(ObjectExplorer::Position)]];
    float3 normal [[attribute(ObjectExplorer::Normal)]];
};

struct VertexOut {
    float4 position [[position]];
    float3 normal;
};

vertex VertexOut vertex_main(
                             const VertexIn in [[stage_in]],
                             constant ObjectExplorer::Data &data [[buffer(ObjectExplorer::DataBuffer)]]
                             )
{
    const float aspect = data.width / data.height;
    const float scale = data.scale;
    
//    const simd_float4x4 aspectMatrix
    const simd_float4x4 scaleMatrix = Math::float4x4FromFloatScale(scale);
    const float4 position = in.position * scaleMatrix;
    
    return {
        .position = position,
        .normal = in.normal
    };
}

fragment float4 fragment_main(const VertexOut out [[stage_in]]) {
    float4 sky = float4(0.34f, 0.9f, 1.f, 1.f);
    float4 earth = float4(0.29f, 0.58f, 0.2f, 1.f);
    float intensity = out.normal.y * 0.5f + 0.5f;
    
    // x + (y - x) * a
    return mix(earth, sky, intensity);
}
