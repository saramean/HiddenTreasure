//
//  HTHideInfoViewController.h
//  HiddenTreasure
//
//  Created by Park on 2016. 11. 7..
//  Copyright © 2016년 Whybox1. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KeychainWrapper.h"
@import LocalAuthentication;

@interface HTHideInfoViewController : UIViewController <UITextFieldDelegate>
@property (strong, nonatomic) KeychainWrapper *keychainForPassword;
@property (weak, nonatomic) IBOutlet UITextField *passwordFiledForHideInfo;

- (IBAction)hideInfoPasswordConfirmBtnTouched:(id)sender;
@end
