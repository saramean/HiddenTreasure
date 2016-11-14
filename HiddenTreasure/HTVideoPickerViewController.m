//
//  HTVideoPickerViewController.m
//  HiddenTreasure
//
//  Created by Park on 2016. 11. 10..
//  Copyright © 2016년 Whybox1. All rights reserved.
//

#import "HTVideoPickerViewController.h"

@interface HTVideoPickerViewController ()

@end

@implementation HTVideoPickerViewController

//Album will be stored in DocumentDir/HTHiddenVideos/HA####_AlbumName/
//In album directories, there are three directories each for thumbnail, resizeImage(For preview), originalVideo
//File hierachy will be like below
//DocumentDir/HTHiddenImages/HA####_AlbumName/thumnail/AlbumName_HV####.jpg
//DocumentDir/HTHiddenImages/HA####_AlbumName/resize/AlbumName_HV####.jpg
//DocumentDir/HTHiddenImages/HA####_AlbumName/original/AlbumName_HV####.mp4
//#### in directory and #### in file name are diffrent number each other.
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    //Path for directory
    NSString *DocumentDir;
    NSArray *DocumentDirsArray;
    
    DocumentDirsArray = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    DocumentDir = DocumentDirsArray[0];
    DocumentDir = [NSString stringWithFormat:@"%@%@%@/", DocumentDir, @"/HTHiddenVideos/", self.selectedAlbumName];
    NSString *thumbnailDir = [NSString stringWithFormat:@"%@%@", DocumentDir, @"thumbnail/"];
    NSString *videoLenghtDataPath = [NSString stringWithFormat:@"%@%@", DocumentDir, @"videoLength.json"];
    
    if(!self.thumbnailImages){
        self.thumbnailImages = [[NSMutableArray alloc] init];
    }
    if(!self.selectedVideos){
        self.selectedVideos = [[NSMutableArray alloc] init];
        self.selectedVideosIndex = [[NSMutableIndexSet alloc] init];
        self.videoLength = [[NSMutableArray alloc] init];
    }
    
    NSData *videoLengthData = [NSData dataWithContentsOfFile:videoLenghtDataPath];
    if(videoLengthData){
        self.videoLength = [NSMutableArray arrayWithArray:[NSJSONSerialization JSONObjectWithData:videoLengthData options:kNilOptions error:nil]];
    }
    for(int i = 0; i < [self.HTHiddenVideosFileNameArray count] ; i++){
        UIImage *temp = [UIImage imageWithContentsOfFile:[NSString stringWithFormat:@"%@%@", thumbnailDir, self.HTHiddenVideosFileNameArray[i]]];
        [self.thumbnailImages addObject:temp];
    }
    //Configure Buttons
    self.HTVideoPickerCancelBtn.hidden = YES;
    self.HTVideoPickerExportBtn.hidden = YES;
    self.HTVideoPickerExportBtn.enabled = NO;
    self.HTVideoPickerDeleteBtn.hidden = YES;
    self.HTVideoPickerDeleteBtn.enabled = NO;
    if([self.HTHiddenVideosFileNameArray count] == 0){
        self.HTVideoPickerSelectBtn.enabled = NO;
    }
    
    //Configure DetailView
    self.HTVideoDetailView.frame = self.view.frame;
    self.HTVideoDetailView.thumbnailImages = self.thumbnailImages;
    self.HTVideoDetailView.selectedAlbumName = self.selectedAlbumName;
    self.HTVideoDetailView.HTVideoPickerCollectionView = self.HTVideoPickerCollectionView;
    self.HTVideoDetailView.delegate = self;
    
    //Notification
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(saveVideoLength) name:UIApplicationWillTerminateNotification object:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    NSLog(@"warning");
}
#pragma mark - Save videoLength file
- (void) saveVideoLength{
    // Do any additional setup after loading the view.
    //Path for directory
    NSString *DocumentDir;
    NSArray *DocumentDirsArray;
    
    DocumentDirsArray = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    DocumentDir = DocumentDirsArray[0];
    DocumentDir = [NSString stringWithFormat:@"%@%@%@/", DocumentDir, @"/HTHiddenVideos/", self.selectedAlbumName];
    NSString *videoLenghtDataPath = [NSString stringWithFormat:@"%@%@", DocumentDir, @"videoLength.json"];
    NSData *videoLengthData = [NSJSONSerialization dataWithJSONObject:self.videoLength options:kNilOptions error:nil];
    [videoLengthData writeToFile:videoLenghtDataPath atomically:YES];
}

