//
//  UIColor+Utility.h
//  QunariPhone
//
//  Created by Neo on 11/12/12.
//  Copyright (c) 2012 姜琢. All rights reserved.
//

#import <UIKit/UIKit.h>

#define kUIColorOfHex(color)						[UIColor colorWithHex:(color) alpha:1.0]

@interface UIColor (Utility)

/**
 *  传入int型色值和alpha生成对应UIColor对象
 *
 *  @param hexValue RGB色值
 *  @param alpha    色值 Aplha 通道
 *
 *  @return The color object. The color information represented by this object is in the device RGB colorspace.
 */
+ (UIColor *)colorWithHex:(NSInteger)hexValue alpha:(CGFloat)alpha;

/**
 *  传入int型ARGB色值生成对应UIColor对象
 *
 *  @param ARGBValue The integer value of ARGB color. From 0x00000000 to 0xFFFFFFFF.
 *
 *  @return The color object. The color information represented by this object is in the device RGB colorspace.
 */
+ (UIColor *)colorWithARGB:(NSInteger)ARGBValue;

/// @name 使用Qunar常用颜色创建UIColor

/// 按钮和部分Label蓝色 色值：0x1ba9ba
+ (UIColor *)qunarBlueColor;

/// 按钮点击态蓝色 色值：0x168795
+ (UIColor *)qunarBlueHighlightColor;

/// 按钮红色 色值：0xff4500
+ (UIColor *)qunarRedColor;

/// 按钮点击态红色 色值：0xbe3300
+ (UIColor *)qunarRedHighlightColor;

/// 灰色 色值：0xff3300
+ (UIColor *)qunarTextRedColor;

/// 黑色 色值：0x333333
+ (UIColor *)qunarTextBlackColor;

/// 灰色 色值：0x888888
+ (UIColor *)qunarTextGrayColor;

/// 边线框颜色 色值：0xc7ced4
+ (UIColor *)qunarGrayColor;

/// 强提示黄色 色值：0xf8facd
+ (UIColor *)warningYellowColor;

/// 橙色   色值: 0xFE9627
+ (UIColor *)qunarOrangeColor;

/// 橙色加亮   色值: 0xFE9627
+ (UIColor *)qunarOrangeHighlightColor;

@end
