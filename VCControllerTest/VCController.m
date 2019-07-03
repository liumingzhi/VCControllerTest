//
//  VCController.m
//  QunariPhone
//
//  Created by 姜琢 on 12-11-12.
//  Copyright (c) 2012年 Qunar.com All rights reserved.
//

#import "VCController.h"
#import "AppInfo.h"
#import "UIView+Frame.h"
//#import "StatisticsUELog.h"
#import "BusinessStack.h"

#define kMaxRightGuestureTouchWidth                         44
#define kMaxValidGuestureMoveWidth                          20


// 全局数据控制器
static VCController *globalVCController = nil;

// UELog私有方法声明
//@interface StatisticsUELog (private_VCController)
//- (void)addStatisticsWithFromVC:(UIViewController *)from toVC:(UIViewController *)to;
//@end

@interface RootVCController : UIViewController



@end

@implementation RootVCController

// 设置StatusBar控制的ViewController
- (UIViewController *)childViewControllerForStatusBarStyle
{
    if ([[[[UIApplication sharedApplication] delegate] window] rootViewController] == nil)
    {
        return self;
    }
    
    if ([[[[UIApplication sharedApplication] delegate] window] rootViewController] == self)
    {
        return [VCController getTopVC];
    }
    
    return nil;
}

// 设置StatusBar控制的ViewController
- (UIViewController *)childViewControllerForStatusBarHidden
{
    if ([[[[UIApplication sharedApplication] delegate] window] rootViewController] == nil)
    {
        return self;
    }
    
    if ([[[[UIApplication sharedApplication] delegate] window] rootViewController] == self)
    {
        return [VCController getTopVC];
    }
    
    return nil;
}

@end


//VCController
@interface VCController ()

@property (nonatomic, strong) NSMutableArray *arrayVCSubs;  // VC堆栈
@property (nonatomic, strong) RootVCController *rootBaseVController; // 根ViewdeController
@property (nonatomic, strong) UIView  *rootBaseView;      // 根View

@property (nonatomic, assign) NSInteger spotWidth;          // 视野宽度
@property (nonatomic, assign) BOOL isPaning;                // 是否在滑动中
@property (nonatomic, assign) CGPoint lastGuestPoint;       // 上一次滑动的坐标
@property (nonatomic, assign) CGFloat rightMoveLenght;      // 向右滑动的距离
@property (nonatomic, strong) UIView  *maskView;

@end

@implementation VCController

+ (id)mainVCC
{
    @synchronized(self)
    {
        // 实例对象只分配一次
        if(globalVCController == nil)
        {
            globalVCController = [[super allocWithZone:NULL] init];
            
            RootVCController *rootBaseVController = [[RootVCController alloc] init];
            [[rootBaseVController view] setFrame:CGRectMake(0, 0, [AppInfo appFrame].size.width, [AppInfo appFrame].size.height)];
            [[rootBaseVController view] setBackgroundColor:[UIColor whiteColor]];
            [globalVCController setRootBaseVController:rootBaseVController];
            [globalVCController setRootBaseView:[rootBaseVController view]];
                        
            [[[[UIApplication sharedApplication] delegate] window] addSubview:[globalVCController rootBaseView]];
            [[[[UIApplication sharedApplication] delegate] window] setRootViewController:rootBaseVController];
            
            UIView *maskView = [[UIView alloc] initWithFrame:[AppInfo appFrame]];
            [maskView setBackgroundColor:[UIColor clearColor]];
            [globalVCController setMaskView:maskView];
            
            // 视野范围默认设置为屏幕size(!!!所有的VCSize的宽度必须保持和spotWidth保持一致，否者无法处理动画效果)
            globalVCController.spotWidth = [AppInfo appFrame].size.width;
        }
    }
    
    return globalVCController;
}

+ (id)allocWithZone:(NSZone *)zone
{
    return [VCController mainVCC];
}

- (instancetype)copyWithZone:(NSZone *)zone
{
    return [VCController mainVCC];
}

#pragma mark - 管理视图控制器
// =======================================================================
// 管理视图控制器
// =======================================================================
// 还原
+ (void)goOriginal
{
	UIViewController *frontVC = [[[VCController mainVCC] arrayVCSubs] lastObject];
	
    UIViewController *backVC = nil;
	NSInteger vcCount = [[[VCController mainVCC] arrayVCSubs] count];
	if(vcCount >= 2)
	{
		backVC = [[[VCController mainVCC] arrayVCSubs] objectAtIndex:vcCount - 2];
	}
	
    [[UIApplication sharedApplication] beginIgnoringInteractionEvents];

	[UIView animateWithDuration:0.2
						  delay:0
						options:UIViewAnimationOptionCurveEaseIn
					 animations:^{
						 [backVC.view setViewX:-([[VCController mainVCC] spotWidth] / 3)];
						 [frontVC.view setViewX:0];
					 }
                     completion:^(BOOL finished){
                         [[backVC view] setViewX:0];
//                         [[backVC view] removeFromSuperview];
                         
                         [[UIApplication sharedApplication] endIgnoringInteractionEvents];
                     }];
}

