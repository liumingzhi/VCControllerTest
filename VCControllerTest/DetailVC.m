//
//  DetailVC.m
//  pushTest
//
//  Created by mingzhi.liu on 15/12/14.
//  Copyright © 2015年 mingzhi.liu. All rights reserved.
//

#import "DetailVC.h"

@interface DetailVC ()

@property (nonatomic, strong) UIControl *bgControl;     // 灰色背景

@property (nonatomic, strong) UIScrollView *scrollView;


@end


@implementation DetailVC


-(void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor yellowColor];
    
    CGRect parentFrame = self.view.frame;
    self.view.userInteractionEnabled = YES;
    _bgControl = [[UIControl alloc] initWithFrame:CGRectMake(0, 0, parentFrame.size.width, parentFrame.size.height)];
    [_bgControl setAlpha:0];
    [_bgControl setBackgroundColor:[UIColor redColor]];
    [_bgControl addTarget:self action:@selector(touchControl) forControlEvents:UIControlEventTouchDown];
    [self.view addSubview:_bgControl];
    
    CGSize scrollViewSize = CGSizeMake(parentFrame.size.width, parentFrame.size.height);
    _scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, parentFrame.size.height, scrollViewSize.width, scrollViewSize.height)];
    [_scrollView setBackgroundColor:[UIColor greenColor]];
    [self.view addSubview:_scrollView];
    
    
    UIButton *btn = [[UIButton  alloc] initWithFrame:CGRectMake(20, 20, 40, 40)];
    btn.backgroundColor = [UIColor redColor];
    [btn addTarget:self action:@selector(btnClick) forControlEvents:UIControlEventTouchDown];
    [_scrollView addSubview:btn];

}

-(void)btnClick
{
 
    if ([_delegate respondsToSelector:@selector(btnClickCallBack)])
    {
        [_delegate btnClickCallBack];
    }
   
    
    
}

-(void)touchControl
{

    [self dissMissView];
}

-(void)showInParent:(UIView *)parentView
{
    if (!_isShow)
    {
        _isShow = YES;
        if ([self.view superview] == nil)
        {
            [parentView addSubview:[self view]];
        }
        
        [_bgControl setAlpha:0];
        [UIView animateWithDuration:0.3 delay:0.0
                            options:UIViewAnimationOptionCurveEaseIn animations:^{
                                
                                [_bgControl setAlpha:1];
                                [_scrollView setFrame:CGRectMake(self.view.frame.size.width/2, 0, self.view.frame.size.width/2, self.view.frame.size.height)];
                                
                            } completion:^(BOOL finished){
                                
                            }];
   
    }
}

-(void)dissMissView
{

    if (_isShow && [[self view] superview] != nil)
    {
        _isShow = NO;
        [_bgControl setAlpha:1];
        
        [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
        
            [_bgControl setAlpha:0];
            [_scrollView setFrame:CGRectMake(self.view.frame.size.width, 0, self.view.frame.size.width/2, self.view.frame.size.height)];
        
        } completion:^(BOOL finished){
        
            [self.view removeFromSuperview];
        }];
        
    }

}



























@end
