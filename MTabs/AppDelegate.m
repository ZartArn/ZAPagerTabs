//
//  AppDelegate.m
//  MTabs
//
//  Created by ZartArn on 02.10.17.
//  Copyright © 2017 ZartArn. All rights reserved.
//

#import "AppDelegate.h"
#import "ZAPageTabsViewController.h"
#import "ViewController.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    ZAPageTabsBarStyle *style = [ZAPageTabsBarStyle new];
    style.backgroundColor   = [UIColor colorWithRed:0.56 green:0.75 blue:0 alpha:1];
    style.indicatorHeight   = 2.f;
    style.indicatorColor    = [UIColor colorWithRed:0.25 green:0.4 blue:0.04 alpha:1];
    style.selectedColor     = [UIColor whiteColor];
    style.normalColor       = [UIColor colorWithRed:1. green:1 blue:1 alpha:0.8];

    
    ZAPageTabsViewController *rootVC = [[ZAPageTabsViewController alloc] initWithStyle:style];
    ViewController *v1 = [[ViewController alloc] initWithItemsCount:30];
    ViewController *v2 = [[ViewController alloc] initWithItemsCount:5];
    ViewController *v3 = [[ViewController alloc] initWithItemsCount:21];
    ViewController *v4 = [[ViewController alloc] initWithItemsCount:8];
    
    v1.title = @"Title";
    v2.title = @"Star Track";
    v4.title = @"Bumbarash";
    v3.title = @"Abraka";
    
    rootVC.viewControllers = @[v1, v4, v2, v3];
    
    // window
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.rootViewController = rootVC;
    [self.window makeKeyAndVisible];
    
    return YES;
}


- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


@end
