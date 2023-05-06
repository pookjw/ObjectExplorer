//
//  ObjectModel.hpp
//  ObjectExplorerRenderer
//
//  Created by Jinwoo Kim on 5/5/23.
//

#import <MetalKit/MetalKit.h>
#import <ObjectExplorerRenderer/ObjectModelType.h>
#import <vector>

NS_HEADER_AUDIT_BEGIN(nullability, sendability)

class ObjectModel {
public:
    ObjectModel(id<MTLDevice> device, ObjectModelType modelType, NSError * __autoreleasing * _Nullable error);
    void drawInRenderEncoder(id<MTLRenderCommandEncoder> renderEncoder, CGSize size);
private:
    
    NSArray<MDLMesh *> *mdlMeshes;
    NSArray<MTKMesh *> *mtkMeshes;
};

NS_HEADER_AUDIT_END(nullability, sendability)
