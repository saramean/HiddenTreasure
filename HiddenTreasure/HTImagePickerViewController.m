//
//  HTImagePickerViewController.m
//  HiddenTreasure
//
//  Created by Park on 2016. 11. 7..
//  Copyright © 2016년 Whybox1. All rights reserved.
//

#import "HTImagePickerViewController.h"

@interface HTImagePickerViewController ()

@end

@implementation HTImagePickerViewController

//Album will be stored in DocumentDir/HTHiddenImages/HA####_AlbumName/
//In album directories, there are three directories each for thumbnail, resizeImage(For preview), originalImage
//File hierachy will be like below
//DocumentDir/HTHiddenImages/HA####_AlbumName/thumnail/AlbumName_HI####.jpg
//DocumentDir/HTHiddenImages/HA####_AlbumName/resize/AlbumName_HI####.jpg
//DocumentDir/HTHiddenImages/HA####_AlbumName/original/AlbumName_HI####.jpg
//#### in directory and #### in file name are diffrent number each other.
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    //Path for directory
    NSString *DocumentDir;
    NSArray *DocumentDirsArray;
    
    DocumentDirsArray = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    DocumentDir = DocumentDirsArray[0];
    DocumentDir = [NSString stringWithFormat:@"%@%@%@/", DocumentDir, @"/HTHiddenImages/", self.selectedAlbumName];
    NSString *thumbnailDir = [NSString stringWithFormat:@"%@%@", DocumentDir, @"thumbnail/"];
    
    if(!self.thumbnailImages){
        self.thumbnailImages = [[NSMutableArray alloc] init];
    }
    if(!self.selectedImages){
        self.selectedImages = [[NSMutableArray alloc] init];
        self.selectedImagesIndex = [[NSMutableIndexSet alloc] init];
    }
    
    for(int i = 0; i < [self.HTHiddenImagesFileNameArray count] ; i++){
        UIImage *temp = [UIImage imageWithContentsOfFile:[NSString stringWithFormat:@"%@%@", thumbnailDir, self.HTHiddenImagesFileNameArray[i]]];
        [self.thumbnailImages addObject:temp];
    }
    //Configure Buttons
    self.HTImagePickerCancelBtn.hidden = YES;
    self.HTImagePickerExportBtn.hidden = YES;
    self.HTImagePickerExportBtn.enabled = NO;
    self.HTImagePickerDeleteBtn.hidden = YES;
    self.HTImagePickerDeleteBtn.enabled = NO;
    if([self.HTHiddenImagesFileNameArray count] == 0){
        self.HTImagePickerSelectBtn.enabled = NO;
    }
    
    //Configure DetailView
    self.HTImageDetailView.frame = self.view.frame;
    self.HTImageDetailView.thumbnailImages = self.thumbnailImages;
    self.HTImageDetailView.selectedAlbumName = self.selectedAlbumName;
    self.HTImageDetailView.HTImagePickerCollectionView = self.HTImagePickerCollectionView;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    NSLog(@"warning");
}

#pragma mark - Collection view delegate
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return [self.thumbnailImages count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    HTImagePickerCollectionViewCell *thumbnailCells = [collectionView dequeueReusableCellWithReuseIdentifier:@"HTImagePickerCollectionViewCell" forIndexPath:indexPath];
    
    if(thumbnailCells.selected){
        [self selectedCellLayoutChange:thumbnailCells];
    }
    else{
        [self deselectedCellLayoutChange:thumbnailCells];
    }
    thumbnailCells.thumbnail.image = self.thumbnailImages[indexPath.row];
    
    return thumbnailCells;
}

- (CGSize) collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    float size = floor(([UIScreen mainScreen].bounds.size.width - 2)/3);
    return CGSizeMake(size, size);
}

