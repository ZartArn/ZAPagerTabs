//
//  ZAPageTabsViewController.m
//  MTabs
//
//  Created by ZartArn on 02.10.17.
//  Copyright © 2017 ZartArn. All rights reserved.
//

#import "ZAPageTabsViewController.h"

typedef NS_ENUM(NSInteger, ZAPageTabsSwipeDirectionType) {
    ZAPageTabsSwipeDirectionLeft,
    ZAPageTabsSwipeDirectionRight,
    ZAPageTabsSwipeDirectionNone
};

@interface ZZIndicatorInfo : NSObject

@property (nonatomic) NSInteger fromIndex;
@property (nonatomic) NSInteger toIndex;
@property (nonatomic) CGFloat progress;
@property (nonatomic) BOOL indexChanged;

@end

@implementation ZZIndicatorInfo
@end

@interface ZAPageTabsViewController ()

@property (strong, nonatomic) UIScrollView *containerView;
@property (strong, nonatomic) ZAPageTabsBar *pageTabBar;

@property (nonatomic) CGSize lastSize;
@property (nonatomic) CGFloat lastOffsetX;
@property (nonatomic) NSUInteger preSelectedIndex;
@property (nonatomic) BOOL shouldUpdateIndicator;

@property (nonatomic) ZAPageTabsSwipeDirectionType swipeDirection;
@property (strong, nonatomic) NSArray *tempViewControllersForJumping;

@end


@implementation ZAPageTabsViewController

- (instancetype)init {
    if (self = [super init]) {
        // tab bar
        self.pageTabBar = [[ZAPageTabsBar alloc] init];
        [self defaultConfigure];
    }
    return self;
}

- (instancetype)initWithStyle:(ZAPageTabsBarStyle *)style {
    if (self = [super init]) {
        // tab bar
        self.pageTabBar = [[ZAPageTabsBar alloc] init];
        [self defaultConfigure];
        self.pageTabBar.style = style;
    }
    return self;
}

- (void)defaultConfigure {
    // tabbar height
    _barHeight = 44.f;
    // bounces
    _bounces = YES;
}

#pragma mark - life cycle

- (void)loadView {
    
    CGRect rect;
    rect = [UIScreen mainScreen].bounds;
    
    UIView *aView = [[UIView alloc] initWithFrame:rect];
    self.view = aView;
    
    // tab bar
    [self.pageTabBar configure];
    self.pageTabBar.delegate = self;
    
    
    // container
    self.containerView = [[UIScrollView alloc] init];
    
    // --
    
    [aView addSubview:self.pageTabBar.barView];
    [aView addSubview:_containerView];

    self.pageTabBar.barView.translatesAutoresizingMaskIntoConstraints = NO;
    self.containerView.translatesAutoresizingMaskIntoConstraints = NO;

    [self.pageTabBar.barView.topAnchor constraintEqualToAnchor:aView.topAnchor];
    [self.pageTabBar.barView.widthAnchor constraintEqualToAnchor:aView.widthAnchor];
    [self.pageTabBar.barView.heightAnchor constraintEqualToConstant:_barHeight];
    [self.pageTabBar.barView.leftAnchor constraintEqualToAnchor:aView.leftAnchor];
    [self.pageTabBar.barView.rightAnchor constraintEqualToAnchor:aView.rightAnchor];

    [self.containerView.topAnchor constraintEqualToAnchor:self.pageTabBar.barView.bottomAnchor];
    [self.containerView.widthAnchor constraintEqualToAnchor:aView.widthAnchor];
    [self.containerView.leftAnchor constraintEqualToAnchor:aView.leftAnchor];
    [self.containerView.rightAnchor constraintEqualToAnchor:aView.rightAnchor];
    [self.containerView.bottomAnchor constraintEqualToAnchor:aView.bottomAnchor];
    
    
    // --
    
    _containerView.bounces = _bounces;
    _containerView.alwaysBounceHorizontal = YES;
    _containerView.alwaysBounceVertical = NO;
    _containerView.scrollsToTop = NO;
    _containerView.showsVerticalScrollIndicator = NO;
    _containerView.showsHorizontalScrollIndicator = NO;
    _containerView.pagingEnabled = YES;
    
    _containerView.delegate = self;
    
    _containerView.backgroundColor = self.backgroundColor ?: [UIColor whiteColor];
    [aView addSubview:_containerView];

    if ([self.containerView respondsToSelector:@selector(contentInsetAdjustmentBehavior)]) {
        [self.containerView performSelector:@selector(contentInsetAdjustmentBehavior) withObject:@(2)];
    } else {
        self.automaticallyAdjustsScrollViewInsets = NO;
    }

    // other configure
    _selectedIndex = 0;
    _preSelectedIndex = 0;
    _shouldUpdateIndicator = YES;
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
    }
    
    // tab bar
    if (self.infoItems && self.infoItems.count == self.viewControllers.count) {
        self.pageTabBar.items = self.infoItems;
    } else {
        NSArray *titles = [self.viewControllers valueForKeyPath:@"title"];
        NSMutableArray *infoItems = [NSMutableArray array];
        
        for (NSInteger i = 0; i < self.viewControllers.count; i++) {
            ZAPageTabIndicatorInfo *info = [ZAPageTabIndicatorInfo new];
            info.title = [titles[i] isEqual:[NSNull null]] ? nil : titles[i];
            [infoItems addObject:info];
        }
        self.pageTabBar.items = [infoItems copy];
    }
    
    // other
    _lastSize = CGSizeZero;
    _lastOffsetX = 0;
    
    NSIndexPath *path = [NSIndexPath indexPathForItem:0 inSection:0];
    [self.pageTabBar.collectionView selectItemAtIndexPath:path animated:YES scrollPosition:UICollectionViewScrollPositionNone];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if (_selectedIndex != _preSelectedIndex) { // ?
        [self moveToViewControllerAtIndex:_preSelectedIndex];
    }
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    [self updateIfNeeded];
}