#pragma mark - Collection view delegate

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return [self.thumbnailImages count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    HTVideoPickerCollectionViewCell *thumbnailCells = [collectionView dequeueReusableCellWithReuseIdentifier:@"HTVideoPickerCollectionViewCell" forIndexPath:indexPath];
    float videoLengthInSeconds = [self.videoLength[indexPath.row] floatValue];
    int lengthHour = 0;
    int lengthMin = 0;
    NSString *videoLength;
    int lengthSecond = (int) videoLengthInSeconds % 60;
    if(videoLengthInSeconds/60 >= 60){
        lengthMin = ((int)videoLengthInSeconds / 60) % 60;
        lengthHour = ((int)videoLengthInSeconds / 60) / 60;
        videoLength = [NSString stringWithFormat:@"%02d:%02d:%02d", lengthHour, lengthMin, lengthSecond];
    }
    else{
        lengthMin = (int)videoLengthInSeconds / 60;
        videoLength = [NSString stringWithFormat:@"%02d:%02d", lengthMin, lengthSecond];
    }
    thumbnailCells.videoLength.text = videoLength;
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


#pragma mark CollectionView Select & Deselect
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    //Select Btn is Not Touched
    if(!collectionView.allowsMultipleSelection){
        //Directory paths
        NSString *DocumentDir;
        NSArray *DocumentDirsArray;
        
        DocumentDirsArray = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        DocumentDir = DocumentDirsArray[0];
        DocumentDir = [NSString stringWithFormat:@"%@%@%@/", DocumentDir, @"/HTHiddenVideos/", self.selectedAlbumName];
        NSString *trimmedAlbumName = [self.selectedAlbumName substringFromIndex:7];
        
        //Path for directories
        NSString *fileName = [NSString stringWithFormat:@"%@_HV%04d.jpg", trimmedAlbumName, (int) indexPath.row + 1];
        NSString *resizeDir = [NSString stringWithFormat:@"%@%@%@", DocumentDir, @"resize/", fileName];
        
        //scroll to show selected image
        [self.HTVideoDetailView.videoDetailCollectionView scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:NO];
        //show sub view
        //selected cell in image picker
        HTVideoPickerCollectionViewCell *selectedCell = (__kindof UICollectionViewCell *)[self.HTVideoPickerCollectionView cellForItemAtIndexPath:indexPath];
        //get frame from selected cell and convert it according to collection's superview to get correct cgrect value according to main screen
        CGRect convertedRect = [self.HTVideoPickerCollectionView convertRect:selectedCell.frame toView:[self.HTVideoPickerCollectionView superview]];
        //make a image view for transition effect
        UIImageView *imageViewForTransition = [[UIImageView alloc] initWithFrame:convertedRect];
        imageViewForTransition.contentMode = UIViewContentModeScaleAspectFill;
        imageViewForTransition.clipsToBounds = YES;
        imageViewForTransition.image = [UIImage imageWithContentsOfFile:resizeDir];
        //make a another image view for hiding cell image
        UIView *hidingImageView = [[UIView alloc] initWithFrame:self.HTVideoDetailView.videoDetailCollectionView.bounds];
        hidingImageView.backgroundColor = self.HTVideoDetailView.videoDetailCollectionView.backgroundColor;
        //add subviews
        [self.view addSubview:self.HTVideoDetailView];
        [self.HTVideoDetailView.videoDetailCollectionView addSubview:hidingImageView];
        [self.view addSubview:imageViewForTransition];
        //animation effect configuration
        [self.HTVideoDetailView setAlpha:0.0];
        [UIView animateWithDuration:0.2 animations:^{
            [self.HTVideoDetailView setAlpha:1];
            [imageViewForTransition setFrame:CGRectInset(self.HTVideoPickerCollectionView.frame, -0.015*CGRectGetWidth(self.HTVideoPickerCollectionView.frame), -0.015*CGRectGetHeight(self.HTVideoPickerCollectionView.frame)) ];
            imageViewForTransition.contentMode = UIViewContentModeScaleAspectFit;
        } completion:^(BOOL finished) {
            [imageViewForTransition removeFromSuperview];
            [hidingImageView removeFromSuperview];
        }];
    }
    //Select Button Touched
    else{
        HTVideoPickerCollectionViewCell *selectedCell = (__kindof UICollectionViewCell *) [collectionView cellForItemAtIndexPath:indexPath];
        [self selectedCellLayoutChange:selectedCell];
        [self.selectedVideos addObject:indexPath];
        [self.selectedVideosIndex addIndex:indexPath.row];
        NSLog(@"selected indexPath %@ index %@", self.selectedVideos, self.selectedVideosIndex);
        if([self.selectedVideos count] > 0){
            self.HTVideoPickerExportBtn.enabled = YES;
            self.HTVideoPickerDeleteBtn.enabled = YES;
        }
    }
}

- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath{
    if(collectionView.allowsMultipleSelection){
        HTVideoPickerCollectionViewCell *deselectedCell = (__kindof UICollectionViewCell *) [collectionView cellForItemAtIndexPath:indexPath];
        [self deselectedCellLayoutChange:deselectedCell];
        for(int i = 0 ; i < [self.selectedVideos count] ; i++){
            if(self.selectedVideos[i] == indexPath){
                [self.selectedVideos removeObjectAtIndex:i];
                [self.selectedVideosIndex removeIndex:indexPath.row];
            }
        }
        if([self.selectedVideos count] == 0){
            self.HTVideoPickerExportBtn.enabled = NO;
            self.HTVideoPickerDeleteBtn.enabled = NO;
        }
        NSLog(@"after deselected %@ index %@", self.selectedVideos, self.selectedVideosIndex);
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
//Format of video file is AlbumName_HV####.mp4
//There are two more images files for video files to show thumbnail and preview
//Their names are AlbumName_HV####.jpg
- (void)getSelectedImageAssetsFromImagePicker:(NSMutableArray *)selectedAssetsArray{
    UIActivityIndicatorView *indicator = [[UIActivityIndicatorView alloc] init];
    indicator.center = self.view.center;
    [self.view addSubview:indicator];
    [indicator startAnimating];
    indicator.hidden = NO;
    //Directory paths
    NSString *DocumentDir;
    NSArray *DocumentDirsArray;
    
    DocumentDirsArray = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    DocumentDir = DocumentDirsArray[0];
    DocumentDir = [NSString stringWithFormat:@"%@%@%@/", DocumentDir, @"/HTHiddenVideos/", self.selectedAlbumName];
    PHImageRequestOptions *synchronousOptions = [[PHImageRequestOptions alloc] init];
    synchronousOptions.synchronous = YES;
    PHVideoRequestOptions *videoRequestOptions = [[PHVideoRequestOptions alloc] init];
    videoRequestOptions.deliveryMode = PHVideoRequestOptionsDeliveryModeAutomatic;
    int thumnailCountBeforeAdd = (int) [self.thumbnailImages count];
    for(int i = 0; i < [selectedAssetsArray count]; i++){
        NSLog(@"%d", i);
        PHAsset *selectedAsset = selectedAssetsArray[i];
        //NSLog(@"%@", originalDir);
        [[PHImageManager defaultManager] requestExportSessionForVideo:selectedAsset options:videoRequestOptions exportPreset:AVAssetExportPresetHighestQuality resultHandler:^(AVAssetExportSession * _Nullable exportSession, NSDictionary * _Nullable info) {
            //Get path for video saving
            //Path for directories
            NSString *trimmedAlbumName = [self.selectedAlbumName substringFromIndex:7];
            NSString *fileNameForVideo = [NSString stringWithFormat:@"%@_HV%04d.mp4", trimmedAlbumName, thumnailCountBeforeAdd + 1 + i];
            NSString *originalDir = [NSString stringWithFormat:@"%@%@%@", DocumentDir, @"original/", fileNameForVideo];
            //save original video
            exportSession.outputURL = [NSURL fileURLWithPath:originalDir];
            exportSession.outputFileType = AVFileTypeMPEG4;
            [exportSession exportAsynchronouslyWithCompletionHandler:^{
                NSLog(@"file %@", originalDir);
                NSLog(@"status %d", (int) exportSession.status);
                NSLog(@"error %@", exportSession.error.localizedDescription);
                if(i == [selectedAssetsArray count] -1){
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [indicator removeFromSuperview];
                    });
                }
            }];
        }];
        //Save Thumbnail
        [[PHImageManager defaultManager] requestImageForAsset:selectedAsset targetSize:CGSizeMake(150, 150) contentMode:PHImageContentModeAspectFit options:synchronousOptions resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
            //Get path for video saving
            //Path for directories
            NSString *trimmedAlbumName = [self.selectedAlbumName substringFromIndex:7];
            NSString *fileName = [NSString stringWithFormat:@"%@_HV%04d.jpg", trimmedAlbumName, thumnailCountBeforeAdd + 1 + i];
            NSString *thumbnailDir = [NSString stringWithFormat:@"%@%@%@", DocumentDir, @"thumbnail/", fileName];
            NSString *resizeDir = [NSString stringWithFormat:@"%@%@%@", DocumentDir, @"resize/", fileName];
            UIImage *thumbnail = result;
            [self.thumbnailImages addObject:thumbnail];
            [self.videoLength addObject:[NSNumber numberWithFloat:selectedAsset.duration]];
            [self.HTHiddenVideosFileNameArray addObject:fileName];
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
        }];
    }
    [self.HTVideoPickerCollectionView reloadData];
    [self.HTVideoDetailView.videoDetailCollectionView reloadData];
    if([self.HTHiddenVideosFileNameArray count] > 0){
        self.HTVideoPickerSelectBtn.enabled = YES;
    }
}

