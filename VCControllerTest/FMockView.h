//
//  FMockView.h
//  VCControllerTest
//
//  Created by mingzhi.liu on 17/3/21.
//  Copyright © 2017年 mingzhi.liu. All rights reserved.
//

#import <UIKit/UIKit.h>

@class FMockView;

@protocol FMockViewDelegate <NSObject>

-(void)mockViewClick:(FMockView *)mockView;

@end


typedef NS_ENUM(NSUInteger, ZYSuspensionViewLeanType) {
    /** Can only stay in the left and right */
    ZYSuspensionViewLeanTypeHorizontal,
    /** Can stay in the upper, lower, left, right */
    ZYSuspensionViewLeanTypeEachSide
};



@interface FMockView : UIButton

@property (nonatomic, strong) UIWindow *backWindow;
@property (nonatomic, weak) id<FMockViewDelegate>delegate;
@property (nonatomic, assign) ZYSuspensionViewLeanType leanType;



/**
 Create a susView
 
 @param frame frame
 @param color background color
 @param delegate delegate for susView
 @return obj
 */
- (instancetype)initWithFrame:(CGRect)frame color:(UIColor*)color delegate:(id<FMockViewDelegate>)delegate;


/**
 *  show
 */
- (void)show;













@end
