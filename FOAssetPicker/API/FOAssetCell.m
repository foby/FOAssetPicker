//
//  FOAssetCell.m
//  FOAssetPicker
//
//  Created by Andreas Pasch (me@fobytes.com) on 10/02/14.
//  Copyright (c) 2014 fobytes.com. All rights reserved.
//

#import "FOAssetCell.h"
#import "FOAssetProxy.h"

@interface FOAssetCell ()
@property (weak, nonatomic) IBOutlet UIImageView* imageView;
@property (weak, nonatomic) IBOutlet UILabel* duration;
@property (weak, nonatomic) IBOutlet UIImageView* check;
@property (weak, nonatomic) IBOutlet UIView* overlayView;
@property (weak, nonatomic) IBOutlet UIView* videoInfoOverlay;
@end

@implementation FOAssetCell

- (void) awakeFromNib {
    [super awakeFromNib];
    self.check.hidden = YES;
}

- (void) setAssetProxy: (FOAssetProxy*) assetProxy {
    self.imageView.image = [assetProxy preview];

    self.checked = assetProxy.selected;

    if ([assetProxy assetType] == SNAssetTypeVideo) {
        self.videoInfoOverlay.hidden = NO;
        self.duration.text = [assetProxy videoDurationFormatted];
    }
    else {
        self.videoInfoOverlay.hidden = YES;
    }
    _assetProxy = assetProxy;
}

- (void) setChecked: (BOOL) checked {
    self.check.hidden = !checked;
    if (checked) {
        self.overlayView.alpha = 0.4;
    }
    else {
        self.overlayView.alpha = 0;
    }
    self.assetProxy.selected = checked;
}

- (BOOL) isChecked {
    return self.assetProxy.selected;
}

@end