#pragma mark CollectionView Cell Select & Deselect
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    //Select Btn is Not Touched
    if(!collectionView.allowsMultipleSelection){
        //Directory paths
        NSString *DocumentDir;
        NSArray *DocumentDirsArray;
        
        DocumentDirsArray = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        DocumentDir = DocumentDirsArray[0];
        DocumentDir = [NSString stringWithFormat:@"%@%@%@/", DocumentDir, @"/HTHiddenImages/", self.selectedAlbumName];
        NSString *trimmedAlbumName = [self.selectedAlbumName substringFromIndex:7];
        
        //Path for directories
        NSString *fileName = [NSString stringWithFormat:@"%@_HI%04d.jpg", trimmedAlbumName, (int) indexPath.row + 1];
        NSString *resizeDir = [NSString stringWithFormat:@"%@%@%@", DocumentDir, @"resize/", fileName];
        
        //scroll to show selected image
        [self.HTImageDetailView.imageDetailCollectionView scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:NO];
        //show sub view
        //selected cell in image picker
        HTImagePickerCollectionViewCell *selectedCell = (__kindof UICollectionViewCell *)[self.HTImagePickerCollectionView cellForItemAtIndexPath:indexPath];
        //get frame from selected cell and convert it according to collection's superview to get correct cgrect value according to main screen
        CGRect convertedRect = [self.HTImagePickerCollectionView convertRect:selectedCell.frame toView:[self.HTImagePickerCollectionView superview]];
        //make a image view for transition effect
        UIImageView *imageViewForTransition = [[UIImageView alloc] initWithFrame:convertedRect];
        imageViewForTransition.contentMode = UIViewContentModeScaleAspectFill;
        imageViewForTransition.clipsToBounds = YES;
        imageViewForTransition.image = [UIImage imageWithContentsOfFile:resizeDir];
        //make a another image view for hiding cell image
        UIView *hidingImageView = [[UIView alloc] initWithFrame:self.HTImageDetailView.imageDetailCollectionView.bounds];
        hidingImageView.backgroundColor = self.HTImageDetailView.imageDetailCollectionView.backgroundColor;
        //add subviews
        [self.view addSubview:self.HTImageDetailView];
        [self.HTImageDetailView.imageDetailCollectionView addSubview:hidingImageView];
        [self.view addSubview:imageViewForTransition];
        //animation effect configuration
        [self.HTImageDetailView setAlpha:0.0];
        [UIView animateWithDuration:0.2 animations:^{
            [self.HTImageDetailView setAlpha:1];
            [imageViewForTransition setFrame:CGRectInset(self.HTImagePickerCollectionView.frame, -0.015*CGRectGetWidth(self.HTImagePickerCollectionView.frame), -0.015*CGRectGetHeight(self.HTImagePickerCollectionView.frame)) ];
            imageViewForTransition.contentMode = UIViewContentModeScaleAspectFit;
        } completion:^(BOOL finished) {
            [imageViewForTransition removeFromSuperview];
            [hidingImageView removeFromSuperview];
        }];
    }
    //Select Button Touched
    else{
        HTImagePickerCollectionViewCell *selectedCell = (__kindof UICollectionViewCell *) [collectionView cellForItemAtIndexPath:indexPath];
        [self selectedCellLayoutChange:selectedCell];
        [self.selectedImages addObject:indexPath];
        [self.selectedImagesIndex addIndex:indexPath.row];
        NSLog(@"selected indexPath %@ index %@", self.selectedImages, self.selectedImagesIndex);
        if([self.selectedImages count] > 0){
            self.HTImagePickerExportBtn.enabled = YES;
            self.HTImagePickerDeleteBtn.enabled = YES;
        }
    }
}

- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath{
    if(collectionView.allowsMultipleSelection){
        HTImagePickerCollectionViewCell *deselectedCell = (__kindof UICollectionViewCell *) [collectionView cellForItemAtIndexPath:indexPath];
        [self deselectedCellLayoutChange:deselectedCell];
        for(int i = 0 ; i < [self.selectedImages count] ; i++){
            if(self.selectedImages[i] == indexPath){
                [self.selectedImages removeObjectAtIndex:i];
                [self.selectedImagesIndex removeIndex:indexPath.row];
            }
        }
        if([self.selectedImages count] == 0){
            self.HTImagePickerExportBtn.enabled = NO;
            self.HTImagePickerDeleteBtn.enabled = NO;
        }
        NSLog(@"after deselected %@ index %@", self.selectedImages, self.selectedImagesIndex);
    }
}


#pragma mark - Cell layout change
- (void) selectedCellLayoutChange: (__kindof UICollectionViewCell *) selectedCell{
    selectedCell.alpha = 0.5;
    selectedCell.layer.borderWidth = 2.0;
    selectedCell.layer.borderColor = [UIColor colorWithWhite:0.1 alpha:1.0].CGColor;
}

- (void) deselectedCellLayoutChange: (__kindof UICollectionViewCell *) deselectedCell{
    deselectedCell.alpha = 1;
    deselectedCell.layer.borderWidth = 0.0;
    deselectedCell.layer.borderColor = [UIColor clearColor].CGColor;
}

#pragma mark - ImagePicker delegate
//Format of Image file is AlbumName_HI####.jpg
- (void)getSelectedImageAssetsFromImagePicker:(NSMutableArray *)selectedAssetsArray{
    //Directory paths
    NSString *DocumentDir;
    NSArray *DocumentDirsArray;

    DocumentDirsArray = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    DocumentDir = DocumentDirsArray[0];
    DocumentDir = [NSString stringWithFormat:@"%@%@%@/", DocumentDir, @"/HTHiddenImages/", self.selectedAlbumName];
    PHImageRequestOptions *synchronousOptions = [[PHImageRequestOptions alloc] init];
    synchronousOptions.synchronous = YES;
    
    for(PHAsset* selectedAsset in selectedAssetsArray){
        [[PHImageManager defaultManager] requestImageDataForAsset:selectedAsset options:synchronousOptions resultHandler:^(NSData * _Nullable imageData, NSString * _Nullable dataUTI, UIImageOrientation orientation, NSDictionary * _Nullable info) {
            //Get path for image saving
            //Path for directories
            NSString *trimmedAlbumName = [self.selectedAlbumName substringFromIndex:7];
            NSString *fileName = [NSString stringWithFormat:@"%@_HI%04d.jpg", trimmedAlbumName, (int) [self.thumbnailImages count] + 1];
            NSString *thumbnailDir = [NSString stringWithFormat:@"%@%@%@", DocumentDir, @"thumbnail/", fileName];
            NSString *resizeDir = [NSString stringWithFormat:@"%@%@%@", DocumentDir, @"resize/", fileName];
            NSString *originalDir = [NSString stringWithFormat:@"%@%@%@", DocumentDir, @"original/", fileName];
            //NSLog(@"%@", originalDir);
            //save original image
            NSData *originalImageData = imageData;
            [originalImageData writeToFile:originalDir atomically:YES];
            //Save Thumbnail
            [[PHImageManager defaultManager] requestImageForAsset:selectedAsset targetSize:CGSizeMake(150, 150) contentMode:PHImageContentModeAspectFit options:synchronousOptions resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
                UIImage *thumbnail = result;
                @autoreleasepool {
                    NSData *thumbnailImageData = [NSData dataWithData:UIImageJPEGRepresentation(thumbnail, 1.0)];
                    [thumbnailImageData writeToFile:thumbnailDir atomically:YES];
                }
                //Save resize image
                [[PHImageManager defaultManager] requestImageForAsset:selectedAsset targetSize:CGSizeMake([UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.width) contentMode:PHImageContentModeAspectFit options:synchronousOptions resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
                    UIImage *resize = result;
                    @autoreleasepool {
                        NSData *resizeImageData = [NSData dataWithData:UIImageJPEGRepresentation(resize, 1.0)];
                        [resizeImageData writeToFile:resizeDir atomically:YES];
                    }
                }];
                [self.thumbnailImages addObject:thumbnail];
                [self.HTHiddenImagesFileNameArray addObject:fileName];
            }];
        }];
    }
    [self.HTImagePickerCollectionView reloadData];
    [self.HTImageDetailView.imageDetailCollectionView reloadData];
    if([self.HTHiddenImagesFileNameArray count] > 0){
        self.HTImagePickerSelectBtn.enabled = YES;
    }
}

