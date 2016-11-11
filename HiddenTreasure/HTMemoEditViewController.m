//
//  HTMemoEditViewController.m
//  HiddenTreasure
//
//  Created by Park on 2016. 11. 11..
//  Copyright © 2016년 Whybox1. All rights reserved.
//

#import "HTMemoEditViewController.h"

@interface HTMemoEditViewController ()

@end

@implementation HTMemoEditViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.memoField.text = @"Memo here";
    self.memoField.textColor = [UIColor colorWithWhite:0.7 alpha:1.0];
    if(!self.memoList){
        self.memoList = [[NSMutableArray alloc] init];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)textViewDidBeginEditing:(UITextView *)textView{
    if([textView.text isEqualToString:@"Memo here"]){
        textView.text = @"";
        textView.textColor = [UIColor blackColor];
    }
}

- (void)textViewDidEndEditing:(UITextView *)textView{
    if([textView.text isEqualToString:@""]){
        textView.text = @"Memo here";
        textView.textColor = [UIColor colorWithWhite:0.7 alpha:1.0];
    }
    
}

- (IBAction)backToMemoListTouched:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

//File name format is HM####_MemoTitle.txt
- (IBAction)memoSaveBtnTouched:(id)sender {
    NSString *memoTitle = self.memoTitleField.text;
    memoTitle = [memoTitle stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@" "]];
    if([memoTitle isEqualToString:@""]){
        memoTitle = self.memoField.text;
        memoTitle = [memoTitle stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@" "]];
        int titleLength = 0;
        if(memoTitle.length > 20){
            titleLength = 20;
        }
        else{
            titleLength = (int) memoTitle.length - 1;
        }
        memoTitle = [memoTitle substringToIndex:titleLength];
    }
    NSString *fileFormatName = [NSString stringWithFormat:@"HM%04d_%@", (int) [self.memoList count] + 1, memoTitle];
    NSString *filePath = [NSString stringWithFormat:@"%@/%@.txt", self.documentPath, fileFormatName];
    [self.memoList addObject:fileFormatName];
    NSData *memoContent = [NSJSONSerialization dataWithJSONObject:@[self.memoField.text] options:kNilOptions error:nil];
    [memoContent writeToFile:filePath atomically:YES];
    [self.memoField resignFirstResponder];
}
@end
