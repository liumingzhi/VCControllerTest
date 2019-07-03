//
//  DetailVC.h
//  pushTest
//
//  Created by mingzhi.liu on 15/12/14.
//  Copyright © 2015年 mingzhi.liu. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol DetailVCDelegate <NSObject>

-(void)btnClickCallBack;

@end

@interface DetailVC : UIViewController
@property (nonatomic, assign, readonly) BOOL isShow;                            // 是否在显示
@property (nonatomic, weak) id<DetailVCDelegate>delegate;

-(void)dissMissView;

-(void)showInParent:(UIView *)parentView;

@end