- (void)imagePickerCanceledWithOutSelection{
    NSLog(@"canceled without selection");
}

#pragma mark - Button Actions
- (IBAction)backToAlbumBtnTouched:(id)sender {
    [self saveVideoLength];
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)addHiddenVideosBtnTouched:(id)sender {
    FTImagePickerOptions *imagePickerOptions = [[FTImagePickerOptions alloc] init];
    imagePickerOptions.multipleSelectOn = YES;
    imagePickerOptions.multipleSelectMin = 1;
    imagePickerOptions.multipleSelectMax = 20;
    imagePickerOptions.theme = WhiteVersion;
    imagePickerOptions.mediaTypeToUse = VideosOnly;
    imagePickerOptions.regularAlbums = @[@2, @3, @4, @5, @6];
    imagePickerOptions.smartAlbums = @[@200, @201, @202, @203, @204, @205, @206, @207, @208, @210, @211];
    
    [FTImagePickerManager presentFTImagePicker:self withOptions:imagePickerOptions];
}

- (IBAction)selectVideosBtnTouched:(id)sender {
    self.HTVideoPickerCollectionView.allowsMultipleSelection = YES;
    self.HTVideoPickerAddBtn.hidden = YES;
    self.HTVideoPickerBackBtn.hidden = YES;
    self.HTVideoPickerCancelBtn.hidden = NO;
    self.HTVideoPickerSelectBtn.hidden = YES;
    self.HTVideoPickerExportBtn.hidden = NO;
    self.HTVideoPickerDeleteBtn.hidden = NO;
}

