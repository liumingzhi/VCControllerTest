//
//  KeyboardController.h
//  QunariPhone
//
//  Created by zhou jinfeng on 13-5-30.
//  Copyright (c) 2013年 Qunar.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@class KeyboardController;

@protocol KeyboardDelegate <NSObject>

@optional

- (void)keyboardWillShowInputView:(UIView<UITextInputTraits> *)inputView;
- (void)keyboardDidShowWithHeight:(CGFloat)height andInputView:(UIView<UITextInputTraits> *)inputView;
- (void)keyboardWillHideWithInputView:(UIView<UITextInputTraits> *)inputView;

@end

//  键盘管理类，目前支持UITextField、UITextView的键盘触发事件处理
//  当输入对象视图被键盘遮挡时，如果设置了输入对象的滚动视图，则会自动滚动，如果有代理则会回调
@interface KeyboardController : NSObject

@property(nonatomic, weak) id<KeyboardDelegate>       delegate;         // 回调对象

- (instancetype)init;

- (void)addInputView:(UIView<UITextInputTraits> *)inputView
    withInScrollView:(UIScrollView *)scrollView;

- (void)changeResponseToInputView:(UIView<UITextInputTraits> *)inputView;

- (void)removeInputView:(UIView<UITextInputTraits> *)inputView;

- (void)removeInputViewWithScrollView:(UIScrollView *)scrollView;

- (void)hideKeyboard;

@end
