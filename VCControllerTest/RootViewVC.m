//
//  RootViewVC.m
//  pushTest
//
//  Created by mingzhi.liu on 15/12/14.
//  Copyright © 2015年 mingzhi.liu. All rights reserved.
//

#import "RootViewVC.h"
#import "DetailVC.h"
#import "secondViewVC.h"
#import "SecondDetailVC.h"
//#import "VCAnimation.h"
//#import "VCAnomationBottom.h"
@interface RootViewVC ()

@property (nonatomic, strong) DetailVC *detailVC;
@property (nonatomic, strong) UILabel     *labelRecommendTip;

@end


@implementation RootViewVC

-(void)dealloc
{


}

// 创建Root View的子界面
-(void)setupViewRootSubs:(UIView *)viewPrent
{
    CGRect parentFrame = [viewPrent frame];
    CGSize parentSize = parentFrame.size;
    
    NSInteger spaceYStart = 0;
    
    // =======================================================================
    // NaviBar
    // =======================================================================
  
   // [self setupNaviBarSubs:naviBar];
    
    
}

-(void)viewWillAppear:(BOOL)animated
{

  
}

-(void)viewDidLoad
{
    
    [super viewDidLoad];
   // self.title = @"root";
    [self setupViewRootSubs:[self view]];

    self.view.backgroundColor = [UIColor whiteColor];
    
    UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(10, 100, 40, 40)];
    btn.backgroundColor = [UIColor redColor];
    [btn setTitle:@"save" forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(btnSaveClick) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn];

    
    UIButton *btnn = [[UIButton alloc] initWithFrame:CGRectMake(100, 100, 40, 40)];
    btnn.backgroundColor = [UIColor greenColor];
    [btnn setTitle:@"get" forState:UIControlStateNormal];
    [btnn addTarget:self action:@selector(getClick) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btnn];
    
    
    UIButton *btn3 = [[UIButton alloc] initWithFrame:CGRectMake(10, 200, 40, 40)];
    btn3.backgroundColor = [UIColor blueColor];
    [btn3 setTitle:@"test" forState:UIControlStateNormal];
    [btn3 addTarget:self action:@selector(testClick) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn3];
    
    UIButton *btn4 = [[UIButton alloc] initWithFrame:CGRectMake(100, 200, 80, 40)];
    btn4.backgroundColor = [UIColor blueColor];
    [btn4 setTitle:@"goTools" forState:UIControlStateNormal];
    [btn4 addTarget:self action:@selector(goTools) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn4];
    
//    NSUserDefaults *settingData = [NSUserDefaults standardUserDefaults];
//    
//    NSArray *arr = [[NSArray alloc] initWithObjects:@"arr1",@"arr2", nil];
//    [settingData setObject:arr forKey:@"arrItem"];
//    [settingData setObject:@"admin" forKey:@"user_name"];
//    [settingData setBool:1 forKey:@"auto_login"];
//    [settingData setInteger:2 forKey:@"count"];
//    
//    
//    NSLog(@"arrItme:  %@",[settingData objectForKey:@"arrItem"]);
//    NSLog(@"user_name: %@",[settingData objectForKey:@"user_name"]);
//    NSLog(@"count : %ld",(long)[settingData integerForKey:@"count"]);
//    NSLog(@"auto_login : %d",[settingData boolForKey:@"auto_login"]);
    
    NSString *soSorry = @" 非常抱歉 !  该日期航班已售完";

    
    NSString* desString = [NSString stringWithFormat:@"%@\n已为您推荐其他日期的航线",soSorry];
    CGSize desStringSize = [desString sizeWithFontCompatible:kCurNormalFontOfSize(13)];
    _labelRecommendTip = [[UILabel alloc] initWithFrame:CGRectZero];
    _labelRecommendTip.backgroundColor = [UIColor grayColor];
    [self.view addSubview:_labelRecommendTip];
    
    _labelRecommendTip.numberOfLines = 0;
    _labelRecommendTip.textAlignment = NSTextAlignmentCenter;
    [_labelRecommendTip setFrame:CGRectMake(100, 300, desStringSize.width, desStringSize.height)];
    [_labelRecommendTip setText:desString];
    [_labelRecommendTip setFont:kCurNormalFontOfSize(13)];
    [_labelRecommendTip setTextColor:[UIColor colorWithHex:0xffffff alpha:0.7]];
    
    
    
}

-(void)getClick
{
    
  //  AddressObj *getAddress = [StoreManager getAddressInfo];
    
   // AddressObj *getAddress = [StoreManager getFAddressInfo];

    
}

//-(void)testClick
//{
//
//    NSRange rg = {3,5};
//    NSRange rg2 = NSMakeRange(3, 5);
////    NSLog(@"rg2 is %@",NSStringFromRange(rg));
////    NSLog(@"rg is %@",NSStringFromRange(rg));
//    
//    CGPoint p = CGPointMake(10, 10);
//  //  NSLog(@"point p is %@",NSStringFromCGPoint(p));
//    
//    
//    CGSize size = CGSizeMake(10, 10);
//   // NSLog(@"size  %@",NSStringFromCGSize(size));
//    
//    CGRect rect = CGRectMake(10, 10, 10, 10);
//    NSLog(@"rect  %@",NSStringFromCGRect(rect));
//}

-(void)btnSaveClick
{

    
}

- (NSString *) nsnumberToNSString:(NSNumber *) number
{
    NSString *numString = @"";
    if(number !=nil)
    {
        numString = [NSNumberFormatter localizedStringFromNumber:number numberStyle:NSNumberFormatterDecimalStyle];
    }
    return numString;
}


#pragma mark -delegate
-(void)testClick
{
    secondViewVC *secondVC = [[secondViewVC alloc] init];

    secondVC.saveBlock = ^(NSString *str){
    
        NSLog(@"---- %@",str);
    
    };
    
    [VCController pushVC:secondVC WithAnimation:[VCAnimationClassic defaultAnimation]];
}

-(void)goTools
{

    SecondDetailVC *secondDetail = [[SecondDetailVC alloc] init];
    
    [VCController pushVC:secondDetail WithAnimation:[VCAnimationClassic defaultAnimation]];
    
    
}


#pragma mark secondView delegate

-(void)secondViewDelegate
{




}












@end