// 询问delegate是否允许手势接收者接收一个touch对象
// 返回YES，则允许对这个touch对象审核，NO，则不允许。
// 这个方法在touchesBegan:withEvent:之前调用，为一个新的touch对象进行调用
// 注意需要横划操作的控件需要在这里添加例外
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    NSLog(@"shouldReceiveTouch");
    CGPoint translatedPoint = [touch locationInView:[gestureRecognizer view]];
    
    if (translatedPoint.x > kMaxRightGuestureTouchWidth)
    {
        return NO;
    }
    
    UIViewController *topVC = [VCController getTopVC];
    
    if ([[touch view] isKindOfClass:NSClassFromString(@"Switch")])
    {
        return NO;
    }
    else if ([[[touch view] superview] isKindOfClass:NSClassFromString(@"FilterCheckSlider")])
    {
        return NO;
    }
    else if ([[[touch view] superview] isKindOfClass:NSClassFromString(@"FilterRedioSlider")])
    {
        return NO;
    }
    else if ([topVC conformsToProtocol:@protocol(VCControllerPtc)] == YES && [topVC respondsToSelector:@selector(ignoreGesture:)] == YES)
    {
        return ![((UIViewController<VCControllerPtc> *)topVC) ignoreGesture:[touch view]];
    }
    
    return YES;
}

- (void)handlePanFrom:(UIPanGestureRecognizer *)recognizer
{
    NSLog(@"handlePanFrom");

	NSInteger vcCount = [[[VCController mainVCC] arrayVCSubs] count];
	if(vcCount < 2)        // 只有2个或以下的VC时不允许进行右滑操作
	{
		return;
	}
	
	UIViewController<VCControllerPtc> *frontVC = [[[VCController mainVCC] arrayVCSubs] lastObject];
    if([VCController canRightPan:frontVC] == NO)       // 若VC当前不支持右滑操作则不处理
	{
		return;
	}
	
	UIViewController *backVC = [[[VCController mainVCC] arrayVCSubs] objectAtIndex:vcCount - 2];
    if(!_isPaning)  // 初始化backVC的状态
    {
        _spotWidth = [backVC view].frame.size.width;
        _lastGuestPoint = CGPointMake(0, 0);
        _rightMoveLenght = 0;
        [[backVC view] setViewX:-(_spotWidth / 3)];
        [[globalVCController maskView] removeFromSuperview];
        [[backVC view] addSubview:[globalVCController maskView]];
//        [[[VCController mainVCC] rootBaseView] insertSubview:[backVC view] belowSubview:[frontVC view]];
    }
    
    // 手势进行中
	if((recognizer.state == UIGestureRecognizerStateBegan)
        || (recognizer.state == UIGestureRecognizerStateChanged))
	{
        if(recognizer.state == UIGestureRecognizerStateBegan)
        {
            _isPaning = YES;
        }
        
        CGPoint translatedPoint = [recognizer translationInView:[recognizer view]];

        if(translatedPoint.x < 0)
        {
            translatedPoint.x = 0;
        }
        else if(translatedPoint.x > _spotWidth)
        {
            translatedPoint.x = _spotWidth;
        }
        
        // 向右滑动
        if (translatedPoint.x >= _lastGuestPoint.x)
        {
            // 相同方向
            if (_rightMoveLenght >= 0)
            {
                _rightMoveLenght += translatedPoint.x - _lastGuestPoint.x;
            }
            // 不同方向
            else
            {
                _rightMoveLenght = translatedPoint.x - _lastGuestPoint.x;
            }
        }
        // 向左滑动
        else
        {
            // 相同方向
            if (_rightMoveLenght <= 0)
            {
                _rightMoveLenght += translatedPoint.x - _lastGuestPoint.x;
            }
            // 不同方向
            else
            {
                _rightMoveLenght = translatedPoint.x - _lastGuestPoint.x;
            }
        }
        
        _lastGuestPoint = translatedPoint;
        
        // 调整frontVC和BackVC的位置
        NSInteger frontPosNew = translatedPoint.x;
        NSInteger backPosNew = (-_spotWidth + translatedPoint.x) / 3;
        [backVC.view setViewX:backPosNew];
        [frontVC.view setViewX:frontPosNew];
    }
	
	// STATE END
	if(recognizer.state == UIGestureRecognizerStateEnded ||
        recognizer.state == UIGestureRecognizerStateCancelled ||
        recognizer.state == UIGestureRecognizerStateFailed)
	{
        _isPaning = NO;
        [[globalVCController maskView] removeFromSuperview];

        // 当向左滑动超过一定距离的时候
        if (_rightMoveLenght < -kMaxValidGuestureMoveWidth)
        {
            // 归位
            [VCController goOriginal];
        }
        // 滑动超过一半
		else if(frontVC.view.frame.origin.x > (_spotWidth / 2))
		{
            // 是否额外控制了返回
            if([frontVC conformsToProtocol:@protocol(VCControllerPtc)])
            {
                UIViewController<VCControllerPtc> *frontVCTmp = (UIViewController<VCControllerPtc> *)frontVC;
                
                BOOL isDoNormal = YES;  // 是否走普通返回模式
                if([frontVCTmp respondsToSelector:@selector(canGoBack)])
                {
                    BOOL canGoBack = [frontVCTmp canGoBack];
                    if(!canGoBack)
                    {
                        isDoNormal = NO;
                        
                        [VCController goOriginal];
                        
                        // 是否
                        if([frontVCTmp respondsToSelector:@selector(doGoBack)])
                        {
                            [frontVCTmp doGoBack];
                        }
                    }
                }
                
                // 如果是走普通模式
                if(isDoNormal)
                {
                    [VCController willPop:[NSNumber numberWithInteger:1] PushToVC:nil];

                    // 动画
                    [[UIApplication sharedApplication] beginIgnoringInteractionEvents];
                    [[VCController mainVCC] removeVC:frontVC];
                    
                    [UIView animateWithDuration:0.15
                                          delay:0
                                        options:UIViewAnimationOptionCurveEaseOut
                                     animations:^{
                                         [[frontVC view] setViewX:_spotWidth];
                                         [[backVC view] setViewX:0];
                                     }
                                     completion:^(BOOL finished) {
                                         
                                         [[frontVC view] removeFromSuperview];
                                         [backVC viewWillAppear:YES];
                                         [backVC viewDidAppear:YES];
                                         
                                         [[[[[UIApplication sharedApplication] delegate] window] rootViewController] setNeedsStatusBarAppearanceUpdate];
                                         
                                         // 恢复VC的可用性
                                         [[UIApplication sharedApplication] endIgnoringInteractionEvents];
                                     }];
                    
                    [VCController addStatisticsWithFromVC:frontVC toVC:backVC];
                    
                    // 处理额外的事情
                    if([frontVCTmp respondsToSelector:@selector(doGoBack)])
                    {
                        [frontVCTmp doGoBack];
                    }
                }
            }
            else
            {
                [VCController willPop:[NSNumber numberWithInteger:1] PushToVC:nil];

                // 动画
                [[UIApplication sharedApplication] beginIgnoringInteractionEvents];
                [[VCController mainVCC] removeVC:frontVC];
                
                [UIView animateWithDuration:0.15
                                      delay:0
                                    options:UIViewAnimationOptionCurveEaseOut
                                 animations:^{
                                     [[frontVC view] setViewX:_spotWidth];
                                     [[backVC view] setViewX:0];
                                 }
                                 completion:^(BOOL finished) {
                                     
                                     [[frontVC view] removeFromSuperview];
                                     [backVC viewWillAppear:YES];
                                     [backVC viewDidAppear:YES];
                                     
                                     [[[[[UIApplication sharedApplication] delegate] window] rootViewController] setNeedsStatusBarAppearanceUpdate];
                                     
                                     // 恢复VC的可用性
                                     [[UIApplication sharedApplication] endIgnoringInteractionEvents];
                                 }];
                
                [VCController addStatisticsWithFromVC:frontVC toVC:backVC];
            }
		}
		else
		{
			// 归位
			[VCController goOriginal];
		}
        
        _rightMoveLenght = 0;
        _lastGuestPoint = CGPointMake(0, 0);
	}
}

