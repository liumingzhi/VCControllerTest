//
//  FlightCustomTextField.h
//  Flight
//
//  Created by xiulian.yin on 15/11/4.
//  Copyright © 2015年 Qunar.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol FlightAuthenticInputViewDelegate <NSObject>

- (void) AuthenticKeyboardInput:(NSString *) number;
- (void) AuthenticKeyboardBackspace;
- (void) AuthenticKeyboardClearTheInput;
@end


@interface FlightAuthenticInputView : UIView

{
    NSArray *arrLetter;
}

@property (nonatomic,weak) id<FlightAuthenticInputViewDelegate> delegate;

@end

#pragma mark FlightCustomTextField

enum  KTrainTextFieldInputViewType
{
    KFlightCustomTextFieldInputView = 1,
    KFlightDefaultTextFieldInputView,
    
};

@interface FlightCustomTextField : UITextField<FlightAuthenticInputViewDelegate>
{
    NSString    *previousTextFieldContent;
    UITextRange *previousSelection;
}

@property(nonatomic,strong) FlightAuthenticInputView * customInputView;


// default 为系统   custom为自定义
- (void)choiceTheTextFieldInputView:(NSInteger)choiceType;
@end
