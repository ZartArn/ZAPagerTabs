//
//  ZASandwichController.m
//  ZartArn
//
//  Created by ZartArn on 18.05.16.
//  Copyright © 2016 ZartArn. All rights reserved.
//

#import "ZASandwichController.h"
#import "ZATransitionContext.h"

@interface ZASandwichController ()

@property (copy, nonatomic, readwrite) NSArray *viewControllers;
@property (strong, nonatomic) UIView *containerView;

@end

@implementation ZASandwichController

- (instancetype)initWithViewControllers:(NSArray *)viewControllers {
    NSParameterAssert ([viewControllers count] > 0);
    if ((self = [super init])) {
        self.viewControllers = [viewControllers copy];
//        _selectedIndex = 2;
    }
    return self;
}

- (void)loadView {
    self.view = [UIView new];
    
    self.containerView = [UIView new];
    [self.view addSubview:_containerView];

    _containerView.frame = self.view.bounds;
    _containerView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
}

- (void)viewDidLoad {
    [super viewDidLoad];
//    self.selectedIndex = self.selectedViewController ? self.selectedIndex : 0;
    self.selectedIndex = _selectedIndex ? self.selectedIndex : 0;
}

- (void)setSelectedIndex:(NSUInteger)selectedIndex {
    
    if (!self.isViewLoaded) {
        _selectedIndex = selectedIndex;
    }
    
    UIViewController *vc = [_viewControllers objectAtIndex:selectedIndex];
    
    if ([self.delegate respondsToSelector:@selector(sandwichController:shouldSelectViewController:atIndex:)]) {
        BOOL enable = [self.delegate sandwichController:self shouldSelectViewController:vc atIndex:selectedIndex];
        if (!enable) {
            return;
        }
    }
    
    // try shood select vc from delegate
    if (self.selectedIndex == selectedIndex && [vc isKindOfClass:[UINavigationController class]]) {
        UINavigationController *nav = (UINavigationController *)vc;
        [nav popToRootViewControllerAnimated:YES];
    }
    
    
    
    [self _transitionToChildViewController:vc];
    _selectedViewController = vc;
    _selectedIndex = selectedIndex;

    if ([self.delegate respondsToSelector:@selector(sandwichController:didSelectViewController:)]) {
        [self.delegate sandwichController:self didSelectViewController:vc];
    }
}

- (void)_transitionToChildViewController:(UIViewController *)toViewController {
    
    UIViewController *fromViewController = ([self.childViewControllers count] > 0 ? self.childViewControllers[0] : nil);
    if (toViewController == fromViewController || ![self isViewLoaded]) {
        return;
    }
    
    UIView *toView = toViewController.view;
    [toView setTranslatesAutoresizingMaskIntoConstraints:YES];
    toView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    toView.frame = self.containerView.bounds;
    
    [fromViewController willMoveToParentViewController:nil];
    [self addChildViewController:toViewController];
    
    if (!fromViewController) {
        [self.containerView addSubview:toViewController.view];
        [toViewController didMoveToParentViewController:self];
        return;
    }
    
    // animate
    
    id<UIViewControllerAnimatedTransitioning>animator = nil;
    if ([self.animatorDelegate respondsToSelector:@selector(sandwichController:animationControllerForTransitionFromViewController:toViewController:)]) {
        animator = [self.animatorDelegate sandwichController:self animationControllerForTransitionFromViewController:fromViewController toViewController:toViewController];
    }
    
    if (!animator) {
        [self.containerView addSubview:toViewController.view];
        [fromViewController.view removeFromSuperview];
        [fromViewController removeFromParentViewController];
        [toViewController didMoveToParentViewController:self];
        return;
    }
    
    ZATransitionContext *transitionContext = [[ZATransitionContext alloc] initWithFromViewController:fromViewController
                                                                                    toViewController:toViewController];
    transitionContext.animated = YES;
    transitionContext.interactive = NO;
    transitionContext.completionBlock = ^(BOOL didComplete) {
        [fromViewController.view removeFromSuperview];
        [fromViewController removeFromParentViewController];
        [toViewController didMoveToParentViewController:self];
        
        if ([animator respondsToSelector:@selector (animationEnded:)]) {
            [animator animationEnded:didComplete];
        }
        
//        if ([self.delegate respondsToSelector:@selector(sandwichController:didSelectViewController:)]) {
//            [self.delegate sandwichController:self didSelectViewController:toViewController];
//        }
    };
    
    [animator animateTransition:transitionContext];
}

- (BOOL)automaticallyForwardAppearanceAndRotationMethodsToChildViewControllers {
    return YES;
}

#pragma mark -

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

@end
