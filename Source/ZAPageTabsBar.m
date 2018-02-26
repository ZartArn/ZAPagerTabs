//
//  ZAPageTabsBar.m
//  Pods
//
//  Created by ZartArn on 22.11.17.
//

#import "ZAPageTabsBar.h"
#import "ZAPageTabsCell.h"

#define TITLE_INSETS (UIEdgeInsets){0.f, 5.f, 0.f, 5.f}
#define MIN_WIDTH 50.f

@implementation ZAPageTabsBarStyle
@end

@implementation ZAPageTabIndicatorInfo
@end


@interface ZAPageTabsBar() <UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout>

@property (strong, nonatomic) NSDictionary *cachedCellWidths;
@property (strong, nonatomic) UIView *indicatorView;

@property (strong, nonatomic) UIColor *normalColor;
@property (strong, nonatomic) UIColor *activeColor;

@property (nonatomic) CGFloat indicatorHeight;

@end

@implementation ZAPageTabsBar

- (instancetype)init {
    if (self = [super init]) {
    }
    return self;
}

- (ZAPageTabsBarStyle *)defaultStyle {
    
    ZAPageTabsBarStyle *style = [ZAPageTabsBarStyle new];
    
    style.backgroundColor   = [UIColor whiteColor];
    style.indicatorHeight   = 1.5f;
    style.indicatorColor    = self.collectionView.tintColor;
    style.normalColor       = [UIColor blackColor];
    style.selectedColor     = [UIColor blackColor];
    
    return style;
}

- (void)applyStyle:(ZAPageTabsBarStyle *)style {
    
    // background color
    self.collectionView.backgroundColor = style.backgroundColor ?: [UIColor whiteColor];
    
    // indicator height
    _indicatorHeight = style.indicatorHeight > 0 ?: 1.5f;
    
    // indicator color
    self.indicatorView.backgroundColor = style.indicatorColor ?: self.collectionView.tintColor;
    
    // text normal color
    self.normalColor = style.normalColor ?: [UIColor blackColor];
    
    // text selected color
    self.activeColor = style.selectedColor ?: [UIColor blackColor];
}

- (void)configureViews {
    
    // bar
    self.barView = [UIView new];
    
    // collection
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    layout.minimumLineSpacing = 0.f;
    layout.minimumInteritemSpacing = 0.f;
    
    self.collectionView = [[UICollectionView alloc] initWithFrame:self.barView.bounds collectionViewLayout:layout];
    self.collectionView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    self.collectionView.showsHorizontalScrollIndicator = NO;
    
    [self.barView addSubview:self.collectionView];

    // bottom view
    self.indicatorView = [UIView new];
    self.indicatorView.backgroundColor = self.indicatorView.tintColor;
    self.indicatorView.layer.zPosition = 9999;
    
    [self.collectionView addSubview:self.indicatorView];
    
    // style
    if (self.style) {
        [self applyStyle:self.style];
    } else {
        [self applyStyle:[self defaultStyle]];
    }
}

- (void)configure {
    [self configureViews];
    self.collectionView.dataSource = self;
    self.collectionView.delegate = self;
    // ! collectionView.delegate set NOT HERE
    if (self.style.cellClass) {
        [self.collectionView registerClass:self.style.cellClass forCellWithReuseIdentifier:@"Cell"];
    } else {
        [self.collectionView registerClass:[ZAPageTabsCell class] forCellWithReuseIdentifier:@"Cell"];
    }
}

#pragma mark - lazy

- (void)setItems:(NSArray *)items {
        _items = items;
        [self calculateWidths];
        [self.collectionView reloadData]; // ?
}

#pragma mark -

- (void)calculateWidths {
    NSMutableDictionary *cached = [NSMutableDictionary dictionaryWithCapacity:self.items.count];
    
    UICollectionViewCell <ZAPageTabsCellProtocol> *tmpCell;
    if (self.style.cellClass) {
        tmpCell = [[self.style.cellClass alloc] initWithFrame:CGRectZero];
    } else {
        tmpCell = [[ZAPageTabsCell alloc] initWithFrame:CGRectZero];
    }
    UIFont *titleFont = tmpCell.titleLabel.font;
    
    [self.items enumerateObjectsUsingBlock:^(ZAPageTabIndicatorInfo *indicatorInfo, NSUInteger idx, BOOL * _Nonnull stop) {
        CGFloat wordWidth;
        
        if (indicatorInfo.title == nil) {
            
            wordWidth = MIN_WIDTH;
            
        } else {
        
            NSAttributedString *ss =[[NSAttributedString alloc] initWithString:indicatorInfo.title
                                                                    attributes: @{
                                                                                  NSFontAttributeName : titleFont
                                                                                  }];
            
            CGRect titleRect = [ss boundingRectWithSize:(CGSize){CGFLOAT_MAX, 44.f}
                                                options:NSStringDrawingUsesFontLeading|NSStringDrawingUsesLineFragmentOrigin
                                                context:nil];
            wordWidth = titleRect.size.width;
        }
        
        double w = ceil(wordWidth) + TITLE_INSETS.left + TITLE_INSETS.right;
        [cached setObject:@(w) forKey:[NSIndexPath indexPathForRow:idx inSection:0]];
    }];
    
    self.cachedCellWidths = [cached copy];
    NSLog(@"%@", self.cachedCellWidths);
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
    NSAssert([aCell conformsToProtocol:@protocol(ZAPageTabsCellProtocol)], @"cell must confirm protocol ZAPageTabsCellProtocol");
    UICollectionViewCell<ZAPageTabsCellProtocol> *cell = (UICollectionViewCell<ZAPageTabsCellProtocol> *)aCell;
    
    ZAPageTabIndicatorInfo *indicatorInfo = [self.items objectAtIndex:indexPath.row];
    cell.titleLabel.text        = indicatorInfo.title;
    cell.icon.highlightedImage  = indicatorInfo.selectedImage;
    cell.icon.image             = indicatorInfo.image;
}

