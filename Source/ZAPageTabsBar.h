//
//  ZAPageTabsBar.h
//  Pods
//
//  Created by ZartArn on 22.11.17.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@protocol ZAPageTabsBarDelegate;

@interface ZAPageTabsBar : NSObject

@property (strong, nonatomic) UICollectionView *collectionView;
@property (strong, nonatomic) UIView *barView;
@property (strong, nonatomic) NSArray *items;
@property (strong, nonatomic) NSArray *iconNames;

@property (weak, nonatomic) id<ZAPageTabsBarDelegate> delegate;

@property (nonatomic) NSUInteger selectedIndex;

- (void)setItems:(NSArray *)items iconNames:(NSArray *)names;


- (void)configure;


- (void)moveToIndex:(NSInteger)toIndex;

- (void)moveFromIndex:(NSInteger)fromIndex
              toIndex:(NSInteger)toIndex
           percentage:(CGFloat)percentage
         indexChanged:(BOOL)indexChanged;

@end




@protocol ZAPageTabsBarDelegate <NSObject>

- (void)pageTabsBar:(ZAPageTabsBar *)pageTabsBar didSelectItemAtIndex:(NSUInteger)index;

@end
