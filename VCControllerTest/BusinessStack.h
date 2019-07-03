//
//  BusinessStack.h
//  Pods
//
//  Created by Quanquan.zhang on 16/4/12.
//
//

#import <Foundation/Foundation.h>

@interface BusinessStack : NSObject

/**
 *  当前业务线名称
 */
@property (nonatomic, readonly) NSString *currentBusiness;

+ (instancetype)sharedInstance;

#pragma mark Scheme
- (void)beginIgnoringScheme;
- (void)endIgnoringScheme;

- (void)willJumpToURL:(NSURL *)jumpURL;
- (void)didReturnFromURL:(NSURL *)jumpURL;

#pragma mark VC
- (void)willPop:(NSNumber *)popVCNumber PushToVC:(NSString *)vcName;

@end
