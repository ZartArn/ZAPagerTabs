//
//  ZAPageTabsViewController.h
//  MTabs
//
//  Created by ZartArn on 02.10.17.
//  Copyright © 2017 ZartArn. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZAPageTabsBar.h"

@interface ZAPageTabsViewController : UIViewController <UIScrollViewDelegate, ZAPageTabsBarDelegate>

/// tab bar
@property (strong, nonatomic) ZAPageTabsBar *tabBar;

/// child viewcontrollers
@property (strong, nonatomic) NSArray *viewControllers;

/// icon names
@property (strong, nonatomic) NSArray *iconNames;

/// currently selected view controller
@property (assign, nonatomic) UIViewController *selectedViewController;

/// currently selected index
@property (nonatomic) NSUInteger selectedIndex;

@end
