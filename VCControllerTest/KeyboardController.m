//
//  KeyboardController.m
//  QunariPhone
//
//  Created by zhou jinfeng on 13-5-30.
//  Copyright (c) 2013年 Qunar.com. All rights reserved.
//

#import "KeyboardController.h"
#import "KeyboardObserver.h"
#import "EventBusCenter.h"

#define kKeyboardControllerVMargin	10

@interface KeyboardController ()

@property(nonatomic, strong) NSMutableArray         *arrayKeyboardObserver; // 观察对象
@property(nonatomic, assign) NSInteger              keyboardHeight;         // 当前键盘高度

@end

@implementation KeyboardController

- (void)dealloc
{
    [self unregKeyboardNotification];
}

- (instancetype)init
{
    self = [super init];
    
    _arrayKeyboardObserver = [[NSMutableArray alloc] init];
    
    [self regKeyboardNotification];
    
    return self;
}

// 注册键盘消息
- (void)regKeyboardNotification
{
	// 键盘显示消息
    [[EventBusCenter defaultCenter] addObserver:self
                                       selector:@selector(keyboardWillShow:)
                                           name:UIKeyboardWillShowNotification];
	
	// 键盘显示消息
    [[EventBusCenter defaultCenter] addObserver:self
                                       selector:@selector(keyboardDidShow:)
                                           name:UIKeyboardDidShowNotification];

	// 键盘隐藏消息
    [[EventBusCenter defaultCenter] addObserver:self
                                       selector:@selector(keyboardWillHide:)
                                           name:UIKeyboardWillHideNotification];
}

