//
//  VCController.h
//  QunariPhone
//
//  Created by 姜琢 on 12-11-12.
//  Copyright (c) 2012年 Qunar.com All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VCControllerPtc.h"
#import "VCAnimation.h"
#import "UIViewController+VCController.h"

// ==================================================================
// 手势类型
// ==================================================================
@interface VCController : NSObject <UIGestureRecognizerDelegate>

/**
 *  获取某一个VCName节点
 *
 *  @param vcName 需要获取的VC的Name
 *
 *  @return 返回对应Name的VC实例
 */
+ (UIViewController<VCControllerPtc> * _Nullable)getVC:(NSString * _Nonnull)vcName;

/**
 *  获取最上层的节点
 *
 *  @return 返回当前在Window最上层的VC实例
 */
+ (UIViewController<VCControllerPtc> * _Nullable)getTopVC;

/**
 *  获取某一个VC节点前面的节点
 *
 *  @param baseNameVC 要指定的VC
 *
 *  @return 返回改VC前的
 */
+ (UIViewController<VCControllerPtc> * _Nullable)getPreviousWithVC:(UIViewController<VCControllerPtc> * _Nonnull)baseNameVC;

/**
 *  获取最下层节点
 *
 *  @return 返回最下层节点的VC
 */
+ (UIViewController<VCControllerPtc> * _Nullable)getHomeVC;

/**
 *  Push一个ViewController，可指定push动画
 *
 *  @param baseNameVC 要Push进来的VC实例
 *  @param animation  Push时使用的动画实例，可以为nil
 */
+ (void)pushVC:(UIViewController<VCControllerPtc> * _Nonnull)baseNameVC WithAnimation:(id <VCAnimation> _Nullable)animation;

/**
 *  Pop到上一个节点，可指定动画模式
 *
 *  @param animation pop时使用的动画实例，可以为nil
 *
 *  @return 返回是否成功Pop
 */
+ (BOOL)popWithAnimation:(id <VCAnimation> _Nullable)animation;

/**
 *  弹出到vcName的VC节点，弹出后显示为vcName的VC
 *
 *  @param vcName    要弹出到VC节点的vcName
 *  @param animation Pop时使用的动画实例，可以为nil
 *
 *  @return 是否弹出VC
 */
+ (BOOL)popToVC:(NSString * _Nonnull)vcName WithAnimation:(id <VCAnimation> _Nullable)animation;

/**
 *  弹出一个VC节点然后压入VC节点
 *
 *  @param baseNameVC 要Push的VC
 *  @param animation  Push时使用的动画实例，可以为nil
 *
 *  @return 是否弹出VC
 */
+ (BOOL)popThenPushVC:(UIViewController<VCControllerPtc> * _Nonnull)baseNameVC WithAnimation:(id <VCAnimation> _Nullable)animation;

/**
 *  弹出到vcName的VC节点，然后压入节点
 *
 *  @param vcName     要弹出到VC节点的vcName
 *  @param baseNameVC 要Push的VC
 *  @param animation  Push时使用的动画实例，可以为nil
 *
 *  @return 是否弹出VC
 */
+ (BOOL)popToVC:(NSString * _Nonnull)vcName thenPushVC:(UIViewController<VCControllerPtc> * _Nonnull)baseNameVC WithAnimation:(id <VCAnimation> _Nullable)animation;

/**
 *  弹出到最下层的VC（即入栈的第一个VC）
 *
 *  @param animation Pop时使用的动画实例，可以为nil
 *
 *  @return 是否弹出VC
 */
+ (BOOL)popToHomeVCWithAnimation:(id <VCAnimation> _Nullable)animation;

/**
 *  弹出到最下层的VC然后压入节点
 *
 *  @param baseNameVC 要Push的VC
 *  @param animation  Push时使用的动画实例，可以为nil
 *
 *  @return 是否弹出VC
 */
+ (BOOL)popToHomeVCThenPushVC:(UIViewController<VCControllerPtc> * _Nonnull)baseNameVC WithAnimation:(id <VCAnimation> _Nullable)animation;

@end
