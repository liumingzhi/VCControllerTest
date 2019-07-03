//
//  FMockView.m
//  VCControllerTest
//
//  Created by mingzhi.liu on 17/3/21.
//  Copyright © 2017年 mingzhi.liu. All rights reserved.
//

#import "FMockView.h"

@implementation FMockView

- (instancetype)initWithFrame:(CGRect)frame color:(UIColor*)color delegate:(id<FMockViewDelegate>)delegate
{
    if(self = [super initWithFrame:frame])
    {
        self.delegate = delegate;
        self.userInteractionEnabled = YES;
        self.backgroundColor = color;
        self.alpha = .7;
        self.titleLabel.font = [UIFont systemFontOfSize:14];
        self.layer.borderColor = [UIColor whiteColor].CGColor;
        self.layer.borderWidth = 1.0;
        self.clipsToBounds = YES;
        
        UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(handlePanGesture:)];
        pan.delaysTouchesBegan = YES;
        [self addGestureRecognizer:pan];
        [self addTarget:self action:@selector(click) forControlEvents:UIControlEventTouchUpInside];
    }
    return self;
}

-(void)show
{
    _backWindow = [[UIWindow alloc] initWithFrame:self.frame];
    _backWindow.windowLevel = UIWindowLevelAlert * 2;
    [_backWindow makeKeyAndVisible];
    
    self.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
    self.layer.cornerRadius = self.frame.size.width <= self.frame.size.height ? self.frame.size.width / 2.0 : self.frame.size.height / 2.0;
    [_backWindow addSubview:self];
}

#pragma mark - event response
- (void)handlePanGesture:(UIPanGestureRecognizer*)p
{
    UIWindow *appWindow = [UIApplication sharedApplication].delegate.window;
    CGPoint panPoint = [p locationInView:appWindow];
    
    if(p.state == UIGestureRecognizerStateBegan) {
        self.alpha = 1;
    }else if(p.state == UIGestureRecognizerStateChanged) {
        
        
        // [ZYSuspensionManager windowForKey:self.md5Key].center = CGPointMake(panPoint.x, panPoint.y);
        
        
        _backWindow.center = CGPointMake(panPoint.x, panPoint.y);
    }else if(p.state == UIGestureRecognizerStateEnded
             || p.state == UIGestureRecognizerStateCancelled) {
        self.alpha = .7;
        
        CGFloat ballWidth = self.frame.size.width;
        CGFloat ballHeight = self.frame.size.height;
        CGFloat screenWidth = [[UIScreen mainScreen] bounds].size.width;
        CGFloat screenHeight = [[UIScreen mainScreen] bounds].size.height;
        
        CGFloat left = fabs(panPoint.x);
        CGFloat right = fabs(screenWidth - left);
        CGFloat top = fabs(panPoint.y);
        CGFloat bottom = fabs(screenHeight - top);
        
        CGFloat minSpace = 0;
        if (self.leanType == ZYSuspensionViewLeanTypeHorizontal) {
            minSpace = MIN(left, right);
        }else{
            minSpace = MIN(MIN(MIN(top, left), bottom), right);
        }
        CGPoint newCenter = CGPointZero;
        CGFloat targetY = 0;
        
        //Correcting Y
        if (panPoint.y < 15 + ballHeight / 2.0) {
            targetY = 15 + ballHeight / 2.0;
        }else if (panPoint.y > (screenHeight - ballHeight / 2.0 - 15)) {
            targetY = screenHeight - ballHeight / 2.0 - 15;
        }else{
            targetY = panPoint.y;
        }
        
        if (minSpace == left) {
            newCenter = CGPointMake(ballHeight / 3, targetY);
        }else if (minSpace == right) {
            newCenter = CGPointMake(screenWidth - ballHeight / 3, targetY);
        }else if (minSpace == top) {
            newCenter = CGPointMake(panPoint.x, ballWidth / 3);
        }else {
            newCenter = CGPointMake(panPoint.x, screenHeight - ballWidth / 3);
        }
        
        [UIView animateWithDuration:.25 animations:^{
            // [ZYSuspensionManager windowForKey:self.md5Key].center = newCenter;
            
            _backWindow.center = newCenter;
        }];
    }else{
        NSLog(@"pan state : %zd", p.state);
    }
}

- (void)click
{
    if([self.delegate respondsToSelector:@selector(mockViewClick:)])
    {
        [self.delegate mockViewClick:self];
    }
}


@end
