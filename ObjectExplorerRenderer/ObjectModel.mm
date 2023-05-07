//
//  ObjectModel.mm
//  ObjectExplorerRenderer
//
//  Created by Jinwoo Kim on 5/5/23.
//

#import <ObjectExplorerRenderer/ObjectModel.hpp>
#import <ObjectExplorerRenderer/constants.h>
#import <ObjectExplorerRenderer/common.hpp>
#import <ObjectExplorerRenderer/Math.hpp>

ObjectModel::ObjectModel(MTKView *mtkView, id<MTLDevice> device, id<MTLLibrary> library, ObjectModelType modelType, NSError * __autoreleasing * _Nullable error) {
    NSBundle *bundle = [NSBundle bundleWithIdentifier:ObjectExplorerRendererBundleIdentifier];
    NSURL *objURL;
    
    
    
    switch (modelType) {
        case ObjectModelTypeCupcakes:
            objURL = [bundle URLForResource:@"cupcakes" withExtension:@"obj"];
            break;
        case ObjectModelTypeChocolateDonut:
            objURL = [bundle URLForResource:@"chocolate_donut" withExtension:@"obj"];
            break;
        case ObjectModelTypeRoom:
            objURL = [bundle URLForResource:@"blender_35_splash_nicole_morena" withExtension:@"obj"];
            break;
        case ObjectModelTypeHand:
            objURL = [bundle URLForResource:@"auto_masking_options" withExtension:@"obj"];
            break;
        default:
            [NSException raise:NSInternalInconsistencyException format:@"Not supported type."];
            break;
    }
    
    assert(objURL);
    
    //
    
    MDLVertexDescriptor *mdlVertexDescriptor = [MDLVertexDescriptor new];
    NSUInteger offset = 0;
    
    mdlVertexDescriptor.attributes[ObjectExplorer::Position] = [[MDLVertexAttribute alloc] initWithName:MDLVertexAttributePosition format:MDLVertexFormatFloat3 offset:offset bufferIndex:ObjectExplorer::VertexBuffer];
    
    offset += sizeof(simd_float3);
    
    mdlVertexDescriptor.attributes[ObjectExplorer::Normal] = [[MDLVertexAttribute alloc] initWithName:MDLVertexAttributeNormal format:MDLVertexFormatFloat3 offset:offset bufferIndex:ObjectExplorer::VertexBuffer];
    
    offset += sizeof(simd_float3);
    
    mdlVertexDescriptor.layouts[ObjectExplorer::VertexBuffer] = [[MDLVertexBufferLayout alloc] initWithStride:offset];
    
    //
    
    MTKMeshBufferAllocator *allocator = [[MTKMeshBufferAllocator alloc] initWithDevice:device];
    MDLAsset *asset = [[MDLAsset alloc] initWithURL:objURL vertexDescriptor:mdlVertexDescriptor bufferAllocator:allocator];
    
    NSArray<MDLMesh *> *mdlMeshes = nil;
    NSArray<MTKMesh *> *mtkMeshes = [MTKMesh newMeshesFromAsset:asset device:device sourceMeshes:&mdlMeshes error:error];
    if (*error) {
        return;
    }
    
    NSLog(@"Loaded!");
    
    //
    
    MTLFunctionDescriptor *vertexFunctionDescriptor = [MTLFunctionDescriptor functionDescriptor];
    vertexFunctionDescriptor.name = @"vertex_main";
    id<MTLFunction> vertexFunction = [library newFunctionWithDescriptor:vertexFunctionDescriptor error:error];
    if (*error) {
        return;
    }
    
    MTLFunctionDescriptor *fragmentFunctionDescriptor = [MTLFunctionDescriptor functionDescriptor];
    fragmentFunctionDescriptor.name = @"fragment_main";
    id<MTLFunction> fragmentFunction = [library newFunctionWithDescriptor:fragmentFunctionDescriptor error:error];
    if (*error) {
        return;
    }
    
    MTLRenderPipelineDescriptor *pipelineDescriptor = [MTLRenderPipelineDescriptor new];
    pipelineDescriptor.vertexFunction = vertexFunction;
    pipelineDescriptor.fragmentFunction = fragmentFunction;
    pipelineDescriptor.colorAttachments[0].pixelFormat = mtkView.colorPixelFormat;
//    pipelineDescriptor.depthAttachmentPixelFormat = MTLPixelFormatDepth32Float;
    pipelineDescriptor.vertexDescriptor = MTKMetalVertexDescriptorFromModelIOWithError(mdlVertexDescriptor, error);
    if (*error) {
        return;
    }
    
    id<MTLRenderPipelineState> pipelineState = [device newRenderPipelineStateWithDescriptor:pipelineDescriptor error:error];
    if (*error) {
        return;
    }
    
    //
    
    this->mdlMeshes = mdlMeshes;
    this->mtkMeshes = mtkMeshes;
    this->device = device;
    this->pipelineState = pipelineState;
    
    this->lastScale.store(1.f);
    this->totalScale.store(1.f);
    this->totalPanX.store(0.f);
    this->totalPanY.store(0.f);
}

void ObjectModel::drawInRenderEncoder(id<MTLRenderCommandEncoder> renderEncoder, CGSize size) {
    [renderEncoder setRenderPipelineState:this->pipelineState];
    
    const ObjectExplorer::Data data {
        .width = static_cast<float>(size.width),
        .height = static_cast<float>(size.height),
        .scale = static_cast<float>(this->totalScale.load()),
        .panX = static_cast<float>(this->totalPanX.load()),
        .panY = static_cast<float>(this->totalPanY.load()),
        .viewMatrix = simd_inverse(Math::translationMatrix({0.f, 0.f, -3.f}))
    };
    
    [renderEncoder setVertexBytes:&data length:sizeof(data) atIndex:ObjectExplorer::DataBuffer];
    
    [this->mtkMeshes enumerateObjectsUsingBlock:^(MTKMesh * _Nonnull mtkMesh, NSUInteger idx, BOOL * _Nonnull stop) {
        [mtkMesh.vertexBuffers enumerateObjectsUsingBlock:^(MTKMeshBuffer * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            [renderEncoder setVertexBuffer:obj.buffer offset:0 atIndex:idx];
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

void ObjectModel::didChangeMagnification(CGFloat scale) {
    this->totalScale.store(this->lastScale.load() + scale);
}

void ObjectModel::didEndMagnification(CGFloat scale) {
    this->lastScale.store(this->totalScale);
}

void ObjectModel::didChangePanning(CGFloat x, CGFloat y) {
    this->totalPanX.store(std::fmaf(this->totalPanX.load(), 1.f, x));
    this->totalPanY.store(std::fmaf(this->totalPanY.load(), 1.f, y));
}
