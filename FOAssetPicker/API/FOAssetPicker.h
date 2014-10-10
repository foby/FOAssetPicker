//
//  FOAssetPicker.h
//  FOAssetPicker
//
//  Created by Andreas Pasch (me@fobytes.com) on 10/02/14.
//  Copyright (c) 2014 fobytes.com. All rights reserved.
//

#import <UIKit/UIKit.h>

// Default maximum selection count (30)
extern NSUInteger const FOAssetPickerDefaultMaxSelectionCount;

// The type of assets to show
extern NS_ENUM(NSUInteger, FOAssetPickerType) {
    FOAssetPickerTypePhotos,
    FOAssetPickerTypeVideos
};

@class ALAssetsLibrary;
@class FOAssetPicker;

@protocol FOAssetPickerDelegate <NSObject>
/*
 * Invoked when the user has finished selecting assets in the picker.
 * Returns an array of ALAsset objects as proxies for images/videos.
 */
- (void) assetPicker: (FOAssetPicker*) assetPicker didFinishPickingWithAssets: (NSArray*) assets;
/*
 * Invoked when an error occures while accessing the library.
 */
- (void) assetPicker: (FOAssetPicker*) assetPicker didAbortWithError: (NSError*) error;
@end


@protocol FOAssetPickerCellRenderer <NSObject>

- (void) renderCell: (UITableViewCell*) cell;

@end

/**
 * View for multi-selectable access to the iOS Asset Library.
 */
@interface FOAssetPicker : UITableViewController <UITableViewDataSource, UITableViewDelegate>

/*
 * The library to use for accessing assets.
 */
@property (nonatomic, strong) ALAssetsLibrary* library;
/*
 * The maximum number of selectable assets.
 */
@property (nonatomic, assign) NSUInteger maxSelectionCount;
/*
 * Flag for configuring video inline playback (on long-press). Default is NO.
 */
@property (nonatomic, assign) BOOL videoPlaybackEnabled;
@property (nonatomic, assign, readonly) enum FOAssetPickerType pickerType;
@property (nonatomic, weak) id<FOAssetPickerDelegate> pickerDelegate;
@property (nonatomic, weak) id<FOAssetPickerCellRenderer> cellRenderer;

/*
 * Creates a new instance of the asset picker for the given picker type.
 */
- (instancetype) initWithPickerType: (enum FOAssetPickerType) type;

/*
 * Convenience method presenting the asset picker modally wrapped in navigation view controller and returns it for configuration purposes.
 */
+ (FOAssetPicker*) presentModallyWithPickerType: (enum FOAssetPickerType) type andParentViewController: (UIViewController*) parentViewController;

@end
