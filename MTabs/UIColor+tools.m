//
//  UIColor+tools.m
//  ZartArn
//
//  Created by Zart Arn on 23.08.12.
//  Copyright (c) 2012 ZartArn. All rights reserved.
//

#import "UIColor+tools.h"

@implementation UIColor (tools)

+ (UIColor *)colorWithR:(CGFloat)red G:(CGFloat)green B:(CGFloat)blue A:(CGFloat)alpha
{
    return [UIColor colorWithRed:(red/255.0) green:(green/255.0) blue:(blue/255.0) alpha:alpha];
}

+ (UIColor *)colorWithHexValue:(uint)hexValue andAlpha:(float)alpha {
    return [UIColor  
            colorWithRed:((float)((hexValue & 0xFF0000) >> 16))/255.0 
            green:((float)((hexValue & 0xFF00) >> 8))/255.0 
            blue:((float)(hexValue & 0xFF))/255.0 
            alpha:alpha];
}

+ (UIColor *)colorWithHexString:(NSString *)hexString andAlpha:(float)alpha {
    UIColor *col;
    hexString = [hexString stringByReplacingOccurrencesOfString:@"#" 
                                                     withString:@"0x"];
    uint hexValue;
    if ([[NSScanner scannerWithString:hexString] scanHexInt:&hexValue]) {
        col = [self colorWithHexValue:hexValue andAlpha:alpha];
    } else {
        // invalid hex string         
        col = [self blackColor];
    }
    return col;
}

+ (UIColor *) getRandomColor
{
    CGFloat hue = (arc4random()%256 / 256.0);
    CGFloat saturation = (arc4random()%128 / 256.0) + 0.5;
    CGFloat brightness = (arc4random()%128 / 256.0) + 0.5;

    return [UIColor colorWithHue:hue saturation:saturation brightness:brightness alpha:1];
}

@end
