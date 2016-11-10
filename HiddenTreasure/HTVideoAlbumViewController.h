//
//  HTVideoAlbumViewController.h
//  HiddenTreasure
//
//  Created by Park on 2016. 11. 10..
//  Copyright © 2016년 Whybox1. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HTVideoPickerViewController.h"

@interface HTVideoAlbumViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UITableView *HTVideoAlbumTableView;
@property (strong, nonatomic) NSMutableArray<NSString *> *videoAlbumNamesArray;


- (IBAction)backToChoiceBtnTouched:(id)sender;
- (IBAction)AddAlbumsBtnTouched:(id)sender;

@end


@interface HTVideoAlbumTableViewCells : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *videoAlbumName;

@end