- (void)imagePickerCanceledWithOutSelection{
    NSLog(@"canceled without selection");
}

#pragma mark - Button Actions
- (IBAction)backToAlbumBtnTouched:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)addHiddenImagesBtnTouched:(id)sender {
    FTImagePickerOptions *imagePickerOptions = [[FTImagePickerOptions alloc] init];
    imagePickerOptions.multipleSelectOn = YES;
    imagePickerOptions.multipleSelectMin = 1;
    imagePickerOptions.multipleSelectMax = 50;
    imagePickerOptions.theme = WhiteVersion;
    imagePickerOptions.mediaTypeToUse = ImagesOnly;
    imagePickerOptions.regularAlbums = @[@2, @3, @4, @5, @6];
    imagePickerOptions.smartAlbums = @[@200, @201, @202, @203, @204, @205, @206, @207, @208, @210, @211];
    
    [FTImagePickerManager presentFTImagePicker:self withOptions:imagePickerOptions];
}

- (IBAction)selectImagesBtnTouched:(id)sender {
    self.HTImagePickerCollectionView.allowsMultipleSelection = YES;
    self.HTImagePickerAddBtn.hidden = YES;
    self.HTImagePickerBackBtn.hidden = YES;
    self.HTImagePickerCancelBtn.hidden = NO;
    self.HTImagePickerSelectBtn.hidden = YES;
    self.HTImagePickerExportBtn.hidden = NO;
    self.HTImagePickerDeleteBtn.hidden = NO;
}

- (IBAction)selectCancelBtnTouched:(id)sender {
    for(int i = 0 ; i < [self.selectedImages count] ;){
        [self.HTImagePickerCollectionView deselectItemAtIndexPath:self.selectedImages[i] animated:YES];
        [self collectionView:self.HTImagePickerCollectionView didDeselectItemAtIndexPath:self.selectedImages[i]];
    }
    self.HTImagePickerCollectionView.allowsMultipleSelection = NO;
    self.HTImagePickerAddBtn.hidden = NO;
    self.HTImagePickerBackBtn.hidden = NO;
    self.HTImagePickerCancelBtn.hidden = YES;
    self.HTImagePickerSelectBtn.hidden = NO;
    self.HTImagePickerExportBtn.hidden = YES;
    self.HTImagePickerExportBtn.enabled = NO;
    self.HTImagePickerDeleteBtn.hidden = YES;
    self.HTImagePickerDeleteBtn.enabled = NO;
}