#pragma mark - upadate

- (void)updateIfNeeded {
    if (self.isViewLoaded && !CGSizeEqualToSize(_lastSize, _containerView.bounds.size)) {
        [self updateContent];
    }
}

- (void)updateContent {
    
    if (_lastSize.width != _containerView.bounds.size.width) {
        self.containerView.contentOffset = (CGPoint){.x = [self pageOffsetForChildAtIndex:_selectedIndex], .y = 0.f};
    }
    _lastSize = self.containerView.bounds.size;
    
    NSArray *pagerControllers = self.tempViewControllersForJumping ?: self.viewControllers;
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
    NSInteger oldIndex = _selectedIndex;
    
    NSInteger virtualPage = [self virtualPageForContentOffset:self.containerView.contentOffset.x];
    NSInteger newIndex   = [self pageForVirtualPage:virtualPage]; // in bounds
    
    BOOL indexChanged = oldIndex != newIndex;
    _selectedIndex = _preSelectedIndex = newIndex;
    
    
    if (_shouldUpdateIndicator) {
        ZZIndicatorInfo *indicatorInfo = [self prepareIndicator:virtualPage indexChanged:indexChanged];
        [self updateIndicatorFromIndex:indicatorInfo.fromIndex
                               toIndex:indicatorInfo.toIndex
                    progressPercentage:indicatorInfo.progress
                          indexChanged:indicatorInfo.indexChanged];
        
        [self didUpdateIndicatorFromIndex:indicatorInfo.fromIndex
                                  toIndex:indicatorInfo.toIndex
                       progressPercentage:indicatorInfo.progress indexChanged:indicatorInfo.indexChanged];
    }
}

- (ZZIndicatorInfo *)prepareIndicator:(NSInteger)virtualPage
                         indexChanged:(BOOL)indexChanged {
    
    NSInteger cnt = (NSInteger)self.viewControllers.count;
    NSInteger fromIdx = _selectedIndex;
    NSInteger toIdx = _selectedIndex;
    CGFloat percentage = [self scrollPercentage];
    
    ZAPageTabsSwipeDirectionType swipeDirection = self.swipeDirection;
    
    if (swipeDirection == ZAPageTabsSwipeDirectionLeft) {
        if (virtualPage > cnt - 1) {
            fromIdx = cnt - 1;
            toIdx = cnt;
        } else {
            if (percentage >= 0.5f) {
                fromIdx = MAX(toIdx - 1, 0);
            } else {
                toIdx = fromIdx + 1;
            }
        }
    } else if (swipeDirection == ZAPageTabsSwipeDirectionRight) {
        if (virtualPage < 0) {
            fromIdx = 0;
            toIdx = -1;
        } else {
            if (percentage > 0.5f) {
                fromIdx = MIN(toIdx + 1, cnt - 1);
            } else {
                toIdx = fromIdx - 1;
            }
        }
    }
    
    ZZIndicatorInfo *info = [ZZIndicatorInfo new];
    info.fromIndex = fromIdx;
    info.toIndex = toIdx;
    info.progress = percentage;
    info.indexChanged = indexChanged;
    
    return info;
}

