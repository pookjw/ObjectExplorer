//
//  ExplorerRenderer.h
//  ObjectExplorerRenderer
//
//  Created by Jinwoo Kim on 5/5/23.
//

#import <MetalKit/MetalKit.h>
#import <ObjectExplorerRenderer/ObjectModelType.h>

NS_HEADER_AUDIT_BEGIN(nullability, sendability)

@interface ExplorerRenderer : NSObject
- (void)setupWithMTKView:(MTKView *)mtkView modelType:(ObjectModelType)modelType completionHandler:(void (^)(NSError * _Nullable __autoreleasing error))completionHandler NS_SWIFT_NAME(setup(mtkView:modelType:completionHandler:));

- (void)didChangeMagnificationWithScale:(CGFloat)scale NS_SWIFT_NAME(didChangeMagnification(scale:));
- (void)didEndMagnificationWithScale:(CGFloat)scale NS_SWIFT_NAME(didEndMagnification(scale:));

- (void)didChangePanningWithX:(CGFloat)x y:(CGFloat)y NS_SWIFT_NAME(didChangePanning(x:y:));
@end

NS_HEADER_AUDIT_END(nullability, sendability)
