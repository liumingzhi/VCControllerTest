//
//  MockVC.m
//  VCControllerTest
//
//  Created by mingzhi.liu on 17/3/21.
//  Copyright © 2017年 mingzhi.liu. All rights reserved.
//

#import "MockVC.h"
#import "FMockView.h"

@interface MockVC ()<FMockViewDelegate>
@property (nonatomic, strong) FMockView *mockView;

@end

@implementation MockVC

-(void)dealloc
{

    _mockView.backWindow = nil;
    _mockView = nil;


}

- (void)viewDidLoad {
    [super viewDidLoad];

    self.view.backgroundColor = [UIColor whiteColor];

    UIColor *color = [UIColor colorWithRed:0.97 green:0.30 blue:0.30 alpha:1.00];

    _mockView = [[FMockView alloc] initWithFrame:CGRectMake(-50/6, 200, 50, 50) color:color delegate:self];
    
    [_mockView setTitle:@"Mock" forState:UIControlStateNormal];
    
    [_mockView show];

}

-(void)mockViewClick:(FMockView *)mockView
{

    NSLog(@"click");

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