// 通知VC事件并从栈里删除VC
- (void)removeVC:(UIViewController<VCControllerPtc> *)removeVC
{
    if (removeVC != nil)
    {
        if ([removeVC conformsToProtocol:@protocol(VCControllerPtc)] == YES
            && [removeVC respondsToSelector:@selector(vcWillPop)] == YES)
        {
            [removeVC vcWillPop];
        }
        
        [[[VCController mainVCC] arrayVCSubs] removeObject:removeVC];
    }
}

// 获取viewController的VCName
+ (NSString *)getVCName:(UIViewController *)viewController
{
    if (viewController == nil)
    {
        return nil;
    }
    
    NSString *vcName = nil;
    
    // 检查是否自定义了VCName
    if ([viewController respondsToSelector:@selector(getVCName)] == YES)
    {
        vcName = [(UIViewController <VCControllerPtc>*)viewController getVCName];
    }
    
    // 如果VCName为空，则取类名
    if (vcName == nil)
    {
        vcName = NSStringFromClass([viewController class]);
    }
    
    return vcName;
}

+ (BOOL)canRightPan:(UIViewController<VCControllerPtc> *)viewController
{
    if (viewController == nil)
    {
        return nil;
    }
    
    BOOL isCanRightPan = YES;
    
    // 检查是否自定义了VCName
    if ([viewController respondsToSelector:@selector(canRightPan)] == YES)
    {
        isCanRightPan = [viewController canRightPan];
    }
    
    return isCanRightPan;
}


