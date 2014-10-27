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
@property (weak, nonatomic) IBOutlet UIButton* buttonAssetTypePhotos;
@property (weak, nonatomic) IBOutlet UIButton* buttonAssetTypeVideos;
@property (weak, nonatomic) IBOutlet UIButton* buttonAssetTypeBoth;
@property (strong, nonatomic) NSArray* supportedMediaTypes;
@end

@implementation FODemoViewController

- (void) viewDidLoad {
    [self photosTapped: nil];
}

- (void) viewDidAppear: (BOOL) animated {
    self.navigationItem.title = @"FOAssetPicker";
}

- (IBAction) presentAssetPicker: (id) sender {
    [self.navigationController pushViewController: [self assetPicker] animated: YES];
    self.pickerPresentedModally = NO;
}

- (IBAction) presentAssetPickerModally: (id) sender {
    FOAssetPicker* assetPicker = [FOAssetPicker presentModallyWithMediaTypes:self.supportedMediaTypes andParentViewController:self];

    assetPicker.maxSelectionCount = 10;
    assetPicker.pickerDelegate = self;
    self.pickerPresentedModally = YES;
}

- (IBAction) photosTapped: (id) sender {
    self.supportedMediaTypes = @[FOAssetPickerMediaTypePhoto];
    self.buttonAssetTypePhotos.titleLabel.attributedText = [[NSAttributedString alloc] initWithString: @"Photos"];
    self.buttonAssetTypeVideos.titleLabel.attributedText = [self strikedThroughString: @"Videos"];
    self.buttonAssetTypeBoth.titleLabel.attributedText = [self strikedThroughString: @"both"];
}

- (IBAction) videosTapped: (id) sender {
    self.supportedMediaTypes = @[FOAssetPickerMediaTypeVideo];
    self.buttonAssetTypeVideos.titleLabel.attributedText = [[NSAttributedString alloc] initWithString: @"Videos"];
    self.buttonAssetTypePhotos.titleLabel.attributedText = [self strikedThroughString: @"Photos"];
    self.buttonAssetTypeBoth.titleLabel.attributedText = [self strikedThroughString: @"both"];
}

- (IBAction) bothTapped: (id) sender {
    self.supportedMediaTypes = @[FOAssetPickerMediaTypePhoto, FOAssetPickerMediaTypeVideo];
    self.buttonAssetTypeBoth.titleLabel.attributedText = [[NSAttributedString alloc] initWithString: @"both"];
    self.buttonAssetTypeVideos.titleLabel.attributedText = [self strikedThroughString: @"Videos"];
    self.buttonAssetTypePhotos.titleLabel.attributedText = [self strikedThroughString: @"Photos"];
}

- (NSAttributedString*) strikedThroughString: (NSString*) s {
    NSMutableAttributedString* attString = [[NSMutableAttributedString alloc] initWithString: s];

    [attString addAttribute: NSStrikethroughStyleAttributeName value: [NSNumber numberWithInt: NSUnderlineStyleThick] range: NSMakeRange(0, [s length])];
    return attString;
}

- (FOAssetPicker*) assetPicker {
    FOAssetPicker* assetPicker = [[FOAssetPicker alloc] init];

    assetPicker.supportedMediaTypes = self.supportedMediaTypes;
    assetPicker.maxSelectionCount = 10;
    assetPicker.pickerDelegate = self;
    return assetPicker;
}

#pragma mark - SNImagePickerDelegate

- (void) assetPicker: (FOAssetPicker*) assetPicker didFinishPickingWithAssets: (NSArray*) assets {
    [self.resultLabel setText: [NSString stringWithFormat: @"%lu assets selected.", (unsigned long)[assets count]]];
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
