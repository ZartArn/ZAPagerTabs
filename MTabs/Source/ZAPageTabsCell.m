//
//  ZAPageTabsCell.m
//  ZAPageTabs
//
//  Created by ZartArn on 22.11.17.
//

#import "ZAPageTabsCell.h"
//#import "Typography.h"
#import <Masonry/Masonry.h>

@implementation ZAPageTabsCell

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self configureViews];
    }
    return self;
}

- (void)configureViews {
    
    self.titleLabel = [[UILabel alloc] init];
//    _titleLabel.font                      = [Typography regularFontWithSize:16.f];
//    _titleLabel.textColor                 = [Typography mainColor];
//    _titleLabel.highlightedTextColor      = [Typography activeColor];
    _titleLabel.textAlignment             = NSTextAlignmentCenter;
    _titleLabel.textColor = [UIColor orangeColor];
    _titleLabel.highlightedTextColor = [UIColor purpleColor];
    
    // hierarchy
    [self.contentView addSubview:self.titleLabel];
    
    // layouts
    self.titleLabel.frame = self.contentView.bounds;
    self.titleLabel.autoresizingMask = 18;
}

@end
