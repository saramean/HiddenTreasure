//
//  HTWebViewController.m
//  HiddenTreasure
//
//  Created by Park on 2016. 11. 7..
//  Copyright © 2016년 Whybox1. All rights reserved.
//

#import "HTWebViewController.h"

@interface HTWebViewController ()

@end

@implementation HTWebViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.HTWebViewAddressField.delegate = self;
    self.HTWebView.delegate = self;
    self.HTWebViewActivityIndicator.hidden = YES;
    [self.HTWebView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"http://www.google.com"]]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Activity Indicator
- (void)webViewDidStartLoad:(UIWebView *)webView{
    self.HTWebViewActivityIndicator.hidden = NO;
}

- (void)webViewDidFinishLoad:(UIWebView *)webView{
    self.HTWebViewActivityIndicator.hidden = YES;
}

#pragma mark - TextField Delegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    if(textField.text.length == 0){
        return NO;
    }
    NSString *prefix = @"http://";
    NSString *addressText = textField.text;
    if(!([addressText hasPrefix:prefix])){
        addressText = [prefix stringByAppendingString:addressText];
    }
    NSURL *url = [NSURL URLWithString:addressText];
    [self.HTWebView loadRequest:[NSURLRequest requestWithURL:url]];
    [self.HTWebViewAddressField resignFirstResponder];
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField{
    [textField selectAll:textField.text];
}

#pragma mark - Web View delegate
//if a page is not found, search it from google
- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error{
    NSString *googleSearch = @"http://www.google.com/search?q=";
    self.HTWebViewAddressField.text = [self.HTWebViewAddressField.text substringFromIndex:7];
    self.HTWebViewAddressField.text = [self.HTWebViewAddressField.text substringToIndex:self.HTWebViewAddressField.text.length -1];
    googleSearch = [googleSearch stringByAppendingString:self.HTWebViewAddressField.text];
    NSURL *searchUrl = [NSURL URLWithString:[googleSearch stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]]];
    [self.HTWebView loadRequest:[NSURLRequest requestWithURL:searchUrl]];
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType{
    self.HTWebViewAddressField.text =[NSString stringWithFormat:@"%@", request.URL.absoluteURL];
    return YES;
}

#pragma mark - Button Actions
- (IBAction)BackToChoicePageBtnTouched:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)prevBtnTouched:(id)sender {
    [self.HTWebView goBack];
}
- (IBAction)nextBtnTouched:(id)sender {
    [self.HTWebView goForward];
}

- (IBAction)stopBtnTouched:(id)sender {
    [self.HTWebView stopLoading];
}

- (IBAction)refreshBtnTouched:(id)sender {
    [self.HTWebView reload];
}

#pragma mark - Keyboard Dismiss
- (IBAction)addressFieldWillResignFirstResponderWhenWebViewTapped:(id)sender {
    [self.HTWebViewAddressField resignFirstResponder];

}
@end