- (IBAction)selectCancelBtnTouched:(id)sender {
    for(int i = 0 ; i < [self.selectedVideos count] ;){
        [self.HTVideoPickerCollectionView deselectItemAtIndexPath:self.selectedVideos[i] animated:YES];
        [self collectionView:self.HTVideoPickerCollectionView didDeselectItemAtIndexPath:self.selectedVideos[i]];
    }
    self.HTVideoPickerCollectionView.allowsMultipleSelection = NO;
    self.HTVideoPickerAddBtn.hidden = NO;
    self.HTVideoPickerBackBtn.hidden = NO;
    self.HTVideoPickerCancelBtn.hidden = YES;
    self.HTVideoPickerSelectBtn.hidden = NO;
    self.HTVideoPickerExportBtn.hidden = YES;
    self.HTVideoPickerExportBtn.enabled = NO;
    self.HTVideoPickerDeleteBtn.hidden = YES;
    self.HTVideoPickerDeleteBtn.enabled = NO;
}

- (IBAction)exportVideosBtnTouched:(id)sender {
    //Array for export images
    NSMutableArray *arrayForExport = [[NSMutableArray alloc] init];
    //Directory paths
    NSString *DocumentDir;
    NSArray *DocumentDirsArray;
    DocumentDirsArray = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    DocumentDir = DocumentDirsArray[0];
    DocumentDir = [NSString stringWithFormat:@"%@%@%@/", DocumentDir, @"/HTHiddenVideos/", self.selectedAlbumName];
    NSString *trimmedAlbumName = [self.selectedAlbumName substringFromIndex:7];
    for(int i = 0; i < [self.selectedVideos count]; i++){
        //Path for directories
        NSString *fileName = [NSString stringWithFormat:@"%@_HV%04d.mp4", trimmedAlbumName, (int) self.selectedVideos[i].row + 1];
        NSString *originalDir = [NSString stringWithFormat:@"%@%@%@", DocumentDir, @"original/", fileName];
        NSLog(@"%@", originalDir);
        NSURL *exportVideo = [NSURL fileURLWithPath:originalDir];
        [arrayForExport addObject:exportVideo];
    }
    //UIActivityViewController
    UIActivityViewController *activityForSharing = [[UIActivityViewController alloc] initWithActivityItems:arrayForExport applicationActivities:nil];
    [self presentViewController:activityForSharing animated:YES completion:nil];
    [self.HTVideoPickerCollectionView reloadItemsAtIndexPaths:self.selectedVideos];
    [self.selectedVideos removeAllObjects];
    [self.selectedVideosIndex removeAllIndexes];
    self.HTVideoPickerCollectionView.allowsMultipleSelection = NO;
    self.HTVideoPickerAddBtn.hidden = NO;
    self.HTVideoPickerBackBtn.hidden = NO;
    self.HTVideoPickerCancelBtn.hidden = YES;
    self.HTVideoPickerSelectBtn.hidden = NO;
    self.HTVideoPickerExportBtn.hidden = YES;
    self.HTVideoPickerExportBtn.enabled = NO;
    self.HTVideoPickerDeleteBtn.hidden = YES;
    self.HTVideoPickerDeleteBtn.enabled = NO;
}

