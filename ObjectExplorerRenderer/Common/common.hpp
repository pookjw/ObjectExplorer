//
//  common.hpp
//  ObjectExplorer
//
//  Created by Jinwoo Kim on 5/6/23.
//

#import <simd/simd.h>

namespace ObjectExplorer {
enum Attributes {
    Position = 0,
    Normal = 1,
};

enum BufferIndices {
    VertexBuffer = 0,
    DataBuffer = 11
};

struct Data {
    const float width;
    const float height;
    const float scale;
    const float panX;
    const float panY;
    const simd_float4x4 viewMatrix;
};
};
