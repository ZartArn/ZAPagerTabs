//
//  ZAPageTabsViewController.m
//  MTabs
//
//  Created by ZartArn on 02.10.17.
//  Copyright © 2017 ZartArn. All rights reserved.
//

#import "ZAPageTabsViewController.h"

#define TABBAR_HEIGHT 44.f

@interface ZAPageTabsViewController ()

@property (strong, nonatomic) UIScrollView *containerView;
@property (strong, nonatomic) ZAPageTabsBar *pageTabBar;

@property (nonatomic) CGSize lastContentSize;
@property (nonatomic) CGFloat lastOffsetX;

@end


@implementation ZAPageTabsViewController

- (instancetype)init {
    if (self = [super init]) {
        // tab bar
        self.pageTabBar = [[ZAPageTabsBar alloc] init];
    }
    return self;
}

#pragma mark - life cycle

- (void)loadView {
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    

    
    CGRect rect;
    rect = [UIScreen mainScreen].bounds;
    
    UIView *aView = [[UIView alloc] initWithFrame:rect];
    self.view = aView;
    
    // tab bar
    [self.pageTabBar configure];
    self.pageTabBar.delegate = self;
    CGRect barRect = (CGRect){.size = (CGSize){aView.bounds.size.width, TABBAR_HEIGHT}};
    self.pageTabBar.barView.frame = barRect;
    self.pageTabBar.barView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    [aView addSubview:self.pageTabBar.barView];
    
    // container
    CGRect containerRect = (CGRect){0.f, TABBAR_HEIGHT, aView.bounds.size.width, aView.bounds.size.height - TABBAR_HEIGHT};
    self.containerView = [[UIScrollView alloc] initWithFrame:containerRect];
    _containerView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    
    _containerView.bounces = YES;
    _containerView.alwaysBounceHorizontal = YES;
    _containerView.alwaysBounceVertical = NO;
    _containerView.scrollsToTop = NO;
    _containerView.showsVerticalScrollIndicator = NO;
    _containerView.showsHorizontalScrollIndicator = NO;
    _containerView.pagingEnabled = YES;
    
    _containerView.delegate = self;
    
    _containerView.backgroundColor = [UIColor whiteColor];
    [aView addSubview:_containerView];

    if (@available(iOS 11.0, *)) {
        self.containerView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    } else {
        // Fallback on earlier versions
    }
    _selectedIndex = 0;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    // first child controller
    if (_selectedIndex < [self.viewControllers count]) {
        UIViewController *toController = [self.viewControllers objectAtIndex:_selectedIndex];
        [self addChildViewController:toController];
        toController.view.frame = self.containerView.bounds;
        toController.view.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
        [self.containerView addSubview:toController.view];
        [toController didMoveToParentViewController:self];
//        self.selectedIndex = 0;
    }
    
    NSArray *items = [self.viewControllers valueForKeyPath:@"title"];
    [self.pageTabBar setItems:items iconNames:self.iconNames];;
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self.pageTabBar updateBottomView];
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
    
    // --
//    NSInteger currentIndex = _selectedIndex;
//    NSInteger virtualPage = [self virtualPageForContentOffset:self.containerView.contentOffset.x];
//    NSInteger newCurrentIndex = [self pageForVirtualPage:virtualPage];
//
//    BOOL changeCurrentIndex = newCurrentIndex != currentIndex;
    
    
/*
    BOOL swipeLeftDisrection = self.containerView.contentOffset.x > _lastOffsetX;
    _lastOffsetX = self.containerView.contentOffset.x;
    
    CGFloat percent = [self scrollPercentage:swipeLeftDisrection];
    [self.pageTabBar updatePercentage:percent];
*/
 
//    currentIndex = newCurrentIndex
//    preCurrentIndex = currentIndex
//    let changeCurrentIndex = newCurrentIndex != oldCurrentIndex
    
//    if let progressiveDeledate = self as? PagerTabStripIsProgressiveDelegate, pagerBehaviour.isProgressiveIndicator {
//        
//        let (fromIndex, toIndex, scrollPercentage) = progressiveIndicatorData(virtualPage)
//        progressiveDeledate.updateIndicator(for: self, fromIndex: fromIndex, toIndex: toIndex, withProgressPercentage: scrollPercentage, indexWasChanged: changeCurrentIndex)
//    } else {
//        delegate?.updateIndicator(for: self, fromIndex: min(oldCurrentIndex, pagerViewControllers.count - 1), toIndex: newCurrentIndex)
//    }
    
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (_containerView == scrollView) {
        [self updateContent];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    CGPoint center = (CGPoint){scrollView.contentOffset.x + (scrollView.frame.size.width / 2), (scrollView.frame.size.height / 2)};
    NSInteger pageIdx = center.x / _containerView.bounds.size.width;
    self.selectedIndex = pageIdx;
}

#pragma mark - ZAPageTabsBarDelegate

- (void)pageTabsBar:(ZAPageTabsBar *)pageTabsBar didSelectItemAtIndex:(NSUInteger)index {
    CGFloat offset = [self pageOffsetForChildAtIndex:index];
    [self.containerView setContentOffset:(CGPoint){offset, 0} animated:YES];
    self.selectedIndex = index;
    [self updateContent];
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

- (NSInteger)virtualPageForContentOffset:(CGFloat)contentOffset {
    CGFloat pageWidth = self.containerView.bounds.size.width;
    return (NSInteger)((contentOffset + 1.5 * pageWidth) / pageWidth) - 1;
}

- (NSInteger)pageForVirtualPage:(NSInteger)virtualPage {
    if (virtualPage < 0) {
        return 0;
    }
    if (virtualPage > self.viewControllers.count - 1) {
        return (self.viewControllers.count - 1);
    }
    return virtualPage;
}

- (CGFloat)scrollPercentage:(BOOL)isLeftDirection {
    CGFloat pageWidth = self.containerView.bounds.size.width;
    NSInteger i = ((int)floorf(self.containerView.contentOffset.x) % (int)floorf(pageWidth));
    if (isLeftDirection) {
        CGFloat percent = i == 0 ? 1.f : i / pageWidth;
        NSLog(@"percent :: %@", @(percent));
        return percent;
    } else {
        CGFloat percent = i / pageWidth;
        NSLog(@"percent :: %@", @(percent));
        return percent;
    }
}

#pragma mark - lazy

- (void)setSelectedIndex:(NSUInteger)selectedIndex {
//    if (_selectedIndex != selectedIndex) {
        _selectedIndex = selectedIndex;
        self.pageTabBar.selectedIndex = selectedIndex;
//    }
}

@end
