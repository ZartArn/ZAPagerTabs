//
//  ZAPageTabsBar.h
//  Pods
//
//  Created by ZartArn on 22.11.17.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@protocol ZAPageTabsBarDelegate;

@interface ZAPageTabsBarStyle : NSObject

/// page tabbar background color
@property (strong, nonatomic) UIColor *backgroundColor;

/// page tabbar line color
@property (strong, nonatomic) UIColor *indicatorColor;

/// page tabbar line height
@property (nonatomic) CGFloat indicatorHeight;

/// page tabbar normal title color, default Black
@property (strong, nonatomic) UIColor *normalColor;

/// page tabbar selected title color, default Black
@property (strong, nonatomic) UIColor *selectedColor;

/// page tabbar cell class if needed
@property (nonatomic) Class cellClass;

@end


@interface ZAPageTabIndicatorInfo : NSObject

@property (copy, nonatomic) NSString *title;
@property (strong, nonatomic) UIImage *image;
@property (strong, nonatomic) UIImage *selectedImage;

@end;


@interface ZAPageTabsBar : NSObject

@property (strong, nonatomic) UICollectionView *collectionView;
@property (strong, nonatomic) UIView *barView;
@property (strong, nonatomic) NSArray<ZAPageTabIndicatorInfo *> *items;

@property (strong, nonatomic) ZAPageTabsBarStyle *style;

@property (weak, nonatomic) id<ZAPageTabsBarDelegate> delegate;

@property (nonatomic) NSUInteger selectedIndex;

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
