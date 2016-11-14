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
            self.memoList[i] = [self.memoList[i] substringWithRange:NSMakeRange(7, self.memoList[i].length -11)];
        }
    }
    
    //tableview setting
    self.HTMemoListTableView.allowsMultipleSelectionDuringEditing = NO;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - TableView Delegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [self.memoList count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    HTMemoListTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"memoListCells"];
    cell.memoTitle.text = self.memoList[indexPath.row];
    return cell;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
    if(editingStyle == UITableViewCellEditingStyleDelete){
        UIAlertController *memoDeleteAlertController = [UIAlertController alertControllerWithTitle:@"Delete Memo" message:@"Do you really want to delete this memo?" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *delete = [UIAlertAction actionWithTitle:@"Delete" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            //Path for memo
            NSFileManager *fileManager = [NSFileManager defaultManager];
            
            NSString *selectedMemoTitle = self.memoList[indexPath.row];
            NSString *selectedMemoPath = [NSString stringWithFormat:@"%@HM%04d_%@.txt", self.documentPath, (int) indexPath.row + 1, self.memoList[indexPath.row]];
            NSLog(@"%@", selectedMemoPath);
            //Remove memo
            [fileManager removeItemAtPath:selectedMemoPath error:nil];
            //Remove Cell
            [self.memoList removeObjectAtIndex:indexPath.row];
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationBottom];
            
            //Rename the other memos
            if(indexPath.row < [self.memoList count]){
                NSString *tempStringForMemoTitle = selectedMemoTitle;
                NSString *tempPathForDirectory = selectedMemoPath;
                for(int i = (int) indexPath.row ; i < [self.memoList count] ; i++){
                    NSString *memoWillBeChanged = self.memoList[i];
                    NSString *destinationPath = [tempPathForDirectory stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"HM%04d_%@", i+1 ,tempStringForMemoTitle] withString:[NSString stringWithFormat:@"HM%04d_%@", i+1, memoWillBeChanged]];
                    NSString *originalPath = [destinationPath stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"%04d", i+1] withString:[NSString stringWithFormat:@"%04d", i+2]];
                    //                    NSLog(@"original path %@", originalPath);
                    //                    NSLog(@"destination path %@", destinationPath);
                    //                    NSError *error;
                    [fileManager moveItemAtPath:originalPath toPath:destinationPath error:nil];
                    //                    NSLog(@"%@", error.localizedDescription);
                    tempPathForDirectory = originalPath;
                    tempStringForMemoTitle = memoWillBeChanged;
                }
            }
        }];
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            
        }];
        
        [memoDeleteAlertController addAction:cancelAction];
        [memoDeleteAlertController addAction:delete];
        
        [self presentViewController:memoDeleteAlertController animated:YES completion:nil];
    }
}

#pragma mark - Button Actions
- (IBAction)backToChoiceBtnTouched:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - Preapare For Segue
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if([segue.identifier isEqualToString:@"addMemo"]){
        HTMemoEditViewController *destination = segue.destinationViewController;
        destination.memoList = self.memoList;
        destination.documentPath = self.documentPath;
        destination.HTMemoListTableView = self.HTMemoListTableView;
    }
    else if([segue.identifier isEqualToString:@"editMemo"]){
        HTMemoEditViewController *destination = segue.destinationViewController;
        HTMemoListTableViewCell *selectedCell = sender;
        NSIndexPath *indexPathForSelectedCell = [self.HTMemoListTableView indexPathForCell:selectedCell];
        NSLog(@"%@", self.memoList[indexPathForSelectedCell.row]);
        destination.memoList = self.memoList;
        destination.documentPath = self.documentPath;
        NSString *selectedMemoPath = [NSString stringWithFormat:@"%@HM%04d_%@.txt", self.documentPath, (int) indexPathForSelectedCell.row + 1, self.memoList[indexPathForSelectedCell.row]];
        NSData *memoData = [NSData dataWithContentsOfFile:selectedMemoPath];
        NSArray *memoArray = [NSJSONSerialization JSONObjectWithData:memoData options:kNilOptions error:nil];
        destination.memoTitleAndContent = @[self.memoList[indexPathForSelectedCell.row], [memoArray firstObject]];
        NSLog(@"%@", [memoArray firstObject]);
        destination.calledIndex = indexPathForSelectedCell.row + 1;
        destination.HTMemoListTableView = self.HTMemoListTableView;
    }
}
@end


#pragma mark -
@interface HTMemoListTableViewCell()
@end
@implementation HTMemoListTableViewCell
@end
