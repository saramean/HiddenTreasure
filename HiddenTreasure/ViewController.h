//
//  ViewController.h
//  HiddenTreasure
//
//  Created by Park on 2016. 11. 7..
//  Copyright © 2016년 Whybox1. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HTTutorialPageContentsViewController.h"

@interface ViewController : UIViewController <UIPageViewControllerDataSource>
@property (strong, nonatomic) NSArray<NSString *> *tutorialPagetitles;
@property (strong, nonatomic) NSArray<NSString *> *tutorialPageDescriptions;

- (HTTutorialPageContentsViewController *) viewControllerAtIndex:(NSUInteger) index;

@end

