//
//  ObjectModel.mm
//  ObjectExplorerRenderer
//
//  Created by Jinwoo Kim on 5/5/23.
//

#import <ObjectExplorerRenderer/ObjectModel.hpp>
#import <ObjectExplorerRenderer/constants.h>
#import <ObjectExplorerRenderer/common.hpp>

ObjectModel::ObjectModel(id<MTLDevice> device, ObjectModelType modelType, NSError * __autoreleasing * _Nullable error) {
    NSBundle *bundle = [NSBundle bundleWithIdentifier:ObjectExplorerRendererBundleIdentifier];
    NSURL *objURL;
    
    switch (modelType) {
        case ObjectModelTypeCupcakes:
            objURL = [bundle URLForResource:@"cupcakes" withExtension:@"obj"];
            break;
        case ObjectModelTypeChocolateDonut:
            objURL = [bundle URLForResource:@"chocolate_donut" withExtension:@"obj"];
            break;
        default:
            [NSException raise:NSInternalInconsistencyException format:@"Not supported type."];
            break;
    }
    
    assert(objURL);
    
    //
    
    MDLVertexDescriptor *mdlVertexDescriptor = [MDLVertexDescriptor new];
    NSUInteger offset = 0;
    
    mdlVertexDescriptor.attributes[Position] = [[MDLVertexAttribute alloc] initWithName:MDLVertexAttributePosition format:MDLVertexFormatFloat3 offset:offset bufferIndex:VertexBuffer];
    
    offset += sizeof(simd_float3);
    
    mdlVertexDescriptor.attributes[Normal] = [[MDLVertexAttribute alloc] initWithName:MDLVertexAttributeNormal format:MDLVertexFormatFloat3 offset:offset bufferIndex:VertexBuffer];
    
    offset += sizeof(simd_float3);
    
    mdlVertexDescriptor.layouts[VertexBuffer] = [[MDLVertexBufferLayout alloc] initWithStride:offset];
    
    //
    
    MTKMeshBufferAllocator *allocator = [[MTKMeshBufferAllocator alloc] initWithDevice:device];
    MDLAsset *asset = [[MDLAsset alloc] initWithURL:objURL vertexDescriptor:mdlVertexDescriptor bufferAllocator:allocator];
    
    NSArray<MDLMesh *> *mdlMeshes = nil;
    NSArray<MTKMesh *> *mtkMeshes = [MTKMesh newMeshesFromAsset:asset device:device sourceMeshes:&mdlMeshes error:error];
    if (*error) {
        return;
    }
    
    this->mdlMeshes = mdlMeshes;
    this->mtkMeshes = mtkMeshes;
}

void ObjectModel::drawInRenderEncoder(id<MTLRenderCommandEncoder> renderEncoder, CGSize size) {
    [this->mtkMeshes enumerateObjectsUsingBlock:^(MTKMesh * _Nonnull mtkMesh, NSUInteger idx, BOOL * _Nonnull stop) {
        [mtkMesh.vertexBuffers enumerateObjectsUsingBlock:^(MTKMeshBuffer * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            [renderEncoder setVertexBuffer:reinterpret_cast<id<MTLBuffer>>(obj) offset:0 atIndex:idx];
        }];
     
        [mtkMesh.submeshes enumerateObjectsUsingBlock:^(MTKSubmesh * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            [renderEncoder drawIndexedPrimitives:MTLPrimitiveTypeTriangle
                                      indexCount:obj.indexCount
                                       indexType:obj.indexType
                                     indexBuffer:obj.indexBuffer.buffer
                               indexBufferOffset:obj.indexBuffer.offset];
        }];
    }];
}
