//
//  UIViewController+VCController.h
//  CommonFramework
//
//  Created by zhou on 16/8/17.
//  Copyright © 2016年 Qunar.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIViewController (VCController)

/**
 *  获取viewController的VCName
 *  默认是返回类名，如果要自定义的VCName，则请自己实现VCControllerPtc中的getVCName方法
 *
 *  @return 生成当前类名
 */
- (NSString * _Nonnull)getVCName;

@end
