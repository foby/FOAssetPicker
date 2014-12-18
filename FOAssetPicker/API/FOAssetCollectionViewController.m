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

static NSString* const FOAssetsCellIdentifier = @"Cell";
static CGFloat const IPhone6ScreenWidth = 375;
static CGFloat const IPhone6PlusScreenWidth = 414;
static CGFloat const IPhone6CellSize = 89;
static CGFloat const IPhone6PlusCellSize = 78;
static CGFloat const IPhone5CellSize = 75;

@interface FOAssetCollectionViewController () <UICollectionViewDelegateFlowLayout>
@property (strong, nonatomic) NSArray* assetProxies;
@property (nonatomic) BOOL isPlayerPlaying;
@property (strong, nonatomic) MPMoviePlayerViewController* playerVC;
@property (weak, nonatomic) IBOutlet UIProgressView* progressView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *progressViewTopLayoutConstraint;
@property (weak, nonatomic) IBOutlet UICollectionView* collectionView;
@end

@implementation FOAssetCollectionViewController

- (void) viewDidLoad {
    [super viewDidLoad];
    self.assetProxies = [NSMutableArray array];
    self.collectionView.delegate = (id)self;
    self.collectionView.dataSource = (id)self;
    self.collectionView.collectionViewLayout = [[UICollectionViewFlowLayout alloc] init];
    
    if (self.videoPlaybackEnabled) {
        UILongPressGestureRecognizer* longPressGesture = [[UILongPressGestureRecognizer alloc]initWithTarget: self action: @selector(handleLongPressGesture:)];
        [self.collectionView addGestureRecognizer: longPressGesture];
        longPressGesture.delegate = (id)self;
    }
}

- (void) viewWillAppear: (BOOL) animated {
    [self.progressView setProgress:0];
    self.progressView.hidden = NO;
    
    // calculate inset due to navigation + status bar visibility
    CGFloat liveTopInset = self.navigationController.navigationBar.frame.size.height + [UIApplication sharedApplication].statusBarFrame.size.height;
    self.progressViewTopLayoutConstraint.constant = liveTopInset;
    [self.collectionView setContentInset:UIEdgeInsetsMake(3, 0, 3, 0)];
}

- (void) viewDidAppear: (BOOL) animated {
    [super viewDidAppear: animated];
    
    UIBarButtonItem* doneBtn = [[UIBarButtonItem alloc] initWithBarButtonSystemItem: UIBarButtonSystemItemDone target: self action: @selector(doneTouched)];
    self.navigationItem.rightBarButtonItem = doneBtn;
    self.navigationItem.rightBarButtonItem.enabled = NO;

    [self.assetsManager loadAssetsForGroup: self.assetsGroup withCompletionHandler: ^(NSArray* assets) {
         self.assetProxies = assets;
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.collectionView reloadData];
            [self updateTitle];
            self.progressView.hidden = YES;
        });
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:[self.assetProxies count] - 1 inSection:0] atScrollPosition:UICollectionViewScrollPositionBottom animated:YES];
        });
     } andProgressHandler:^(CGFloat progress) {
         dispatch_async(dispatch_get_main_queue(), ^{
             [self.progressView setProgress:progress];
         });
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
    FOAssetCell* cell = (FOAssetCell*)[collectionView dequeueReusableCellWithReuseIdentifier: FOAssetsCellIdentifier forIndexPath: indexPath];
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
        if (!assetProxy.selected && [self selectionCount] >= self.maxSelectionCount) {
            return;
        }
        assetProxy.selected = !assetProxy.selected;
        cell.checked = assetProxy.selected;
        [self updateTitle];
    }
}

#pragma mark - UICollectionViewDelegateFlowLayout

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    CGSize screenSize = [[UIScreen mainScreen] applicationFrame].size;
    
    // TODO: generic cell size calculation based on the available width
    if (screenSize.width == IPhone6ScreenWidth) {
        return CGSizeMake(IPhone6CellSize, IPhone6CellSize);
    } else if (screenSize.width == IPhone6PlusScreenWidth) {
        return CGSizeMake(IPhone6PlusCellSize, IPhone6PlusCellSize);
    }
    return CGSizeMake(IPhone5CellSize, IPhone5CellSize);
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    return UIEdgeInsetsMake(0, 4, 0, 4);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return 2;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return 4;
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

    NSString* titlePattern = NSLocalizedString(@"FOAssetPicker.numAssetsSelectedMultiple", nil);

    if (selectionCount == 1) {
        titlePattern = NSLocalizedString(@"FOAssetPicker.numAssetsSelectedSingle", nil);
    }
    self.navigationItem.title = [NSString stringWithFormat: titlePattern, selectionCount];
    self.navigationItem.rightBarButtonItem.enabled = selectionCount > 0;
}

- (void) didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
