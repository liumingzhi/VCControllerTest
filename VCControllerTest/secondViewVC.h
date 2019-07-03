//
//  secondViewVC.h
//  pushTest
//
//  Created by mingzhi.liu on 15/12/14.
//  Copyright © 2015年 mingzhi.liu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface secondViewVC : UIViewController 
@property (nonatomic,strong) void(^saveBlock)(NSString *);
-(void)secondViewTest;
@end
