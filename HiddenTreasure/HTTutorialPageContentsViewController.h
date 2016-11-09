//
//  HTTutorialPageContentsViewController.h
//  HiddenTreasure
//
//  Created by Park on 2016. 11. 7..
//  Copyright © 2016년 Whybox1. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HTTutorialPageContentsViewController : UIViewController
@property (weak, nonatomic) IBOutlet UILabel *tutorialPageTitle;
@property (weak, nonatomic) IBOutlet UILabel *tutorialDescription;
@property (weak, nonatomic) IBOutlet UIButton *tutorialStartBtn;
@property (strong, nonatomic) NSString *tutorialPageTitleText;
@property (strong, nonatomic) NSString *tutorialDescriptionText;
@property (assign, nonatomic) BOOL BtnHidden;
@property (assign, nonatomic) NSUInteger index;

- (IBAction)startApplicationStartBtnTouched:(id)sender;
@end
