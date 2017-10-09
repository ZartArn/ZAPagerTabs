//
//  ZATransitionContext.h
//  ZartArn
//
//  Created by ZartArn on 18.05.16.
//  Copyright © 2016 ZartArn. All rights reserved.
//

/**
 *  Custom Transition Context
 *  thanks, Joachim Bondo
 *  \https://www.objc.io/issues/12-animations/custom-container-view-controller-transitions/
 */

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface ZATransitionContext : NSObject<UIViewControllerContextTransitioning>

- (instancetype)initWithFromViewController:(UIViewController *)fromViewController
                          toViewController:(UIViewController *)toViewController;

@property (nonatomic, copy) void(^completionBlock)(BOOL didComplete);

@property (nonatomic, assign, getter=isAnimated) BOOL animated;
@property (nonatomic, assign, getter=isInteractive) BOOL interactive;

@end
