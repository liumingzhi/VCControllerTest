//
//  AppInof.m
//  CommonFramework
//
//  Created by zhoujinfeng on 4/10/15.
//  Copyright (c) 2015 Qunar.com. All rights reserved.
//

#import "AppInfo.h"
#import <objc/runtime.h>
#include <sys/socket.h>
#include <sys/sysctl.h>
#include <net/if.h>
#include <net/if_dl.h>
#import <CoreTelephony/CTCarrier.h>
#import <CoreTelephony/CTTelephonyNetworkInfo.h>
#import "Reachability.h"
#import <dlfcn.h>
//#import "StatisticsUELog.h"
#import "StorageManager.h"

#define kAppInfoKey                                 @"AppInfo"
#define kFrameworkModuleName                        @"CommonFramework"

@interface AppInfo ()

// 文件持久化存储
@property (nonatomic, strong) NSNumber *appServerTimeLag;          // 本地时间和服务器的时差，如果比服务器时间快，则为负数，如果比服务器时间慢，则为正数
@property (nonatomic, strong) NSNumber *appStatisticsSwitch;       // 统计开关
@property (nonatomic, strong) NSString *appGID;                    // 客户端Gid
@property (nonatomic, strong) NSString *appSID;                    // 服务器分配的ServerID
@property (nonatomic, strong) NSString *appIID;                    // 客户端的广告标识,用户唯一标识
@property (nonatomic, strong) NSString *appAID;                    // 机器的唯一标识
@property (nonatomic, strong) NSString *ipServerURL;               // ip服务器地址

// 内存缓存，初始化时需要清零
@property (nonatomic, strong) NSString *macAddress;                // 网卡mac地址
@property (nonatomic, strong) NSString *qRequestID;                // QRequestID

#if (BETA_BUILD == 1)

@property (nonatomic, strong) NSNumber *appBetaDebug;              // beta调试开关
@property (nonatomic, strong) NSNumber *appStatisticsLog;          // 交互统计日志
@property (nonatomic, strong) NSNumber *appJSPatch;                // JSPatch debugview展示以及开关

#endif

@end

static AppInfo *globalAppInfo = nil;

@implementation AppInfo

+ (id)getInstance
{
    @synchronized(self)
    {
        if (globalAppInfo == nil)
        {
            globalAppInfo = [StorageManager objectWithModule:kFrameworkModuleName withKey:kAppInfoKey withMerge:nil];
            
            // 实例对象只分配一次
            if(globalAppInfo == nil)
            {
                globalAppInfo = [[super allocWithZone:NULL] init];
            }
            else
            {
                // 清除网卡mac地址，重新获取
                [globalAppInfo setMacAddress:nil];
                [globalAppInfo setIpServerURL:nil];
                [globalAppInfo setQRequestID:nil];
            }
            
        }
    }
    
    return globalAppInfo;
}

- (void)saveAppInfo
{
    [StorageManager saveDataWithObject:globalAppInfo withModule:kFrameworkModuleName withKey:kAppInfoKey];
}

+ (Class)appInfoInstances
{
    return [[[UIApplication sharedApplication] delegate] class];
}

// appName
+ (NSString *)appName
{
    Class appInfoInstances = [AppInfo appInfoInstances];
    
    if (appInfoInstances != nil &&
        class_conformsToProtocol(appInfoInstances, @protocol(AppInfoPrt)) == YES &&
        class_getClassMethod(appInfoInstances, @selector(appName)) != nil)
    {
        return [appInfoInstances appName];
    }
    
    return nil;
}

// appGroupID
+ (NSString *)appGroupID
{
    Class appInfoInstances = [AppInfo appInfoInstances];
    
    if (appInfoInstances != nil &&
        class_conformsToProtocol(appInfoInstances, @protocol(AppInfoPrt)) == YES &&
        class_getClassMethod(appInfoInstances, @selector(appGroupID)) != nil)
    {
        return [appInfoInstances appGroupID];
    }
    
    return nil;
}

// vid
+ (NSString *)appVID
{
    Class appInfoInstances = [AppInfo appInfoInstances];
    
    if (appInfoInstances != nil &&
        class_conformsToProtocol(appInfoInstances, @protocol(AppInfoPrt)) == YES &&
        class_getClassMethod(appInfoInstances, @selector(appVID)) != nil)
    {
        return [appInfoInstances appVID];
    }
    
    return nil;
}