// 获取节点
+ (UIViewController<VCControllerPtc> *)getVC:(NSString *)vcName
{
	// 获取window的子VC
	if ([[VCController mainVCC] arrayVCSubs] != nil)
	{
		NSInteger subsCount = [[[VCController mainVCC] arrayVCSubs] count];
		
		// 从上往下逐个遍历
		for (NSInteger i = 0; i < subsCount; i++)
		{
			UIViewController<VCControllerPtc> *viewController = [[[VCController mainVCC] arrayVCSubs] objectAtIndex:(subsCount - i - 1)];
            
            // 名称相同
            if ([[VCController getVCName:viewController] isEqualToString:vcName] == YES)
            {
                return viewController;
            }
		}
	}
	
	return nil;
}

// 获取最下层的
+ (UIViewController<VCControllerPtc> *)getTopVC
{
    // 获取window的子VC
    if ([[VCController mainVCC] arrayVCSubs] != nil)
    {
        NSInteger subsCount = [[[VCController mainVCC] arrayVCSubs] count];
        
        if (subsCount > 0)
        {
            UIViewController<VCControllerPtc> *baseNameVC = [[[VCController mainVCC] arrayVCSubs] objectAtIndex:subsCount - 1];
            return baseNameVC;
        }
    }
    
    return nil;
}

// 获取节点的下一层节点
+ (UIViewController<VCControllerPtc> *)getPreviousWithVC:(UIViewController<VCControllerPtc> *)baseNameVC
{
    if (baseNameVC  == nil)
    {
        return nil;
    }
    
    // 获取window的子VC
    if ([[VCController mainVCC] arrayVCSubs] != nil)
    {
        NSInteger subsCount = [[[VCController mainVCC] arrayVCSubs] count];
        
        // 从上往下逐个遍历
        for (NSInteger i = 0; i < subsCount; i++)
        {
            UIViewController<VCControllerPtc> *viewController = [[[VCController mainVCC] arrayVCSubs] objectAtIndex:(subsCount - i - 1)];
            
            // VC相同
            if (viewController == baseNameVC)
            {
                if (i + 1 < subsCount)
                {
                    return [[[VCController mainVCC] arrayVCSubs] objectAtIndex:(subsCount - i - 2)];
                }
            }
        }
    }
    
    return nil;
}

// 获取最下层的
+ (UIViewController<VCControllerPtc> *)getHomeVC
{
    // 获取window的子VC
    if ([[VCController mainVCC] arrayVCSubs] != nil)
    {
        NSInteger subsCount = [[[VCController mainVCC] arrayVCSubs] count];
        
        if (subsCount > 0)
        {
            UIViewController<VCControllerPtc> *baseNameVC = [[[VCController mainVCC] arrayVCSubs] objectAtIndex:0];
            return baseNameVC;
        }
    }
    
    return nil;
}

// 压入节点
+ (void)pushVC:(UIViewController<VCControllerPtc> *)baseNameVC WithAnimation:(id <VCAnimation>)animation
{
    [VCController beginIgnoringScheme];
    
	// 加载View
	if ([baseNameVC isViewLoaded] == NO)
	{
		[baseNameVC view];
	}
    
    [VCController endIgnoringScheme];
    
    [VCController willPop:[NSNumber numberWithInteger:0] PushToVC:[VCController getVCName:baseNameVC]];
	
    // 注册手势
    if([VCController canRightPan:baseNameVC] == YES)
    {
        UIPanGestureRecognizer *gesture = [[UIPanGestureRecognizer alloc] initWithTarget:[VCController mainVCC]
                                                                                                      action:@selector(handlePanFrom:)];
        [gesture setDelegate:[VCController mainVCC]];
        [gesture setMaximumNumberOfTouches:1];
        [[baseNameVC view] addGestureRecognizer:gesture];
    }
    
	// 往window中添加子VC
    if ([[VCController mainVCC] arrayVCSubs] != nil)
    {
		NSInteger subsCount = [[[VCController mainVCC] arrayVCSubs] count];
		if (subsCount > 0)
		{
            // 当前最前面的VC
            UIViewController<VCControllerPtc> *baseNameVCTop = [[[VCController mainVCC] arrayVCSubs] objectAtIndex:(subsCount - 1)];
			
			if (animation != nil)
			{
                [baseNameVCTop viewWillDisappear:YES];
                if(baseNameVC)
                {
                    [[[VCController mainVCC] arrayVCSubs] addObject:baseNameVC];
                }
                // 设置新的根节点
                
                [[[VCController mainVCC] rootBaseView] addSubview:[baseNameVC view]];
                
                CGRect originFrame = [[baseNameVCTop view] frame];
                
                // 动画
                [[UIApplication sharedApplication] beginIgnoringInteractionEvents];
				[animation pushAnimationFromTopVC:baseNameVCTop
									   ToArriveVC:baseNameVC
								   WithCompletion:^(BOOL finished) {
									   
                                       [[baseNameVCTop view] setFrame:originFrame];
//                                       [[baseNameVCTop view] removeFromSuperview];
                                       
                                       [baseNameVCTop viewDidDisappear:YES];
                                       
                                       [[[[[UIApplication sharedApplication] delegate] window] rootViewController] setNeedsStatusBarAppearanceUpdate];

									   // 恢复VC的可用性
									   [[UIApplication sharedApplication] endIgnoringInteractionEvents];
								   }];
			}
			else
			{
                [baseNameVCTop viewWillDisappear:NO];

                [[[VCController mainVCC] arrayVCSubs] addObject:baseNameVC];
                
				// 设置新的根节点
                [[baseNameVC view] setViewX:0];
                [[[VCController mainVCC] rootBaseView] addSubview:[baseNameVC view]];
                
                // 移除上一个VC
//                [[baseNameVCTop view] removeFromSuperview];
                [baseNameVCTop viewDidDisappear:NO];
                
                [[[[[UIApplication sharedApplication] delegate] window] rootViewController] setNeedsStatusBarAppearanceUpdate];
			}
            
            //UELog
            [VCController addStatisticsWithFromVC:baseNameVCTop toVC:baseNameVC];
        }
    }
    else
    {
		// 添加到队列中
		NSMutableArray *arrayVCSubsNew = [[NSMutableArray alloc] init];
		[[VCController mainVCC] setArrayVCSubs:arrayVCSubsNew];
        [[[VCController mainVCC] arrayVCSubs] addObject:baseNameVC];
        
        // 设置根VC
        [[baseNameVC view] setViewX:0];
        [[[VCController mainVCC] rootBaseView] addSubview:[baseNameVC view]];
        
        [[[[[UIApplication sharedApplication] delegate] window] rootViewController] setNeedsStatusBarAppearanceUpdate];
        
        //UELog
        [VCController addStatisticsWithFromVC:nil toVC:baseNameVC];
    }
    
}

