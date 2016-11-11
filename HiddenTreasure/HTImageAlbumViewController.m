//
//  HTImageAlbumViewController.m
//  HiddenTreasure
//
//  Created by Park on 2016. 11. 7..
//  Copyright © 2016년 Whybox1. All rights reserved.
//

#import "HTImageAlbumViewController.h"

@interface HTImageAlbumViewController ()

@end

@implementation HTImageAlbumViewController

//Album will be stored in DocumentDir/HTHiddenImages/HA####_AlbumName/
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    if(!self.imageAlbumNamesArray){
        self.imageAlbumNamesArray = [[NSMutableArray alloc] init];
    }
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *DocumentDir;
    NSArray *DocumentDirsArray;
    DocumentDirsArray = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    DocumentDir = DocumentDirsArray[0];
    DocumentDir = [NSString stringWithFormat:@"%@%@", DocumentDir, @"/HTHiddenImages/"];
    
    
    
    [self.imageAlbumNamesArray setArray:[fileManager contentsOfDirectoryAtPath:DocumentDir error:nil]];
    NSLog(@"%@", self.imageAlbumNamesArray);
    for(int i = 0 ; i < [self.imageAlbumNamesArray count] ; i++){
        if(![self.imageAlbumNamesArray[i] hasPrefix:@"HA"]){
            [self.imageAlbumNamesArray removeObjectAtIndex:i];
        }
        else{
            self.imageAlbumNamesArray[i] = [self.imageAlbumNamesArray[i] substringFromIndex:7];
        }
    }
    
    //tableview setting
    self.HTImageAlbumTableView.allowsMultipleSelectionDuringEditing = NO;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//Table view delegate
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    HTImageAlbumTableViewCells *imageAlbumNamesCell = [tableView dequeueReusableCellWithIdentifier:@"albumNamesCell" forIndexPath:indexPath];
    imageAlbumNamesCell.imageAlbumName.text = self.imageAlbumNamesArray[indexPath.row];
    
//    if(indexPath.row == [self.imageAlbumNamesArray count]){
//        NSLog(@"log");
//        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"addAlbumsCell" forIndexPath:indexPath];
//        return cell;
//    }
    
    return imageAlbumNamesCell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [self.imageAlbumNamesArray count];
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
            
            HTImageAlbumTableViewCells *selectedCell = [tableView cellForRowAtIndexPath:indexPath];
            NSString *directoryName = selectedCell.imageAlbumName.text;
            directoryName = [NSString stringWithFormat:@"HA%04d_%@", (int) (indexPath.row + 1), directoryName];
            DocumentDir = [NSString stringWithFormat:@"%@%@%@%@", DocumentDir, @"/HTHiddenImages/", directoryName, @"/"];
            NSLog(@"%@", DocumentDir);
            //Remove directory
            [fileManager removeItemAtPath:DocumentDir error:nil];
            //Remove Cell
            [self.imageAlbumNamesArray removeObjectAtIndex:indexPath.row];
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationBottom];
            
            //Rename the other directories
            if(indexPath.row < [self.imageAlbumNamesArray count]){
                NSString *tempStringForDirectoryName = selectedCell.imageAlbumName.text;
                NSString *tempPathForDirectory = DocumentDir;
                for(int i = (int) indexPath.row ; i < [self.imageAlbumNamesArray count] ; i++){
                    NSIndexPath *nextCellsIndexPath = [NSIndexPath indexPathForRow:i inSection:0];
                    HTImageAlbumTableViewCells *cellForChange = [tableView cellForRowAtIndexPath:nextCellsIndexPath];
                    NSString *directoryWillBeChanged = cellForChange.imageAlbumName.text;
                    NSString *destinationPath = [tempPathForDirectory stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"HA%04d_%@/", i+1 ,tempStringForDirectoryName] withString:[NSString stringWithFormat:@"HA%04d_%@/", i+1, directoryWillBeChanged]];
                    NSString *originalPath = [destinationPath stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"%04d", i+1] withString:[NSString stringWithFormat:@"%04d", i+2]];
                    //[fileManager createDirectoryAtPath:destinationPath withIntermediateDirectories:YES attributes:nil error:nil];
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


