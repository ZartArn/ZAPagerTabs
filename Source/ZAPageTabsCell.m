//
//  ZAPageTabsCell.m
//  ZAPageTabs
//
//  Created by ZartArn on 22.11.17.
//

#import "ZAPageTabsCell.h"
#import "NSObject+ZAObjectMaker.h"
#import "Typography.h"
#import <GeneralHelpers/UIColor+tools.h>
#import <Masonry/Masonry.h>

@implementation ZAPageTabsCell

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self configureViews];
    }
    return self;
}

- (void)configureViews {
    
    self.titleLabel = [UILabel za_makeObject:^(UILabel *i) {
        i.font                      = [Typography regularFontWithSize:16.f];
        i.textColor                 = [Typography mainColor];
        i.highlightedTextColor      = [Typography activeColor];
        i.textAlignment             = NSTextAlignmentCenter;
    }];
    
    // hierarchy
    [self.contentView addSubview:self.titleLabel];
    
    // layouts
    self.titleLabel.frame = self.contentView.bounds;
    self.titleLabel.autoresizingMask = 18;
}

@end
