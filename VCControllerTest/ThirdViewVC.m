//
//  ThirdViewVC.m
//  pushTest
//
//  Created by mingzhi.liu on 16/1/14.
//  Copyright © 2016年 mingzhi.liu. All rights reserved.
//

#import "ThirdViewVC.h"

@interface ThirdViewVC ()

@end

@implementation ThirdViewVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor greenColor];
    [self setupViewRootSubs:[self view]];
    
    UIButton *btn3 = [[UIButton alloc] initWithFrame:CGRectMake(10, 200, 80, 40)];
    btn3.backgroundColor = [UIColor blueColor];
    [btn3 setTitle:@"goback" forState:UIControlStateNormal];
    [btn3 addTarget:self action:@selector(goBack:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn3];
    
    
    UIButton *btn4 = [[UIButton alloc] initWithFrame:CGRectMake(10, 300, 80, 40)];
    btn4.backgroundColor = [UIColor blueColor];
    [btn4 setTitle:@"goRoot" forState:UIControlStateNormal];
    [btn4 addTarget:self action:@selector(goRoot:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn4];
}

// 创建Root View的子界面
-(void)setupViewRootSubs:(UIView *)viewPrent
{
    CGRect parentFrame = [viewPrent frame];
    CGSize parentSize = parentFrame.size;
    
    NSInteger spaceYStart = 0;
    

    
    
}

- (void)goBack:(id)sender
{
    [VCController popWithAnimation:[VCAnimationClassic defaultAnimation]];
}

- (void)goRoot:(id)sender
{
   [VCController popToVC:@"RootViewVC" WithAnimation:[VCAnimationClassic defaultAnimation]];

}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
