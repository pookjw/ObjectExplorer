//
//  ObjectModel.hpp
//  ObjectExplorerRenderer
//
//  Created by Jinwoo Kim on 5/5/23.
//

#import <MetalKit/MetalKit.h>
#import <ObjectExplorerRenderer/ObjectModelType.h>
#import <vector>
#import <atomic>

NS_HEADER_AUDIT_BEGIN(nullability, sendability)

class ObjectModel {
public:
    ObjectModel(MTKView *mtkView, id<MTLDevice> device, id<MTLLibrary> library, ObjectModelType modelType, NSError * __autoreleasing * _Nullable error);
    void drawInRenderEncoder(id<MTLRenderCommandEncoder> renderEncoder, CGSize size);
    
    void didChangeMagnification(CGFloat scale);
    void didEndMagnification(CGFloat scale);
    void didChangePanning(CGFloat x, CGFloat y);
private:
    NSArray<MDLMesh *> *mdlMeshes;
    NSArray<MTKMesh *> *mtkMeshes;
    id<MTLDevice> device;
    id<MTLRenderPipelineState> pipelineState;
    
    std::atomic<CGFloat> lastScale;
    std::atomic<CGFloat> totalScale;
    std::atomic<CGFloat> totalPanX;
    std::atomic<CGFloat> totalPanY;
};

NS_HEADER_AUDIT_END(nullability, sendability)
