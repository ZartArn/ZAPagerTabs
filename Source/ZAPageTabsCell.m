//
//  ZAPageTabsCell.m
//  ZAPageTabs
//
//  Created by ZartArn on 22.11.17.
//

#import "ZAPageTabsCell.h"
#import "Typography.h"
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
    _titleLabel.font                      = [Typography regularFontWithSize:16.f];
    _titleLabel.textColor                 = [Typography mainColor];
    _titleLabel.highlightedTextColor      = [Typography activeColor];
    _titleLabel.textAlignment             = NSTextAlignmentCenter;

    self.icon = [[UIImageView alloc] init];
//    self.icon.contentMode = UIViewContentModeScaleAspectFit;
    
    // hierarchy
    [self.contentView addSubview:self.icon];
    [self.contentView addSubview:self.titleLabel];
    
    // layouts
//    self.titleLabel.frame = self.contentView.bounds;
//    self.titleLabel.autoresizingMask = 18;
    [self configureLayouts];
}

- (void)configureLayouts {
    
    [self.icon mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(@0.f);
        make.width.height.equalTo(@15.f);
        make.centerX.equalTo(@0.f);
    }];
    
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.icon.mas_bottom);
        make.leading.trailing.bottom.equalTo(@0.f);
    }];
}

@end
