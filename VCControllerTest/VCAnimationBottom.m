//
//  VCAnimationBottom.m
//  QunariPhone
//
//  Created by 姜琢 on 13-9-10.
//  Copyright (c) 2013年 Qunar.com. All rights reserved.
//

#import "VCAnimationBottom.h"
#import "UIView+Frame.h"

@implementation VCAnimationBottom

+ (VCAnimationBottom *)defaultAnimation
{
    return [[VCAnimationBottom alloc] init];
}

- (void)pushAnimationFromTopVC:(UIViewController *)topVC
                    ToArriveVC:(UIViewController *)arriveVC
                WithCompletion:(void (^)(BOOL finished))completion
{
    [[arriveVC view] setViewY:[[arriveVC view] frame].size.height];
    
    [UIView animateWithDuration:0.3
                          delay:0
                        options:UIViewAnimationOptionCurveEaseIn
                     animations:^{
                         [[arriveVC view] setViewY:0];
                     }
                     completion:completion];
}

- (void)popAnimationFromTopVC:(UIViewController *)topVC
                   ToArriveVC:(UIViewController *)arriveVC
               WithCompletion:(void (^)(BOOL finished))completion
{
    [UIView animateWithDuration:0.3
                          delay:0
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         [[topVC view] setViewY:[[topVC view] frame].size.height];
                     }
                     completion:completion];
}

@end
