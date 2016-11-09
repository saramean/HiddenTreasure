//
//  HTTutorialPageContentsViewController.m
//  HiddenTreasure
//
//  Created by Park on 2016. 11. 7..
//  Copyright © 2016년 Whybox1. All rights reserved.
//

#import "HTTutorialPageContentsViewController.h"

@interface HTTutorialPageContentsViewController ()

@end

@implementation HTTutorialPageContentsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.tutorialPageTitle.text = self.tutorialPageTitleText;
    self.tutorialDescription.text = self.tutorialDescriptionText;
    self.tutorialStartBtn.hidden = self.BtnHidden;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



- (IBAction)startApplicationStartBtnTouched:(id)sender {
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    UINavigationController *navigation =  [mainStoryboard instantiateViewControllerWithIdentifier:@"HTNavigationController"];
    [self presentViewController:navigation animated:YES completion:nil];
    [self.navigationController dismissViewControllerAnimated:NO completion:nil];
    
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"firstLaunch"];
}
@end
