//
//  UIView+Frame.h
//  CommonFramework
//
//  Created by zhoujinfeng on 4/13/15.
//  Copyright (c) 2015 Qunar.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (Frame)

/**
 *  设置UIView的origin.x
 *
 *  @param newX 新的origin.x
 */
- (void)setViewX:(CGFloat)newX;

/**
 *  设置UIView的origin.y
 *
 *  @param newY 新的origin.y
 */
- (void)setViewY:(CGFloat)newY;

/**
 *  设置UIView的origin
 *
 *  @param newOrigin 新的origin
 */
- (void)setViewOrigin:(CGPoint)newOrigin;

/**
 *  设置UIView的width
 *
 *  @param newWidth 新的width
 */
- (void)setViewWidth:(CGFloat)newWidth;

/**
 *  设置UIView的height
 *
 *  @param newHeight 新的height
 */
- (void)setViewHeight:(CGFloat)newHeight;

/**
 *  设置UIView的Size
 *
 *  @param newSize 新的Size
 */
- (void)setViewSize:(CGSize)newSize;


@end