// pid
+ (NSString *)appPID
{
    Class appInfoInstances = [AppInfo appInfoInstances];
    
    if (appInfoInstances != nil &&
        class_conformsToProtocol(appInfoInstances, @protocol(AppInfoPrt)) == YES &&
        class_getClassMethod(appInfoInstances, @selector(appPID)) != nil)
    {
        return [appInfoInstances appPID];
    }
    
    return nil;
}

// cid
+ (NSString *)appCID
{
    Class appInfoInstances = [AppInfo appInfoInstances];
    
    if (appInfoInstances != nil &&
        class_conformsToProtocol(appInfoInstances, @protocol(AppInfoPrt)) == YES &&
        class_getClassMethod(appInfoInstances, @selector(appCID)) != nil)
    {
        return [appInfoInstances appCID];
    }

    return nil;
}

// 客户端Gid
+ (NSString *)appGID
{
    return [[AppInfo getInstance] appGID];
}

+ (void)setAppGID:(NSString *)appGIDNew
{
    [[AppInfo getInstance] setAppGID:appGIDNew];
    [AppInfo saveAppInfo];
}

// 服务器分配的ServerID
+ (NSString *)appSID
{
    return [[AppInfo getInstance] appSID];
}

+ (void)setAppSID:(NSString *)appSIDNew
{
    [[AppInfo getInstance] setAppSID:appSIDNew];
    [AppInfo saveAppInfo];
}

// 客户端的广告标识,用户唯一标识
+ (NSString *)appIID
{
    if ([[AppInfo getInstance] appIID] == nil)
    {
        Class appInfoInstances = [AppInfo appInfoInstances];
        
        if (appInfoInstances != nil &&
            class_conformsToProtocol(appInfoInstances, @protocol(AppInfoPrt)) == YES &&
            class_getClassMethod(appInfoInstances, @selector(appIID)) != nil)
        {
            NSString *appIIDNew = [appInfoInstances appIID];
            [[AppInfo getInstance] setAppIID:appIIDNew];
            [AppInfo saveAppInfo];
        }
    }
    
    return [[AppInfo getInstance] appIID];
}

// 机器的唯一标识
+ (NSString *)appAID
{
    if ([[AppInfo getInstance] appAID] == nil)
    {
        // 产生唯一标识
        CFUUIDRef puuid = CFUUIDCreate(nil);
        CFStringRef uuidString = CFUUIDCreateString(nil, puuid);
        NSString *appAIDNew = (__bridge_transfer  NSString *)CFStringCreateCopy(NULL, uuidString);
        CFRelease(puuid);
        CFRelease(uuidString);
        
        if (appAIDNew != nil && [appAIDNew length] > 0)
        {
            [[AppInfo getInstance] setAppAID:appAIDNew];
            [AppInfo saveAppInfo];
        }
    }
    
    return [[AppInfo getInstance] appAID];
}

+ (void)setAppAID:(NSString *)appAIDNew
{
    [[AppInfo getInstance] setAppAID:appAIDNew];
    [AppInfo saveAppInfo];
}

// uid
+ (NSString *)appUID
{
    Class appInfoInstances = [AppInfo appInfoInstances];
    
    if (appInfoInstances != nil &&
        class_conformsToProtocol(appInfoInstances, @protocol(AppInfoPrt)) == YES &&
        class_getClassMethod(appInfoInstances, @selector(appUID)) != nil)
    {
        return [appInfoInstances appUID];
    }

    return nil;
}

// vendorUID
+ (NSString *)vendorUID
{
    Class appInfoInstances = [AppInfo appInfoInstances];
    
    if (appInfoInstances != nil &&
        class_conformsToProtocol(appInfoInstances, @protocol(AppInfoPrt)) == YES &&
        class_getClassMethod(appInfoInstances, @selector(vendorUID)) != nil)
    {
        return [appInfoInstances vendorUID];
    }
    
    return nil;
}

// deviceUID
+ (NSString *)deviceUID
{
    Class appInfoInstances = [AppInfo appInfoInstances];
    
    if (appInfoInstances != nil &&
        class_conformsToProtocol(appInfoInstances, @protocol(AppInfoPrt)) == YES &&
        class_getClassMethod(appInfoInstances, @selector(deviceUID)) != nil)
    {
        return [appInfoInstances deviceUID];
    }

    return nil;
}

// 加密版本
+ (NSString *)keyVersion
{
    Class appInfoInstances = [AppInfo appInfoInstances];
    
    if (appInfoInstances != nil &&
        class_conformsToProtocol(appInfoInstances, @protocol(AppInfoPrt)) == YES &&
        class_getClassMethod(appInfoInstances, @selector(keyVersion)) != nil)
    {
        return [appInfoInstances keyVersion];
    }
    
    return nil;
}

