//
//  KeyboardObserver.h
//  lawyer
//
//  Created by Neo on 3/13/15.
//  Copyright (c) 2015 Neo. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface KeyboardObserver : NSObject

@property (nonatomic, strong) UIView<UITextInputTraits> *inputView; // 触发键盘的输入对象:UITextField或UITextView对象
@property (nonatomic, strong) UIScrollView *scrollView;             // 输入对象所在的ScrollView对象,ScrollView对象可以为:UITableView,UIScrollView
@property (nonatomic, strong) NSValue *scrollViewNormalFrame;       // 输入对象所在的ScrollView对象的初始坐标和大小

@end