- (IBAction)exportImagesBtnTouched:(id)sender {
    //Array for export images
    NSMutableArray *arrayForExport = [[NSMutableArray alloc] init];
    //Directory paths
    NSString *DocumentDir;
    NSArray *DocumentDirsArray;
    DocumentDirsArray = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    DocumentDir = DocumentDirsArray[0];
    DocumentDir = [NSString stringWithFormat:@"%@%@%@/", DocumentDir, @"/HTHiddenImages/", self.selectedAlbumName];
    NSString *trimmedAlbumName = [self.selectedAlbumName substringFromIndex:7];
    for(int i = 0; i < [self.selectedImages count]; i++){
        //Path for directories
        NSString *fileName = [NSString stringWithFormat:@"%@_HI%04d.jpg", trimmedAlbumName, (int) self.selectedImages[i].row + 1];
        NSString *originalDir = [NSString stringWithFormat:@"%@%@%@", DocumentDir, @"original/", fileName];
        UIImage *exportImage = [UIImage imageWithContentsOfFile:originalDir];
        [arrayForExport addObject:exportImage];
    }
    //UIActivityViewController
    UIActivityViewController *activityForSharing = [[UIActivityViewController alloc] initWithActivityItems:arrayForExport applicationActivities:nil];
    [self presentViewController:activityForSharing animated:YES completion:nil];
    [self.HTImagePickerCollectionView reloadItemsAtIndexPaths:self.selectedImages];
    [self.selectedImages removeAllObjects];
    [self.selectedImagesIndex removeAllIndexes];
    self.HTImagePickerCollectionView.allowsMultipleSelection = NO;
    self.HTImagePickerAddBtn.hidden = NO;
    self.HTImagePickerBackBtn.hidden = NO;
    self.HTImagePickerCancelBtn.hidden = YES;
    self.HTImagePickerSelectBtn.hidden = NO;
    self.HTImagePickerExportBtn.hidden = YES;
    self.HTImagePickerExportBtn.enabled = NO;
    self.HTImagePickerDeleteBtn.hidden = YES;
    self.HTImagePickerDeleteBtn.enabled = NO;
}

- (IBAction)deleteImagesBtnTouched:(id)sender {
    //File manager
    NSFileManager *fileManager = [NSFileManager defaultManager];
    //Directory paths
    NSString *DocumentDir;
    NSArray *DocumentDirsArray;
    DocumentDirsArray = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    DocumentDir = DocumentDirsArray[0];
    DocumentDir = [NSString stringWithFormat:@"%@%@%@/", DocumentDir, @"/HTHiddenImages/", self.selectedAlbumName];
    NSString *trimmedAlbumName = [self.selectedAlbumName substringFromIndex:7];
    for(int i = 0; i < [self.selectedImages count]; i++){
        //Path for directories
        NSString *fileName = [NSString stringWithFormat:@"%@_HI%04d.jpg", trimmedAlbumName, (int) self.selectedImages[i].row + 1];
        NSString *thumbnailDir = [NSString stringWithFormat:@"%@%@%@", DocumentDir, @"thumbnail/", fileName];
        NSString *resizeDir = [NSString stringWithFormat:@"%@%@%@", DocumentDir, @"resize/", fileName];
        NSString *originalDir = [NSString stringWithFormat:@"%@%@%@", DocumentDir, @"original/", fileName];
        //Delete files in sandbox
        [fileManager removeItemAtPath:thumbnailDir error:nil];
        [fileManager removeItemAtPath:resizeDir error:nil];
        [fileManager removeItemAtPath:originalDir error:nil];
    }
    //Update datasource
    [self.thumbnailImages removeObjectsAtIndexes:self.selectedImagesIndex];
    [self.HTHiddenImagesFileNameArray removeObjectsAtIndexes:self.selectedImagesIndex];
    
    NSLog(@"FileName %@", self.HTHiddenImagesFileNameArray);
    //Update collectionview
    [self.HTImagePickerCollectionView performBatchUpdates:^{
        [self.HTImagePickerCollectionView deleteItemsAtIndexPaths:self.selectedImages];
    } completion:^(BOOL finished) {
        self.HTImagePickerCollectionView.allowsMultipleSelection = NO;
        self.HTImagePickerAddBtn.hidden = NO;
        self.HTImagePickerBackBtn.hidden = NO;
        self.HTImagePickerCancelBtn.hidden = YES;
        self.HTImagePickerSelectBtn.hidden = NO;
        self.HTImagePickerExportBtn.hidden = YES;
        self.HTImagePickerExportBtn.enabled = NO;
        self.HTImagePickerDeleteBtn.hidden = YES;
        self.HTImagePickerDeleteBtn.enabled = NO;
        //Move images
        //1. find image which index is not equal to its file name
        //2. move it to its correct index
        for(int i = 0 ; i < [self.HTHiddenImagesFileNameArray count]; i++){
            if(![self.HTHiddenImagesFileNameArray[i] isEqualToString:[NSString stringWithFormat:@"%@_HI%04d.jpg", trimmedAlbumName, i + 1]]){
                NSString *nearBlank = [self.HTHiddenImagesFileNameArray[i] substringWithRange:NSMakeRange(trimmedAlbumName.length + 3, 4)];
                int nearBlankInt = [nearBlank intValue];
                NSString *originalFileForThumbnail = [NSString stringWithFormat:@"%@%@%@_HI%04d.jpg", DocumentDir, @"thumbnail/", trimmedAlbumName, nearBlankInt];
                NSString *destinationFileForThumbnail= [NSString stringWithFormat:@"%@%@%@_HI%04d.jpg", DocumentDir, @"thumbnail/", trimmedAlbumName, i+1];
                NSString *originalFileForResize = [NSString stringWithFormat:@"%@%@%@_HI%04d.jpg", DocumentDir, @"resize/", trimmedAlbumName, nearBlankInt];
                NSString *destinationFileForResize= [NSString stringWithFormat:@"%@%@%@_HI%04d.jpg", DocumentDir, @"resize/", trimmedAlbumName, i+1];
                NSString *originalFileForOriginal = [NSString stringWithFormat:@"%@%@%@_HI%04d.jpg", DocumentDir, @"original/", trimmedAlbumName, nearBlankInt];
                NSString *destinationFileForOriginal = [NSString stringWithFormat:@"%@%@%@_HI%04d.jpg", DocumentDir, @"original/", trimmedAlbumName, i+1];
                [fileManager moveItemAtPath:originalFileForThumbnail toPath:destinationFileForThumbnail error:nil];
                [fileManager moveItemAtPath:originalFileForResize toPath:destinationFileForResize error:nil];
                [fileManager moveItemAtPath:originalFileForOriginal toPath:destinationFileForOriginal error:nil];
                
                self.HTHiddenImagesFileNameArray[i] = [NSString stringWithFormat:@"%@_HI%04d.jpg", trimmedAlbumName, i+1];
                NSLog(@"Filenames after file moved %@", self.HTHiddenImagesFileNameArray);
            }
        }
        [self.selectedImages removeAllObjects];
        [self.selectedImagesIndex removeAllIndexes];
    }];
    if([self.HTHiddenImagesFileNameArray count] == 0){
        self.HTImagePickerSelectBtn.enabled = NO;
    }
}