#pragma mark - UICollectionViewDelegateFlowLayout

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    NSArray *cachedWidthValues = [self.cachedCellWidths allValues];
    CGFloat allWidths = [[cachedWidthValues valueForKeyPath:@"@sum.self"] doubleValue];
    
    if (allWidths > collectionView.bounds.size.width) {
        return (CGSize){[self.cachedCellWidths[indexPath] doubleValue], collectionView.bounds.size.height};
    }
    
    CGFloat maxWidth = [[cachedWidthValues valueForKeyPath:@"@max.self"] doubleValue];
    CGFloat w = (collectionView.bounds.size.width / self.items.count);
    if (w > maxWidth) {
        return (CGSize){w, collectionView.bounds.size.height};
    }
    
    // streched widths
    CGFloat addSpacing = (collectionView.bounds.size.width - allWidths) / (float)self.items.count;
    CGSize size = (CGSize){
                        [self.cachedCellWidths[indexPath] doubleValue] + addSpacing,
                        collectionView.bounds.size.height
                    };
//
//    NSLog(@"collectionView size :: %@", NSStringFromCGSize(collectionView.frame.size));
//    NSLog(@"cell size :: %@", NSStringFromCGSize(size));
//    NSLog(@"\n\n");
    
    return size;
}

#pragma mark - UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)aCell forItemAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"will display cell :: %@", indexPath);
    
    NSAssert([aCell conformsToProtocol:@protocol(ZAPageTabsCellProtocol)], @"cell must confirm protocol ZAPageTabsCellProtocol");
    UICollectionViewCell<ZAPageTabsCellProtocol> *cell = (UICollectionViewCell<ZAPageTabsCellProtocol> *)aCell;

    if (!self.style.cellClass) {
        cell.titleLabel.textColor = self.normalColor;
        cell.titleLabel.highlightedTextColor = self.activeColor;
    }
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    [self.delegate pageTabsBar:self didSelectItemAtIndex:indexPath.row];
}

#pragma mark - move

- (void)moveToIndex:(NSInteger)toIndex {
    _selectedIndex = toIndex;
    [self updateSelectedBarPositionToIndex:toIndex];
}

- (void)moveFromIndex:(NSInteger)fromIndex
              toIndex:(NSInteger)toIndex
           percentage:(CGFloat)percentage
         indexChanged:(BOOL)indexChanged {
    
//    NSLog(@"%@ :: %@", @(fromIndex), @(toIndex));
    
    NSInteger numberOfItems = [self.collectionView numberOfItemsInSection:0];
    
    if (indexChanged) {
        _selectedIndex = toIndex;
        NSIndexPath *path = [NSIndexPath indexPathForItem:_selectedIndex inSection:0];
        [self.collectionView selectItemAtIndexPath:path animated:NO scrollPosition:UICollectionViewScrollPositionNone];
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
    targetFrame.origin.y    = self.barView.frame.size.height - _indicatorHeight;
    targetFrame.size.width += (toFrame.size.width - fromFrame.size.width) * percentage;
    targetFrame.size.height = _indicatorHeight;
    
    self.indicatorView.frame = targetFrame;
    
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

- (void)updateSelectedBarPositionToIndex:(NSInteger)toIndex {
    CGRect selectedBarFrame = self.indicatorView.frame;
    
    NSIndexPath *selectedIndexPath = [NSIndexPath indexPathForItem:toIndex inSection:0];
    UICollectionViewLayoutAttributes *attr = [self.collectionView layoutAttributesForItemAtIndexPath:selectedIndexPath];
    CGRect selectedCellFrame = attr.frame;

    [self updateContentOffsetToFrame:selectedCellFrame toIndex:_selectedIndex];
    
    selectedBarFrame.origin.x = selectedCellFrame.origin.x;
    selectedBarFrame.size.width = selectedCellFrame.size.width;
    
    [UIView animateWithDuration:0.3f animations:^{
        self.indicatorView.frame = selectedBarFrame;
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
