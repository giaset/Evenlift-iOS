//
//  ELColorUtil.m
//  Evenlift iOS
//
//  Created by Gianni Settino on 2014-04-21.
//  Copyright (c) 2014 Evenlift. All rights reserved.
//

#import "ELColorUtil.h"

@implementation ELColorUtil

+ (UIImage*)imageWithColor:(UIColor*)color {
    CGRect rect = CGRectMake(0.0f, 0.0f, 1.0f, 1.0f);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

+ (UIColor*)evenLiftRed
{
    // FLAT UI "ALIZARIN" = #e74c3c
    // R:231 G:76 B:60
    return [UIColor colorWithRed:0.906 green:0.298 blue:0.235 alpha:1.0];
}

+ (UIColor*)evenLiftRedHighlighted
{
    // FLAT UI "POMEGRANATE" = #c0392b
    // R:192 G:57 B:43
    return [UIColor colorWithRed:0.753 green:0.224 blue:0.169 alpha:1.0];
}

+ (UIColor*)evenLiftBlack
{
    // #222222
    // R:34 G:34 B:34
    return [UIColor colorWithRed:0.133 green:0.133 blue:0.133 alpha:1];
}

+ (UIColor*)evenLiftWhite
{
    // #f7f7f7
    // R:247 G:247 B:247
    return [UIColor colorWithRed:0.969 green:0.969 blue:0.969 alpha:1];
}

@end
