//
//  HTVideoPickerViewController.h
//  HiddenTreasure
//
//  Created by Park on 2016. 11. 10..
//  Copyright © 2016년 Whybox1. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FTImagePicker.h"
@import Photos;
@import AVKit;
@class HTVideoDetailView;

@protocol HTVideoDetailViewDelegate <NSObject>
- (void) presentAVPlayerViewController: (AVPlayerViewController *) AVPlayerViewController AVPlayer:(AVPlayer *) AVPlayer;
@end

@interface HTVideoPickerViewController : UIViewController<UICollectionViewDelegate, UICollectionViewDataSource, FTImagePickerViewControllerDelegate, UICollectionViewDelegateFlowLayout, HTVideoDetailViewDelegate>

@property (strong, nonatomic) NSString *selectedAlbumName;
@property (strong, nonatomic) NSMutableArray<NSString *> *HTHiddenVideosFileNameArray;
@property (strong, nonatomic) NSMutableArray<UIImage *> *thumbnailImages;
@property (strong, nonatomic) NSMutableArray<NSNumber *> *videoLength;
@property (weak, nonatomic) IBOutlet UICollectionView *HTVideoPickerCollectionView;
@property (strong, nonatomic) IBOutlet HTVideoDetailView *HTVideoDetailView;
@property (weak, nonatomic) IBOutlet UIButton *HTVideoPickerBackBtn;
@property (weak, nonatomic) IBOutlet UIButton *HTVideoPickerAddBtn;
@property (weak, nonatomic) IBOutlet UIButton *HTVideoPickerSelectBtn;
@property (weak, nonatomic) IBOutlet UIButton *HTVideoPickerCancelBtn;
@property (weak, nonatomic) IBOutlet UIButton *HTVideoPickerExportBtn;
@property (weak, nonatomic) IBOutlet UIButton *HTVideoPickerDeleteBtn;
@property (strong, nonatomic) NSMutableArray<NSIndexPath *> *selectedVideos;
@property (strong, nonatomic) NSMutableIndexSet *selectedVideosIndex;

- (IBAction)backToAlbumBtnTouched:(id)sender;
- (IBAction)addHiddenVideosBtnTouched:(id)sender;
- (IBAction)selectVideosBtnTouched:(id)sender;
- (IBAction)selectCancelBtnTouched:(id)sender;
- (IBAction)exportVideosBtnTouched:(id)sender;
- (IBAction)deleteVideosBtnTouched:(id)sender;
@end



@interface HTVideoDetailView : UIView <UICollectionViewDataSource, UICollectionViewDataSource, UIScrollViewDelegate, UICollectionViewDelegateFlowLayout>
@property (weak, nonatomic) IBOutlet UICollectionView *videoDetailCollectionView;
@property (strong, nonatomic) NSMutableArray<UIImage *> *thumbnailImages;
@property (strong, nonatomic) NSString *selectedAlbumName;
@property (strong, nonatomic) UICollectionView *HTVideoPickerCollectionView;
@property (weak, nonatomic) IBOutlet UIButton *videoPlayBtn;
@property (weak, nonatomic) id<HTVideoDetailViewDelegate> delegate;

- (IBAction)videoPlayBtnTouched:(id)sender;
- (IBAction)backToPickerBtnTouched:(id)sender;
@end

@interface HTVideoPickerCollectionViewCell : UICollectionViewCell
@property (weak, nonatomic) IBOutlet UIImageView *thumbnail;
@property (weak, nonatomic) IBOutlet UILabel *videoLength;
@end

@interface HTVideoDetailCollectionViewCell : UICollectionViewCell
@property (weak, nonatomic) IBOutlet UIScrollView *detailViewScrollView;
@property (weak, nonatomic) IBOutlet UIImageView *detailViewImageView;

@end

