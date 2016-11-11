//
//  HTMemoListViewController.h
//  HiddenTreasure
//
//  Created by Park on 2016. 11. 11..
//  Copyright © 2016년 Whybox1. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HTMemoEditViewController.h"

@interface HTMemoListViewController : UIViewController<UITableViewDelegate, UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITableView *HTMemoListTableView;
@property (strong, nonatomic) NSMutableArray<NSString *> *memoList;
@property (strong, nonatomic) NSString *selectedMemoTitle;
@property (strong, nonatomic) NSString *documentPath;

- (IBAction)backToChoiceBtnTouched:(id)sender;
@end

@interface HTMemoListTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *memoTitle;
@end