// Pitcher代理服务器地址
+ (NSString *)proxyURL
{
    Class appInfoInstances = [AppInfo appInfoInstances];
    
    if (appInfoInstances != nil &&
        class_conformsToProtocol(appInfoInstances, @protocol(AppInfoPrt)) == YES &&
        class_getClassMethod(appInfoInstances, @selector(proxyURL)) != nil)
    {
        return [appInfoInstances proxyURL];
    }
    
    return nil;
}

// 服务器地址
+ (NSString *)serverURL
{
    Class appInfoInstances = [AppInfo appInfoInstances];
    
    if (appInfoInstances != nil &&
        class_conformsToProtocol(appInfoInstances, @protocol(AppInfoPrt)) == YES &&
        class_getClassMethod(appInfoInstances, @selector(serverURL)) != nil)
    {
        return [appInfoInstances serverURL];
    }

    return nil;
}

// 图片上传服务器地址
+ (NSString *)picUploadServer
{
    Class appInfoInstances = [AppInfo appInfoInstances];
    
    if (appInfoInstances != nil &&
        class_conformsToProtocol(appInfoInstances, @protocol(AppInfoPrt)) == YES &&
        class_getClassMethod(appInfoInstances, @selector(picUploadServer)) != nil)
    {
        return [appInfoInstances picUploadServer];
    }
    
    return nil;
}

// 获取当前APP的Scheme跳转协议头
+ (NSString *)QunarIPhoneScheme
{
    Class appInfoInstances = [AppInfo appInfoInstances];
    
    if (appInfoInstances != nil &&
        class_conformsToProtocol(appInfoInstances, @protocol(AppInfoPrt)) == YES &&
        class_getClassMethod(appInfoInstances, @selector(QunarIPhoneScheme)) != nil)
    {
        return [appInfoInstances QunarIPhoneScheme];
    }
    
    return nil;
}

// 获取当前APP的支付宝Scheme跳转协议头
+ (NSString *)QunarIPhoneAlipayScheme
{
    Class appInfoInstances = [AppInfo appInfoInstances];
    
    if (appInfoInstances != nil &&
        class_conformsToProtocol(appInfoInstances, @protocol(AppInfoPrt)) == YES &&
        class_getClassMethod(appInfoInstances, @selector(QunarIPhoneAlipayScheme)) != nil)
    {
        return [appInfoInstances QunarIPhoneAlipayScheme];
    }
    
    return nil;
}

// 获取当前APP的微信Scheme跳转协议头
+ (NSString *)QunarIPhoneWechatScheme
{
    Class appInfoInstances = [AppInfo appInfoInstances];
    
    if (appInfoInstances != nil &&
        class_conformsToProtocol(appInfoInstances, @protocol(AppInfoPrt)) == YES &&
        class_getClassMethod(appInfoInstances, @selector(QunarIPhoneWechatScheme)) != nil)
    {
        return [appInfoInstances QunarIPhoneWechatScheme];
    }
    
    return nil;
}

// 获取当前APP的携程Scheme跳转协议头
+ (NSString *)QunarIPhoneCtripScheme
{
    Class appInfoInstances = [AppInfo appInfoInstances];
    
    if (appInfoInstances != nil &&
        class_conformsToProtocol(appInfoInstances, @protocol(AppInfoPrt)) == YES &&
        class_getClassMethod(appInfoInstances, @selector(QunarIPhoneCtripScheme)) != nil)
    {
        return [appInfoInstances QunarIPhoneCtripScheme];
    }
    
    return nil;
}

+ (CGRect)appFrame
{
    return [[[[UIApplication sharedApplication] delegate] window] frame];
}

// mac地址
+ (NSString *)macAddress
{
    if ([[AppInfo getInstance] macAddress] == nil)
    {
        int                 mib[6];
        size_t              len;
        char                *buf;
        unsigned char       *ptr;
        struct if_msghdr    *ifm;
        struct sockaddr_dl  *sdl;
        
        mib[0] = CTL_NET;
        mib[1] = AF_ROUTE;
        mib[2] = 0;
        mib[3] = AF_LINK;
        mib[4] = NET_RT_IFLIST;
        
        if ((mib[5] = if_nametoindex("en0")) == 0)
        {
            return nil;
        }
        
        if (sysctl(mib, 6, NULL, &len, NULL, 0) < 0)
        {
            return nil;
        }
        
        if ((buf = malloc(len)) == NULL)
        {
            return nil;
        }
        
        if (sysctl(mib, 6, buf, &len, NULL, 0) < 0)
        {
            free(buf);
            return nil;
        }
        
        ifm = (struct if_msghdr *)buf;
        sdl = (struct sockaddr_dl *)(ifm + 1);
        ptr = (unsigned char *)LLADDR(sdl);
        NSString *outstring = [NSString stringWithFormat:@"%02X:%02X:%02X:%02X:%02X:%02X",
                               *ptr, *(ptr+1), *(ptr+2), *(ptr+3), *(ptr+4), *(ptr+5)];
        free(buf);
        
        [[AppInfo getInstance] setMacAddress:outstring];
    }
    
    return [[AppInfo getInstance] macAddress];
}

