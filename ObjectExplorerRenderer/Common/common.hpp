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
    Normal = 1
};

enum BufferIndices {
    VertexBuffer = 0,
    DataBuffer = 11
};

struct Data {
    const float width;
    const float height;
    const float scale;
};
};
