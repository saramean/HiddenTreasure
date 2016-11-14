//
//  HTHideInfoViewController.m
//  HiddenTreasure
//
//  Created by Park on 2016. 11. 7..
//  Copyright © 2016년 Whybox1. All rights reserved.
//

#import "HTHideInfoViewController.h"

@interface HTHideInfoViewController ()

@end

@implementation HTHideInfoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(authenticateUser) name:UIApplicationWillEnterForegroundNotification object:nil];
}

#pragma mark - Touch ID Authentication
- (void) authenticateUser{
    LAContext *contextForAuth = [[LAContext alloc] init];
    NSError *authError = nil;
    NSString *reasonForTouchID = @"To see this page, please authenticate yourself";
    
    if([contextForAuth canEvaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics error:&authError]){
        [contextForAuth evaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics localizedReason:reasonForTouchID reply:^(BOOL success, NSError * _Nullable error) {
            if(success){
                NSLog(@"success");
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.navigationController popViewControllerAnimated:YES];
                });
            }
            else{
                NSLog(@"failed error is %@",error);
            }
        }];
    }
    else{
        [self.passwordFiledForHideInfo becomeFirstResponder];
    }
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Text Field Delegate
//delegate for limiting string number
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    if((self.passwordFiledForHideInfo.text.length >= 4) && range.length == 0){
        return NO;
    }
    return YES;
}

#pragma mark - Button Actions
- (IBAction)hideInfoPasswordConfirmBtnTouched:(id)sender {
    if([self.passwordFiledForHideInfo.text isEqualToString:[self.keychainForPassword myObjectForKey:(__bridge id)kSecValueData]]){
        [self.navigationController popViewControllerAnimated:YES];
    }
    else{
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Incorrect Password" message:@"Check your password again" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *OKAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
        [alertController addAction:OKAction];
        [self presentViewController:alertController animated:YES completion:nil];
    }

}
@end
