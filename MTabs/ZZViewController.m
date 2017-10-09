//
//  ZZViewController.m
//  MTabs
//
//  Created by ZartArn on 02.10.17.
//  Copyright © 2017 ZartArn. All rights reserved.
//

#import "ZZViewController.h"
#import "ViewController.h"

@interface ZZViewController () <MDCTabBarDelegate>

@end

@implementation ZZViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    // Do any additional setup after loading the view.

    UIViewController *v1 = [[ViewController alloc] initWithItemsCount:30];
    v1.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"Title 1" image:nil tag:0];
    
    UIViewController *v2 = [[ViewController alloc] initWithItemsCount:5];
    v2.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"Title 2" image:nil tag:0];
    
    UIViewController *v3 = [[ViewController alloc] initWithItemsCount:40];
    v3.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"Title 3" image:nil tag:0];

    self.viewControllers = @[
                             v1, v2, v3
                             ];
    self.selectedViewController = v1;
    
    self.tabBar.delegate = self;
    
    self.tabBar.items = @[
                          v1.tabBarItem,
                          v2.tabBarItem,
                          v3.tabBarItem
                          ];
    
    self.tabBar.selectedItem = v1.tabBarItem;
    
    self.tabBar.backgroundColor = [UIColor purpleColor];
}

//- (UIBarPosition)positionForBar:(id<UIBarPositioning>)bar {
//    return UIBarPositionTop;
//}
@end