#pragma mark - Image Resize and Fix Orientation(Not used for this Project)
//- (UIImage *) scaleToSize: (CGSize) size withImage:(UIImage *) imageWillBeResized{
//    UIGraphicsBeginImageContext(size);
//    CGContextRef context = UIGraphicsGetCurrentContext();
//    CGContextTranslateCTM(context, 0.0, size.height);
//    CGContextScaleCTM(context, 1.0, -1.0);
//    CGContextDrawImage(context, CGRectMake(0, 0, size.width, size.height), imageWillBeResized.CGImage);
//    UIImage *resizedImage = UIGraphicsGetImageFromCurrentImageContext();
//    UIGraphicsEndImageContext();
//    return resizedImage;
//}
//
//- (UIImage *)fixImageOrientation:(UIImage *) imageToFix {
//
//    // No-op if the orientation is already correct
//    if (imageToFix == UIImageOrientationUp) return imageToFix;
//
//    // We need to calculate the proper transformation to make the image upright.
//    // We do it in 2 steps: Rotate if Left/Right/Down, and then flip if Mirrored.
//    CGAffineTransform transform = CGAffineTransformIdentity;
//
//    switch (imageToFix.imageOrientation) {
//        case UIImageOrientationDown:
//        case UIImageOrientationDownMirrored:
//            transform = CGAffineTransformTranslate(transform, imageToFix.size.width, imageToFix.size.height);
//            transform = CGAffineTransformRotate(transform, M_PI);
//            break;
//
//        case UIImageOrientationLeft:
//        case UIImageOrientationLeftMirrored:
//            transform = CGAffineTransformTranslate(transform, imageToFix.size.width, 0);
//            transform = CGAffineTransformRotate(transform, M_PI_2);
//            break;
//
//        case UIImageOrientationRight:
//        case UIImageOrientationRightMirrored:
//            transform = CGAffineTransformTranslate(transform, 0, imageToFix.size.height);
//            transform = CGAffineTransformRotate(transform, -M_PI_2);
//            break;
//        case UIImageOrientationUp:
//        case UIImageOrientationUpMirrored:
//            break;
//    }
//
//    switch (imageToFix.imageOrientation) {
//        case UIImageOrientationUpMirrored:
//        case UIImageOrientationDownMirrored:
//            transform = CGAffineTransformTranslate(transform, imageToFix.size.width, 0);
//            transform = CGAffineTransformScale(transform, -1, 1);
//            break;
//
//        case UIImageOrientationLeftMirrored:
//        case UIImageOrientationRightMirrored:
//            transform = CGAffineTransformTranslate(transform, imageToFix.size.height, 0);
//            transform = CGAffineTransformScale(transform, -1, 1);
//            break;
//        case UIImageOrientationUp:
//        case UIImageOrientationDown:
//        case UIImageOrientationLeft:
//        case UIImageOrientationRight:
//            break;
//    }
//
//    // Now we draw the underlying CGImage into a new context, applying the transform
//    // calculated above.
//    CGContextRef ctx = CGBitmapContextCreate(NULL, imageToFix.size.width, imageToFix.size.height,
//                                             CGImageGetBitsPerComponent(imageToFix.CGImage), 0,
//                                             CGImageGetColorSpace(imageToFix.CGImage),
//                                             CGImageGetBitmapInfo(imageToFix.CGImage));
//    CGContextConcatCTM(ctx, transform);
//    switch (imageToFix.imageOrientation) {
//        case UIImageOrientationLeft:
//        case UIImageOrientationLeftMirrored:
//        case UIImageOrientationRight:
//        case UIImageOrientationRightMirrored:
//            // Grr...
//            CGContextDrawImage(ctx, CGRectMake(0,0,imageToFix.size.height,imageToFix.size.width), imageToFix.CGImage);
//            break;
//
//        default:
//            CGContextDrawImage(ctx, CGRectMake(0,0,imageToFix.size.width, imageToFix.size.height), imageToFix.CGImage);
//            break;
//    }
//
//    // And now we just create a new UIImage from the drawing context
//    CGImageRef cgimg = CGBitmapContextCreateImage(ctx);
//    UIImage *img = [UIImage imageWithCGImage:cgimg];
//    CGContextRelease(ctx);
//    CGImageRelease(cgimg);
//    return img;
//}


