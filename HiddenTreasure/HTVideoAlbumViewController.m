//
//  HTVideoAlbumViewController.m
//  HiddenTreasure
//
//  Created by Park on 2016. 11. 10..
//  Copyright © 2016년 Whybox1. All rights reserved.
//

#import "HTVideoAlbumViewController.h"

@interface HTVideoAlbumViewController ()

@end

@implementation HTVideoAlbumViewController

//Album will be stored in DocumentDir/HTHiddenVideos/HA####_AlbumName/
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    if(!self.videoAlbumNamesArray){
        self.videoAlbumNamesArray = [[NSMutableArray alloc] init];
    }
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *DocumentDir;
    NSArray *DocumentDirsArray;
    DocumentDirsArray = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    DocumentDir = DocumentDirsArray[0];
    DocumentDir = [NSString stringWithFormat:@"%@%@", DocumentDir, @"/HTHiddenVideos/"];
    
    
    
    [self.videoAlbumNamesArray setArray:[fileManager contentsOfDirectoryAtPath:DocumentDir error:nil]];
    NSLog(@"%@", self.videoAlbumNamesArray);
    for(int i = 0 ; i < [self.videoAlbumNamesArray count] ; i++){
        if(![self.videoAlbumNamesArray[i] hasPrefix:@"HA"]){
            [self.videoAlbumNamesArray removeObjectAtIndex:i];
        }
        else{
            self.videoAlbumNamesArray[i] = [self.videoAlbumNamesArray[i] substringFromIndex:7];
        }
    }
    
    //tableview setting
    self.HTVideoAlbumTableView.allowsMultipleSelectionDuringEditing = NO;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table View Delegate
//Table view delegate
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    HTVideoAlbumTableViewCells *videoAlbumNamesCell = [tableView dequeueReusableCellWithIdentifier:@"albumNamesCell" forIndexPath:indexPath];
    videoAlbumNamesCell.videoAlbumName.text = self.videoAlbumNamesArray[indexPath.row];
    
    //    if(indexPath.row == [self.videoAlbumNamesArray count]){
    //        NSLog(@"log");
    //        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"addAlbumsCell" forIndexPath:indexPath];
    //        return cell;
    //    }
    
    return videoAlbumNamesCell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [self.videoAlbumNamesArray count];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath{
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
    if(editingStyle == UITableViewCellEditingStyleDelete){
        UIAlertController *albumDeleteAlertController = [UIAlertController alertControllerWithTitle:@"Delete Album" message:@"If you delete this album, all the files inside of this album will be delete. Do you really want to delete this album?" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *delete = [UIAlertAction actionWithTitle:@"Delete" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            //Path for directory
            NSFileManager *fileManager = [NSFileManager defaultManager];
            NSString *DocumentDir;
            NSArray *DocumentDirsArray;
            DocumentDirsArray = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
            DocumentDir = DocumentDirsArray[0];
            
            HTVideoAlbumTableViewCells *selectedCell = [tableView cellForRowAtIndexPath:indexPath];
            NSString *directoryName = selectedCell.videoAlbumName.text;
            directoryName = [NSString stringWithFormat:@"HA%04d_%@", (int) (indexPath.row + 1), directoryName];
            DocumentDir = [NSString stringWithFormat:@"%@%@%@%@", DocumentDir, @"/HTHiddenVideos/", directoryName, @"/"];
            NSLog(@"%@", DocumentDir);
            //Remove directory
            [fileManager removeItemAtPath:DocumentDir error:nil];
            //Remove Cell
            [self.videoAlbumNamesArray removeObjectAtIndex:indexPath.row];
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationBottom];
            
            //Rename the other directories
            if(indexPath.row < [self.videoAlbumNamesArray count]){
                NSString *tempStringForDirectoryName = selectedCell.videoAlbumName.text;
                NSString *tempPathForDirectory = DocumentDir;
                for(int i = (int) indexPath.row ; i < [self.videoAlbumNamesArray count] ; i++){
                    NSIndexPath *nextCellsIndexPath = [NSIndexPath indexPathForRow:i inSection:0];
                    HTVideoAlbumTableViewCells *cellForChange = [tableView cellForRowAtIndexPath:nextCellsIndexPath];
                    NSString *directoryWillBeChanged = cellForChange.videoAlbumName.text;
                    NSString *destinationPath = [tempPathForDirectory stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"HA%04d_%@/", i+1 ,tempStringForDirectoryName] withString:[NSString stringWithFormat:@"HA%04d_%@/", i+1, directoryWillBeChanged]];
                    NSString *originalPath = [destinationPath stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"%04d", i+1] withString:[NSString stringWithFormat:@"%04d", i+2]];
                    //                    NSLog(@"original path %@", originalPath);
                    //                    NSLog(@"destination path %@", destinationPath);
                    //                    NSError *error;
                    [fileManager moveItemAtPath:originalPath toPath:destinationPath error:nil];
                    //                    NSLog(@"%@", error.localizedDescription);
                    tempPathForDirectory = originalPath;
                    tempStringForDirectoryName = directoryWillBeChanged;
                }
            }
        }];
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            
        }];
        
        [albumDeleteAlertController addAction:cancelAction];
        [albumDeleteAlertController addAction:delete];
        
        [self presentViewController:albumDeleteAlertController animated:YES completion:nil];
    }
}