- (IBAction)deleteVideosBtnTouched:(id)sender {
    //File manager
    NSFileManager *fileManager = [NSFileManager defaultManager];
    //Directory paths
    NSString *DocumentDir;
    NSArray *DocumentDirsArray;
    DocumentDirsArray = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    DocumentDir = DocumentDirsArray[0];
    DocumentDir = [NSString stringWithFormat:@"%@%@%@/", DocumentDir, @"/HTHiddenVideos/", self.selectedAlbumName];
    NSString *trimmedAlbumName = [self.selectedAlbumName substringFromIndex:7];
    for(int i = 0; i < [self.selectedVideos count]; i++){
        //Path for directories
        NSString *fileName = [NSString stringWithFormat:@"%@_HV%04d.jpg", trimmedAlbumName, (int) self.selectedVideos[i].row + 1];
        NSString *thumbnailDir = [NSString stringWithFormat:@"%@%@%@", DocumentDir, @"thumbnail/", fileName];
        NSString *resizeDir = [NSString stringWithFormat:@"%@%@%@", DocumentDir, @"resize/", fileName];
        NSString *originalDir = [NSString stringWithFormat:@"%@%@%@", DocumentDir, @"original/", fileName];
        //Delete files in sandbox
        [fileManager removeItemAtPath:thumbnailDir error:nil];
        [fileManager removeItemAtPath:resizeDir error:nil];
        [fileManager removeItemAtPath:originalDir error:nil];
    }
    //Update datasource
    [self.thumbnailImages removeObjectsAtIndexes:self.selectedVideosIndex];
    [self.HTHiddenVideosFileNameArray removeObjectsAtIndexes:self.selectedVideosIndex];
    
    NSLog(@"FileName %@", self.HTHiddenVideosFileNameArray);
    //Update collectionview
    [self.HTVideoPickerCollectionView performBatchUpdates:^{
        [self.HTVideoPickerCollectionView deleteItemsAtIndexPaths:self.selectedVideos];
    } completion:^(BOOL finished) {
        self.HTVideoPickerCollectionView.allowsMultipleSelection = NO;
        self.HTVideoPickerAddBtn.hidden = NO;
        self.HTVideoPickerBackBtn.hidden = NO;
        self.HTVideoPickerCancelBtn.hidden = YES;
        self.HTVideoPickerSelectBtn.hidden = NO;
        self.HTVideoPickerExportBtn.hidden = YES;
        self.HTVideoPickerExportBtn.enabled = NO;
        self.HTVideoPickerDeleteBtn.hidden = YES;
        self.HTVideoPickerDeleteBtn.enabled = NO;
        //Move videos
        //1. find video which index is not equal to its file name
        //2. move it to its correct index
        for(int i = 0 ; i < [self.HTHiddenVideosFileNameArray count]; i++){
            if(![self.HTHiddenVideosFileNameArray[i] isEqualToString:[NSString stringWithFormat:@"%@_HV%04d.jpg", trimmedAlbumName, i + 1]]){
                NSString *nearBlank = [self.HTHiddenVideosFileNameArray[i] substringWithRange:NSMakeRange(trimmedAlbumName.length + 3, 4)];
                int nearBlankInt = [nearBlank intValue];
                NSString *originalFileForThumbnail = [NSString stringWithFormat:@"%@%@%@_HV%04d.jpg", DocumentDir, @"thumbnail/", trimmedAlbumName, nearBlankInt];
                NSString *destinationFileForThumbnail= [NSString stringWithFormat:@"%@%@%@_HV%04d.jpg", DocumentDir, @"thumbnail/", trimmedAlbumName, i+1];
                NSString *originalFileForResize = [NSString stringWithFormat:@"%@%@%@_HV%04d.jpg", DocumentDir, @"resize/", trimmedAlbumName, nearBlankInt];
                NSString *destinationFileForResize= [NSString stringWithFormat:@"%@%@%@_HV%04d.jpg", DocumentDir, @"resize/", trimmedAlbumName, i+1];
                NSString *originalFileForOriginal = [NSString stringWithFormat:@"%@%@%@_HV%04d.mp4", DocumentDir, @"original/", trimmedAlbumName, nearBlankInt];
                NSString *destinationFileForOriginal = [NSString stringWithFormat:@"%@%@%@_HV%04d.mp4", DocumentDir, @"original/", trimmedAlbumName, i+1];
                [fileManager moveItemAtPath:originalFileForThumbnail toPath:destinationFileForThumbnail error:nil];
                [fileManager moveItemAtPath:originalFileForResize toPath:destinationFileForResize error:nil];
                [fileManager moveItemAtPath:originalFileForOriginal toPath:destinationFileForOriginal error:nil];
                
                self.HTHiddenVideosFileNameArray[i] = [NSString stringWithFormat:@"%@_HV%04d.jpg", trimmedAlbumName, i+1];
                NSLog(@"Filenames after file moved %@", self.HTHiddenVideosFileNameArray);
            }
        }
        [self.selectedVideos removeAllObjects];
        [self.selectedVideosIndex removeAllIndexes];
    }];
    if([self.HTHiddenVideosFileNameArray count] == 0){
        self.HTVideoPickerSelectBtn.enabled = NO;
    }
}

