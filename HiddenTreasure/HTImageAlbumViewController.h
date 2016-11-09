//
//  HTImageAlbumViewController.h
//  HiddenTreasure
//
//  Created by Park on 2016. 11. 7..
//  Copyright © 2016년 Whybox1. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HTImagePickerViewController.h"

@interface HTImageAlbumViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UITableView *HTImageAlbumTableView;
@property (strong, nonatomic) NSMutableArray<NSString *> *imageAlbumNamesArray;


- (IBAction)backToChoiceBtnTouched:(id)sender;
- (IBAction)AddAlbumsBtnTouched:(id)sender;

@end


@interface HTImageAlbumTableViewCells : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *imageAlbumName;

@end
