//
//  Math.hpp
//  MetalBirdRenderer
//
//  Created by Jinwoo Kim on 4/22/23.
//

#import <simd/simd.h>

#if !defined(M_PI)
#define M_PI 3.14159265358979323846264338327950288
#endif

namespace Math {

const float radiansFromDegrees(float degrees) {
#if __METAL__
    return metal::fma(metal::fma(degrees, M_PI, 0.f), metal::pow(180.f, -1.f), 0.f);
#else
    return std::fmaf(std::fmaf(degrees, M_PI, 0.f), std::powf(180.f, -1.f), 0.f);
#endif
}

const float degreesFromRadians(float radians) {
#if __METAL__
    return metal::fma(metal::fma(radians, 180.f, 0.f), metal::pow(M_PI, -1.f), 0.f);
#else
    return std::fmaf(std::fmaf(radians, 180.f, 0.f), std::powf(M_PI, -1.f), 0.f);
#endif
}

const simd_float4x4 identityFloat4x4() {
#if __METAL__
    simd_float4x4 result;
    
    result.columns[0].x = 1.f;
    result.columns[0].y = 0.f;
    result.columns[0].z = 0.f;
    result.columns[0].w = 0.f;
    
    result.columns[1].x = 0.f;
    result.columns[1].y = 1.f;
    result.columns[1].z = 0.f;
    result.columns[1].w = 0.f;
    
    result.columns[2].x = 0.f;
    result.columns[2].y = 0.f;
    result.columns[2].z = 1.f;
    result.columns[2].w = 0.f;
    
    result.columns[3].x = 0.f;
    result.columns[3].y = 0.f;
    result.columns[3].z = 0.f;
    result.columns[3].w = 1.f;
    
    return result;
#else
    return matrix_identity_float4x4;
#endif
}

const simd_float4x4 float4x4FromFloatScale(float scale) {
    simd_float4x4 result = identityFloat4x4();
    
#if __METAL__
    result.columns[3].w = metal::pow(scale, -1.f);
#else
    result.columns[3].w = std::powf(scale, -1.f);
#endif
    
    return result;
};

const simd_float4x4 projectionMatrix(float fov, float near, float far, float aspect, bool lhs) {
    float y;
#if __METAL__
    y = 1.f / metal::tan(fov * 0.5f);
#else
    y = 1.f / std::tanf(fov * 0.5f);
#endif
    
    const float x = y / aspect;
    const float z = lhs ? (far / (far - near)) : (far / (near - far));
    const simd_float4 X = {x, 0.f, 0.f, 0.f};
    const simd_float4 Y = {0.f, y, 0.f, 0.f};
    
    simd_float4 Z;
    if (lhs) {
        Z = {0.f, 0.f, z, 1.f};
    } else {
        Z = {0.f, 0.f, z, -1.f};
    }
    
    simd_float4 W;
    if (lhs) {
        W = {0.f, 0.f, z * -near, 0.f};
    } else {
        W = {0.f, 0.f, z * near, 0.f};
    }
    
    simd_float4x4 result = identityFloat4x4();
    result.columns[0] = X;
    result.columns[1] = Y;
    result.columns[2] = Z;
    result.columns[3] = W;
    
    return result;
}

const simd_float4x4 translationMatrix(simd_float3 translation) {
    simd_float4x4 result = identityFloat4x4();
    result.columns[3].x = translation.x;
    result.columns[3].y = translation.y;
    result.columns[3].z = translation.z;
    
    return result;
}
 
};
