//
//  ZAPageTabsBar.m
//  Pods
//
//  Created by ZartArn on 22.11.17.
//

#import "ZAPageTabsBar.h"
#import "ZAPageTabsCell.h"
#import "Typography.h"
#import "StyleHelper.h"

#define TITLE_INSETS (UIEdgeInsets){0.f, 5.f, 0.f, 5.f}

@interface ZAPageTabsBar() <UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout>

@property (strong, nonatomic) NSDictionary *cachedCellWidths;
@property (strong, nonatomic) UIView *bView;

@property (strong, nonatomic) UIColor *normalColor;
@property (strong, nonatomic) UIColor *activeColor;

@property (nonatomic) CGFloat bHeight;

@end

@implementation ZAPageTabsBar

- (instancetype)init {
    if (self = [super init]) {
    }
    return self;
}

- (void)configureViews {
    
    // style
    _bHeight = 1.5f;
    self.normalColor = [Typography mainColor];
    self.activeColor = [Typography activeColor];
    
    // bar
    self.barView = [UIView new];
    
    // collection
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    layout.minimumLineSpacing = 0.f;
    layout.minimumInteritemSpacing = 0.f;
    
    self.collectionView = [[UICollectionView alloc] initWithFrame:self.barView.bounds collectionViewLayout:layout];
    self.collectionView.backgroundColor = [UIColor whiteColor];
    self.collectionView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    self.collectionView.showsHorizontalScrollIndicator = NO;
    
    [self.barView addSubview:self.collectionView];

    // bottom view
    self.bView = [UIView new];
    self.bView.backgroundColor = [Typography activeColor];
    self.bView.layer.zPosition = 9999;
    
    [self.collectionView addSubview:self.bView];
}

- (void)configure {
    [self configureViews];
    self.collectionView.dataSource = self;
    self.collectionView.delegate = self;
    // ! collectionView.delegate set NOT HERE
    [self.collectionView registerClass:[ZAPageTabsCell class] forCellWithReuseIdentifier:@"Cell"];
}

#pragma mark - lazy

- (void)setItems:(NSArray *)items iconNames:(NSArray *)names {    
        self.items = items;
        self.iconNames = names;
        [self calculateWidths];
        [self.collectionView reloadData]; // ?
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
                                                                              NSFontAttributeName : [Typography regularFontWithSize:18.f]
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
    NSString *icon = [self.iconNames objectAtIndex:indexPath.row];
    cell.titleLabel.text = title;
    cell.icon.highlightedImage = [StyleHelper loadImage:icon];
    cell.icon.image = nil;
    
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

#pragma mark - move

- (void)moveToIndex:(NSInteger)toIndex {
    _selectedIndex = toIndex;
    [self updateSelectedBarPosition];
}

- (void)moveFromIndex:(NSInteger)fromIndex
              toIndex:(NSInteger)toIndex
           percentage:(CGFloat)percentage
         indexChanged:(BOOL)indexChanged {
    
    
    NSInteger numberOfItems = [self.collectionView numberOfItemsInSection:0];
    
    // calculate currentIndex
    if (percentage > 0.5f) {
        _selectedIndex = MAX(0, MIN(toIndex, numberOfItems - 1));
    } else {
        _selectedIndex = fromIndex;
    }
    
    // calculate  fromFrame
    NSIndexPath *fromIndexPath = [NSIndexPath indexPathForItem:fromIndex inSection:0];
    CGRect fromFrame = [self.collectionView layoutAttributesForItemAtIndexPath:fromIndexPath].frame;
    
    // calculate toFrame
    CGRect toFrame;
    if (toIndex < 0 || toIndex > numberOfItems - 1) {
        if (toIndex < 0) {
            NSIndexPath *toIndexPath = [NSIndexPath indexPathForItem:0 inSection:0];
            UICollectionViewLayoutAttributes *attr = [self.collectionView layoutAttributesForItemAtIndexPath:toIndexPath];
            toFrame = CGRectOffset(attr.frame, -attr.frame.size.width, 0.f);
        } else {
            NSIndexPath *toIndexPath = [NSIndexPath indexPathForItem:(numberOfItems - 1) inSection:0];
            UICollectionViewLayoutAttributes *attr = [self.collectionView layoutAttributesForItemAtIndexPath:toIndexPath];
            toFrame = CGRectOffset(attr.frame, attr.frame.size.width, 0.f);
        }
    } else {
        NSIndexPath *toIndexPath = [NSIndexPath indexPathForItem:toIndex inSection:0];
        toFrame = [self.collectionView layoutAttributesForItemAtIndexPath:toIndexPath].frame;
    }
    
    // calculate indicator frame
    CGRect targetFrame = fromFrame;
    
    targetFrame.origin.x   += (toFrame.origin.x - fromFrame.origin.x) * percentage;
    targetFrame.origin.y    = self.barView.frame.size.height - _bHeight;
    targetFrame.size.width += (toFrame.size.width - fromFrame.size.width) * percentage;
    targetFrame.size.height = _bHeight;
    
    self.bView.frame = targetFrame;
    
    // calculate scroll content offset
    CGPoint targetOffset = CGPointZero;
    
    if (self.collectionView.contentSize.width > self.barView.frame.size.width) {
        CGPoint toContentOffset     = [self contentOffsetForCellWithFrame:toFrame atIndex:toIndex];
        CGPoint fromContentOffset   = [self contentOffsetForCellWithFrame:fromFrame atIndex:fromIndex];
    
        targetOffset = (CGPoint){
            .x = fromContentOffset.x + (toContentOffset.x - fromContentOffset.x) * percentage,
            .y = 0.f
        };
    }
    
    [self.collectionView setContentOffset:targetOffset animated:NO];
}

- (void)updateSelectedBarPosition {
    CGRect selectedBarFrame = self.bView.frame;
    
    NSIndexPath *selectedIndexPath = [NSIndexPath indexPathForItem:_selectedIndex inSection:0];
    UICollectionViewLayoutAttributes *attr = [self.collectionView layoutAttributesForItemAtIndexPath:selectedIndexPath];
    CGRect selectedCellFrame = attr.frame;

    [self updateContentOffsetToFrame:selectedCellFrame toIndex:_selectedIndex];
    
    selectedBarFrame.origin.x = selectedCellFrame.origin.x;
    selectedBarFrame.size.width = selectedCellFrame.size.width;
    
    [UIView animateWithDuration:0.3f animations:^{
        self.bView.frame = selectedBarFrame;
    }];
}


- (void)updateContentOffsetToFrame:(CGRect)toFrame toIndex:(NSInteger)toIndex {
    CGPoint targetOffset = CGPointZero;
    if (self.collectionView.contentSize.width > self.collectionView.frame.size.width) {
        targetOffset = [self contentOffsetForCellWithFrame:toFrame atIndex:toIndex];
    }
    [self.collectionView setContentOffset:targetOffset animated:YES];
}


- (CGPoint)contentOffsetForCellWithFrame:(CGRect)cellFrame atIndex:(NSInteger)index {
    CGFloat alignOffset = (self.collectionView.frame.size.width - cellFrame.size.width) * 0.5f;
    
    CGFloat tempDx = MAX(0, cellFrame.origin.x - alignOffset);
    CGFloat dx = MIN(tempDx, self.collectionView.contentSize.width - self.barView.frame.size.width);

    return (CGPoint){dx, 0.f};
}


@end
