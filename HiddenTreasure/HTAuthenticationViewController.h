//
//  HTAuthenticationViewController.h
//  HiddenTreasure
//
//  Created by Park on 2016. 11. 7..
//  Copyright © 2016년 Whybox1. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KeychainWrapper.h"
@import LocalAuthentication;

@class AppDelegate;

@protocol HTAuthenticationViewControllerDelegate <NSObject>

- (void) keyChainSendToAppdelegate: (KeychainWrapper *) keychainForPassword navigationController: (UINavigationController *) navigationController;

@end

@interface HTAuthenticationViewController : UIViewController <UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UITextField *passwordFieldForLogin;
@property (weak, nonatomic) IBOutlet UITextField *passwordFieldForCreation;
@property (weak, nonatomic) IBOutlet UITextField *passwordFieldForConfirm;
@property (assign, nonatomic) BOOL passwordSet;
@property (strong, nonatomic) KeychainWrapper *keychainForPassword;
@property (weak, nonatomic) IBOutlet UIButton *resetPasswordBtn;
@property (strong, nonatomic) UIView *passwordCreationView;
@property (strong, nonatomic) UIView *passwordConfirmView;
@property (weak, nonatomic) id<HTAuthenticationViewControllerDelegate> delegate;


- (IBAction)loginWithTouchIDBtnTouched:(id)sender;
- (IBAction)resetPasswordBtnTouched:(id)sender;
- (IBAction)passwordCreationConfirmBtnTouched:(id)sender;
- (IBAction)passwordConfirmConfirmBtnTouched:(id)sender;
- (IBAction)passwordConfirmBackBtnTouched:(id)sender;
- (IBAction)loginWithPaswordBtnTouched:(id)sender;

@end
