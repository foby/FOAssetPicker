//
//  FOAssetCell.h
//  FOAssetPicker
//
//  Created by Andreas Pasch (me@fobytes.com) on 10/02/14.
//  Copyright (c) 2014 fobytes.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@class FOAssetProxy;
@interface FOAssetCell : UICollectionViewCell

@property (strong, nonatomic) FOAssetProxy* assetProxy;
@property (assign, nonatomic) BOOL checked;

@end