- (IBAction)backToChoiceBtnTouched:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)AddAlbumsBtnTouched:(id)sender {
    UIAlertController *imageAlbumCreationAlertController = [UIAlertController alertControllerWithTitle:@"Create an Album" message:@"Enter Album Name" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *createAction = [UIAlertAction actionWithTitle:@"Create" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        NSString *newAlbumName = [imageAlbumCreationAlertController.textFields firstObject].text;
        if([self checkAllowedName:newAlbumName]){
            [self.imageAlbumNamesArray addObject:newAlbumName];
            [self.HTImageAlbumTableView beginUpdates];
            [self.HTImageAlbumTableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:[self.imageAlbumNamesArray count] - 1 inSection:0]] withRowAnimation:UITableViewRowAnimationTop];
            [self.HTImageAlbumTableView endUpdates];
            
            [self makeDirectoryWithDirectoryName:newAlbumName];
        }
    }];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil];
    
    [imageAlbumCreationAlertController addAction:cancelAction];
    [imageAlbumCreationAlertController addAction:createAction];
    
    [imageAlbumCreationAlertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.placeholder = @"Album Name";
    }];
    
    [self presentViewController:imageAlbumCreationAlertController animated:YES completion:nil];
    
}

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
                [self.imageAlbumNamesArray addObject:newAlbumName];
                [self.HTImageAlbumTableView beginUpdates];
                [self.HTImageAlbumTableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:[self.imageAlbumNamesArray count] - 1 inSection:0]] withRowAnimation:UITableViewRowAnimationTop];
                [self.HTImageAlbumTableView endUpdates];
                
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
                [self.imageAlbumNamesArray addObject:newAlbumName];
                [self.HTImageAlbumTableView beginUpdates];
                [self.HTImageAlbumTableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:[self.imageAlbumNamesArray count] - 1 inSection:0]] withRowAnimation:UITableViewRowAnimationTop];
                [self.HTImageAlbumTableView endUpdates];
                
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
//'/' cannot be used in album name
//Count For naming directory
- (void) makeDirectoryWithDirectoryName: (NSString *) directoryName{
    //Path for directory
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *DocumentDir;
    NSArray *DocumentDirsArray;
    
    DocumentDirsArray = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    DocumentDir = DocumentDirsArray[0];
    DocumentDir = [NSString stringWithFormat:@"%@%@%04d%@%@%@", DocumentDir, @"/HTHiddenImages/HA", (int) [self.imageAlbumNamesArray count] ,@"_" ,  directoryName, @"/"];
    NSString *thumbnailDir = [NSString stringWithFormat:@"%@%@", DocumentDir, @"thumbnail/"];
    NSString *resizeDir = [NSString stringWithFormat:@"%@%@", DocumentDir, @"resize/"];
    NSString *originalDir =[NSString stringWithFormat:@"%@%@", DocumentDir, @"original/"];
    
    if(!([fileManager fileExistsAtPath:DocumentDir])){
        [fileManager createDirectoryAtPath:thumbnailDir withIntermediateDirectories:YES attributes:nil error:nil];
        [fileManager createDirectoryAtPath:resizeDir withIntermediateDirectories:YES attributes:nil error:nil];
        [fileManager createDirectoryAtPath:originalDir withIntermediateDirectories:YES attributes:nil error:nil];
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if([segue.identifier isEqualToString:@"albumSelected"]){
        //Get destination View Controller
        HTImagePickerViewController *destinationViewController =  segue.destinationViewController;
        //Get selected Cell
        NSIndexPath *selectedCellIndexPath = [self.HTImageAlbumTableView indexPathForSelectedRow];
        HTImageAlbumTableViewCells *selectedCell = [self.HTImageAlbumTableView cellForRowAtIndexPath:selectedCellIndexPath];
        
        NSString *directoryName = selectedCell.imageAlbumName.text;
        
        //Path for directory
        NSFileManager *fileManager = [NSFileManager defaultManager];
        NSString *DocumentDir;
        NSArray *DocumentDirsArray;
        
        DocumentDirsArray = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        DocumentDir = DocumentDirsArray[0];
        DocumentDir = [NSString stringWithFormat:@"%@%@%04d_%@/thumbnail/", DocumentDir, @"/HTHiddenImages/HA", (int) (selectedCellIndexPath.row + 1) ,  directoryName];
        
        destinationViewController.selectedAlbumName = [NSString stringWithFormat:@"HA%04d_%@", (int) (selectedCellIndexPath.row + 1), directoryName];
        destinationViewController.HTHiddenImagesFileNameArray =[NSMutableArray arrayWithArray:[fileManager contentsOfDirectoryAtPath:DocumentDir error:nil]];
        NSLog(@"Document directory path %@", DocumentDir);
        NSLog(@"selected album name %@", destinationViewController.selectedAlbumName);
        NSLog(@"hidden images %@", destinationViewController.HTHiddenImagesFileNameArray);
        
    }
}

@end




@interface HTImageAlbumTableViewCells ()
@end

@implementation HTImageAlbumTableViewCells
@end
