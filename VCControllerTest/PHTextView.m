//
//  PHTextView.m
//  
//
//  Created by Neo on 1/18/11.
//  Copyright 2011 .com. All rights reserved.
//

#import "PHTextView.h"

@interface PHTextView ()

@property (nonatomic, strong) NSString *placeHolder;	// 占位文本

// 文本变化回调函数
- (void)textDidChanged:(NSNotification *)notificaiton;

@end

// =======================================================================
// 实现
// =======================================================================
@implementation PHTextView

// 初始化函数
- (id)initWithFrame:(CGRect)frame 
{
    if((self = [super initWithFrame:frame]) != nil)
	{
		// 注册文本变化消息
        [[NSNotificationCenter defaultCenter] addObserver:self 
												 selector:@selector(textDidChanged:) 
													 name:UITextViewTextDidChangeNotification 
												   object:self];
		
		// 初始化占位文本
        _placeHolder = nil;
    }
	
    return self;
}

// 绘制函数
- (void)drawRect:(CGRect)rect 
{
    [super drawRect:rect];
	
	// 绘制占位文本
    if((_placeHolder != nil) && ([self text] != nil && [[self text] length] == 0))
	{
        UIColor *penColor = [UIColor colorWithHex:0xc7ced4 alpha:1.0f];
        
        if([_placeHolder respondsToSelector:@selector(drawWithRect:options:attributes:context:)])
        {
            NSDictionary *dictionaryAttributes = @{NSFontAttributeName:[self font],
                                        NSForegroundColorAttributeName:penColor};
            
            [_placeHolder drawWithRect:CGRectMake(5, 8, [self frame].size.width - 10, [self frame].size.height - 16)
                               options:NSStringDrawingUsesLineFragmentOrigin
                            attributes:dictionaryAttributes
                               context:nil];
        }
        else
        {
            [penColor set];
            
            // 绘制placeHolder(8,10是一个经验值)
            [_placeHolder drawInRectCompatible:CGRectMake(10, 8, [self frame].size.width - 20, [self frame].size.height - 16)
                                      withFont:[self font]];
        }
    }
}

// 设置文本
- (void)setText:(NSString *)textNew 
{
    [super setText:textNew];
	
	// 刷新界面
    [self setNeedsDisplay];
}

// 设置占位文本
- (void)setPlaceHolder:(NSString *)placeHolderNew 
{
    _placeHolder = placeHolderNew;
	
	//刷新界面
    [self setNeedsDisplay];
}

// 消息回调函数
- (void)textDidChanged:(NSNotification *)notificaiton 
{
	[self setNeedsDisplay];  
}

-(void)setContentInset:(UIEdgeInsets)s
{
	UIEdgeInsets insets = s;
	if(s.bottom>8)
    {
        insets.bottom = 0;
    }
    
	insets.top = 0;
    
	[super setContentInset:insets];
}

- (CGFloat)contentHeight
{
    if([self respondsToSelector:@selector(textContainer)])
    {
        CGRect frame = self.bounds;
        
        // Take account of the padding added around the text.
        
        UIEdgeInsets textContainerInsets = self.textContainerInset;
        UIEdgeInsets contentInsets = self.contentInset;
        
        CGFloat leftRightPadding = textContainerInsets.left + textContainerInsets.right + self.textContainer.lineFragmentPadding * 2 + contentInsets.left + contentInsets.right;
        CGFloat topBottomPadding = textContainerInsets.top + textContainerInsets.bottom + contentInsets.top + contentInsets.bottom;
        
        frame.size.width -= leftRightPadding;
        frame.size.height -= topBottomPadding;
        
        // NSString class method: boundingRectWithSize:options:attributes:context is
        // available only on ios7.0 sdk.
        
        CGSize size = [[self text] sizeWithFontCompatible:self.font constrainedToSize:CGSizeMake(CGRectGetWidth(frame), MAXFLOAT) lineBreakMode:NSLineBreakByWordWrapping];
        CGFloat measuredHeight = ceilf(size.height + topBottomPadding);
        
        return measuredHeight;
    }
    else
    {
        return self.contentSize.height;
    }
}

// =======================================================================
// 分界线
// =======================================================================
- (void)dealloc
{
	// 删除消息注册
    [[NSNotificationCenter defaultCenter] removeObserver:self
													name:UITextViewTextDidChangeNotification
												  object:self];
}

@end