// 弹出节点
+ (BOOL)popWithAnimation:(id <VCAnimation>)animation
{
	if ([[VCController mainVCC] arrayVCSubs] != nil)
	{
		NSInteger subsCount = [[[VCController mainVCC] arrayVCSubs] count];
		if (subsCount > 1)
		{
            // 获取顶层的VC
            UIViewController<VCControllerPtc> *baseNameVCTop = [[[VCController mainVCC] arrayVCSubs] objectAtIndex:(subsCount - 1)];
            
			// 下一个VC
			UIViewController<VCControllerPtc> *baseNameVCTopNew = [[[VCController mainVCC] arrayVCSubs] objectAtIndex:(subsCount - 2)];
            
            [VCController willPop:[NSNumber numberWithInteger:1] PushToVC:nil];
            
			if(animation != nil)
			{
                [[VCController mainVCC] removeVC:baseNameVCTop];
//                [[[VCController mainVCC] rootBaseView] addSubview:[baseNameVCTopNew view]];

                // 动画
                [[UIApplication sharedApplication] beginIgnoringInteractionEvents];
                [animation popAnimationFromTopVC:baseNameVCTop
                                      ToArriveVC:baseNameVCTopNew
                                  WithCompletion:^(BOOL finished) {
                                      
                                      [[baseNameVCTop view] removeFromSuperview];
                                      [baseNameVCTopNew viewWillAppear:YES];
                                      [baseNameVCTopNew viewDidAppear:YES];
                                      
                                      [[[[[UIApplication sharedApplication] delegate] window] rootViewController] setNeedsStatusBarAppearanceUpdate];
                                      
                                      // 恢复VC的可用性
                                      [[UIApplication sharedApplication] endIgnoringInteractionEvents];
                                  }];
			}
			else
			{
                // 获取顶层的VC
                UIViewController<VCControllerPtc> *baseNameVCTop = [[[VCController mainVCC] arrayVCSubs] objectAtIndex:(subsCount - 1)];
                
                // 从逻辑数组中删除VC
                [[VCController mainVCC] removeVC:baseNameVCTop];

                [[baseNameVCTop view] removeFromSuperview];
                
                // 下一个VC
                UIViewController<VCControllerPtc> *baseNameVCTopNew = [[[VCController mainVCC] arrayVCSubs] objectAtIndex:(subsCount - 2)];
                [[baseNameVCTopNew view] setViewX:0];
//                [[[VCController mainVCC] rootBaseView] addSubview:[baseNameVCTopNew view]];
                
                [baseNameVCTopNew viewDidAppear:NO];
                [[[[[UIApplication sharedApplication] delegate] window] rootViewController] setNeedsStatusBarAppearanceUpdate];
			}
			
            //UELog
            [VCController addStatisticsWithFromVC:baseNameVCTop toVC:baseNameVCTopNew];
            
			return YES;
		}
	}
	
	return NO;
}

