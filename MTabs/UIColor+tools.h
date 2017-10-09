//
//  UIColor+tools.h
//  ZartArn
//
//  Created by Zart Arn on 23.08.12.
//  Copyright (c) 2012 ZartArn. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIColor (tools)

+ (UIColor *)colorWithR:(CGFloat)red G:(CGFloat)green B:(CGFloat)blue A:(CGFloat)alpha;
+ (UIColor *)colorWithHexValue:(uint)hexValue andAlpha:(float)alpha;
+ (UIColor *)colorWithHexString:(NSString *)hexString andAlpha:(float)alpha;
+ (UIColor *)getRandomColor;

@end
