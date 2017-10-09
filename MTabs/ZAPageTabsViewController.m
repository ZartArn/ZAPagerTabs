//
//  ZAPageTabsViewController.m
//  MTabs
//
//  Created by ZartArn on 02.10.17.
//  Copyright © 2017 ZartArn. All rights reserved.
//

#import "ZAPageTabsViewController.h"

@interface ZAPageTabsViewController ()

@property (strong, nonatomic) UIScrollView *containerView;
@property (nonatomic) CGSize lastContentSize;

@end

@implementation ZAPageTabsViewController

- (void)loadView {
    UIView *aView = [[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    self.view = aView;
    
    self.containerView = [[UIScrollView alloc] initWithFrame:aView.bounds];
    _containerView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    
    _containerView.bounces = YES;
    _containerView.alwaysBounceHorizontal = YES;
    _containerView.alwaysBounceVertical = NO;
    _containerView.scrollsToTop = NO;
    _containerView.showsVerticalScrollIndicator = NO;
    _containerView.showsHorizontalScrollIndicator = NO;
    _containerView.pagingEnabled = YES;
    
    _containerView.delegate = self;
    
    _containerView.backgroundColor = [UIColor yellowColor];
    [aView addSubview:_containerView];
}

- (void)viewDidLoad {
    [super viewDidLoad];

    // first child controller
    if (_selectedIndex < self.viewControllers.count) {
        UIViewController *toController = [self.viewControllers objectAtIndex:_selectedIndex];
        [self addChildViewController:toController];
        toController.view.frame = self.containerView.bounds;
        toController.view.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
        [self.containerView addSubview:toController.view];
        [toController didMoveToParentViewController:self];
        
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    [self updateIfNeeded];
}



- (void)updateContent {
    
    if (_lastContentSize.width != _containerView.bounds.size.width) {
        self.containerView.contentOffset = (CGPoint){.x = [self pageOffsetForChildAtIndex:_selectedIndex], .y = 0.f};
    }
    self.lastContentSize = self.containerView.bounds.size;
    

    NSArray *pagerControllers = self.viewControllers;
    self.containerView.contentSize = (CGSize){
        .width = _containerView.bounds.size.width * pagerControllers.count,
        .height = _containerView.bounds.size.height
    };
    

    [pagerControllers enumerateObjectsUsingBlock:^(UIViewController *childController, NSUInteger idx, BOOL * _Nonnull stop) {
        CGFloat pageOffset = [self pageOffsetForChildAtIndex:idx];
        if (fabs(_containerView.contentOffset.x - pageOffset) < _containerView.bounds.size.width) {
            // update frame
            childController.view.frame = (CGRect){
                .origin = (CGPoint){.x = pageOffset, .y = 0},
                .size = _containerView.bounds.size
            };
            childController.view.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
            // add child controller if needed
            if (childController.parentViewController == nil) {
                [self addChildViewController:childController];
                [_containerView addSubview:childController.view];
                [childController didMoveToParentViewController:self];
            }
        } else {
            // remove from parent if needed
            if (childController.parentViewController != nil) {
                [childController willMoveToParentViewController:nil];
                [childController.view removeFromSuperview];
                [childController removeFromParentViewController];
            }
        }
    }];
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (_containerView == scrollView) {
        [self updateContent];
    }
}

#pragma mark - helpers

- (void)updateIfNeeded {
    if (self.isViewLoaded && !CGSizeEqualToSize(_lastContentSize, _containerView.bounds.size)) {
        [self updateContent];
    }
}

- (CGFloat)pageOffsetForChildAtIndex:(NSInteger)index {
    return ((float)index * _containerView.bounds.size.width);
}

@end
