//
//  HTAuthenticationViewController.m
//  HiddenTreasure
//
//  Created by Park on 2016. 11. 7..
//  Copyright © 2016년 Whybox1. All rights reserved.
//

#import "HTAuthenticationViewController.h"

@interface HTAuthenticationViewController ()

@end

@implementation HTAuthenticationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    //Set AppDelegate as a delegate
    self.delegate = (id)(AppDelegate *) [[UIApplication sharedApplication] delegate];
    
    //Set Frame of subviews
    [self.passwordCreationView setFrame: self.view.frame];
    [self.passwordConfirmView setFrame: self.view.frame];
    //Set Text Field Delegates
    self.passwordFieldForLogin.delegate = self;
    self.passwordFieldForCreation.delegate = self;
    self.passwordFieldForConfirm.delegate = self;
    //Initialize keychain
    self.keychainForPassword = [[KeychainWrapper alloc] init];
    //check existing password
    self.passwordSet = [[NSUserDefaults standardUserDefaults] boolForKey:@"passwordSet"];
    if(self.passwordSet){
        [self.delegate keyChainSendToAppdelegate:self.keychainForPassword navigationController:self.navigationController];
    }
    self.resetPasswordBtn.enabled = self.passwordSet;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//Delegate for limiting string number
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    if((self.passwordFieldForLogin.text.length >= 4) && self.passwordFieldForLogin.isFirstResponder && range.length == 0){
        return NO;
    }
    else if ((self.passwordFieldForCreation.text.length >= 4) && self.passwordFieldForCreation.isFirstResponder && range.length == 0){
        return NO;
    }
    else if ((self.passwordFieldForConfirm.text.length >= 4) && self.passwordFieldForConfirm.isFirstResponder && range.length == 0){
        return NO;
    }
    return YES;
}

//If password is not set, show password creation view
- (void)textFieldDidBeginEditing:(UITextField *)textField{
    if(textField == self.passwordFieldForLogin){
        if(!self.passwordSet){
            textField.inputView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.view addSubview:self.passwordCreationView];
                [self.passwordFieldForCreation becomeFirstResponder];
            });
        }
        else{
            textField.inputView = nil;
        }
    }
    else{
        textField.inputView = nil;
    }
}



- (IBAction)loginWithTouchIDBtnTouched:(id)sender {
    LAContext *contextForAuth = [[LAContext alloc] init];
    NSError *authError = nil;
    NSString *reasonForTouchID = @"Test application to practice Touch ID example";
    
    if([contextForAuth canEvaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics error:&authError]){
        [contextForAuth evaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics localizedReason:reasonForTouchID reply:^(BOOL success, NSError * _Nullable error) {
            if(success){
                NSLog(@"success");
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self performSegueWithIdentifier:@"authenticationSuccess" sender:self];
                    //In case, user use the app without setting his/her password
                    if(!self.passwordSet){
                        [self.delegate keyChainSendToAppdelegate:nil navigationController:self.navigationController];
                    }
                });
            }
            else{
                NSLog(@"failed error is %@",error);
            }
        }];
    }
    else{
        NSLog(@"auth error %@", authError);
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Touch ID is not Available" message:@"Check your Touch ID setting again" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *OKAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
        [alertController addAction:OKAction];
        [self presentViewController:alertController animated:YES completion:nil];
    }

}

- (IBAction)resetPasswordBtnTouched:(id)sender {
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"passwordSet"];
    self.passwordSet = NO;
    self.resetPasswordBtn.enabled = self.passwordSet;
    [self.keychainForPassword resetKeychainItem];
}

- (IBAction)passwordCreationConfirmBtnTouched:(id)sender {
    if(self.passwordFieldForCreation.text.length == 4){
        [self.keychainForPassword mySetObject:self.passwordFieldForCreation.text forKey:(__bridge id)kSecValueData];
        [self.keychainForPassword writeToKeychain];
        [self.passwordCreationView addSubview:self.passwordConfirmView];
        [self.passwordFieldForConfirm becomeFirstResponder];
    }
    else{
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Type 4-digit Number" message:@"Password should be a 4-digit number" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *OKAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
        [alertController addAction:OKAction];
        [self presentViewController:alertController animated:YES completion:nil];
    }

}

- (IBAction)passwordConfirmConfirmBtnTouched:(id)sender {
    NSString *password = [self.keychainForPassword myObjectForKey:(__bridge id)kSecValueData];
    if([password isEqualToString:self.passwordFieldForConfirm.text]){
        self.passwordSet = YES;
        self.resetPasswordBtn.enabled = self.passwordSet;
        [[NSUserDefaults standardUserDefaults] setBool:self.passwordSet forKey:@"passwordSet"];
        [self.delegate keyChainSendToAppdelegate:self.keychainForPassword navigationController:self.navigationController];
        [self.passwordConfirmView removeFromSuperview];
        [self.passwordCreationView removeFromSuperview];
        [self.passwordFieldForConfirm resignFirstResponder];
    }
    else{
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Password is different" message:@"Password you typed is different from the one you typed before" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *OKAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
        [alertController addAction:OKAction];
        [self presentViewController:alertController animated:YES completion:nil];
    }

}

- (IBAction)passwordConfirmBackBtnTouched:(id)sender {
    [self.passwordConfirmView removeFromSuperview];
    [self.passwordFieldForCreation becomeFirstResponder];
}

- (IBAction)loginWithPaswordBtnTouched:(id)sender {
    if([self.passwordFieldForLogin.text isEqualToString:[self.keychainForPassword myObjectForKey:(__bridge id)kSecValueData]]){
        self.passwordFieldForLogin.text = nil;
        [self performSegueWithIdentifier:@"authenticationSuccess" sender:self];
    }
    else{
        NSLog(@"fail to login");
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Incorrect Password" message:@"Check your password again" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *OKAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
        [alertController addAction:OKAction];
        [self presentViewController:alertController animated:YES completion:nil];
    }

}
@end
