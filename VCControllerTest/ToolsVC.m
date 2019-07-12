//
//  SecondDetailVC.m
//  pushTest
//
//  Created by mingzhi.liu on 16/1/12.
//  Copyright © 2016年 mingzhi.liu. All rights reserved.
//

#import "ToolsVC.h"
#import "KeyBoardVC.h"
#import "MockVC.h"
@interface ToolsVC ()
@property (nonatomic, strong) UITableView *tableView;

@end
@implementation ToolsVC

-(void)viewWillAppear:(BOOL)animated
{


}
-(void)viewDidLoad
{
    self.view.backgroundColor = [UIColor whiteColor];
    
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 20, self.view.frame.size.width, self.view.frame.size.height - 20) style:UITableViewStylePlain];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    
    [self.view addSubview:_tableView];
    


}

#pragma -mark UITableViewDataSource
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;

}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 18;
}

#pragma -mark UITableViewDelegate
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *reusedIndetifier = @"resusedCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reusedIndetifier];
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reusedIndetifier];
    }

    if (indexPath.row == 0)
    {
        cell.textLabel.text = @"keyBoardController";
        
    }
    else if (indexPath.row == 1)
    {
        cell.textLabel.text = @"Mock";

    }
    else if (indexPath.row == 2)
    {
        cell.textLabel.text = @"bbb";

    }else if (indexPath.row == 3)
    {
        
    }else if (indexPath.row == 4)
    {
        
    }else if (indexPath.row == 5)
    {
        
    }else if (indexPath.row == 6)
    {
        
    }else if (indexPath.row == 7)
    {
        
    }
        
    


    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    
    if (indexPath.row == 0)
    {
        KeyBoardVC *keyboard = [[KeyBoardVC alloc] init];
        
        [VCController pushVC:keyboard WithAnimation:[VCAnimationClassic defaultAnimation]];
    }
    else if (indexPath.row == 1)
    {
        MockVC *mockttt = [[MockVC alloc] init];
        
        [VCController pushVC:mockttt WithAnimation:[VCAnimationClassic defaultAnimation]];
    
    }


}


@end
