//
//  AppDelegate.h
//  HiddenTreasure
//
//  Created by Park on 2016. 11. 7..
//  Copyright © 2016년 Whybox1. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import "HTAuthenticationViewController.h"
#import "HTHideInfoViewController.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate, HTAuthenticationViewControllerDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (readonly, strong) NSPersistentContainer *persistentContainer;

@property (strong, nonatomic) KeychainWrapper *keychainForPassword;
@property (strong, nonatomic) UINavigationController *HTNavigationController;

- (void)saveContext;


@end

