//
//  AppInfo.h
//  CommonFramework
//
//  Created by zhoujinfeng on 4/10/15.
//  Copyright (c) 2015 Qunar.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol AppInfoPrt <NSObject>

@required

// appName
+ (NSString *)appName;

// appGroupID
+ (NSString *)appGroupID;

// vid
+ (NSString *)appVID;

// pid
+ (NSString *)appPID;

// cid
+ (NSString *)appCID;

// iid
+ (NSString *)appIID;

// aid
+ (NSString *)appAID;

// 加密版本
+ (NSString *)keyVersion;

// Pitcher代理服务器地址
+ (NSString *)proxyURL;

// 服务器地址
+ (NSString *)serverURL;

// 图片上传服务器地址
+ (NSString *)picUploadServer;

// 获取当前APP的Scheme跳转协议头
+ (NSString *)QunarIPhoneScheme;

// 获取当前APP的支付宝Scheme跳转协议头
+ (NSString *)QunarIPhoneAlipayScheme;

// 获取当前APP的微信Scheme跳转协议头
+ (NSString *)QunarIPhoneWechatScheme;

// 获取当前APP的携程Scheme跳转协议头
+ (NSString *)QunarIPhoneCtripScheme;

@optional

// uid
+ (NSString *)appUID;

// vendorUID
+ (NSString *)vendorUID;

// deviceUID
+ (NSString *)deviceUID;


@end
