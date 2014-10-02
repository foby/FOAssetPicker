//
//  FOAssetsManager.h
//  FOAssetPicker
//
//  Created by Andreas Pasch (me@fobytes.com) on 10/02/14.
//  Copyright (c) 2014 fobytes.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@class ALAssetsGroup;
@class ALAssetsLibrary;

@interface FOAssetsManager : NSObject

@property (nonatomic, strong, readonly) ALAssetsLibrary* library;

- (instancetype) initWithAssetsLibrary: (ALAssetsLibrary*) assetsLibrary;

- (void) loadAssetGroupsWithCompletionHandler: (void (^)(NSArray* assetGroups)) completionHandler failureHandler: (void (^)(NSError* error)) failureHandler;

- (void) loadAssetsForGroup: (ALAssetsGroup*) group withCompletionHandler: (void (^)(NSArray* assets)) completionHandler;

@end