#pragma mark - Button Actions
- (IBAction)backToChoiceBtnTouched:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)AddAlbumsBtnTouched:(id)sender {
    UIAlertController *videoAlbumCreationAlertController = [UIAlertController alertControllerWithTitle:@"Create an Album" message:@"Enter Album Name" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *createAction = [UIAlertAction actionWithTitle:@"Create" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        NSString *newAlbumName = [videoAlbumCreationAlertController.textFields firstObject].text;
        if([self checkAllowedName:newAlbumName]){
            [self.videoAlbumNamesArray addObject:newAlbumName];
            [self.HTVideoAlbumTableView beginUpdates];
            [self.HTVideoAlbumTableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:[self.videoAlbumNamesArray count] - 1 inSection:0]] withRowAnimation:UITableViewRowAnimationTop];
            [self.HTVideoAlbumTableView endUpdates];
            
            [self makeDirectoryWithDirectoryName:newAlbumName];
        }
    }];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil];
    
    [videoAlbumCreationAlertController addAction:cancelAction];
    [videoAlbumCreationAlertController addAction:createAction];
    
    [videoAlbumCreationAlertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.placeholder = @"Album Name";
    }];
    
    [self presentViewController:videoAlbumCreationAlertController animated:YES completion:nil];
    
}

#pragma mark - Create Album Directory
//check invalid characters in file name
// '/' is not allowed.
- (BOOL) checkAllowedName: (NSString *) fileName{
    // '/'
    NSCharacterSet *notAllowedCharacterSet = [NSCharacterSet characterSetWithCharactersInString:@"/"];
    NSRange notAllowedCharactersInName = [fileName rangeOfCharacterFromSet:notAllowedCharacterSet];
    fileName = [fileName stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@" "]];
    if (notAllowedCharactersInName.length != 0){
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Not allowed Character" message:@"/ is not allowed for directory name. please change your directory name without /." preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *createAction = [UIAlertAction actionWithTitle:@"Create" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            NSString *newAlbumName = [alertController.textFields firstObject].text;
            if([self checkAllowedName:newAlbumName]){
                [self.videoAlbumNamesArray addObject:newAlbumName];
                [self.HTVideoAlbumTableView beginUpdates];
                [self.HTVideoAlbumTableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:[self.videoAlbumNamesArray count] - 1 inSection:0]] withRowAnimation:UITableViewRowAnimationTop];
                [self.HTVideoAlbumTableView endUpdates];
                
                [self makeDirectoryWithDirectoryName:newAlbumName];
            }
        }];
        
        [alertController addAction:createAction];
        
        [alertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
            textField.placeholder = @"Album Name";
        }];
        
        [self presentViewController:alertController animated:YES completion:nil];
        return NO;
    }
    else if(fileName.length == 0){
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Album Name cannot be blank" message:@"Album Name cannot be blank. Please type something for your album name." preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *createAction = [UIAlertAction actionWithTitle:@"Create" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            NSString *newAlbumName = [alertController.textFields firstObject].text;
            if([self checkAllowedName:newAlbumName]){
                [self.videoAlbumNamesArray addObject:newAlbumName];
                [self.HTVideoAlbumTableView beginUpdates];
                [self.HTVideoAlbumTableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:[self.videoAlbumNamesArray count] - 1 inSection:0]] withRowAnimation:UITableViewRowAnimationTop];
                [self.HTVideoAlbumTableView endUpdates];
                
                [self makeDirectoryWithDirectoryName:newAlbumName];
            }
        }];
        
        [alertController addAction:createAction];
        
        [alertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
            textField.placeholder = @"Album Name";
        }];
        
        [self presentViewController:alertController animated:YES completion:nil];
        return NO;
    }
    else{
        return YES;
    }
}

