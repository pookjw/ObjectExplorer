//
//  Math.hpp
//  MetalBirdRenderer
//
//  Created by Jinwoo Kim on 4/22/23.
//

#import <simd/simd.h>

namespace Math {

const simd_float4x4 identityFloat4x4() {
#if SIMD_MATRIX_HEADER
    return matrix_identity_float4x4;
#else
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
#endif
}

const simd_float4x4 float4x4FromFloatScale(float scale) {
    simd_float4x4 result = identityFloat4x4();
    
#if _LIBCPP_MATH_H
    result = matrix_identity_float4x4;
    result.columns[3].w = std::powf(scale, -1.f);
#else
    result.columns[3].w = 1.f / scale;
#endif
    
    return result;
};
 
};
