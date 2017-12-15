//
//  ZAPageTabsBar.m
//  Pods
//
//  Created by ZartArn on 22.11.17.
//

#import "ZAPageTabsBar.h"
#import "ZAPageTabsCell.h"
//#import "Typography.h"

#define TITLE_INSETS (UIEdgeInsets){0.f, 5.f, 0.f, 5.f}

@interface ZAPageTabsBar() <UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout>

@property (strong, nonatomic) UICollectionView *collectionView;
@property (strong, nonatomic) NSDictionary *cachedCellWidths;
@property (strong, nonatomic) UIView *bView;

@property (strong, nonatomic) UIColor *normalColor;
@property (strong, nonatomic) UIColor *activeColor;

@property (nonatomic) CGFloat bHeight;

@end

@implementation ZAPageTabsBar

- (instancetype)init {
    if (self = [super init]) {
        [self configureViews];
        [self configure];
    }
    return self;
}

- (void)configureViews {
    
    // style
    _bHeight = 2.f;
    self.normalColor = [UIColor orangeColor];
    self.activeColor = [UIColor purpleColor];
    
    // bar
    self.barView = [UIView new];
    
    // collection
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    layout.minimumLineSpacing = 0.f;
    layout.minimumInteritemSpacing = 0.f;
    
    self.collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
    self.collectionView.backgroundColor = [UIColor whiteColor];
    self.collectionView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    self.collectionView.showsHorizontalScrollIndicator = NO;
    
    [self.barView addSubview:self.collectionView];

    // bottom view
    self.bView = [UIView new];
    self.bView.backgroundColor = [UIColor redColor];
    [self.barView addSubview:self.bView];
}

- (void)configure {
    self.collectionView.dataSource = self;
    self.collectionView.delegate = self;
    [self.collectionView registerClass:[ZAPageTabsCell class] forCellWithReuseIdentifier:@"Cell"];
}

#pragma mark - lazy

- (void)setItems:(NSArray *)items {
    if (_items != items) {
        _items = items;
        [self calculateWidths];
        [self.collectionView reloadData];
        if (_selectedIndex >= items.count) {
            _selectedIndex = 0;
        }
        [self.collectionView selectItemAtIndexPath:[NSIndexPath indexPathForRow:_selectedIndex inSection:0]
                                          animated:YES
                                    scrollPosition:UICollectionViewScrollPositionCenteredHorizontally];
    }
}

- (void)setSelectedIndex:(NSUInteger)selectedIndex {
    if (_selectedIndex != selectedIndex) {
        _selectedIndex = selectedIndex;
        [self.collectionView selectItemAtIndexPath:[NSIndexPath indexPathForRow:selectedIndex inSection:0]
                                          animated:YES
                                    scrollPosition:UICollectionViewScrollPositionCenteredHorizontally];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self updateBottomView];
        });
    } else {
        [self updateBottomView];
    }
}

#pragma mark -

- (void)calculateWidths {
    NSMutableDictionary *cached = [NSMutableDictionary dictionaryWithCapacity:self.items.count];
    [self.items enumerateObjectsUsingBlock:^(NSString *title, NSUInteger idx, BOOL * _Nonnull stop) {
//        NSAttributedString *s = [[NSAttributedString alloc] initWithString:title
//                                                                attributes:@{
//                                                                             NSFontAttributeName : [UIFont systemFontOfSize:16.f]
//                                                                             }];
//        CGSize titleSize = [title sizeWithAttributes:@{NSFontAttributeName:[Typography regularFontWithSize:16.f]}];
        
        NSAttributedString *ss =[[NSAttributedString alloc] initWithString:title
                                                                attributes: @{
                                                                              NSFontAttributeName : [UIFont systemFontOfSize:20.f]
                                                                              }];
        
        CGRect titleRect = [ss boundingRectWithSize:(CGSize){CGFLOAT_MAX, 50.f}
                                               options:NSStringDrawingUsesFontLeading|NSStringDrawingUsesLineFragmentOrigin
                                               context:nil];
        
//        CGSize titleSize = [title boundingRectWithSize:(CGSize){INFINITY, INFINITY}
//                                               options:NSStringDrawingOptions|NSStringDrawingUsesLineFragmentOrigin
//                                            attributes:attributes:@{
//                                                                    NSFontAttributeName : [UIFont systemFontOfSize:16.f]
//                                                                    }
//                                           context:nil];
        double w = ceil(titleRect.size.width) + TITLE_INSETS.left + TITLE_INSETS.right;
        [cached setObject:@(w) forKey:[NSIndexPath indexPathForRow:idx inSection:0]];
    }];
    self.cachedCellWidths = [cached copy];
    NSLog(@"%@", self.cachedCellWidths);
}

