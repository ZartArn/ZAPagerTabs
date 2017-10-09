//
//  ZAPageTabsViewController.h
//  MTabs
//
//  Created by ZartArn on 02.10.17.
//  Copyright © 2017 ZartArn. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ZAPageTabsViewController : UIViewController <UIScrollViewDelegate>

/// child viewcontrollers
@property (strong, nonatomic) NSArray *viewControllers;

/// currently selected view controller
@property (assign, nonatomic) UIViewController *selectedViewController;

/// currently selected index
@property (nonatomic) NSUInteger selectedIndex;

@end