- (void)updateIndicatorFromIndex:(NSInteger)fromIndex
                         toIndex:(NSInteger)toIndex
              progressPercentage:(CGFloat)percentage
                    indexChanged:(BOOL)indexChanged {
    
    [self.pageTabBar moveFromIndex:fromIndex toIndex:toIndex percentage:percentage indexChanged:indexChanged];
}

// update indicator for subclass override
- (void)didUpdateIndicatorFromIndex:(NSInteger)fromIndex
                         toIndex:(NSInteger)toIndex
              progressPercentage:(CGFloat)percentage
                    indexChanged:(BOOL)indexChanged {
    // can override
}

#pragma mark - moveTo

- (void)moveToViewControllerAtIndex:(NSInteger)toIndex {
    
    if (!self.isViewLoaded || self.view.window == nil || _selectedIndex == toIndex) {
        return;
    }
    
    _shouldUpdateIndicator = NO;
    if (labs(_selectedIndex - toIndex) > 1) {
        
        NSMutableArray *tmpViewControllers = [self.viewControllers mutableCopy];
        NSInteger fromIndex = _selectedIndex < toIndex ? toIndex - 1 : toIndex + 1;
        [tmpViewControllers exchangeObjectAtIndex:fromIndex withObjectAtIndex:_selectedIndex];
        self.tempViewControllersForJumping = [tmpViewControllers copy];

        CGPoint offsetA = (CGPoint){[self pageOffsetForChildAtIndex:fromIndex], 0};
        [self.containerView setContentOffset:offsetA animated:NO];
        CGPoint offsetB = (CGPoint){[self pageOffsetForChildAtIndex:toIndex], 0};
        [self.containerView setContentOffset:offsetB animated:YES];
        
        [self didUpdateIndicatorFromIndex:fromIndex toIndex:toIndex progressPercentage:1.f indexChanged:YES];
        
    } else {
        CGPoint offset = (CGPoint){[self pageOffsetForChildAtIndex:toIndex], 0};
        [self.containerView setContentOffset:offset animated:YES];
        [self didUpdateIndicatorFromIndex:_selectedIndex toIndex:toIndex progressPercentage:1.f indexChanged:YES];
    }
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (_containerView == scrollView) {
        [self updateContent];
        _lastOffsetX = scrollView.contentOffset.x;
    }
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView {
    if (_containerView == scrollView) {
        self.tempViewControllersForJumping = nil;
        [self updateContent];
        _shouldUpdateIndicator = YES;
    }
}

#pragma mark - ZAPageTabsBarDelegate

- (void)pageTabsBar:(ZAPageTabsBar *)pageTabsBar didSelectItemAtIndex:(NSUInteger)index {
    [self moveToViewControllerAtIndex:index];
    [self.pageTabBar moveToIndex:index];
}

#pragma mark - helpers

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

- (CGFloat) scrollPercentage {
    CGFloat pageWidth = self.containerView.bounds.size.width;
    
    if (self.swipeDirection != ZAPageTabsSwipeDirectionRight) {
        CGFloat mod = fmod(self.containerView.contentOffset.x, pageWidth);
        return mod == 0.0f ? 1.0f : (mod / pageWidth);
    }

    CGFloat mod = 0.f;
    if (self.containerView.contentOffset.x > 0.f) {
        mod = fmod(self.containerView.contentOffset.x, pageWidth);
    } else {
        mod = fmod(self.containerView.contentOffset.x + pageWidth, pageWidth);
    }
    return (1.f - (mod / pageWidth));
}

#pragma mark - lazy

- (ZAPageTabsSwipeDirectionType)swipeDirection {
    if (self.containerView.contentOffset.x > _lastOffsetX) {
        return ZAPageTabsSwipeDirectionLeft;
    }
    if (self.containerView.contentOffset.x < _lastOffsetX) {
        return ZAPageTabsSwipeDirectionRight;
    }
    return ZAPageTabsSwipeDirectionNone;
}

- (void)setBounces:(BOOL)bounces {
    _bounces = bounces;
    if (self.isViewLoaded) {
        self.containerView.bounces = bounces;
    }
}

@end
