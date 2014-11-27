//
//  FOAssetsManager.m
//  FOAssetPicker
//
//  Created by Andreas Pasch (me@fobytes.com) on 10/02/14.
//  Copyright (c) 2014 fobytes.com. All rights reserved.
//

#import "FOAssetsManager.h"
#import "FOAssetProxy.h"
#import <AssetsLibrary/AssetsLibrary.h>

@interface FOAssetsManager ()
@property (nonatomic, strong, readwrite) ALAssetsLibrary* library;
@end

@implementation FOAssetsManager

- (instancetype) initWithAssetsLibrary: (ALAssetsLibrary*) assetsLibrary {
    self = [super init];
    if (self) {
        _library = assetsLibrary;
        _supportedMediaTypes = @[FOAssetPickerMediaTypePhoto];
        _previewCache = [[NSCache alloc] init];
    }
    return self;
}

- (void) loadAssetGroupsWithCompletionHandler: (void (^)(NSArray* assetGroups)) completionHandler failureHandler: (void (^)(NSError* error)) failureHandler {
    __strong NSMutableArray* assetGroups = [NSMutableArray array];

    void (^ assetGroupEnumerator)(ALAssetsGroup*, BOOL*) = ^(ALAssetsGroup* group, BOOL* stop)
    {
        if (!group) {
            // enumeration done
            completionHandler(assetGroups);
            return;
        }
        [group setAssetsFilter: [self filterForMediaTypes: self.supportedMediaTypes]];
        if ([group numberOfAssets] != 0) {
            [assetGroups addObject: group];
        }
    };
    void (^ assetGroupEnumberatorFailure)(NSError*) = ^(NSError* error) {
        failureHandler(error);
    };
    [self.library enumerateGroupsWithTypes: ALAssetsGroupAll
                                usingBlock: assetGroupEnumerator
                              failureBlock: assetGroupEnumberatorFailure];
}

- (void) loadAssetsForGroup: (ALAssetsGroup*) group withCompletionHandler: (void (^)(NSArray*)) completionHandler {
    __strong NSMutableArray* assets = [NSMutableArray array];

    [group enumerateAssetsUsingBlock: ^(ALAsset* result, NSUInteger index, BOOL* stop) {
         if (!result) {
             completionHandler(assets);
             return;
         }
        FOAssetProxy* assetProxy = [[FOAssetProxy alloc] initWithAsset:result];
        assetProxy.previewCache = self.previewCache;
        [assetProxy loadPreview];
        [assets addObject:assetProxy];
     }];
}

- (ALAssetsFilter*) filterForMediaTypes: (NSArray*) pickerTypes {
    if ([pickerTypes containsObject:FOAssetPickerMediaTypePhoto] &&
        [pickerTypes containsObject:FOAssetPickerMediaTypeVideo]) {
        return [ALAssetsFilter allAssets];
    }
    if ([pickerTypes containsObject:FOAssetPickerMediaTypePhoto]) {
        return [ALAssetsFilter allPhotos];
    }
    else if ([pickerTypes containsObject:FOAssetPickerMediaTypeVideo]) {
        return [ALAssetsFilter allVideos];
    }
    return [ALAssetsFilter allAssets];
}

@end