// 弹出节点
+ (BOOL)popToVC:(NSString *)vcName WithAnimation:(id <VCAnimation>)animation
{
	if ([[VCController mainVCC] arrayVCSubs] != nil)
	{
		NSInteger subsCount = [[[VCController mainVCC] arrayVCSubs] count];
		
		// 从上往下逐个遍历
		for (NSInteger i = subsCount - 1; i >= 0; i--)
		{
			UIViewController<VCControllerPtc> *baseNameVCTopNew = [[[VCController mainVCC] arrayVCSubs] objectAtIndex:i];
			
            if ([[VCController getVCName:baseNameVCTopNew] isEqualToString:vcName] == YES)
			{
				// pop到当前VC，不做任何动作
				if (i == subsCount - 1)
				{
                    return YES;
				}
                
                [VCController willPop:[NSNumber numberWithInteger:(subsCount - i - 1)] PushToVC:nil];
                
                // 获取顶层的VC
                UIViewController<VCControllerPtc> *baseNameVCTop = [[[VCController mainVCC] arrayVCSubs] objectAtIndex:(subsCount - 1)];

				if (animation != nil)
				{
                    // 最上层节点
                    UIViewController<VCControllerPtc> *baseNameVCTop = [[[VCController mainVCC] arrayVCSubs] objectAtIndex:(subsCount - 1)];
                    
					// 从逻辑数据中删除目标节点之前的节点和其对应的maskView
                    for(NSUInteger j = subsCount - 2; j > i; j--)
                    {
                        UIViewController<VCControllerPtc> *baseNameVCTmp = [[[VCController mainVCC] arrayVCSubs] objectAtIndex:j];
                        [[VCController mainVCC] removeVC:baseNameVCTmp];
                        [[baseNameVCTmp view] removeFromSuperview];
                    }
					
                    // 添加VC
                    [[VCController mainVCC] removeVC:baseNameVCTop];
//                    [[[VCController mainVCC] rootBaseView] addSubview:[baseNameVCTopNew view]];
                    [baseNameVCTopNew viewWillAppear:YES];
                    
                    // 动画
                    [[UIApplication sharedApplication] beginIgnoringInteractionEvents];
                    [animation popAnimationFromTopVC:baseNameVCTop
                                          ToArriveVC:baseNameVCTopNew
                                      WithCompletion:^(BOOL finished) {
                                          
                                          [[baseNameVCTop view] removeFromSuperview];
                                          
                                          [baseNameVCTopNew viewDidAppear:YES];
                                          
                                          [[[[[UIApplication sharedApplication] delegate] window] rootViewController] setNeedsStatusBarAppearanceUpdate];
                                          
                                          // 恢复VC的可用性
                                          [[UIApplication sharedApplication] endIgnoringInteractionEvents];
                                      }];
				}
				else
				{
                    [baseNameVCTopNew viewWillAppear:NO];

                    // 循环删除目标节点之前的节点
                    for(NSUInteger j = subsCount - 1; j > i; j--)
                    {
                        UIViewController<VCControllerPtc> *baseNameVCTmp = [[[VCController mainVCC] arrayVCSubs] objectAtIndex:j];
                        
                        // 从逻辑数据中删除
                        [[VCController mainVCC] removeVC:baseNameVCTmp];

                        // 当前的根节点
                        [[baseNameVCTmp view] removeFromSuperview];
                    }
                    
                    // 设置新的根节点
                    [[baseNameVCTopNew view] setViewX:0];
//                    [[[VCController mainVCC] rootBaseView] addSubview:[baseNameVCTopNew view]];
                    
                    [baseNameVCTopNew viewDidAppear:NO];
                    
                    [[[[[UIApplication sharedApplication] delegate] window] rootViewController] setNeedsStatusBarAppearanceUpdate];
				}
				
                //UELog
                [VCController addStatisticsWithFromVC:baseNameVCTop toVC:baseNameVCTopNew];
                
				return YES;
			}
		}
	}
	
	return NO;
}

