//
//  ZASandwichController.h
//  ZartArn
//
//  Created by ZartArn on 18.05.16.
//  Copyright © 2016 ZartArn. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 *  Container ViewController aka UITabBarController without UITabBar and MoreControllers
 */

@protocol ZASandwichControllerDelegate, ZASandwichControllerAnimatorDelegate;

@interface ZASandwichController : UIViewController

/// child viewcontrollers
@property (copy, nonatomic, readonly) NSArray *viewControllers;

/// currently selected view controller
@property (assign, nonatomic) UIViewController *selectedViewController;

/// currently selected index
@property (nonatomic) NSUInteger selectedIndex;

/// delegate
@property (assign, nonatomic) id<ZASandwichControllerDelegate> delegate;
@property (strong, nonatomic) id<ZASandwichControllerAnimatorDelegate> animatorDelegate;

/// initialize
- (instancetype)initWithViewControllers:(NSArray *)viewControllers;

@end

@protocol ZASandwichControllerDelegate <NSObject>
@optional

- (BOOL)sandwichController:(ZASandwichController *)sandwichController shouldSelectViewController:(UIViewController *)viewController atIndex:(NSInteger)selectedIndex;
- (void)sandwichController:(ZASandwichController *)sandwichControllerarController willSelectViewController:(UIViewController *)viewController;
- (void)sandwichController:(ZASandwichController *)sandwichControllerarController didSelectViewController:(UIViewController *)viewController;

@end

@protocol ZASandwichControllerAnimatorDelegate <NSObject>
@optional

- (id <UIViewControllerAnimatedTransitioning>)sandwichController:(ZASandwichController *)sandwichController
              animationControllerForTransitionFromViewController:(UIViewController *)fromVC
                                                toViewController:(UIViewController *)toVC;
@end