// 取消注册的键盘消息
- (void)unregKeyboardNotification
{
    [[EventBusCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification];
    [[EventBusCenter defaultCenter] removeObserver:self name:UIKeyboardDidShowNotification];
    [[EventBusCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification];
}

// 键盘显示
- (void)keyboardWillShow:(NSNotification *)notification
{
    if (_arrayKeyboardObserver == nil)
    {
        return;
    }
    
    NSUInteger observerCount = [_arrayKeyboardObserver count];
    if(observerCount == 0)
    {
        return;
    }
    
    for (int i = 0; i < observerCount; ++i)
    {
        KeyboardObserver *keyboardObserver = [_arrayKeyboardObserver objectAtIndex:i];
        UIView<UITextInputTraits> *inputView  = [keyboardObserver inputView];
		
        // 如果输入对象为第一响应
        if ([inputView isFirstResponder] == YES)
        {
			if ((_delegate != nil)
				&& ([_delegate conformsToProtocol:@protocol(KeyboardDelegate)])
				&& ([_delegate respondsToSelector:@selector(keyboardWillShowInputView:)]))
			{
				[_delegate keyboardWillShowInputView:inputView];
			}
		}
	}
}

// 键盘显示
- (void)keyboardDidShow:(NSNotification *)notification
{
    if (_arrayKeyboardObserver == nil)
    {
        return;
    }
    
    NSUInteger observerCount = [_arrayKeyboardObserver count];
    if(observerCount == 0)
    {
        return;
    }
    
    for (int i = 0; i < observerCount; ++i)
    {
        KeyboardObserver *keyboardObserver = [_arrayKeyboardObserver objectAtIndex:i];
        UIView<UITextInputTraits> *inputView  = [keyboardObserver inputView];
        UIScrollView *scrollView = [keyboardObserver scrollView];
        NSValue *frameValue = [keyboardObserver scrollViewNormalFrame];
        
        if ([inputView isDescendantOfView:scrollView])
        {
            // 如果输入对象为第一响应
            if ([inputView isFirstResponder] == YES)
            {
                NSValue *frameEnd = nil;
                CGFloat keyboardHeight = 0;
                
                frameEnd = [[notification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey];
                
                // 3.2以后的版本
                if(frameEnd != nil)
                {
                    // 键盘的Frame
                    CGRect keyBoardFrame;
                    [frameEnd getValue:&keyBoardFrame];
                    
                    // 保存键盘的高度
                    keyboardHeight = keyBoardFrame.size.height;
                }
                else
                {
                    // 保存键盘的高度
                    keyboardHeight = 216;
                }
                _keyboardHeight = keyboardHeight;
                
                // 滚动
                [self scrollInputView:inputView
                     withInScrollView:scrollView
                          andOldFrame:[frameValue CGRectValue]
                    andKeyboardHeight:keyboardHeight];
                
                // 回调
                if ((_delegate != nil)
                    && ([_delegate conformsToProtocol:@protocol(KeyboardDelegate)])
                    && ([_delegate respondsToSelector:@selector(keyboardDidShowWithHeight:andInputView:)]))
                {
                    [_delegate keyboardDidShowWithHeight:keyboardHeight andInputView:inputView];
                }
            }
        }
    }
}

// 键盘消失
- (void)keyboardWillHide:(NSNotification *)notification
{
    if (_arrayKeyboardObserver == nil)
    {
        return;
    }
    
    NSUInteger observerCount = [_arrayKeyboardObserver count];
    if(observerCount == 0)
    {
        return;
    }
    
    for (int i = 0; i < observerCount; ++i)
    {
        KeyboardObserver *keyboardObserver = [_arrayKeyboardObserver objectAtIndex:i];
        UIView<UITextInputTraits> *inputView  = [keyboardObserver inputView];
        UIScrollView *scrollView = [keyboardObserver scrollView];
        NSValue *frameValue = [keyboardObserver scrollViewNormalFrame];
        
        if ([inputView isDescendantOfView:scrollView])
        {
            // 如果输入对象为第一响应
            if ([inputView isFirstResponder] == YES)
            {
                _keyboardHeight = 0;

                // 滚动
                [self scrollInputView:inputView
                     withInScrollView:scrollView
                          andOldFrame:[frameValue CGRectValue]
                    andKeyboardHeight:0];
            
                // 回调
                if ((_delegate != nil)
                    && ([_delegate conformsToProtocol:@protocol(KeyboardDelegate)])
                    && ([_delegate respondsToSelector:@selector(keyboardWillHideWithInputView:)]))
                {
                    [_delegate keyboardWillHideWithInputView:inputView];
                }
            }
        }
    }
}

// 滚动ContentView
- (void)scrollInputView:(UIView *)viewFocus
       withInScrollView:(UIScrollView *)scrollView
            andOldFrame:(CGRect)scrollViewOldFrame
      andKeyboardHeight:(CGFloat)keyboardHeight
{
    // ======================================================================
    // 这里面一个假设的前提是参数viewController是一个全屏的VC，否则算出来的坐标就不正确
    // 这个貌似严格的限制，总是可以通过UI布局的实施来轻松解决
    // ======================================================================
    // 键盘的顶部在VCView中的坐标
    UIView *mainWindow = [[UIApplication sharedApplication] keyWindow];
    CGRect viewFrame = [mainWindow frame];
    NSInteger keyboardYInVC = viewFrame.size.height - keyboardHeight;
    
    // 计算ScrollView在VCView中的Y坐标
    CGRect scrollFrameInVC = CGRectMake(0, 0, [scrollView frame].size.width, [scrollView frame].size.height);
    if ([scrollView superview] != nil)
    {
        scrollFrameInVC = [[scrollView superview] convertRect:[scrollView frame] toView:mainWindow];
        
    }
    CGPoint scrollTopPoint = CGPointMake(scrollFrameInVC.origin.x, scrollFrameInVC.origin.y);
    CGPoint scrollBottomPoint = CGPointMake(scrollTopPoint.x, scrollTopPoint.y + [scrollView frame].size.height);
    
    if (scrollTopPoint.y < keyboardYInVC)
    {
        // scrollView的位置被键盘遮盖
        if(scrollBottomPoint.y > keyboardYInVC)
        {
            [scrollView setFrame:CGRectMake([scrollView frame].origin.x, [scrollView frame].origin.y, [scrollView frame].size.width, keyboardYInVC - scrollTopPoint.y)];
        }
        else
        {
            if(scrollTopPoint.y + scrollViewOldFrame.size.height > keyboardYInVC)
            {
                [scrollView setFrame:CGRectMake([scrollView frame].origin.x, [scrollView frame].origin.y, [scrollView frame].size.width, keyboardYInVC - scrollTopPoint.y)];
            }
            else
            {
                [scrollView setFrame:CGRectMake([scrollView frame].origin.x, [scrollView frame].origin.y, [scrollView frame].size.width, scrollViewOldFrame.size.height)];
            }
        }
    }
    
    // 计算输入框底部在VCView中的Y坐标
    CGPoint topPointInScrollView = [viewFocus convertPoint:CGPointZero toView:scrollView];
    CGPoint bottomPointInFocus = CGPointMake(0, [viewFocus frame].size.height + kKeyboardControllerVMargin);
    CGPoint bottomPointInVC = [viewFocus convertPoint:bottomPointInFocus toView:mainWindow];
    
    
    // 获取TableView的Offset
    CGPoint scrollViewInfoOffset = [scrollView contentOffset];
    
    // 该坐标的位置被键盘遮盖
    if(bottomPointInVC.y > keyboardYInVC)
    {
        // 滚动Content View
        [UIView animateWithDuration:0.3
                              delay:0.0
                            options:UIViewAnimationOptionCurveEaseInOut
                         animations:^{
                             [scrollView setContentOffset:CGPointMake(scrollViewInfoOffset.x, scrollViewInfoOffset.y + bottomPointInVC.y - keyboardYInVC)];
                         }
                         completion:nil];
        
    }
    // 顶部被TableView遮盖
    else if(topPointInScrollView.y < scrollViewInfoOffset.y)
    {
        // 滚动Content View
        [UIView animateWithDuration:0.3
                              delay:0.0
                            options:UIViewAnimationOptionCurveEaseInOut
                         animations:^{
                             [scrollView setContentOffset:CGPointMake(scrollViewInfoOffset.x, topPointInScrollView.y)];
                         }
                         completion:nil];
    }
}

- (void)addInputView:(UIView<UITextInputTraits> *)inputView
    withInScrollView:(UIScrollView *)scrollView
{
    if((inputView != nil) && (scrollView != nil))
    {
        [self removeInputView:inputView];
        [self insertInputObject:inputView withInScrollView:scrollView];
    }
}

- (void)changeResponseToInputView:(UIView<UITextInputTraits> *)inputView
{
    if (_arrayKeyboardObserver == nil)
    {
        return;
    }
    
    NSUInteger observerCount = [_arrayKeyboardObserver count];
    if(observerCount == 0)
    {
        return;
    }
    
    // 查找该控件是否存在
    KeyboardObserver *keyboardObserverTmp = nil;
    UIView<UITextInputTraits> *inputViewTmp  = nil;
    UIScrollView *scrollViewTmp = nil;
    NSValue *frameValueTmp = nil;
    BOOL isExist = NO;
    
    for (int i = 0; i < observerCount; ++i)
    {
        keyboardObserverTmp = [_arrayKeyboardObserver objectAtIndex:i];
        inputViewTmp  = [keyboardObserverTmp inputView];
        if(inputViewTmp == inputView)
        {
            scrollViewTmp = [keyboardObserverTmp scrollView];
            frameValueTmp = [keyboardObserverTmp scrollViewNormalFrame];
            isExist = YES;
            
            break;
        }
    }
    
    [inputView becomeFirstResponder];
    
    if ([inputView isDescendantOfView:scrollViewTmp])
    {
        // 滚动
        [self scrollInputView:inputView
             withInScrollView:scrollViewTmp
                  andOldFrame:[frameValueTmp CGRectValue]
            andKeyboardHeight:_keyboardHeight];
    }
}

- (void)insertInputObject:(UIView<UITextInputTraits> *)inputView
         withInScrollView:(UIScrollView *)scrollView
{
    KeyboardObserver *keyboardObserver = [[KeyboardObserver alloc] init];
    [keyboardObserver setInputView:inputView];
    [keyboardObserver setScrollView:scrollView];
    [keyboardObserver setScrollViewNormalFrame:[NSValue valueWithCGRect:[scrollView frame]]];
    [_arrayKeyboardObserver addObject:keyboardObserver];
}

- (void)removeInputView:(UIView<UITextInputTraits> *)inputView
{
    if (_arrayKeyboardObserver == nil)
    {
        return;
    }
    
    NSUInteger observerCount = [_arrayKeyboardObserver count];
    if(observerCount == 0)
    {
        return;
    }
    
    NSMutableArray *arrayRemoveKeyboardObserver = [[NSMutableArray alloc] init];
    
    for (int i = 0; i < observerCount; ++i)
    {
        KeyboardObserver *keyboardObserverTmp = [_arrayKeyboardObserver objectAtIndex:i];
        UIView<UITextInputTraits> *inputViewTmp  = [keyboardObserverTmp inputView];

        if (inputView == inputViewTmp)
        {
            [arrayRemoveKeyboardObserver addObject:keyboardObserverTmp];
        }
    }
    
    [_arrayKeyboardObserver removeObjectsInArray:arrayRemoveKeyboardObserver];

    [arrayRemoveKeyboardObserver removeAllObjects];
}

- (void)removeInputViewWithScrollView:(UIScrollView *)scrollView
{
    if (_arrayKeyboardObserver == nil)
    {
        return;
    }
    
    NSUInteger observerCount = [_arrayKeyboardObserver count];
    if(observerCount == 0)
    {
        return;
    }
    
    NSMutableArray *arrayRemoveKeyboardObserver = [[NSMutableArray alloc] init];
    
    for (int i = 0; i < observerCount; ++i)
    {
        KeyboardObserver *keyboardObserverTmp = [_arrayKeyboardObserver objectAtIndex:i];
        UIScrollView *scrollViewTmp = [keyboardObserverTmp scrollView];
        
        if (scrollView == scrollViewTmp)
        {
            [arrayRemoveKeyboardObserver addObject:keyboardObserverTmp];
        }
    }
    
    [_arrayKeyboardObserver removeObjectsInArray:arrayRemoveKeyboardObserver];
    
    [arrayRemoveKeyboardObserver removeAllObjects];
}

- (void)hideKeyboard
{
    if (_arrayKeyboardObserver == nil)
    {
        return;
    }
    
    NSUInteger observerCount = [_arrayKeyboardObserver count];
    if(observerCount == 0)
    {
        return;
    }
    
    for (int i = 0; i < observerCount; ++i)
    {
        KeyboardObserver *keyboardObserverTmp = [_arrayKeyboardObserver objectAtIndex:i];
        UIView<UITextInputTraits> *inputViewTmp  = [keyboardObserverTmp inputView];
        
        // 如果输入对象为第一响应
        if ([inputViewTmp isFirstResponder] == YES)
        {
            [inputViewTmp resignFirstResponder];
        }
    }
}

- (NSInteger)keyboardHeight
{
    return _keyboardHeight;
}

@end
