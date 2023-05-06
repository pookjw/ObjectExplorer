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
@end

NS_HEADER_AUDIT_END(nullability, sendability)
