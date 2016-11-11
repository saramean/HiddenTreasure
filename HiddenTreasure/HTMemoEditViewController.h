//
//  HTMemoEditViewController.h
//  HiddenTreasure
//
//  Created by Park on 2016. 11. 11..
//  Copyright © 2016년 Whybox1. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HTMemoEditViewController : UIViewController<UITextViewDelegate>
@property (strong, nonatomic) NSMutableArray<NSString *> *memoList;
@property (weak, nonatomic) IBOutlet UIButton *memoSaveBtn;
@property (weak, nonatomic) IBOutlet UITextField *memoTitleField;
@property (weak, nonatomic) IBOutlet UITextView *memoField;
@property (strong, nonatomic) NSString *documentPath;

- (IBAction)backToMemoListTouched:(id)sender;
- (IBAction)memoSaveBtnTouched:(id)sender;
@end
