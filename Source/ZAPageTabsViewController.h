//
//  ZAPageTabsViewController.h
//  MTabs
//
//  Created by ZartArn on 02.10.17.
//  Copyright © 2017 ZartArn. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZAPageTabsBar.h"

@class ZAPageTabsBarStyle;

/**
 *  barHeight, infoItems and style for PageTabsBar must be set before ZAPageTabsViewController load view. After, they do not change
 *  if infoItems is null, will be using ViewController.title for automatic creating info items
 *  if infoItems.count != viewControllers.count, they are ignored
 */

@interface ZAPageTabsViewController : UIViewController <UIScrollViewDelegate, ZAPageTabsBarDelegate>

/// create instance with style properties
- (instancetype)initWithStyle:(ZAPageTabsBarStyle *)style;

/// tab bar
@property (strong, nonatomic) ZAPageTabsBar *tabBar;

/// tab bar height
@property (nonatomic) CGFloat barHeight;

/// indicator info items, nullable
@property (strong, nonatomic) NSArray <ZAPageTabIndicatorInfo *> *infoItems;

/// child viewcontrollers
@property (strong, nonatomic) NSArray *viewControllers;

/// current selected index, readonly yet
@property (nonatomic) NSInteger selectedIndex;

@end
