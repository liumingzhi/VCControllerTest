//
//  UIView+TouchIconAnimate.m
//  Lianjia_Beike_Home
//
//  Created by mingzhi.liu on 2019/4/26.
//

#import "UIView+TouchIconAnimate.h"
#import <objc/runtime.h>

@interface LJHomePageTouchIconHandler : UIPanGestureRecognizer <UIGestureRecognizerDelegate>
@property (nonatomic, assign) BOOL didFinished;
@end

@implementation LJHomePageTouchIconHandler

- (void)dealloc
{
    [self removeObserver:self forKeyPath:@"state"];
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.delegate = self;
        self.cancelsTouchesInView = NO;
        
       [self addObserver:self forKeyPath:@"state" options:NSKeyValueObservingOptionOld | NSKeyValueObservingOptionNew context:nil];
    }
    return self;
}
 
// 监听手势状态
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context
{
    // 复原动画
    self.view.transform = CGAffineTransformIdentity;
    self.view.alpha = 1;
}

#pragma mark - UIGestureRecognizerDelegate
// 手指接触屏幕的回调方法，返回NO则不进行手势识别
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
   // 放大动画
    self.view.alpha = 1;
    [UIView animateWithDuration:0.25 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        self.view.alpha = 0;
        self.view.transform = CGAffineTransformMakeScale(2.5, 2.5);
        self.didFinished = NO;
        
    } completion:^(BOOL finished) {
        self.didFinished = YES;
    }];
    
    return YES;
}

// 是否支持多手势触发，返回YES，则可以多个手势一起触发方法，返回NO则为互斥
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return YES;
}

// 这个方法返回YES，第一个手势和第二个互斥时，第一个会失效，即当前手势失效
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRequireFailureOfGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return YES;
}

@end



@implementation UIView (TouchIconAnimate)

- (void)setShowTouchIconAnimate:(BOOL)showTouchIconAnimate
{
    UIPanGestureRecognizer *gesture = objc_getAssociatedObject(self, &self);
    
    if (showTouchIconAnimate && !gesture) {
        LJHomePageTouchIconHandler *gesture = [[LJHomePageTouchIconHandler alloc] init];
        gesture.cancelsTouchesInView = !self.userInteractionEnabled;
        [self addGestureRecognizer:gesture];
        self.userInteractionEnabled = YES;
        
        objc_setAssociatedObject(self, &self, gesture, OBJC_ASSOCIATION_ASSIGN);
    }
    // 移除动效
    else if (! showTouchIconAnimate && gesture){
        [self removeGestureRecognizer:gesture];
    }
}

- (BOOL)showTouchIconAnimate
{
    UIPanGestureRecognizer *gesture = objc_getAssociatedObject(self, &self);
    return gesture != nil;
}

@end
