//
//  FOAssetProxy.m
//  FOAssetPicker
//
//  Created by Andreas Pasch (me@fobytes.com) on 10/02/14.
//  Copyright (c) 2014 fobytes.com. All rights reserved.
//

#import "FOAssetProxy.h"
#import <AssetsLibrary/ALAsset.h>

@interface FOAssetProxy ()
@property (nonatomic, strong) ALAsset* asset;
@property (nonatomic, strong) NSNumber* duration;
@property (nonatomic, strong) NSString* durationFormatted;
@end

@implementation FOAssetProxy

- (instancetype) initWithAsset: (ALAsset*) asset {
    self = [super init];
    if (self) {
        _asset = asset;
    }
    return self;
}

- (UIImage*) loadPreview {
    UIImage* image = nil;
    if (self.previewCache) {
        NSURL* assetUrl = [self assetURL];
        image = [self.previewCache objectForKey: assetUrl];
        if (!image) {
            image = [UIImage imageWithCGImage: [self.asset aspectRatioThumbnail]];
            [self.previewCache setObject: image forKey: assetUrl];
        }
    }
    return image;
}

- (UIImage*) preview {
    UIImage* image = [self loadPreview];

    if (!image) {
        image = [UIImage imageWithCGImage: [self.asset aspectRatioThumbnail]];
    }
    return image;
}

- (SNAssetType) assetType {
    NSString* type = [self.asset valueForProperty: ALAssetPropertyType];

    if ([ALAssetTypePhoto isEqualToString: type]) {
        return SNAssetTypePhoto;
    }
    else if ([ALAssetTypeVideo isEqualToString: type]) {
        return SNAssetTypeVideo;
    }
    return SNAssetTypeUnknown;
}

- (NSTimeInterval) videoDuration {
    if (!_duration) {
        _duration = [self.asset valueForProperty: ALAssetPropertyDuration];
    }
    return [_duration doubleValue];
}

- (NSString*) videoDurationFormatted {
    if (!_durationFormatted) {
        NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat: @"mm:ss"];
        _durationFormatted = [formatter stringFromDate: [NSDate dateWithTimeIntervalSince1970: [self videoDuration]]];
    }
    return _durationFormatted;
}

- (NSURL*) assetURL {
    return [self.asset valueForProperty: ALAssetPropertyAssetURL];
}

- (ALAsset*) asset {
    return _asset;
}

@end