// 弹出节点然后压入节点
+ (BOOL)popThenPushVC:(UIViewController<VCControllerPtc> *)baseNameVC WithAnimation:(id <VCAnimation>)animation
{
    [VCController beginIgnoringScheme];
    
	// 加载View
	if ([baseNameVC isViewLoaded] == NO)
	{
		[baseNameVC view];
	}
    
    [VCController endIgnoringScheme];
	
    // 注册手势
    if([VCController canRightPan:baseNameVC] == YES)
    {
        UIPanGestureRecognizer *gesture = [[UIPanGestureRecognizer alloc] initWithTarget:[VCController mainVCC]
                                                                                  action:@selector(handlePanFrom:)];
        [gesture setDelegate:[VCController mainVCC]];
        [gesture setMaximumNumberOfTouches:1];
        [[baseNameVC view] addGestureRecognizer:gesture];
    }
    
	if ([[VCController mainVCC] arrayVCSubs] != nil)
	{
		NSInteger subsCount = [[[VCController mainVCC] arrayVCSubs] count];
		if (subsCount > 1)
		{
			// 获取顶层的VC
            UIViewController<VCControllerPtc> *baseNameVCTop = [[[VCController mainVCC] arrayVCSubs] objectAtIndex:(subsCount - 1)];
            
            [VCController willPop:[NSNumber numberWithInteger:1] PushToVC:[VCController getVCName:baseNameVC]];
            
			if (animation)
			{
                [[VCController mainVCC] removeVC:baseNameVCTop];
                
				// 设置新的根节点
				[[[VCController mainVCC] arrayVCSubs] addObject:baseNameVC];
                [[[VCController mainVCC] rootBaseView] addSubview:[baseNameVC view]];
                
                // 动画
				[[UIApplication sharedApplication] beginIgnoringInteractionEvents];
				[animation pushAnimationFromTopVC:baseNameVCTop
									   ToArriveVC:baseNameVC
								   WithCompletion:^(BOOL finished) {
									   
									   [[baseNameVCTop view] removeFromSuperview];
                                       
                                       [[[[[UIApplication sharedApplication] delegate] window] rootViewController] setNeedsStatusBarAppearanceUpdate];
                                       
									   // 恢复VC的可用性
									   [[UIApplication sharedApplication] endIgnoringInteractionEvents];
								   }];
			}
			else
			{
                // 从逻辑数据中删除
                [[VCController mainVCC] removeVC:baseNameVCTop];

				// 设置新的根节点
				[[[VCController mainVCC] arrayVCSubs] addObject:baseNameVC];
                [[[VCController mainVCC] rootBaseView] addSubview:[baseNameVC view]];
				
                [[baseNameVCTop view] removeFromSuperview];
                
                [[[[[UIApplication sharedApplication] delegate] window] rootViewController] setNeedsStatusBarAppearanceUpdate];
			}
		
            //UELog
            [VCController addStatisticsWithFromVC:baseNameVCTop toVC:baseNameVC];
            
			return YES;
		}
        else if (subsCount == 1)
        {
            [VCController pushVC:baseNameVC WithAnimation:animation];
        }
		else
		{
            [VCController willPop:[NSNumber numberWithInteger:0] PushToVC:[VCController getVCName:baseNameVC]];

			[[[VCController mainVCC] arrayVCSubs] addObject:baseNameVC];
			[[[VCController mainVCC] rootBaseView] addSubview:[baseNameVC view]];
            
            [[[[[UIApplication sharedApplication] delegate] window] rootViewController] setNeedsStatusBarAppearanceUpdate];
		}
	}
	else
	{
        [VCController willPop:[NSNumber numberWithInteger:0] PushToVC:[VCController getVCName:baseNameVC]];

		// 添加到队列中
		NSMutableArray *arrayVCSubsNew = [[NSMutableArray alloc] init];
		[[VCController mainVCC] setArrayVCSubs:arrayVCSubsNew];
        [[[VCController mainVCC] arrayVCSubs] addObject:baseNameVC];
        
        // 设置根VC
        [[baseNameVC view] setViewX:0];
        [[[VCController mainVCC] rootBaseView] addSubview:[baseNameVC view]];
        
        [[[[[UIApplication sharedApplication] delegate] window] rootViewController] setNeedsStatusBarAppearanceUpdate];
        
        //UELog
        [VCController addStatisticsWithFromVC:nil toVC:baseNameVC];
	}
	
	return NO;
}

