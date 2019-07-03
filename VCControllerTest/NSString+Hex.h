//
//  NSString+Hex.h
//  CommonFramework
//
//  Created by zhoujinfeng on 4/14/15.
//  Copyright (c) 2015 Qunar.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (Hex)

// 十六进制转换为普通字符串的。
- (NSString *)stringFromHexString:(NSString *)hexString;

//普通字符串转换为十六进制的
- (NSString *)hexStringFromString:(NSString *)string;

@end