#pragma mark - DetailView Delegate
- (void)presentAVPlayerViewController:(AVPlayerViewController *)AVPlayerViewController AVPlayer:(AVPlayer *)AVPlayer{
    [self presentViewController:AVPlayerViewController animated:YES completion:^{
        [AVPlayerViewController.player play];
    }];
}


@end

#pragma mark -
@interface HTVideoDetailView()

@end
@implementation HTVideoDetailView
#pragma mark- CollectionView delegate
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return [self.thumbnailImages count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    NSLog(@"cell");
    HTVideoDetailCollectionViewCell *detailViewCell = [collectionView dequeueReusableCellWithReuseIdentifier:@"detailViewCell" forIndexPath:indexPath];
    
    //Directory paths
    NSString *DocumentDir;
    NSArray *DocumentDirsArray;
    
    DocumentDirsArray = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    DocumentDir = DocumentDirsArray[0];
    DocumentDir = [NSString stringWithFormat:@"%@%@%@/", DocumentDir, @"/HTHiddenVideos/", self.selectedAlbumName];
    
    //Path for directories
    NSString *trimmedAlbumName = [self.selectedAlbumName substringFromIndex:7];
    NSString *fileName = [NSString stringWithFormat:@"%@_HV%04d.jpg", trimmedAlbumName, (int) (indexPath.row + 1)];
    NSString *resizeDir = [NSString stringWithFormat:@"%@%@%@", DocumentDir, @"resize/", fileName];
    detailViewCell.detailViewImageView.image = [UIImage imageWithContentsOfFile:resizeDir];
    //ScrollView setting
    detailViewCell.detailViewScrollView.maximumZoomScale = 5.0;
    detailViewCell.detailViewScrollView.minimumZoomScale = 1.0;
    detailViewCell.detailViewScrollView.zoomScale = 1.0;
    //frame setting
    detailViewCell.detailViewScrollView.frame = CGRectMake(0, 0, detailViewCell.frame.size.width, detailViewCell.frame.size.height);
    detailViewCell.detailViewScrollView.contentSize = CGSizeMake(detailViewCell.frame.size.width, detailViewCell.frame.size.height);
    detailViewCell.detailViewImageView.frame = detailViewCell.detailViewScrollView.bounds;
    
    return detailViewCell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    return self.videoDetailCollectionView.frame.size;
}

#pragma mark - scrollview delegate
- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView{
    for(UIView *view in [scrollView subviews]){
        if([view isKindOfClass:[UIImageView class]]){
            return view;
        }
    }
    return nil;
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    self.videoPlayBtn.enabled = NO;
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    self.videoPlayBtn.enabled = YES;
}