// 弹出节点然后压入节点
+ (BOOL)popToVC:(NSString *)vcName thenPushVC:(UIViewController<VCControllerPtc> *)baseNameVC WithAnimation:(id <VCAnimation>)animation
{
    [VCController beginIgnoringScheme];
    
    // 加载View
	if ([baseNameVC isViewLoaded] == NO)
	{
		[baseNameVC view];
	}
    
    [VCController endIgnoringScheme];

    // 注册手势
    if([VCController canRightPan:baseNameVC] == YES)
    {
        UIPanGestureRecognizer *gesture = [[UIPanGestureRecognizer alloc] initWithTarget:[VCController mainVCC]
                                                                                  action:@selector(handlePanFrom:)];
        [gesture setDelegate:[VCController mainVCC]];
        [gesture setMaximumNumberOfTouches:1];
        [[baseNameVC view] addGestureRecognizer:gesture];
    }
    
    if ([[VCController mainVCC] arrayVCSubs] != nil)
	{
		NSInteger subsCount = [[[VCController mainVCC] arrayVCSubs] count];
		
		// 从上往下逐个遍历
		for (NSInteger i = subsCount - 1; i >= 0; i--)
		{
			UIViewController<VCControllerPtc> *baseNameVCBackNew = [[[VCController mainVCC] arrayVCSubs] objectAtIndex:i];
            
			// 名称相同
            if ([[VCController getVCName:baseNameVCBackNew] isEqualToString:vcName] == YES)
			{
				if (i == subsCount - 1)
				{
					// 跳转到当前VC，则直接Push即可
					[self pushVC:baseNameVC WithAnimation:animation];

                    return YES;
				}
                
                [VCController willPop:[NSNumber numberWithInteger:(subsCount - i -1)] PushToVC:[VCController getVCName:baseNameVC]];
				
                // 最上层节点
                UIViewController<VCControllerPtc> *baseNameVCTop = [[[VCController mainVCC] arrayVCSubs] objectAtIndex:(subsCount - 1)];
                
				if(animation != nil)
				{
					// 从逻辑数据中删除目标节点之前的节点
					for (NSInteger j = subsCount - 2; j > i; j--)
					{
						UIViewController<VCControllerPtc> *baseNameVCTmp = [[[VCController mainVCC] arrayVCSubs] objectAtIndex:j];
                        [[VCController mainVCC] removeVC:baseNameVCTmp];
                        [[baseNameVCTmp view] removeFromSuperview];
					}
                    
                    [[VCController mainVCC] removeVC:baseNameVCTop];
                    
					// 将新界面入栈
					[[[VCController mainVCC] arrayVCSubs] addObject:baseNameVC];
                    [[[VCController mainVCC] rootBaseView] addSubview:[baseNameVC view]];
                    
                    // 动画
                    [[UIApplication sharedApplication] beginIgnoringInteractionEvents];
                    [animation pushAnimationFromTopVC:baseNameVCTop
                                           ToArriveVC:baseNameVC
                                       WithCompletion:^(BOOL finished) {
                                        
                                           [[baseNameVCTop view] removeFromSuperview];
                                           
                                           [[[[[UIApplication sharedApplication] delegate] window] rootViewController] setNeedsStatusBarAppearanceUpdate];
                                           
                                           // 恢复VC的可用性
                                           [[UIApplication sharedApplication] endIgnoringInteractionEvents];
                                      }];
				}
				else
				{
                    // 循环删除目标节点之前的节点
					for (NSInteger j = subsCount - 1; j > i; j--)
                    {
						UIViewController<VCControllerPtc> *baseNameVCTmp = [[[VCController mainVCC] arrayVCSubs] objectAtIndex:j];
                        [[VCController mainVCC] removeVC:baseNameVCTmp];
                        [[baseNameVCTmp view] removeFromSuperview];
                    }
                    
                    // 删除当前首节点
                    [[VCController mainVCC] removeVC:baseNameVCTop];
                    [[baseNameVCTop view] removeFromSuperview];
                    
					// 将Push进来的VC Add到view上
					[[baseNameVC view] setViewX:0];
                    [[[VCController mainVCC] arrayVCSubs] addObject:baseNameVC];
                    [[[VCController mainVCC] rootBaseView] addSubview:[baseNameVC view]];
                    
                    [[[[[UIApplication sharedApplication] delegate] window] rootViewController] setNeedsStatusBarAppearanceUpdate];
				}
                
                //UELog
                [VCController addStatisticsWithFromVC:baseNameVCTop toVC:baseNameVC];
                
                // 已完成，跳出循环
                return YES;
			}
		}
	}
	else
	{
        [VCController willPop:[NSNumber numberWithInteger:0] PushToVC:[VCController getVCName:baseNameVC]];

        // 添加到队列中
        NSMutableArray *arrayVCSubsNew = [[NSMutableArray alloc] init];
        [[VCController mainVCC] setArrayVCSubs:arrayVCSubsNew];
        [[[VCController mainVCC] arrayVCSubs] addObject:baseNameVC];
        
        // 设置根VC
        [[baseNameVC view] setViewX:0];
        [[[VCController mainVCC] rootBaseView] addSubview:[baseNameVC view]];
        
        [[[[[UIApplication sharedApplication] delegate] window] rootViewController] setNeedsStatusBarAppearanceUpdate];
        
        //UELog
        [VCController addStatisticsWithFromVC:nil toVC:baseNameVC];
	}
    
    return NO;
}

// 弹出到最下层的VC然后压入节点
+ (BOOL)popToHomeVCWithAnimation:(id <VCAnimation>)animation
{
    return [VCController popToVC:[VCController getVCName:[VCController getHomeVC]] WithAnimation:animation];
}

// 弹出到最下层的VC然后压入节点
+ (BOOL)popToHomeVCThenPushVC:(UIViewController<VCControllerPtc> *)baseNameVC WithAnimation:(id <VCAnimation>)animation
{
    return [VCController popToVC:[VCController getVCName:[VCController getHomeVC]] thenPushVC:baseNameVC WithAnimation:animation];
}

// 调用统计模块事件
+ (void)addStatisticsWithFromVC:(UIViewController *)from toVC:(UIViewController *)to
{
   // [[StatisticsUELog getInstance] addStatisticsWithFromVC:from toVC:to];
}

// 调用崩溃统计模块事件 - 忽略scheme
+ (void)beginIgnoringScheme
{
    [[BusinessStack sharedInstance] beginIgnoringScheme];
}

// 调用崩溃统计模块事件 - 停止忽略scheme
+ (void)endIgnoringScheme
{
    [[BusinessStack sharedInstance] endIgnoringScheme];
}

+ (void)willPop:(NSNumber *)popVCNumber PushToVC:(NSString *)vcName
{
    [[BusinessStack sharedInstance] willPop:popVCNumber PushToVC:vcName];
}

@end
