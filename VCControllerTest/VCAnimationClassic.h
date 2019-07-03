//
//  VCPushAnimation.h
//  QunariPhone
//
//  Created by 姜琢 on 12-11-12.
//  Copyright (c) 2012年 Qunar.com All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VCAnimation.h"

@interface VCAnimationClassic : NSObject <VCAnimation>

/**
 *  Classic弹出动画默认创建实例
 *
 *  @return 返回默认配置实例
 */
+ (VCAnimationClassic *)defaultAnimation;

@end
