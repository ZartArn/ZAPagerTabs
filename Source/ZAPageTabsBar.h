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

@property (strong, nonatomic) UIView *barView;
@property (strong, nonatomic) NSArray *items;
@property (strong, nonatomic) NSArray *iconNames;

@property (nonatomic) NSUInteger selectedIndex;
@property (weak, nonatomic) id<ZAPageTabsBarDelegate> delegate;

- (void)setItems:(NSArray *)items iconNames:(NSArray *)names;


- (void)configure;

- (void)updateBottomView;

- (void)updatePercentage:(CGFloat)percent;

@end



@protocol ZAPageTabsBarDelegate <NSObject>

- (void)pageTabsBar:(ZAPageTabsBar *)pageTabsBar didSelectItemAtIndex:(NSUInteger)index;

@end
