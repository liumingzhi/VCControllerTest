//
//  PHTextView.h
//  
//
//  Created by Neo on 1/18/11.
//  Copyright 2011 .com. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface PHTextView : UITextView

// 设置文本
- (void)setText:(NSString *)textNew;

// 设置占位文本
- (void)setPlaceHolder:(NSString *)placeHolderNew;

// 计算尺寸
- (CGFloat)contentHeight;

@end