@end

#pragma mark -
@interface HTImageDetailView()

@end
@implementation HTImageDetailView

#pragma mark - Collection View Delegate
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return [self.thumbnailImages count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    NSLog(@"cell");
    HTImageDetailCollectionViewCell *detailViewCell = [collectionView dequeueReusableCellWithReuseIdentifier:@"detailViewCell" forIndexPath:indexPath];
    
    //Directory paths
    NSString *DocumentDir;
    NSArray *DocumentDirsArray;
    
    DocumentDirsArray = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    DocumentDir = DocumentDirsArray[0];
    DocumentDir = [NSString stringWithFormat:@"%@%@%@/", DocumentDir, @"/HTHiddenImages/", self.selectedAlbumName];
    
    //Path for directories
    NSString *trimmedAlbumName = [self.selectedAlbumName substringFromIndex:7];
    NSString *fileName = [NSString stringWithFormat:@"%@_HI%04d.jpg", trimmedAlbumName, (int) (indexPath.row + 1)];
    NSString *resizeDir = [NSString stringWithFormat:@"%@%@%@", DocumentDir, @"resize/", fileName];
    detailViewCell.detailViewImageView.image = [UIImage imageWithContentsOfFile:resizeDir];
    //ScrollView setting
    detailViewCell.detailViewScrollView.maximumZoomScale = 5.0;
    detailViewCell.detailViewScrollView.minimumZoomScale = 1.0;
    detailViewCell.detailViewScrollView.zoomScale = 1.0;
    //frame setting
    detailViewCell.detailViewScrollView.frame = CGRectMake(0, 0, self.imageDetailCollectionView.frame.size.width, self.imageDetailCollectionView.frame.size.height);
    detailViewCell.detailViewScrollView.contentSize = CGSizeMake(self.imageDetailCollectionView.frame.size.width, self.imageDetailCollectionView.frame.size.height);
    detailViewCell.detailViewImageView.frame = CGRectMake(0, 0, self.imageDetailCollectionView.frame.size.width, self.imageDetailCollectionView.frame.size.height);
    
    //NSLog(@"cell size %f %f", detailViewCell.frame.size.width, detailViewCell.frame.size.height);
    NSLog(@"scrollview size %f %f", detailViewCell.detailViewScrollView.frame.size.width, detailViewCell.detailViewScrollView.frame.size.height);
    NSLog(@"scrollview zoom scale %f, %d", detailViewCell.detailViewScrollView.zoomScale, detailViewCell.detailViewScrollView.zooming);
    
    return detailViewCell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    return self.imageDetailCollectionView.frame.size;
}

