//
//  HTMemoListViewController.m
//  HiddenTreasure
//
//  Created by Park on 2016. 11. 11..
//  Copyright © 2016년 Whybox1. All rights reserved.
//

#import "HTMemoListViewController.h"

@interface HTMemoListViewController ()

@end

@implementation HTMemoListViewController

//Memo will be stored in DocumentDir/HTHiddenMemo/
- (void)viewDidLoad {
    [super viewDidLoad];
    if(!self.memoList){
        self.memoList = [[NSMutableArray alloc] init];
    }
    // Do any additional setup after loading the view.
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSArray *DocumentDirsArray;
    DocumentDirsArray = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    self.documentPath = DocumentDirsArray[0];
    self.documentPath = [NSString stringWithFormat:@"%@%@", self.documentPath, @"/HTHiddenMemo/"];
    if(![fileManager fileExistsAtPath:self.documentPath]){
        [fileManager createDirectoryAtPath:self.documentPath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    self.memoList = [NSMutableArray arrayWithArray:[fileManager contentsOfDirectoryAtPath:self.documentPath error:nil]];
    
    NSLog(@"%@", self.memoList);
    for(int i = 0 ; i < [self.memoList count] ; i++){
        if(![self.memoList[i] hasPrefix:@"HM"]){
            [self.memoList removeObjectAtIndex:i];
        }
        else{
            self.memoList[i] = [self.memoList[i] substringFromIndex:7];
        }
    }
    
    //tableview setting
    self.HTMemoListTableView.allowsMultipleSelectionDuringEditing = NO;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [self.memoList count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    HTMemoListTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"memoListCells"];
    cell.memoTitle.text = self.memoList[indexPath.row];
    return cell;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (IBAction)backToChoiceBtnTouched:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if([segue.identifier isEqualToString:@"addMemo"]){
        HTMemoEditViewController *destination = segue.destinationViewController;
        destination.memoList = self.memoList;
        destination.documentPath = self.documentPath;
    }
}
@end



@interface HTMemoListTableViewCell()
@end
@implementation HTMemoListTableViewCell
@end
