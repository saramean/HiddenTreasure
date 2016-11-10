//
//  HTImagePickerViewController.h
//  HiddenTreasure
//
//  Created by Park on 2016. 11. 7..
//  Copyright © 2016년 Whybox1. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FTImagePicker.h"
@import Photos;
@class HTImageDetailView;

@interface HTImagePickerViewController : UIViewController<UICollectionViewDelegate, UICollectionViewDataSource, FTImagePickerViewControllerDelegate, UICollectionViewDelegateFlowLayout>

@property (strong, nonatomic) NSString *selectedAlbumName;
@property (strong, nonatomic) NSMutableArray<NSString *> *HTHiddenImagesFileNameArray;
@property (strong, nonatomic) NSMutableArray<UIImage *> *thumbnailImages;
@property (weak, nonatomic) IBOutlet UICollectionView *HTImagePickerCollectionView;
@property (strong, nonatomic) IBOutlet HTImageDetailView *HTImageDetailView;
@property (weak, nonatomic) IBOutlet UIButton *HTImagePickerBackBtn;
@property (weak, nonatomic) IBOutlet UIButton *HTImagePickerAddBtn;
@property (weak, nonatomic) IBOutlet UIButton *HTImagePickerSelectBtn;
@property (weak, nonatomic) IBOutlet UIButton *HTImagePickerCancelBtn;
@property (weak, nonatomic) IBOutlet UIButton *HTImagePickerExportBtn;
@property (weak, nonatomic) IBOutlet UIButton *HTImagePickerDeleteBtn;
@property (strong, nonatomic) NSMutableArray<NSIndexPath *> *selectedImages;
@property (strong, nonatomic) NSMutableIndexSet *selectedImagesIndex;

- (IBAction)backToAlbumBtnTouched:(id)sender;
- (IBAction)addHiddenImagesBtnTouched:(id)sender;
- (IBAction)selectImagesBtnTouched:(id)sender;
- (IBAction)selectCancelBtnTouched:(id)sender;
- (IBAction)exportImagesBtnTouched:(id)sender;
- (IBAction)deleteImagesBtnTouched:(id)sender;
@end

@interface HTImageDetailView : UIView <UICollectionViewDataSource, UICollectionViewDataSource, UIScrollViewDelegate, UICollectionViewDelegateFlowLayout>
@property (weak, nonatomic) IBOutlet UICollectionView *imageDetailCollectionView;
@property (strong, nonatomic) NSMutableArray<UIImage *> *thumbnailImages;
@property (strong, nonatomic) NSString *selectedAlbumName;
@property (strong, nonatomic) UICollectionView *HTImagePickerCollectionView;

- (IBAction)backToPickerBtnTouched:(id)sender;
@end

@interface HTImagePickerCollectionViewCell : UICollectionViewCell
@property (weak, nonatomic) IBOutlet UIImageView *thumbnail;
@end

@interface HTImageDetailCollectionViewCell : UICollectionViewCell
@property (weak, nonatomic) IBOutlet UIScrollView *detailViewScrollView;
@property (weak, nonatomic) IBOutlet UIImageView *detailViewImageView;

@end
