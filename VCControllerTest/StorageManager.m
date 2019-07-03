//
//  DataManager.m
//  CommonFramework
//
//  Created by zhoujinfeng on 4/14/15.
//  Copyright (c) 2015 Qunar.com. All rights reserved.
//

#import "StorageManager.h"
#import "DataStruct.h"
#import <objc/runtime.h>
#import "NSString+Hex.h"
@implementation StorageManager

// 通过module和key来存储对象,数据结构的版本号和数据内容的版本号则会为nil
+ (BOOL)saveDataWithObject:(id)object withModule:(NSString *)module withKey:(NSString *)key
{
    return [StorageManager saveDataWithObject:object withStructVersion:nil withDataVersion:nil withModule:module withKey:key];
    
    return NO;
}

// 通过数据结构版本、数据内容版本、module和key来存储对象
+ (BOOL)saveDataWithObject:(id)object
         withStructVersion:(NSString *)structVersion
           withDataVersion:(NSString *)dataVersion
                withModule:(NSString *)module
                   withKey:(NSString *)key
{
    if (module == nil || [module length] <= 0 || key == nil  || [key length] <= 0)
    {
        return NO;
    }
    
    DataStruct *dataStruct = [DataStruct createDataStructWithObject:object withStructVersion:structVersion andDataVersion:dataVersion];
    
    if (dataStruct == nil)
    {
        return NO;
    }
    
    // 获取document文件夹位置
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentDirectory = [paths objectAtIndex:0];

    // 存储目录
    NSString *directoryPath = [documentDirectory stringByAppendingPathComponent:[[NSString alloc] initWithFormat:@"/%@", [module hexStringFromString:module]]];

    //如果文件夹不存在,那么建立这个文件夹
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if([fileManager fileExistsAtPath:directoryPath] == NO)
    {
        [fileManager createDirectoryAtPath:directoryPath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    
    // 保存文件
    NSString *filePath = [directoryPath stringByAppendingPathComponent:[[NSString alloc] initWithFormat:@"/%@", [key hexStringFromString:key]]];

    NSData *data = [dataStruct data];
    return [data writeToFile:filePath atomically:YES];
}

// 通过module和key来删除存储数据
+ (void)deleteDataWithModule:(NSString *)module withKey:(NSString *)key
{
    if (module == nil || [module length] <= 0 || key == nil  || [key length] <= 0)
    {
        return;
    }
    
    // 获取document文件夹位置
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentDirectory = [paths objectAtIndex:0];
    
    // 存储目录
    NSString *filePath = [documentDirectory stringByAppendingPathComponent:[[NSString alloc] initWithFormat:@"/%@/%@", [module hexStringFromString:module], [key hexStringFromString:key]]];

    //如果文件夹不存在,那么建立这个文件夹
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if([fileManager fileExistsAtPath:filePath] == YES)
    {
        [fileManager removeItemAtPath:filePath error:nil];
    }
}

// 通过module和key来取数据结构版本
+ (NSString *)structVersionWithModule:(NSString *)module withKey:(NSString *)key
{
    DataStruct *dataStruct = [StorageManager dataStructWithModule:module withKey:key];
    
    return [dataStruct structVersion];
}

// 通过module和key来取数据内容版本
+ (NSString *)dataVersionWithModule:(NSString *)module withKey:(NSString *)key
{
    DataStruct *dataStruct = [StorageManager dataStructWithModule:module withKey:key];

    return [dataStruct dataVersion];
}

+ (DataStruct *)dataStructWithModule:(NSString *)module withKey:(NSString *)key
{
    // 获取document文件夹位置
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentDirectory = [paths objectAtIndex:0];
    
    // 加载文件
    NSString *filePath = [documentDirectory stringByAppendingPathComponent:[[NSString alloc] initWithFormat:@"/%@/%@", [module hexStringFromString:module], [key hexStringFromString:key]]];
        
    NSData *data = [[NSData alloc] initWithContentsOfFile:filePath];
    
    return [DataStruct createDataStructWithData:data];
}

// 通过module和key来取对应的数据
// 如果merge对象实现了DataStoragePrt协议方法，则会在存储的数据结构和对象的数据结构或数据结构版本或数据版本有差异的时候回调DataStoragePrt协议方法
// 差异的情况是指：1、对象的属性名的类型发生变化(包括属性名的类型发生变化或属性名的对应的类不存在)；2、数据对应的数据类不存在
// 注意：NSString和NSMutableString、NSData和NSMutableData、NSArray和NSMutableArray、NSDictionary和NSMutableDictionary的变化也会忽略
+ (id)objectWithModule:(NSString *)module withKey:(NSString *)key withMerge:(id<MergeDataStoragePrt>)merge
{
    DataStruct *dataStruct = [StorageManager dataStructWithModule:module withKey:key];
    
    if (dataStruct == nil)
    {
        return nil;
    }
    
    id object = [dataStruct objectWithDataStruct];
    
    if (object != nil)
    {
        return object;
    }
    else
    {
        if (merge != nil
            && class_conformsToProtocol([merge class], @protocol(MergeDataStoragePrt)) == YES
            && class_getClassMethod([merge class], @selector(mergeDataWithOriginData:withAppVID:withStructVersion:withDataVersion:withModule:withKey:)) !=  nil)
        {
            return [[merge class] mergeDataWithOriginData:[dataStruct dataVaule] withAppVID:[dataStruct appVID] withStructVersion:[dataStruct structVersion] withDataVersion:[dataStruct dataVersion] withModule:module withKey:key];
        }
    }
    
    return nil;
}

@end