#pragma mark - bottomView

- (void)updateBottomView {
    NSLog(@"%s", __FUNCTION__);
    NSIndexPath *indexPath = [NSIndexPath indexPathForItem:_selectedIndex inSection:0];
    UICollectionViewCell *cell = [self.collectionView cellForItemAtIndexPath:indexPath];
    
    CGRect rect = [cell.superview convertRect:cell.frame toView:self.barView];
    
    CGRect newRect;
    if (cell) {
        newRect = (CGRect){
                                        rect.origin.x,
                                        self.barView.bounds.size.height - _bHeight,
                                        rect.size.width,
                                        _bHeight
                                    };
    } else {
        newRect = CGRectZero;
    }
//    NSLog(@"%@", NSStringFromCGRect(newRect));
    
    [UIView animateWithDuration:0.3f animations:^{
        self.bView.frame = newRect;
    }];
}

- (void)updatePercentage:(CGFloat)percent {
    NSLog(@"%s", __FUNCTION__);
    NSInteger nextIdx = MIN(self.items.count - 1, (_selectedIndex + 1));
    NSIndexPath *currentIndexPath = [NSIndexPath indexPathForItem:_selectedIndex inSection:0];
    NSIndexPath *nextIndexPath = [NSIndexPath indexPathForItem:nextIdx inSection:0];
    
    UICollectionViewCell *currentCell = [self.collectionView cellForItemAtIndexPath:currentIndexPath];
    CGRect rect = [currentCell.superview convertRect:currentCell.frame toView:self.barView];
//    UICollectionViewCell *nextCell = [self.collectionView cellForItemAtIndexPath:nextIndexPath];
    
    CGFloat nextWidth = [[self.cachedCellWidths objectForKey:nextIndexPath] floatValue];
    CGFloat dx = nextWidth * percent;

    CGRect newRect = (CGRect){
        rect.origin.x,
        self.barView.bounds.size.height - _bHeight,
        rect.size.width + dx,
        _bHeight
    };
//    NSLog(@"%@", NSStringFromCGRect(newRect));
    
    self.bView.frame = newRect;
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.items.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(nonnull NSIndexPath *)indexPath {
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"Cell" forIndexPath:indexPath];
    [self configureCell:cell forIndexPath:indexPath];
    return cell;
}

- (void)configureCell:(UICollectionViewCell *)aCell forIndexPath:(NSIndexPath *)indexPath {
    NSAssert([aCell isKindOfClass:[ZAPageTabsCell class]], @"cell must be subclass of ZAPageTabsCell class");
    ZAPageTabsCell *cell = (ZAPageTabsCell *)aCell;
    
    NSString *title = [self.items objectAtIndex:indexPath.row];
    cell.titleLabel.text = title;
    
//    [cell configureWithViewModel:[self.viewModel cellViewModelForIndexPath:indexPath]];
}

#pragma mark - UICollectionViewDelegateFlowLayout

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    CGFloat allWidths = [[[self.cachedCellWidths allValues] valueForKeyPath:@"@sum.self"] doubleValue];
    
    if (allWidths > collectionView.bounds.size.width) {
        return (CGSize){[self.cachedCellWidths[indexPath] doubleValue], collectionView.bounds.size.height};
    }
    
    CGFloat w = (collectionView.bounds.size.width / self.items.count);
    CGSize size = (CGSize){w, collectionView.bounds.size.height};
    
    NSLog(@"collectionView size :: %@", NSStringFromCGSize(collectionView.frame.size));
    NSLog(@"cell size :: %@", NSStringFromCGSize(size));
    NSLog(@"\n\n");
    
    return size;
}

#pragma mark - UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    [self.delegate pageTabsBar:self didSelectItemAtIndex:indexPath.row];
}

@end
