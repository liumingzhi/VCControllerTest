//
//  VCPushAnimation.m
//  QunariPhone
//
//  Created by 姜琢 on 12-11-12.
//  Copyright (c) 2012年 Qunar.com All rights reserved.
//

#import "VCAnimationClassic.h"
#import "UIView+Frame.h"

@implementation VCAnimationClassic

+ (VCAnimationClassic *)defaultAnimation
{
    return [[VCAnimationClassic alloc] init];
}

- (void)pushAnimationFromTopVC:(UIViewController *)topVC
					ToArriveVC:(UIViewController *)arriveVC
				WithCompletion:(void (^)(BOOL finished))completion
{
    [[arriveVC view] setViewX:[[arriveVC view] frame].size.width];
    
    [UIView animateWithDuration:0.3
                          delay:0
                        options:UIViewAnimationOptionCurveEaseIn
                     animations:^{
                         [[topVC view] setViewX:-[[topVC view] frame].size.width];
                         [[arriveVC view] setViewX:0];
                     }
                     completion:completion];
}

- (void)popAnimationFromTopVC:(UIViewController *)topVC
				   ToArriveVC:(UIViewController *)arriveVC
			   WithCompletion:(void (^)(BOOL finished))completion
{
    [[arriveVC view] setViewX:-[[arriveVC view] frame].size.width];
    
    [UIView animateWithDuration:0.3
                          delay:0
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         [[topVC view] setViewX:[[topVC view] frame].size.width];
                         [[arriveVC view] setViewX:0];
                     }
                     completion:completion];
}

@end
