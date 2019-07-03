//
//  secondViewVC.m
//  pushTest
//
//  Created by mingzhi.liu on 15/12/14.
//  Copyright © 2015年 mingzhi.liu. All rights reserved.
//

#import "secondViewVC.h"
#import "ThirdViewVC.h"
@interface secondViewVC ()


@end

@implementation secondViewVC

-(void)dealloc
{

    NSLog(@"---- dealloc");

}
-(void)viewDidLoad
{

    
    [super viewDidLoad];
    

    self.saveBlock = ^(NSString *ttt){
    
        NSLog(@"-----  self.saveBlock");
    
    };
    
     
    //self.title = @"secondView";
    
    self.view.backgroundColor = [UIColor redColor];
    
    UIButton *btn3 = [[UIButton alloc] initWithFrame:CGRectMake(10, 200, 140, 40)];
    btn3.backgroundColor = [UIColor grayColor];
    [btn3 setTitle:@"secondViewVC" forState:UIControlStateNormal];
    [btn3 addTarget:self action:@selector(testClicktt) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn3];
    
    
}

-(void)viewWillAppear:(BOOL)animated
{

    [super viewWillAppear:animated];

}


-(void)testClicktt
{
    
    NSString *tests = @"dsfsdfdsfsdfds";
    
    if (self.saveBlock) {
        self.saveBlock(tests);
    }
    
    

//    ThirdViewVC *thirdVC = [[ThirdViewVC alloc] init];
//    
//    [VCController pushVC:thirdVC WithAnimation:[VCAnimationClassic defaultAnimation]];
    
}

-(void)secondViewTest
{
    NSLog(@"secondViewTest");

}

-(void)secondViewTest11
{

    NSLog(@"secondViewTest11");

}


@end
