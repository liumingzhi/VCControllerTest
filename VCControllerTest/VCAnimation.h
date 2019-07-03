//
//  VCAnimation.h
//  QunariPhone
//
//  Created by 姜琢 on 12-11-12.
//  Copyright (c) 2012年 Qunar.com All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
@protocol VCAnimation <NSObject>

// 压入节点动画
/**
 *  <#Description#>
 *
 *  @param topVC      push在底部的VC
 *  @param arriveVC   push在顶部的VC
 *  @param completion push动画完成后的处理block
 */
- (void)pushAnimationFromTopVC:(UIViewController *)topVC
                    ToArriveVC:(UIViewController *)arriveVC
                WithCompletion:(void (^)(BOOL finished))completion;

/**
 *  弹出节点动画
 *
 *  @param topVC      pop在顶部的VC
 *  @param arriveVC   pop在底部的VC
 *  @param completion pop动画完成后的处理block
 */
- (void)popAnimationFromTopVC:(UIViewController *)topVC ToArriveVC:(UIViewController *)arriveVC WithCompletion:(void (^)(BOOL finished))completion;

@end
