//
//  constants.h
//  ObjectExplorerRenderer
//
//  Created by Jinwoo Kim on 4/17/23.
//

#import <Foundation/Foundation.h>

static NSString * const ObjectExplorerRendererBundleIdentifier = @"com.pookjw.ObjectExplorerRenderer";

static NSErrorDomain const ObjectExplorerRendererErrorDomain = @"ObjectExplorerRendererErrorDomain";

NS_ERROR_ENUM(ObjectExplorerRendererErrorDomain) {
    ObjectExplorerRendererErrorAlreadySetup = 0b1
};
