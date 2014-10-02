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
@property (nonatomic, strong) UIImage* preview;
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

- (UIImage*) preview {
    if (!_preview) {
        _preview = [UIImage imageWithCGImage: [self.asset aspectRatioThumbnail]];
    }
    return _preview;
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
