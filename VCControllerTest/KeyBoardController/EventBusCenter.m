//
//  SingleNotificationCenter.m
//  QunariPhone
//
//  Created by zhou jinfeng on 13-6-3.
//  Copyright (c) 2013年 Qunar.com. All rights reserved.
//

#import "EventBusCenter.h"

// =====================================================================================
// 全局默认消息
// =====================================================================================
// 全局定位器控制器
static EventBusCenter *defaultEventBusCenter = nil;

@interface ObserverInfo : NSObject

@property (nonatomic, assign) id                        observer;                // 消息接受对象
@property (nonatomic, assign) SEL                       selector;                // 消息处理方法
@property (nonatomic, strong) NSString                  *name;                   // 消息类型

@end

@implementation ObserverInfo

@end

@interface EventBusCenter ()

@property(nonatomic, strong) NSMutableDictionary            *dictionaryObserver;

@end

@implementation EventBusCenter

+ (id)defaultCenter
{
    @synchronized(self)
	{
		// 实例对象只分配一次
		if(defaultEventBusCenter == nil)
		{
			defaultEventBusCenter = [[super allocWithZone:NULL] init];
            
			// 初始化
            if ([defaultEventBusCenter dictionaryObserver] == nil)
            {
                NSMutableDictionary *dictionaryObserverTemp = [[NSMutableDictionary alloc] init];
                [defaultEventBusCenter setDictionaryObserver:dictionaryObserverTemp];
            }
        }
	}
	
	return defaultEventBusCenter;
}

+ (id)allocWithZone:(NSZone *)zone
{
    return [self defaultCenter];
}

- (instancetype)init
{
    @synchronized(self)
    {
        self = [super init];
        
        if (_dictionaryObserver == nil)
        {
            _dictionaryObserver = [[NSMutableDictionary alloc] init];
        }
    }
    
    return self;
}

- (instancetype)copyWithZone:(NSZone *)zone
{
    return [self init];
}

// 添加消息监听
- (void)addObserver:(id)observer selector:(SEL)aSelector name:(NSString *)aName
{
    if (observer == nil || aSelector == nil || aName == nil)
    {
        return;
    }
    
    if (_dictionaryObserver == nil)
    {
        _dictionaryObserver = [[NSMutableDictionary alloc] init];
    }

    // 保存消息回调信息
    ObserverInfo *observerInfo = [[ObserverInfo alloc] init];
    [observerInfo setName:aName];
    [observerInfo setObserver:observer];
    [observerInfo setSelector:aSelector];

    NSMutableArray *arryObserverInfo = [_dictionaryObserver objectForKey:aName];
    if (arryObserverInfo != nil && [arryObserverInfo count] > 0)
    {
        [self removeObserver:observer name:aName];
        [self addObserverInfo:observerInfo];
    }
    else
    {
        [self addObserverInfo:observerInfo];
        
        // 向系统注册消息监听，并回调自己
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(handleNotification:)
                                                     name:aName
                                                   object:nil];
    }
}

// 删除observer的消息监听
- (void)removeObserver:(id)observer
{
    NSArray *arrayKeys = [_dictionaryObserver allKeys];
    
    for (NSInteger i = 0; i < [arrayKeys count]; ++i)
    {
        NSString *keyValues = [arrayKeys objectAtIndex:i];
        NSMutableArray *arrayObserverInfo = [_dictionaryObserver objectForKey:keyValues];
        
        if (arrayObserverInfo != nil)
        {
            NSMutableArray *arrayRemove = [[NSMutableArray alloc] init];
            
            for (NSInteger i = 0; i < [arrayObserverInfo count]; ++i)
            {
                ObserverInfo *observerInfo = [arrayObserverInfo objectAtIndex:i];
                
                if ([observerInfo observer] == observer)
                {
                    [arrayRemove addObject:observerInfo];
                }
            }
            
            [arrayObserverInfo removeObjectsInArray:arrayRemove];
            
            if ([arrayObserverInfo count] == 0)
            {
                [[NSNotificationCenter defaultCenter] removeObserver:self name:keyValues object:nil];
            }
        }
    }
}

// 删除observer的aName类型消息监听
- (void)removeObserver:(id)observer name:(NSString *)aName
{
    if (observer == nil)
    {
        return;
    }
    
    if (aName == nil)
    {
        [self removeObserver:observer];
        return;
    }
    
    NSMutableArray *arrayObserverInfo = [_dictionaryObserver objectForKey:aName];
    
    if (arrayObserverInfo != nil)
    {
        NSMutableArray *arrayRemove = [[NSMutableArray alloc] init];
        
        for (NSInteger i = 0; i < [arrayObserverInfo count]; ++i)
        {
            ObserverInfo *observerInfo = [arrayObserverInfo objectAtIndex:i];

            if ([observerInfo observer] == observer)
            {
                [arrayRemove addObject:observerInfo];
            }
        }
        
        [arrayObserverInfo removeObjectsInArray:arrayRemove];
        
        if ([arrayObserverInfo count] == 0)
        {
            [[NSNotificationCenter defaultCenter] removeObserver:self name:aName object:nil];
        }        
    }
}

// 保存回调信息
- (void)addObserverInfo:(ObserverInfo *)observerInfo
{
    NSMutableArray *arrayObserverInfo = [_dictionaryObserver objectForKey:[observerInfo name]];
    if (arrayObserverInfo == nil)
    {
        arrayObserverInfo = [[NSMutableArray alloc] init];
        [_dictionaryObserver setObject:arrayObserverInfo forKey:[observerInfo name]];
    }
    
    [arrayObserverInfo addObject:observerInfo];
}

// 处理系统消息回调
- (void)handleNotification:(NSNotification *)notification
{
    if (notification == nil)
    {
        return;
    }
        
    if ([notification name] == nil)
    {
        return;
    }
    
    NSMutableArray *arrayObserverInfo = [_dictionaryObserver objectForKey:[notification name]];
    if (arrayObserverInfo != nil && [arrayObserverInfo count] > 0)
    {
        ObserverInfo *observerInfo = [arrayObserverInfo objectAtIndex:[arrayObserverInfo count] - 1];
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
        [[observerInfo observer] performSelector:[observerInfo selector] withObject:notification];
#pragma clang diagnostic pop
    }
}


@end
