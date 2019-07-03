//
//  BusinessStack.m
//  Pods
//
//  Created by Quanquan.zhang on 16/4/12.
//
//

#import "BusinessStack.h"
#import "AppInfo.h"
#import "VCController.h"


@interface BusinessStack ()

// 保存 Scheme 堆栈信息
@property (nonatomic, strong) NSMutableArray *schemeStack;

@property (nonatomic, copy) NSString *lastBusiness;
@property (nonatomic, strong) NSMutableArray *vcStack;
@property (nonatomic, strong) NSMutableArray *businessStack;
@property (nonatomic, assign) BOOL ignoringScheme;

@end

@implementation BusinessStack

- (instancetype)init
{
    self = [super init];
    if (self) {
        _schemeStack = [[NSMutableArray alloc] initWithCapacity:3];
        _lastBusiness = @"home";
        _ignoringScheme = NO;
        _vcStack = [[NSMutableArray alloc] initWithCapacity:3];
        _businessStack = [[NSMutableArray alloc] initWithCapacity:3];
    }
    
    return self;
}

+ (instancetype)sharedInstance
{
    static BusinessStack *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[BusinessStack alloc] init];
    });
    
    return instance;
}

- (NSString *)currentBusiness
{
    if ([_businessStack count] > 0)
    {
        return [_businessStack lastObject];
    }
    
    return @"home";
}

#pragma mark - Scheme

- (NSString *)keyOfURL:(NSURL *)url
{
    NSString *scheme = url.scheme;
    NSString *key = url.host;
    
    if (![[scheme lowercaseString] isEqualToString:[[AppInfo QunarIPhoneScheme] lowercaseString]]) {
        // 非 Qunar 的 scheme，保存 scheme 信息。
        key = [NSString stringWithFormat:@"%@:%@", scheme, url.host];
    }

    return key;
}

- (void)willJumpToURL:(NSURL *)jumpURL
{
    // 只需要关心页面相关的 Scheme 调用，所以不是在主线程的都不记录。
    if (![NSThread isMainThread]) {
        return;
    }
    
    if (_ignoringScheme == YES)
    {
        return;
    }
    
    NSString *key = [self keyOfURL:jumpURL];
    if (!key || key.length == 0) {
        return;
    }
    
    [_schemeStack addObject:key];
}

- (void)didReturnFromURL:(NSURL *)jumpURL
{
    if (![NSThread isMainThread]) {
        return;
    }
    
    if (_ignoringScheme == YES)
    {
        return;
    }
    
    NSString *key = [self keyOfURL:jumpURL];
    if (!key || key.length == 0) {
        return;
    }
    
    [_schemeStack removeLastObject];
    
    if ([_schemeStack count] == 0 && [_businessStack count] <= 1)
    {
        _lastBusiness = key;
    }
}


- (void)beginIgnoringScheme
{
    _ignoringScheme = YES;
}

- (void)endIgnoringScheme
{
    _ignoringScheme = NO;
}

#pragma mark - VC

- (void)willPop:(NSNumber *)popVCNumber PushToVC:(NSString *)vcName;
{
    // Scheme 有嵌套调用的情况，一般第一个是业务线的 Scheme
    NSString *currentScheme = _lastBusiness;
    
    if ([_schemeStack count] > 0)
    {
        currentScheme = [_schemeStack firstObject];
    }
    
    if (currentScheme == nil && [_businessStack count] > 0)
    {
        currentScheme = [_businessStack lastObject];
    }
    
    if (currentScheme == nil)
    {
        currentScheme = @"home";
    }
    
    if (popVCNumber != nil && [popVCNumber integerValue] > 0)
    {
        if ([_businessStack count] > [popVCNumber integerValue])
        {
            for (NSInteger i = 0; i < [popVCNumber integerValue]; ++i)
            {
                [_businessStack removeLastObject];
            }
        }
        
        if ([_vcStack count] > [popVCNumber integerValue])
        {
            for (NSInteger i = 0; i < [popVCNumber integerValue]; ++i)
            {
                [_vcStack removeLastObject];
            }
        }
    }
    
    // 肯定在主线程
    if (vcName == nil) {
        return;
    }
    
    
    [self recordScheme:currentScheme withVCName:vcName];
    _lastBusiness = nil;
}

- (void)recordScheme:(NSString *)scheme withVCName:(NSString *)vcName
{
    if (!vcName || !scheme) {
        return;
    }
    
    // 保存当前的 VC 名与 scheme 的对应关系，做校验用
    [_vcStack addObject:@{@"vc": vcName, @"scheme":scheme}];
    [_businessStack addObject:scheme];
}

@end
