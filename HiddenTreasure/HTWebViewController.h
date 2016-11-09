//
//  HTWebViewController.h
//  HiddenTreasure
//
//  Created by Park on 2016. 11. 7..
//  Copyright © 2016년 Whybox1. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HTWebViewController : UIViewController<UITextFieldDelegate, UIWebViewDelegate>
@property (weak, nonatomic) IBOutlet UIWebView *HTWebView;
@property (weak, nonatomic) IBOutlet UITextField *HTWebViewAddressField;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *HTWebViewActivityIndicator;

- (IBAction)BackToChoicePageBtnTouched:(id)sender;
- (IBAction)prevBtnTouched:(id)sender;
- (IBAction)nextBtnTouched:(id)sender;
- (IBAction)stopBtnTouched:(id)sender;
- (IBAction)refreshBtnTouched:(id)sender;
- (IBAction)addressFieldWillResignFirstResponderWhenWebViewTapped:(id)sender;

@end
