//
//  FOAssetProxy.h
//  FOAssetPicker
//
//  Created by Andreas Pasch (me@fobytes.com) on 10/02/14.
//  Copyright (c) 2014 fobytes.com. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM (NSUInteger, SNAssetType) {
    SNAssetTypeVideo,
    SNAssetTypePhoto,
    SNAssetTypeUnknown
};


@class ALAsset;
@interface FOAssetProxy : NSObject

@property (weak, nonatomic) NSCache* previewCache;
@property (assign, nonatomic) BOOL selected;

- (instancetype) initWithAsset: (ALAsset*) asset;

/*
 * Loads and caches the preview of the resource represented by this asset proxy.
 */
- (UIImage*) loadPreview;
/*
 * Creates a preview of the asset.
 */
- (UIImage*) preview;
/*
 * Indicates the type of asset.
 */
- (SNAssetType) assetType;
/*
 * Returns the duration (for motion content).
 */
- (NSTimeInterval) videoDuration;
/*
 * Returns the duraction formatted as string (for motion content).
 */
- (NSString*) videoDurationFormatted;
/*
 * Returns the asset URL.
 */
- (NSURL*) assetURL;
/*
 * Returns the original asset.
 */
- (ALAsset*) asset;

@end
