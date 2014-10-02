//
//  FOAssetCollectionViewController.m
//  FOAssetPicker
//
//  Created by Andreas Pasch (me@fobytes.com) on 10/02/14.
//  Copyright (c) 2014 fobytes.com. All rights reserved.
//

#import "FOAssetCollectionViewController.h"
#import <MediaPlayer/MediaPlayer.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import "FOAssetsManager.h"
#import "FOAssetProxy.h"
#import "FOAssetCell.h"

static NSString* const SNAssetsCellIdentifier = @"Cell";

@interface FOAssetCollectionViewController ()
@property (strong, nonatomic) NSArray* assetProxies;
@property (nonatomic) BOOL isPlayerPlaying;
@property (strong, nonatomic) MPMoviePlayerViewController* playerVC;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView* activityIndicator;
@end

@implementation FOAssetCollectionViewController

- (void) viewDidLoad {
    [super viewDidLoad];
    self.assetProxies = [NSMutableArray array];
    self.collectionView.delegate = (id)self;
    self.collectionView.dataSource = (id)self;
    self.collectionView.contentInset = UIEdgeInsetsMake(0, 0, 100, 0);
    UILongPressGestureRecognizer* longPressGesture = [[UILongPressGestureRecognizer alloc]initWithTarget: self action: @selector(handleLongPressGesture:)];
    [self.collectionView addGestureRecognizer: longPressGesture];
    longPressGesture.delegate = (id)self;
}

- (void) viewWillAppear: (BOOL) animated {
    self.activityIndicator.hidden = NO;
}

- (void) viewDidAppear: (BOOL) animated {
    [super viewDidAppear: animated];

    UIBarButtonItem* doneBtn = [[UIBarButtonItem alloc] initWithBarButtonSystemItem: UIBarButtonSystemItemDone target: self action: @selector(doneTouched)];
    [self.navigationItem setRightBarButtonItem: doneBtn];

    [self.assetsManager loadAssetsForGroup: self.assetsGroup withCompletionHandler: ^(NSArray* assets) {
         NSMutableArray* tmp = [NSMutableArray array];
         for (ALAsset * asset in assets) {
             FOAssetProxy* proxy = [[FOAssetProxy alloc] initWithAsset: asset];
             [tmp addObject: proxy];
         }
         self.assetProxies = tmp;
         [self.collectionView reloadData];
         [self updateTitle];
         self.activityIndicator.hidden = YES;
     }];
}

- (void) handleLongPressGesture: (UILongPressGestureRecognizer*) gestureRecognizer {
    self.collectionView.userInteractionEnabled = NO;
    CGPoint p = [gestureRecognizer locationInView: self.collectionView];

    NSIndexPath* indexPath = [self.collectionView indexPathForItemAtPoint: p];
    if (indexPath == nil) {
        NSLog(@"Long press on collection view but not on a row");
    }
    else {
        NSLog(@"long press on collection view at row %d", indexPath.row);
        FOAssetProxy* proxy = [self.assetProxies objectAtIndex: indexPath.row];
        [self playVideoAtURL: [proxy assetURL]];
    }
}

- (void) doneTouched {
    // collect selected assets
    NSMutableArray* selectedAssets = [NSMutableArray array];

    for (FOAssetProxy* proxy in self.assetProxies) {
        if (proxy.selected) {
            [selectedAssets addObject: proxy];
        }
    }

    if (self.selectionDoneHandler) {
        self.selectionDoneHandler(selectedAssets);
    }
}

#pragma mark - UICollectionViewDataSource methods

- (NSInteger) numberOfSectionsInCollectionView: (UICollectionView*) collectionView {
    return 1;
}

- (NSInteger) collectionView: (UICollectionView*) collectionView numberOfItemsInSection: (NSInteger) section {
    return [self.assetProxies count];
}

- (UICollectionViewCell*) collectionView: (UICollectionView*) collectionView cellForItemAtIndexPath: (NSIndexPath*) indexPath {
    FOAssetCell* cell = (FOAssetCell*)[collectionView dequeueReusableCellWithReuseIdentifier: SNAssetsCellIdentifier forIndexPath: indexPath];
    FOAssetProxy* proxy = [self.assetProxies objectAtIndex: indexPath.row];

    if (proxy) {
        cell.assetProxy = proxy;
    }
    return cell;
}

#pragma mark - UICollectionViewDelegate methods

- (void) collectionView: (UICollectionView*) collectionView didSelectItemAtIndexPath: (NSIndexPath*) indexPath {
    FOAssetCell* cell = (FOAssetCell*)[collectionView cellForItemAtIndexPath: indexPath];
    FOAssetProxy* assetProxy = [self.assetProxies objectAtIndex: indexPath.row];

    if (assetProxy) {
        cell.checked = !assetProxy.selected;
        [self updateTitle];
    }
}

#pragma mark - Play Movie

- (void) playVideoAtURL: (NSURL*) videoUrl {
    if (!self.isPlayerPlaying) {
        self.isPlayerPlaying = YES;
        self.playerVC = [[MPMoviePlayerViewController alloc] initWithContentURL: videoUrl];

        [[NSNotificationCenter defaultCenter] removeObserver: self.playerVC
                                                        name: MPMoviePlayerPlaybackDidFinishNotification
                                                      object: self.playerVC.moviePlayer];

        [[NSNotificationCenter defaultCenter] addObserver: self
                                                 selector: @selector(movieFinishedCallback:)
                                                     name: MPMoviePlayerPlaybackDidFinishNotification
                                                   object: self.playerVC.moviePlayer];

        self.playerVC.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
        self.playerVC.modalPresentationStyle = UIModalPresentationFullScreen;
        [self presentViewController: self.playerVC animated: YES completion: ^{
             NSLog(@"done present player");
         }];
        [self.playerVC.moviePlayer setFullscreen: NO];
        [self.playerVC.moviePlayer prepareToPlay];
        [self.playerVC.moviePlayer play];
    }
}

- (void) movieFinishedCallback: (NSNotification*) aNotification {
    if ([aNotification.name isEqualToString: MPMoviePlayerPlaybackDidFinishNotification]) {
        NSNumber* finishReason = [[aNotification userInfo] objectForKey: MPMoviePlayerPlaybackDidFinishReasonUserInfoKey];

        if ([finishReason intValue] != MPMovieFinishReasonPlaybackEnded) {
            MPMoviePlayerController* moviePlayer = [aNotification object];


            [[NSNotificationCenter defaultCenter] removeObserver: self
                                                            name: MPMoviePlayerPlaybackDidFinishNotification
                                                          object: moviePlayer];
            [self dismissViewControllerAnimated: YES completion: ^{  }];
        }
        self.collectionView.userInteractionEnabled = YES;
        self.isPlayerPlaying = NO;
    }
}

#pragma mark - Helper

- (NSUInteger) selectionCount {
    NSUInteger selectionCount = 0;

    for (FOAssetProxy* proxy in self.assetProxies) {
        if (proxy.selected) {
            selectionCount++;
        }
    }
    return selectionCount;
}

- (void) updateTitle {
    NSUInteger selectionCount = [self selectionCount];

    NSString* titlePattern = NSLocalizedString(@"SNImagePicker.numAssetsSelectedMultiple", nil);

    if (selectionCount == 1) {
        titlePattern = NSLocalizedString(@"SNImagePicker.numAssetsSelectedSingle", nil);
    }
    self.navigationItem.title = [NSString stringWithFormat: titlePattern, selectionCount];
}

- (void) didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