#pragma mark - Button Actions
- (IBAction)videoPlayBtnTouched:(id)sender {
    //Directory paths
    NSString *DocumentDir;
    NSArray *DocumentDirsArray;
    DocumentDirsArray = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    DocumentDir = DocumentDirsArray[0];
    DocumentDir = [NSString stringWithFormat:@"%@%@%@/", DocumentDir, @"/HTHiddenVideos/", self.selectedAlbumName];
    NSString *trimmedAlbumName = [self.selectedAlbumName substringFromIndex:7];
    NSArray *videoIndexPaths = [self.videoDetailCollectionView indexPathsForVisibleItems];
    NSIndexPath *videoIndexPath = [videoIndexPaths firstObject];
    //Path for directories
    NSString *fileName = [NSString stringWithFormat:@"%@_HV%04d.mp4", trimmedAlbumName, (int) videoIndexPath.row + 1];
    NSString *originalDir = [NSString stringWithFormat:@"%@%@%@", DocumentDir, @"original/", fileName];
    NSURL *videoURL = [NSURL fileURLWithPath:originalDir];
    NSLog(@"%@", [[NSFileManager defaultManager] contentsOfDirectoryAtPath:[NSString stringWithFormat:@"%@%@", DocumentDir, @"original/"] error:nil]);
    //AVPlayer
    AVPlayerViewController *videoPlayerViewController = [[AVPlayerViewController alloc] init];
    AVPlayerItem *playItem = [AVPlayerItem playerItemWithURL:videoURL];
    AVPlayer *videoPlayer = [[AVPlayer alloc] initWithPlayerItem:playItem];
    videoPlayerViewController.player = videoPlayer;
    [videoPlayerViewController.view setFrame:self.bounds];
    videoPlayerViewController.showsPlaybackControls = YES;
    [self.delegate presentAVPlayerViewController:videoPlayerViewController AVPlayer:videoPlayer];
}

- (IBAction)backToPickerBtnTouched:(id)sender {
    //make a imageView For transition and configure
    UIImageView *imageViewForTransition = [[UIImageView alloc] initWithFrame:self.HTVideoPickerCollectionView.bounds];
    imageViewForTransition.contentMode = UIViewContentModeScaleAspectFit;
    //selected cell for get image from it
    HTVideoDetailCollectionViewCell *selectedCell = (__kindof UICollectionViewCell *) [self.videoDetailCollectionView cellForItemAtIndexPath:[[self.videoDetailCollectionView indexPathsForVisibleItems] firstObject]];
    //assign image to imageview
    imageViewForTransition.image = selectedCell.detailViewImageView.image;
    //add imageView as subview of Image Picker collection view
    [self.HTVideoPickerCollectionView addSubview:imageViewForTransition];
    //Image picker cell for destination point of transition
    HTVideoPickerCollectionViewCell *selectedCellInVideoPIcker = (__kindof UICollectionViewCell *) [self.HTVideoPickerCollectionView cellForItemAtIndexPath:[[self.videoDetailCollectionView indexPathsForVisibleItems] firstObject]];
    //hide image in image picker for effect
    [selectedCellInVideoPIcker.contentView setAlpha:0.0];
    //Animation effect
    [UIView animateWithDuration:0.2 animations:^{
        [imageViewForTransition setFrame:selectedCellInVideoPIcker.frame];
        NSLog(@"%f %f", selectedCellInVideoPIcker.frame.origin.x, selectedCellInVideoPIcker.frame.origin.y);
        [self setAlpha:0.0];
    } completion:^(BOOL finished) {
        imageViewForTransition.contentMode = UIViewContentModeScaleAspectFill;
        [imageViewForTransition removeFromSuperview];
        [self removeFromSuperview];
        //show cell in image picker after transition
        [selectedCellInVideoPIcker.contentView setAlpha:1.0];
    }];
}
@end

#pragma mark -
@interface HTVideoPickerCollectionViewCell()
@end
@implementation HTVideoPickerCollectionViewCell
@end
#pragma mark -
@interface HTVideoDetailCollectionViewCell()
@end
@implementation HTVideoDetailCollectionViewCell
@end
