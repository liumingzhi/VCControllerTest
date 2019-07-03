//
//  UIImage+Utility.h
//  QunariPhone
//
//  Created by 姜琢 on 13-6-8.
//  Copyright (c) 2013年 Qunar.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (Utility)

/// @name 获取图片

/**
 *  使用 xxx.bundle/xxx.png 这样的path来获取UIImage对象的方法
 *
 *  @param path 图片文件所在的Path
 *
 *  @return 返回UIImage对象
 */
+ (UIImage *)imageWithBundlePath:(NSString *)path;

/**
 *  生成一张像素大小为 1x1 可以指定颜色的UIImage对象的方法
 *
 *  @param color image的颜色
 *
 *  @return 返回该颜色的 UIImage 对象
 */
+ (UIImage *)imageFromColor:(UIColor *)color;

/// @name 裁剪和缩放图片

/**
 *  从一个UIImage对象中截取一个子区域并返回UIImage的方法
 *
 *  @param rect 子区域的frame
 *
 *  @return 返回截取后的UIImage对象
 */
- (UIImage *)getSubImage:(CGRect)rect;

/**
 *  将一个UIImage对象根据指定的size进行放缩的方法
 *
 *  该方法会考虑当前设备屏幕的Scale, 保证图片显示出来是高清的方法
 *
 *  @param size 需要放缩的CGSize, 逻辑像素值，可直接传想要的控件大小
 *
 *  @return 返回放缩后的UIImage对象
 */
- (UIImage *)scaleToSize:(CGSize)size;

/**
 *  将一个UIImage对象根据指定的size进行放缩的类方法
 *
 *  @param size  需要放缩的CGSize, 实际图片Size
 *  @param image 需要转换的UIImage对象
 *
 *  @return 返回缩放后的UIImage对象
 */
+ (UIImage *)TransformtoSize:(CGSize)size image:(UIImage *)image;

/**
 *  将一个UIImage对象维持原高宽比的情况下，根据指定的宽度(逻辑像素)进行缩放
 *
 *  @param sideLenght 逻辑像素宽度，可直接传控件宽度
 *
 *  @return 返回缩放后的UIImage对象
 */
- (UIImage *)imageWithMaxLength:(CGFloat)sideLenght;


- (UIImage *)boxBlurWithRadius:(CGFloat)radius;
- (UIImage *)applyTintEffectWithColor:(UIColor *)tintColor;
- (UIImage *)applyBlurWithRadius:(CGFloat)blurRadius tintColor:(UIColor *)tintColor saturationDeltaFactor:(CGFloat)saturationDeltaFactor maskImage:(UIImage *)maskImage;

@end
