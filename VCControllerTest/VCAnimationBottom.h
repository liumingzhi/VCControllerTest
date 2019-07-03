//
//  VCAnimationBottom.h
//  QunariPhone
//
//  Created by 姜琢 on 13-9-10.
//  Copyright (c) 2013年 Qunar.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VCAnimation.h"

@interface VCAnimationBottom : NSObject <VCAnimation>

/**
 *  底部弹出动画默认创建实例
 *
 *  @return 返回默认配置实例
 */
+ (VCAnimationBottom *)defaultAnimation;

@end
