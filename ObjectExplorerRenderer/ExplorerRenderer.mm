//
//  ExplorerRenderer.mm
//  ObjectExplorerRenderer
//
//  Created by Jinwoo Kim on 5/5/23.
//

#import <ObjectExplorerRenderer/ExplorerRenderer.h>
#import <ObjectExplorerRenderer/constants.h>
#import <ObjectExplorerRenderer/ObjectModel.hpp>
#import <optional>
#import <memory>

@interface ExplorerRenderer () <MTKViewDelegate>
@property (strong) NSOperationQueue *queue;

@property (strong, nullable) MTKView *mtkView;
@property (strong) id<MTLDevice> device;
@property (strong) id<MTLCommandQueue> commandQueue;
@property (strong) id<MTLLibrary> library;

@property (assign) std::optional<std::shared_ptr<ObjectModel>> objectModel;
@end

@implementation ExplorerRenderer

- (instancetype)init {
    if (self = [super init]) {
        [self setupQueue];
    }
    
    return self;
}

- (void)setupWithMTKView:(MTKView *)mtkView modelType:(ObjectModelType)modelType completionHandler:(void (^)(NSError * _Nullable __autoreleasing))completionHandler {
    [self.queue addOperationWithBlock:^{
        if (self.mtkView) {
            completionHandler([NSError errorWithDomain:ObjectExplorerRendererErrorDomain code:ObjectExplorerRendererErrorAlreadySetup userInfo:nil]);
            return;
        }
        
        NSError * _Nullable __autoreleasing error = nil;
        
        id<MTLDevice> device = MTLCreateSystemDefaultDevice();
        id<MTLCommandQueue> commandQueue = device.newCommandQueue;
        
        NSBundle *bundle = [NSBundle bundleWithIdentifier:ObjectExplorerRendererBundleIdentifier];
        id<MTLLibrary> library = [device newDefaultLibraryWithBundle:bundle error:&error];
        if (error) {
            completionHandler(error);
            return;
        }
        
        //
        
        mtkView.device = device;
        mtkView.delegate = self;
        mtkView.clearColor = MTLClearColorMake(1.f, 1.f, 1.f, 1.f);
        
        self.mtkView = mtkView;
        self.device = device;
        self.commandQueue = commandQueue;
        self.library = library;
        self.objectModel = std::shared_ptr<ObjectModel>(new ObjectModel(device, modelType, &error));
        
        if (error) {
            completionHandler(error);
            return;
        }
        
        completionHandler(nil);
    }];
}

- (void)setupQueue {
    NSOperationQueue *queue = [NSOperationQueue new];
    queue.qualityOfService = NSQualityOfServiceUserInteractive;
    queue.maxConcurrentOperationCount = 1;
    self.queue = queue;
}

- (void)renderWithMTKView:(MTKView *)mtkView size:(std::optional<CGSize>)size {
    const CGSize drawableSize = size.value_or(mtkView.currentDrawable.layer.drawableSize);
    
    [self.queue addOperationWithBlock:^{
        if (!self->_objectModel.has_value()) return;
        
        MTLCommandBufferDescriptor *commandBufferDescriptor = [MTLCommandBufferDescriptor new];
        commandBufferDescriptor.retainedReferences = NO;
        
        id<MTLCommandBuffer> commandBuffer = [self->_commandQueue commandBufferWithDescriptor:commandBufferDescriptor];
        MTLRenderPassDescriptor * _Nullable renderPassDescriptor = mtkView.currentRenderPassDescriptor;
        if (!renderPassDescriptor) return;
        
        id<MTLRenderCommandEncoder> renderEncoder = [commandBuffer renderCommandEncoderWithDescriptor:renderPassDescriptor];
        
        self->_objectModel.value().get()->drawInRenderEncoder(renderEncoder, drawableSize);
        
        [renderEncoder endEncoding];
        [commandBuffer presentDrawable:mtkView.currentDrawable];
        
        dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
        [commandBuffer addCompletedHandler:^(id<MTLCommandBuffer> _Nonnull buffer) {
            dispatch_semaphore_signal(semaphore);
        }];
        [commandBuffer commit];
        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
    }];
}

- (void)mtkView:(nonnull MTKView *)view drawableSizeWillChange:(CGSize)size {
    [self renderWithMTKView:view size:size];
}

- (void)drawInMTKView:(nonnull MTKView *)view {
    [self renderWithMTKView:view size:std::nullopt];
}

@end