#pragma mark - Scroll View Delegate
- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView{
    for(UIView *view in [scrollView subviews]){
        if([view isKindOfClass:[UIImageView class]]){
            return view;
        }
    }
    return nil;
}

#pragma mark - Button Actions
- (IBAction)backToPickerBtnTouched:(id)sender {
    //make a imageView For transition and configure
    UIImageView *imageViewForTransition = [[UIImageView alloc] initWithFrame:self.HTImagePickerCollectionView.bounds];
    imageViewForTransition.contentMode = UIViewContentModeScaleAspectFit;
    //selected cell for get image from it
    HTImageDetailCollectionViewCell *selectedCell = (__kindof UICollectionViewCell *) [self.imageDetailCollectionView cellForItemAtIndexPath:[[self.imageDetailCollectionView indexPathsForVisibleItems] firstObject]];
    //assign image to imageview
    imageViewForTransition.image = selectedCell.detailViewImageView.image;
    //add imageView as subview of Image Picker collection view
    [self.HTImagePickerCollectionView addSubview:imageViewForTransition];
    //Image picker cell for destination point of transition
    HTImagePickerCollectionViewCell *selectedCellInImagePicker = (__kindof UICollectionViewCell *) [self.HTImagePickerCollectionView cellForItemAtIndexPath:[[self.imageDetailCollectionView indexPathsForVisibleItems] firstObject]];
    //hide image in image picker for effect
    [selectedCellInImagePicker.contentView setAlpha:0.0];
    //Animation effect
    [UIView animateWithDuration:0.2 animations:^{
        [imageViewForTransition setFrame:selectedCellInImagePicker.frame];
        NSLog(@"%f %f", selectedCellInImagePicker.frame.origin.x, selectedCellInImagePicker.frame.origin.y);
        [self setAlpha:0.0];
    } completion:^(BOOL finished) {
        imageViewForTransition.contentMode = UIViewContentModeScaleAspectFill;
        [imageViewForTransition removeFromSuperview];
        [self removeFromSuperview];
        //show cell in image picker after transition
        [selectedCellInImagePicker.contentView setAlpha:1.0];
    }];
}
@end

#pragma mark -
@interface HTImagePickerCollectionViewCell()
@end
@implementation HTImagePickerCollectionViewCell
@end

#pragma mark -
@interface HTImageDetailCollectionViewCell()
@end
@implementation HTImageDetailCollectionViewCell
@end
