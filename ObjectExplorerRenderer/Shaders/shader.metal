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
    const float scale = data.scale;
    const simd_float4x4 scaleMatrix = Math::float4x4FromFloatScale(scale);
    
    //
    
    const float rotationX = metal::max(-M_PI * 0.5f, metal::min(data.panY / data.height, M_PI * 0.5f));
    const float rotationY = -metal::max(-M_PI * 0.5f, metal::min(data.panX / data.width, M_PI * 0.5));;
    
    simd_float4x4 rotationXMatrix = Math::identityFloat4x4();
    rotationXMatrix.columns[1].y = metal::cos(rotationX);
    rotationXMatrix.columns[1].z = metal::sin(rotationX);
    rotationXMatrix.columns[2].y = -metal::sin(rotationX);
    rotationXMatrix.columns[2].z = metal::cos(rotationX);
    
    simd_float4x4 rotationYMatrix = Math::identityFloat4x4();
    rotationYMatrix.columns[0].x = metal::cos(rotationY);
    rotationYMatrix.columns[0].z = -metal::sin(rotationY);
    rotationYMatrix.columns[2].x = metal::sin(rotationY);
    rotationYMatrix.columns[2].z = metal::cos(rotationY);
    
    const simd_float4x4 rotationMatrix = rotationXMatrix * rotationYMatrix;
//
//    //
//
    const simd_float4x4 projectionMatrix = Math::projectionMatrix(Math::radiansFromDegrees(70.f), 0.1f, 100.f, data.width / data.height, true);
    
    const simd_float3 translation {0.f, 0.f, -3.f};
    
    float4 position = projectionMatrix * data.viewMatrix * scaleMatrix * rotationMatrix * in.position;
    
    return {
        .position = position,
        .normal = in.normal
    };
}

fragment float4 fragment_main(const VertexOut out [[stage_in]]) {
//    float4 sky = float4(0.34f, 0.9f, 1.f, 1.f);
//    float4 earth = float4(0.29f, 0.58f, 0.2f, 1.f);
//    float intensity = metal::fma(out.normal.y, 0.5f, 0.5f);
//
//    // x + (y - x) * a
//    return mix(earth, sky, intensity);
    
    return float4(out.normal, 0.f);
}