// 设备类型
+ (NSString *)deviceType
{
    size_t size;
    
    sysctlbyname("hw.machine", NULL, &size, NULL, 0);
    
    char *machine = malloc(size);
    
    sysctlbyname("hw.machine", machine, &size, NULL, 0);
    
    NSString *platform = [NSString stringWithCString:machine
                                            encoding:NSUTF8StringEncoding];
    
    free(machine);
    
    return platform;
}

// 系统版本
+ (NSString *)systemVersion
{
    return [[UIDevice currentDevice] systemVersion];;
}

// 运营商信息
+ (NSString *)carrierCode
{
    // 判断是否能够取得运营商
    Class telephoneNetWorkClass = (NSClassFromString(@"CTTelephonyNetworkInfo"));
    if (telephoneNetWorkClass != nil)
    {
        CTTelephonyNetworkInfo *telephonyNetworkInfo = [[CTTelephonyNetworkInfo alloc] init];
        
        // 获得运营商的信息
        Class carrierClass = (NSClassFromString(@"CTCarrier"));
        if (carrierClass != nil)
        {
            CTCarrier *carrier = telephonyNetworkInfo.subscriberCellularProvider;
            
            // 移动运营商的mcc 和 mnc
            NSString * mobileCountryCode = [carrier mobileCountryCode];
            NSString * mobileNetworkCode = [carrier mobileNetworkCode];
            
            // 统计能够取到信息的运营商
            if ((mobileCountryCode != nil) && (mobileNetworkCode != nil))
            {
                NSString *mobileCode = [[NSString alloc] initWithFormat:@"%@%@", mobileCountryCode, mobileNetworkCode];
                return mobileCode;
            }
        }
    }
    
    return nil;
}

// 网络类型：wifi/3G
+ (NSString *)netType
{
    Reachability *curReach = [Reachability reachabilityForInternetConnection];
    
    // 获得网络状态
    NetworkStatus netStatus = [curReach currentReachabilityStatus];
    switch (netStatus)
    {
        case NotReachable:
        {
            return nil;
        }
            break;
            
        case ReachableViaWWAN:
        {
            // 判断是否能够取得运营商
            Class telephoneNetWorkClass = (NSClassFromString(@"CTTelephonyNetworkInfo"));
            if (telephoneNetWorkClass != nil)
            {
                CTTelephonyNetworkInfo *telephonyNetworkInfo = [[CTTelephonyNetworkInfo alloc] init];
                
                if ([telephonyNetworkInfo respondsToSelector:@selector(currentRadioAccessTechnology)])
                {
                    // 7.0 系统的适配处理。
                    
                    return [NSString stringWithFormat:@"%@",telephonyNetworkInfo.currentRadioAccessTechnology];
                }
            }
            
            return @"2g/3g";
        }
            break;
            
        case ReachableViaWiFi:
        {
            return @"wifi";
        }
            break;
            
        default:
            break;
    }
    
    return nil;
}

+ (BOOL)isSingleLine
{
    Dl_info info;
    
    IMP startUpdatingLocationIMP = class_getMethodImplementation(objc_getClass("CLLocationManager"),
                                                                 sel_registerName("startUpdatingLocation"));
    
    if (dladdr(startUpdatingLocationIMP, &info)) {
        
        if (0 != strcmp(info.dli_fname, "/System/Library/Frameworks/CoreLocation.framework/CoreLocation")) {
            return YES;
        }
    }
    
    IMP setDelegateIMP = class_getMethodImplementation(objc_getClass("CLLocationManager"),
                                                       sel_registerName("setDelegate:"));
    
    if (dladdr(setDelegateIMP, &info)) {
        
        if (0 != strcmp(info.dli_fname, "/System/Library/Frameworks/CoreLocation.framework/CoreLocation")) {
            return YES;
        }
    }
    
    return NO;
}