//Make Directory for albums
//Name Format of directory will be HA####_AlbumName(#### is 4 digit integer value)
//'/' cannot be used as a album name
//Count For naming directory
- (void) makeDirectoryWithDirectoryName: (NSString *) directoryName{
    //Path for directory
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *DocumentDir;
    NSArray *DocumentDirsArray;
    
    DocumentDirsArray = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    DocumentDir = DocumentDirsArray[0];
    DocumentDir = [NSString stringWithFormat:@"%@%@%04d%@%@%@", DocumentDir, @"/HTHiddenVideos/HA", (int) [self.videoAlbumNamesArray count] ,@"_" ,  directoryName, @"/"];
    NSString *thumbnailDir = [NSString stringWithFormat:@"%@%@", DocumentDir, @"thumbnail/"];
    NSString *resizeDir = [NSString stringWithFormat:@"%@%@", DocumentDir, @"resize/"];
    NSString *originalDir =[NSString stringWithFormat:@"%@%@", DocumentDir, @"original/"];
    
    if(!([fileManager fileExistsAtPath:DocumentDir])){
        [fileManager createDirectoryAtPath:thumbnailDir withIntermediateDirectories:YES attributes:nil error:nil];
        [fileManager createDirectoryAtPath:resizeDir withIntermediateDirectories:YES attributes:nil error:nil];
        [fileManager createDirectoryAtPath:originalDir withIntermediateDirectories:YES attributes:nil error:nil];
    }
}

#pragma mark - Prepare For Segue
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if([segue.identifier isEqualToString:@"albumSelected"]){
        //Get destination View Controller
        HTVideoPickerViewController *destinationViewController =  segue.destinationViewController;
        //Get selected Cell
        NSIndexPath *selectedCellIndexPath = [self.HTVideoAlbumTableView indexPathForSelectedRow];
        HTVideoAlbumTableViewCells *selectedCell = [self.HTVideoAlbumTableView cellForRowAtIndexPath:selectedCellIndexPath];
        
        NSString *directoryName = selectedCell.videoAlbumName.text;
        
        //Path for directory
        NSFileManager *fileManager = [NSFileManager defaultManager];
        NSString *DocumentDir;
        NSArray *DocumentDirsArray;
        
        DocumentDirsArray = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        DocumentDir = DocumentDirsArray[0];
        DocumentDir = [NSString stringWithFormat:@"%@%@%04d_%@/thumbnail/", DocumentDir, @"/HTHiddenVideos/HA", (int) (selectedCellIndexPath.row + 1) ,  directoryName];
        
        destinationViewController.selectedAlbumName = [NSString stringWithFormat:@"HA%04d_%@", (int) (selectedCellIndexPath.row + 1), directoryName];
        destinationViewController.HTHiddenVideosFileNameArray =[NSMutableArray arrayWithArray:[fileManager contentsOfDirectoryAtPath:DocumentDir error:nil]];
        NSLog(@"Document directory path %@", DocumentDir);
        NSLog(@"selected album name %@", destinationViewController.selectedAlbumName);
        NSLog(@"hidden videos %@", destinationViewController.HTHiddenVideosFileNameArray);
        
    }
}

@end


#pragma mark -
@interface HTVideoAlbumTableViewCells ()
@end

@implementation HTVideoAlbumTableViewCells
@end
