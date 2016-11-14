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
    if(self.memoTitleAndContent){
        self.memoTitleField.text = [self.memoTitleAndContent firstObject];
        self.memoField.text = [self.memoTitleAndContent lastObject];
        self.memoField.textColor = [UIColor blackColor];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - TextView Delegate
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

#pragma mark - Button Actions
- (IBAction)backToMemoListTouched:(id)sender {
    [self.HTMemoListTableView reloadData];
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
            titleLength = (int) memoTitle.length;
        }
        memoTitle = [memoTitle substringToIndex:titleLength];
        self.memoTitleField.text = memoTitle;
    }
    //save new file
    if(self.calledIndex == 0){
        int indexMemoWillBeSaved = (int) [self.memoList count] + 1;
        NSString *fileFormatName = [NSString stringWithFormat:@"HM%04d_%@", indexMemoWillBeSaved , memoTitle];
        NSString *filePath = [NSString stringWithFormat:@"%@%@.txt", self.documentPath, fileFormatName];
        [self.memoList addObject:[fileFormatName substringFromIndex:7]];
        NSData *memoContent = [NSJSONSerialization dataWithJSONObject:@[self.memoField.text] options:kNilOptions error:nil];
        [memoContent writeToFile:filePath atomically:YES];
        [self.memoField resignFirstResponder];
        [self.memoTitleField resignFirstResponder];
        self.calledIndex = indexMemoWillBeSaved;
    }
    //edit existing file
    else{
        int indexMemoWillBeSaved = (int) self.calledIndex;
        NSString *fileFormatName = [NSString stringWithFormat:@"HM%04d_%@", indexMemoWillBeSaved , memoTitle];
        NSString *filePath = [NSString stringWithFormat:@"%@%@.txt", self.documentPath, fileFormatName];
        NSLog(@"new file path %@", filePath);
        //remove former file
        NSFileManager *fileManager = [NSFileManager defaultManager];
        NSString *fileWillBeRemoved = [NSString stringWithFormat:@"%@HM%04d_%@.txt", self.documentPath, (int) self.calledIndex ,self.memoList[self.calledIndex - 1]];
        NSLog(@"old file path %@", fileWillBeRemoved);
        [fileManager removeItemAtPath:fileWillBeRemoved error:nil];
        
        [self.memoList replaceObjectAtIndex:self.calledIndex - 1 withObject:[fileFormatName substringFromIndex:7]];
        NSData *memoContent = [NSJSONSerialization dataWithJSONObject:@[self.memoField.text] options:kNilOptions error:nil];
        //save editted file
        [memoContent writeToFile:filePath atomically:YES];
        [self.memoField resignFirstResponder];
        [self.memoTitleField resignFirstResponder];
    }
}
@end
