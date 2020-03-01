//
//  AppInfo.h
//  CommonFramework
//
//  Created by zhoujinfeng on 4/10/15.
//  Copyright (c) 2015 Qunar.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AppInfoPrt.h"
#import <UIKit/UIKit.h>
@interface AppInfo : NSObject <AppInfoPrt>

/**
 *  获取当前App所占屏幕的大小
 *
 *  @return 返回屏幕大小
 */
+ (CGRect)appFrame;

/**
 *  获取客户端 gid：gid 由服务端生成，保证唯一性，但无法进行有效性校验
 *
 *  @return 返回gid字符串
 */
+ (NSString *)appGID;
+ (void)setAppGID:(NSString *)appGIDNew;

/**
 *  返回客户端 Server ID：sid 由服务端生成派发，保证唯一性，且可进行有效性校验
 *
 *  @return 返回sid字符串
 */
+ (NSString *)appSID;
+ (void)setAppSID:(NSString *)appSIDNew;

// 机器的唯一标识
/**
 *  返回 aid : aid由客户端生成，早期用来替代UDID，后Apple推出了identifyForVendor，这个字端基本废弃了
 *
 *  @return 返回aid
 */
+ (NSString *)appAID;

/**
 *  机器的Mac地址：在iOS7之前用来替代UDID，iOS7后，该接口永远返回 02:00:00:00:00:00
 *
 *  @return 返回mac地址
 */
+ (NSString *)macAddress;

// 设备类型
/**
 *  返回设备类型：返回格式为 iPhone 2,1 | iPad 3,2 | iPod 4,1 形式的型号
 *  
 *  具体对应机型可在 https://www.theiphonewiki.com/wiki/Models 找到对应关系
 *
 *  @return 返回设备类型字符串
 */
+ (NSString *)deviceType;

/**
 *  系统版本
 *
 *  @return 返回当前系统版本
 */
+ (NSString *)systemVersion;

/**
 *  返回用户iPhone中SIM卡的运营商代号 MCC+MNC
 *
 *  具体MCC+MNC 对照可查看 https://en.wikipedia.org/wiki/Mobile_country_code
 *
 *  @return 返回用户iPhone中SIM卡的运营商
 */
+ (NSString *)carrierCode;

/**
 *  获取当前的网络类型：
 *      iOS7之前，Apple未开放网络类型相关的API，故只能判断是否是 蜂窝网络(2g/3g) 和 Wifi 网络
 *      iOS7后，Apple放出了该API，故当用户使用蜂窝网络时返回值为一个字符串宏，具体可参看 CoreTelephony/CTTelephonyNetworkInfo.h 中 "Radio Access Technology values" 的内容
 *
 *  @return 返回表示网络类型的字符串
 */
+ (NSString *)netType;

/**
 *  目前防作弊调用的代码
 *
 *  @return 返回当前是否进行了安装了Hook对位置作弊
 */
+ (BOOL)isSingleLine;

// 设置和
/**
 *  设置本地时间和服务器的时差
 *
 *  @param utcTime 设置与服务器时差
 */
+ (void)setServerTimeLag:(double)utcTime;

/**
 *  获取本地时间和服务器的时间差
 *
 *  @return 返回与服务器的时间差，单位为秒
 */
+ (NSNumber *)serverTimeLag;

/**
 *  获取当前服务器时间
 *
 *  @return 返回当前服务器时间的NSDate对象
 */
+ (NSDate *)nowServerTime;

/**
 *  获取交互日志开关状态
 *
 *  @return 交互日志开关状态
 */
+ (NSNumber *)statisticsSwitch;
+ (void)setStatisticsSwitch:(NSNumber *)switchValue;

/**
 *  获取QRequestID，改ID由UELog操作事件触发生成新的ID
 *
 *  @return QRequestID
 */
+ (NSString *)QRequestID;

/**
 *  获取IP服务器URL：该地址由公共业务维护，其它业务请勿设置
 *
 *  @return IP服务器URL
 */
+ (NSString *)IPServerURL;
+ (void)setIPServerURL:(NSString *)ipServerURL;

/**
 *  给出URL不包含Scheme header的部分，根据所使用的客户端天假Scheme头
 *
 *  @param string URL除去Scheme头的部分
 *
 *  @return 返回添加了Scheme Header后的URL字符串
 */
+ (NSString *)appQunarIPhoneSchemeString:(NSString *)string;

#if (BETA_BUILD == 1)
/**
 *  获取服务器地址开关状态
 *
 *  @return 服务器地址开关状态
 */
+ (BOOL)isOpenBetaDebug;
+ (void)setOpenBetaDebug:(NSNumber *)isOpenDebug;

/**
 *  获取打印统计日志开关状态
 *
 *  @return 打印统计日志开关状态
 */
+ (BOOL)isOpenStatisticsLog;
+ (void)setOpenStatisticsLog:(NSNumber *)isOpenLog;

/**
 *  获取JSPatch debugView展示以及开关状态
 *
 *  @return JSPatch开关状态
 */
+ (BOOL)isOpenJSPatch;
+ (void)setOpenJSPatch:(NSNumber *)isOpenJSPatch;

#endif

@end
