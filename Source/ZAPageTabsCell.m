//
//  ZAPageTabsCell.m
//  ZAPageTabs
//
//  Created by ZartArn on 22.11.17.
//

#import "ZAPageTabsCell.h"

@implementation ZAPageTabsCell

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self configureViews];
    }
    return self;
}

- (void)configureViews {
    
    self.titleLabel = [[UILabel alloc] init];
    _titleLabel.textAlignment             = NSTextAlignmentCenter;

    self.icon = [[UIImageView alloc] init];
    
    // hierarchy
    [self.contentView addSubview:self.icon];
    [self.contentView addSubview:self.titleLabel];
    
    // layouts
    self.titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
    self.icon.translatesAutoresizingMaskIntoConstraints = NO;
    [self configureLayouts];
}

- (void)configureLayouts {

    [self.icon addConstraint:[NSLayoutConstraint constraintWithItem:self.icon
                                                          attribute:NSLayoutAttributeHeight
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:nil
                                                          attribute:NSLayoutAttributeNotAnAttribute
                                                         multiplier:1
                                                           constant:35.f]];

    [self.icon addConstraint:[NSLayoutConstraint constraintWithItem:self.icon
                                                          attribute:NSLayoutAttributeWidth
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:nil
                                                          attribute:NSLayoutAttributeNotAnAttribute
                                                         multiplier:1
                                                           constant:35.f]];

    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.icon
                                                          attribute:NSLayoutAttributeCenterY
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.contentView
                                                          attribute:NSLayoutAttributeCenterY
                                                         multiplier:1
                                                           constant:0.f]];

    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.icon
                                                                 attribute:NSLayoutAttributeCenterX
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:self.contentView
                                                                 attribute:NSLayoutAttributeCenterX
                                                                multiplier:1
                                                                  constant:0.f]];
    
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.titleLabel
                                                                 attribute:NSLayoutAttributeCenterY
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:self.contentView
                                                                 attribute:NSLayoutAttributeCenterY
                                                                multiplier:1
                                                                  constant:0.f]];

    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.titleLabel
                                                                 attribute:NSLayoutAttributeCenterX
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:self.contentView
                                                                 attribute:NSLayoutAttributeCenterX
                                                                multiplier:1
                                                                  constant:0.f]];
}

@end
