//
//  FOViewController.m
//  FOAssetPicker
//
//  Created by Andreas Pasch (me@fobytes.com) on 10/02/14.
//  Copyright (c) 2014 fobytes.com. All rights reserved.
//

#import "FODemoViewController.h"
#import "FOAssetPicker.h"

@interface FODemoViewController () <FOAssetPickerDelegate>
@property (weak, nonatomic) IBOutlet UILabel* resultLabel;
@property (assign, nonatomic) BOOL pickerPresentedModally;

@end

@implementation FODemoViewController

- (void) viewDidAppear: (BOOL) animated {
    self.navigationItem.title = @"FOAssetPicker";
}

- (IBAction) presentAssetPicker: (id) sender {
    [self.navigationController pushViewController: [self assetPicker] animated: YES];
    self.pickerPresentedModally = NO;
}

- (IBAction) presentAssetPickerModally: (id) sender {
    FOAssetPicker* assetPicker = [FOAssetPicker presentModallyWithParentViewController: self];

    assetPicker.maxSelectionCount = 10;
    assetPicker.pickerDelegate = self;
    self.pickerPresentedModally = YES;
}

- (FOAssetPicker*) assetPicker {
    FOAssetPicker* assetPicker = [[FOAssetPicker alloc] init];

    assetPicker.maxSelectionCount = 10;
    assetPicker.pickerDelegate = self;
    return assetPicker;
}

#pragma mark - SNImagePickerDelegate

- (void) assetPicker: (FOAssetPicker*) assetPicker didFinishPickingWithAssets: (NSArray*) info {
    [self.resultLabel setText: [NSString stringWithFormat: @"%d assets selected.", [info count]]];
    if (self.pickerPresentedModally) {
        [assetPicker dismissViewControllerAnimated: YES completion: ^{
             NSLog(@"dismissed modally done");
         }];
    }
    else {
        [self.navigationController popToViewController: self animated: YES];
    }
}

- (void) assetPicker: (FOAssetPicker*) imagePicker didAbortWithError: (NSError*) error {
    NSLog(@"didAbortWithError=%@", error);
}

@end
