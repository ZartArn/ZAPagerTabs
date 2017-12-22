//
//  Typography.m
//  MTabs
//
//  Created by ZartArn on 19.12.17.
//  Copyright © 2017 ZartArn. All rights reserved.
//

#import "Typography.h"

@implementation Typography

+ (UIFont *)regularFontWithSize:(CGFloat)size {
    return [UIFont systemFontOfSize:size];
}

+ (UIColor *)mainColor {
    return [UIColor darkGrayColor];
}

+ (UIColor *)activeColor {
    return [UIColor purpleColor];
}

@end
