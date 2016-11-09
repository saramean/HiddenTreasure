//
//  ViewController.m
//  HiddenTreasure
//
//  Created by Park on 2016. 11. 7..
//  Copyright © 2016년 Whybox1. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)viewDidAppear:(BOOL)animated{
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    if(![[NSUserDefaults standardUserDefaults] boolForKey:@"firstLaunch"]){
        UIPageViewController *tutorialPage = [mainStoryboard instantiateViewControllerWithIdentifier:@"HTTutorialPageController"];
        
        self.tutorialPagetitles = @[@"Secure your data", @"For your private Life", @"Ready?"];
        self.tutorialPageDescriptions = @[@"Nobody can see", @"Private data", @"Press start and go"];
        
        tutorialPage.dataSource = self;
        
        HTTutorialPageContentsViewController *startingPage = [self viewControllerAtIndex:0];
        NSArray *viewControllers = @[startingPage];
        [tutorialPage setViewControllers:viewControllers direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:nil];
        [self presentViewController:tutorialPage animated:YES completion:nil];
    }
    else{
        UINavigationController *navigation = [mainStoryboard instantiateViewControllerWithIdentifier:@"HTNavigationController"];
        [self presentViewController:navigation animated:YES completion:nil];
    }
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController{
    NSUInteger index = ((HTTutorialPageContentsViewController *) viewController).index;
    if((index == 0) || (index == NSNotFound)){
        return nil;
    }
    index --;
    return [self viewControllerAtIndex:index];
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController{
    NSUInteger index = ((HTTutorialPageContentsViewController *) viewController).index;
    if(index == NSNotFound){
        return nil;
    }
    index ++;
    if(index == [self.tutorialPagetitles count]){
        return nil;
    }
    return [self viewControllerAtIndex:index];
}

- (HTTutorialPageContentsViewController *)viewControllerAtIndex:(NSUInteger)index{
    if(([self.tutorialPagetitles count] == 0) || (index >= [self.tutorialPagetitles count])){
        return nil;
    }
    
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    HTTutorialPageContentsViewController *tutorialPageContentsViewController = [mainStoryboard instantiateViewControllerWithIdentifier:@"HTTutorialPageContentsController"];
    tutorialPageContentsViewController.index = index;
    tutorialPageContentsViewController.tutorialPageTitleText = self.tutorialPagetitles[index];
    tutorialPageContentsViewController.tutorialDescriptionText = self.tutorialPageDescriptions[index];
    
    if(tutorialPageContentsViewController.index != 2){
        tutorialPageContentsViewController.BtnHidden = YES;
    }
    else{
        tutorialPageContentsViewController.BtnHidden = NO;
    }
    return tutorialPageContentsViewController;
}

- (NSInteger)presentationCountForPageViewController:(UIPageViewController *)pageViewController{
    return  [self.tutorialPagetitles count];
}

- (NSInteger)presentationIndexForPageViewController:(UIPageViewController *)pageViewController{
    return 0;
}


@end
