//
//  UIViewController+VCController.m
//  CommonFramework
//
//  Created by zhou on 16/8/17.
//  Copyright © 2016年 Qunar.com. All rights reserved.
//

#import "UIViewController+VCController.h"

@implementation UIViewController (VCController)

- (NSString * _Nonnull)getVCName
{
    return NSStringFromClass([self class]);
}

@end