// 设置和获取本地时间和服务器的时差
+ (void)setServerTimeLag:(double)utcTime
{
    [[AppInfo getInstance] setAppServerTimeLag:[NSNumber numberWithDouble:utcTime]];
    [AppInfo saveAppInfo];
}

+ (NSNumber *)serverTimeLag
{
    return [[AppInfo getInstance] appServerTimeLag];
}

// 设置当前服务器时间
+ (NSDate *)nowServerTime
{
    NSDate *date = [NSDate date];
    
    NSNumber *serverTimeDiff = [[AppInfo getInstance] appServerTimeLag];
    if (serverTimeDiff != nil)
    {
        date = [date dateByAddingTimeInterval:[serverTimeDiff doubleValue]];
    }
    
    return date;
}

// 获取和设置交互日志开关状态
+ (NSNumber *)statisticsSwitch
{
    return [[AppInfo getInstance] appStatisticsSwitch];
}

+ (void)setStatisticsSwitch:(NSNumber *)switchValue
{
    [[AppInfo getInstance] setAppStatisticsSwitch:switchValue];
    [AppInfo saveAppInfo];
}

// 获取和设置QRequestID，改ID由UELog操作事件触发生成新的ID
+ (NSString *)QRequestID
{
    if ([[AppInfo getInstance] qRequestID] == nil)
    {
        long long timeIntervalNow = (long long)([[AppInfo nowServerTime] timeIntervalSince1970] * 1000);
        [AppInfo updateQRequestID:timeIntervalNow];
    }
    
    return [[AppInfo getInstance] qRequestID];
}

+ (NSString *)updateQRequestID:(long long)seed
{
    NSString *timeStr = [[NSString alloc] initWithFormat:@"%lld", seed];
    [[AppInfo getInstance] setQRequestID:timeStr];
    return timeStr;
}

// 获取和设置IP服务器URL
+ (NSString *)IPServerURL
{
    return [[AppInfo getInstance] ipServerURL];
}

+ (void)setIPServerURL:(NSString *)ipServerURL
{
    [[AppInfo getInstance] setIpServerURL:ipServerURL];
    [AppInfo saveAppInfo];
}


// App的scheme，该方法会根据App的不同添加不同的scheme头
+ (NSString *)appQunarIPhoneSchemeString:(NSString *)string
{
    NSString *qunarString = [NSString stringWithFormat:@"%@://%@",[AppInfo QunarIPhoneScheme],string];
    return qunarString;
}

+ (void)saveAppInfo
{
    [StorageManager saveDataWithObject:[AppInfo getInstance] withModule:kFrameworkModuleName withKey:kAppInfoKey];
}

#if (BETA_BUILD == 1)
// 服务器地址开关
+ (BOOL)isOpenBetaDebug
{
    NSNumber *appBetaDebug = [[AppInfo getInstance] appBetaDebug];
    
    if (appBetaDebug != nil && [appBetaDebug boolValue] == YES)
    {
        return YES;
    }
    
    return NO;
}

+ (void)setOpenBetaDebug:(NSNumber *)isOpenDebug
{
    [[AppInfo getInstance] setAppBetaDebug:isOpenDebug];
    [AppInfo saveAppInfo];
}

// 打印统计日志开关
+ (BOOL)isOpenStatisticsLog
{
    NSNumber *appStatisticsLog = [[AppInfo getInstance] appStatisticsLog];
    
    if ([AppInfo isOpenBetaDebug] == YES && appStatisticsLog != nil && [appStatisticsLog boolValue] == YES)
    {
        return YES;
    }
    
    return NO;
}

+ (void)setOpenStatisticsLog:(NSNumber *)isOpenLog
{
    [[AppInfo getInstance] setAppStatisticsLog:isOpenLog];
    [[StatisticsUELog getInstance] openShowLog:[isOpenLog boolValue]];
    [AppInfo saveAppInfo];
}

// JSPatch debugView展示以及开关状态
+ (BOOL)isOpenJSPatch
{
    NSNumber *appJSPatch = [[AppInfo getInstance] appJSPatch];
    
    if ([AppInfo isOpenBetaDebug] == YES && appJSPatch != nil && [appJSPatch boolValue] == YES)
    {
        return YES;
    }
    
    return NO;
}

+ (void)setOpenJSPatch:(NSNumber *)isOpenJSPatch
{
    [[AppInfo getInstance] setAppJSPatch:isOpenJSPatch];
    [AppInfo saveAppInfo];
}

#endif

@end
