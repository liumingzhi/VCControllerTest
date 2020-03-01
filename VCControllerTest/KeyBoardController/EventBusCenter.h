//
//  SingleNotificationCenter.h
//  QunariPhone
//
//  Created by zhou jinfeng on 13-6-3.
//  Copyright (c) 2013年 Qunar.com. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface EventBusCenter : NSObject

+ (id)defaultCenter;

- (instancetype)init;

- (void)addObserver:(id)observer selector:(SEL)aSelector name:(NSString *)aName;

- (void)removeObserver:(id)observer;
- (void)removeObserver:(id)observer name:(NSString *)aName;

@end
