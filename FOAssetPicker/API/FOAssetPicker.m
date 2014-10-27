//
//  FOAssetPicker.m
//  FOAssetPicker
//
//  Created by Andreas Pasch (me@fobytes.com) on 10/02/14.
//  Copyright (c) 2014 fobytes.com. All rights reserved.
//

#import "FOAssetPicker.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import "FOAssetCollectionViewController.h"
#import "FOAssetsManager.h"
#import "FOAssetProxy.h"

static NSString* const FOAssetPickerAssetsSegue = @"AssetsSegue";
static NSString* const FOAssetPickerCellIdentifier = @"Cell";

NSString* const FOAssetPickerMediaTypePhoto = @"photo";
NSString* const FOAssetPickerMediaTypeVideo = @"video";

NSUInteger const FOAssetPickerDefaultMaxSelectionCount = 30;

@interface FOAssetPicker ()
@property (nonatomic, strong) NSArray* assetGroups;
@property (nonatomic, strong) FOAssetCollectionViewController* videosVC;
@property (nonatomic) NSUInteger assetsGroupIndex;
@property (nonatomic) NSUInteger numberOfGroups;
@property (nonatomic, strong) FOAssetsManager* assetsManager;
@end

@implementation FOAssetPicker

- (instancetype) init {
    UIStoryboard* storyboard = [UIStoryboard storyboardWithName: @"FOAssetPicker" bundle: nil];

    self = [storyboard instantiateInitialViewController];
    if (self) {
        self.library = [[ALAssetsLibrary alloc] init];
        self.maxSelectionCount = FOAssetPickerDefaultMaxSelectionCount;
        self.videoPlaybackEnabled = NO;
        self.supportedMediaTypes = @[FOAssetPickerMediaTypePhoto];
    }
    return self;
}

+ (FOAssetPicker*) presentModallyWithMediaTypes: (NSArray*) mediaTypes andParentViewController: (UIViewController*) parentViewController {
    FOAssetPicker* assetPicker = [[[self class] alloc] init];
    assetPicker.supportedMediaTypes = mediaTypes;

    assetPicker.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle: NSLocalizedString(@"FOAssetPicker.cancel", nil) style: UIBarButtonItemStylePlain target: assetPicker action: @selector(dismissImagePicker)];
    UINavigationController* navigationController = [[UINavigationController alloc] initWithRootViewController: assetPicker];

    [parentViewController presentViewController: navigationController animated: YES completion: NULL];
    return assetPicker;
}

- (void) setLibrary: (ALAssetsLibrary*) library {
    self.assetsManager = [[FOAssetsManager alloc] initWithAssetsLibrary: library];
    self.assetsManager.supportedMediaTypes = self.supportedMediaTypes;
}

- (ALAssetsLibrary*) library {
    return self.assetsManager.library;
}

- (void) setSupportedMediaTypes:(NSArray *)supportedMediaTypes {
    self.assetsManager.supportedMediaTypes = supportedMediaTypes;
    _supportedMediaTypes = supportedMediaTypes;
}

#pragma - mark View lifecycle

- (void) viewDidLoad {
    [super viewDidLoad];
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame: CGRectZero];
    self.tableView.contentInset = UIEdgeInsetsMake(5, 0, 0, 0);
    [self prepareAssetGroups];
}

- (void) viewWillAppear: (BOOL) animated {
    for (NSUInteger row = 0; row < [self.assetGroups count]; row++) {
        [self.tableView deselectRowAtIndexPath: [NSIndexPath indexPathForRow: row inSection: 0] animated: NO];
    }
}

- (void) viewDidAppear: (BOOL) animated {
    self.navigationItem.title = NSLocalizedString(@"FOAssetPicker.albums", nil);
}

- (void) reloadTableView {
    [self.tableView reloadData];
}

- (void) dismissImagePicker {
    dispatch_async(dispatch_get_main_queue(), ^{
                       [self dismissViewControllerAnimated: YES completion: ^{
                        }];
                   });
}

#pragma mark - TableView data source

- (NSInteger) numberOfSectionsInTableView: (UITableView*) tableView {
    return 1;
}

- (NSInteger) tableView: (UITableView*) tableView numberOfRowsInSection: (NSInteger) section {
    return [self.assetGroups count];
}

- (UITableViewCell*) tableView: (UITableView*) tableView cellForRowAtIndexPath: (NSIndexPath*) indexPath {
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier: FOAssetPickerCellIdentifier];

    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle: UITableViewCellStyleDefault reuseIdentifier: FOAssetPickerCellIdentifier];
    }
    ALAssetsGroup* group = (ALAssetsGroup*)[self.assetGroups objectAtIndex: indexPath.row];
    NSInteger groupCount = [group numberOfAssets];
    cell.textLabel.text = [NSString stringWithFormat: @"%@ (%ld)", [group valueForProperty: ALAssetsGroupPropertyName], (long)groupCount];
    [cell.imageView setImage: [UIImage imageWithCGImage: [(ALAssetsGroup*)[self.assetGroups objectAtIndex: indexPath.row] posterImage]]];
    [cell setAccessoryType: UITableViewCellAccessoryDisclosureIndicator];

    if (self.cellRenderer) {
        [self.cellRenderer renderCell: cell];
    }

    return cell;
}

#pragma mark - Table view delegate methods

- (void) tableView: (UITableView*) tableView didSelectRowAtIndexPath: (NSIndexPath*) indexPath {
    self.assetsGroupIndex = indexPath.row;
    [self performSegueWithIdentifier: FOAssetPickerAssetsSegue sender: nil];
}

#pragma mark - Prepare segue

- (void) prepareForSegue: (UIStoryboardSegue*) segue sender: (id) sender {
    if ([[segue identifier] isEqualToString: FOAssetPickerAssetsSegue]) {
        FOAssetCollectionViewController* assetsVC = [segue destinationViewController];
        assetsVC.assetsGroup = [self.assetGroups objectAtIndex: self.assetsGroupIndex];
        assetsVC.maxSelectionCount = self.maxSelectionCount;
        assetsVC.videoPlaybackEnabled = self.videoPlaybackEnabled;
        assetsVC.assetsManager = self.assetsManager;
        assetsVC.selectionDoneHandler = ^(NSArray* assetProxies) {
            if ([self.pickerDelegate respondsToSelector: @selector(assetPicker:didFinishPickingWithAssets:)]) {
                [self.pickerDelegate assetPicker: self didFinishPickingWithAssets: [self assetsFromProxies: assetProxies]];
            }
        };
    }
}

#pragma mark - Helper

- (NSArray*) assetsFromProxies: (NSArray*) assetProxies {
    NSMutableArray* result = [NSMutableArray array];

    for (FOAssetProxy* proxy in assetProxies) {
        [result addObject: [proxy asset]];
    }
    return result;
}

- (void) prepareAssetGroups {
    [self.assetsManager loadAssetGroupsWithCompletionHandler: ^(NSArray* assetGroups) {
         self.assetGroups = assetGroups;
         [self reloadTableView];
     } failureHandler: ^(NSError* error) {
         [self.pickerDelegate assetPicker: self didAbortWithError: error];
     }];
}

@end
