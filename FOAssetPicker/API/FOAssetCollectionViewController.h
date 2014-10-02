//
//  FOAssetCollectionViewController.h
//  FOAssetPicker
//
//  Created by Andreas Pasch (me@fobytes.com) on 10/02/14.
//  Copyright (c) 2014 fobytes.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ALAssetsGroup;
@class FOAssetsManager;

typedef void (^ FOAssetSelectionDoneHandler)(NSArray* assetProxies);

@interface FOAssetCollectionViewController : UIViewController

@property (weak, nonatomic) IBOutlet UICollectionView* collectionView;
@property (strong, nonatomic) ALAssetsGroup* assetsGroup;
@property (assign, nonatomic) NSUInteger maxSelectionCount;
@property (copy, nonatomic) FOAssetSelectionDoneHandler selectionDoneHandler;
@property (nonatomic, strong) FOAssetsManager* assetsManager;

@end
