//
//  FlightCustomTextField.m
//  Flight
//
//  Created by xiulian.yin on 15/11/4.
//  Copyright © 2015年 Qunar.com. All rights reserved.
//

#import "FlightCustomTextField.h"

@implementation FlightAuthenticInputView

static int x_count = 3;
static int y_count = 4;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.bounds = CGRectMake(0, 0, frame.size.width, frame.size.height);
        
        for (int i=0; i<y_count; i++)
        {
            for (int j=0; j<x_count; j++)
            {
                UIButton *button = [self creatButtonWithX:i Y:j];
                [self addSubview:button];
            }
        }
        
        UIColor *color = [UIColor colorWithHex:0x8c8c8c alpha:1.0f];
        
        UIScreen *currentScreen = [UIScreen mainScreen];
        CGFloat buttonWidth = currentScreen.applicationFrame.size.width/3 - 0.5;
        CGFloat buttonHeight = 54;
        UIView *line1 = [[UIView alloc] initWithFrame:CGRectMake(buttonWidth, 0, 0.5, frame.size.height)];
        line1.backgroundColor = color;
        [self addSubview:line1];
        
        UIView *line2 = [[UIView alloc] initWithFrame:CGRectMake(2*buttonWidth+0.5, 0, 0.5, frame.size.height)];
        line2.backgroundColor = color;
        [self addSubview:line2];
        
        for (int i=0; i<3; i++)
        {
            UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0, buttonHeight*(i+1), frame.size.width, 0.5)];
            line.backgroundColor = color;
            [self addSubview:line];
        }
        
    }
    return self;
}

-(UIButton *)creatButtonWithX:(NSInteger) x Y:(NSInteger) y
{
    UIButton *button;
    
    CGFloat frameX = 0;
    UIScreen *currentScreen = [UIScreen mainScreen];
    CGFloat buttonWidth = currentScreen.applicationFrame.size.width/3 - 0.5;
    CGFloat buttonHeight = 54;
    switch (y)
    {
        case 0:
            frameX = 0.0;
            break;
        case 1:
            frameX = buttonWidth+0.5;
            break;
        case 2:
            frameX = 2*buttonWidth+1;
            break;
        default:
            break;
    }
    CGFloat frameY = 54*x;
    
    button = [[UIButton alloc] initWithFrame:CGRectMake(frameX, frameY, buttonWidth, 54)];
    
    NSInteger num = 3*x+y+1;
    button.tag = num;
    [button addTarget:self action:@selector(clickButton:) forControlEvents:UIControlEventTouchUpInside];
    
    UIColor *colorNormal = [UIColor colorWithRed:252/255.0 green:252/255.0 blue:252/255.0 alpha:1];
    UIColor *colorHightlighted = [UIColor colorWithHex:0xd2d5db alpha:1.0f];
    if ( num == 12)
    {
        UIColor *colorTemp = colorNormal;
        colorNormal = colorHightlighted;
        colorHightlighted = colorTemp;
        UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(btnLong:)];
        longPress.minimumPressDuration = 1.f; //定义按的时间
        [button addGestureRecognizer:longPress];
    }
    button.backgroundColor = colorNormal;
    CGSize imageSize = CGSizeMake(buttonWidth, 54);
    UIGraphicsBeginImageContextWithOptions(imageSize, 0, [UIScreen mainScreen].scale);
    [colorHightlighted set];
    UIRectFill(CGRectMake(0, 0, imageSize.width, imageSize.height));
    UIImage *pressedColorImg = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    [button setImage:pressedColorImg forState:UIControlStateHighlighted];
    
    if (num<10)
    {
        UILabel *labelNum = [[UILabel alloc] initWithFrame:CGRectMake(0, buttonHeight/4, buttonWidth, buttonHeight/2)];
        labelNum.text = [NSString stringWithFormat:@"%ld",(long)num];
        labelNum.textColor = [UIColor blackColor];
        labelNum.textAlignment = NSTextAlignmentCenter;
        labelNum.font = kCurNormalFontOfSize(27);
        labelNum.backgroundColor = [UIColor clearColor];
        [button addSubview:labelNum];
    }
    else if (num == 11)
    {
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, buttonHeight/4, buttonWidth, buttonHeight/2)];
        label.text = @"0";
        label.textColor = [UIColor blackColor];
        label.textAlignment = NSTextAlignmentCenter;
        label.font = kCurNormalFontOfSize(27);
        label.backgroundColor = [UIColor clearColor];
        [button addSubview:label];
    }
    else if (num == 10)
    {
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, buttonHeight/4,buttonWidth, buttonHeight/2)];
        label.text = @"X";
        label.textColor = [UIColor blackColor];
        label.textAlignment = NSTextAlignmentCenter;
        label.font = kCurNormalFontOfSize(25);
        label.backgroundColor = [UIColor clearColor];
        [button addSubview:label];
    }
    else
    {
        UIImageView *arrow = [[UIImageView alloc] initWithFrame:CGRectMake(buttonWidth/2 - 11, 19, 23, 17)];
        arrow.image = [UIImage imageWithBundlePath:@"FCustomBack.png"];
        [button addSubview:arrow];
    }
    return button;
}

-(void)clickButton:(UIButton *)sender
{
    if (sender.tag == 10)
    {
        [self.delegate AuthenticKeyboardInput:@"X"];
    }
    else if(sender.tag == 12)
    {
        [self.delegate AuthenticKeyboardBackspace];
    }
    else
    {
        NSString * num = [NSString stringWithFormat:@"%ld",(long)sender.tag];
        if (sender.tag == 11)
        {
            num = @"0";
        }
        [self.delegate AuthenticKeyboardInput:num];
    }
}

- (void)btnLong:(id)sender{
    if ([self.delegate respondsToSelector:@selector(AuthenticKeyboardClearTheInput)]) {
        [self.delegate AuthenticKeyboardClearTheInput];
    }
}

@end


@implementation FlightCustomTextField
#pragma mark - 可开启功能方法，由外部控制
- (void)reformatAsCardNumber:(UITextField *)textField
{
    NSUInteger targetCursorPosition =
    [textField offsetFromPosition:textField.beginningOfDocument
                       toPosition:textField.selectedTextRange.start];
    
    NSString *cardNumberWithoutSpaces =
    [self removeNonDigits:textField.text
andPreserveCursorPosition:&targetCursorPosition];
    NSLog(@"string = %@",cardNumberWithoutSpaces);
    if ([cardNumberWithoutSpaces length] > 18) {
        [textField setText:previousTextFieldContent];
        textField.selectedTextRange = previousSelection;
        return;
    }
    
    NSString *cardNumberWithSpaces =
    [self insertSpacesEveryFourDigitsIntoString:cardNumberWithoutSpaces
                      andPreserveCursorPosition:&targetCursorPosition];
    
    textField.text = cardNumberWithSpaces;
    UITextPosition *targetPosition =
    [textField positionFromPosition:[textField beginningOfDocument]
                             offset:targetCursorPosition];
    
    [textField setSelectedTextRange:
     [textField textRangeFromPosition:targetPosition
     toPosition                      :targetPosition]
     ];
}

- (NSString *)  removeNonDigits             :(NSString *)string
                andPreserveCursorPosition   :(NSUInteger *)cursorPosition
{
    NSUInteger      originalCursorPosition = *cursorPosition;
    NSMutableString *digitsOnlyString = [NSMutableString new];
    
    for (NSUInteger i = 0; i < [string length]; i++) {
        unichar characterToAdd = [string characterAtIndex:i];
        
        if (isdigit(characterToAdd) || characterToAdd == 'X') {
            NSString *stringToAdd =
            [NSString stringWithCharacters:&characterToAdd
                                    length:1];
            
            [digitsOnlyString appendString:stringToAdd];
        } else {
            if (i < originalCursorPosition) {
                (*cursorPosition)--;
            }
        }
    }
    
    return digitsOnlyString;
}

- (NSString *)  insertSpacesEveryFourDigitsIntoString   :(NSString *)string
                andPreserveCursorPosition               :(NSUInteger *)cursorPosition
{
    NSMutableString *stringWithAddedSpaces = [NSMutableString new];
    NSUInteger      cursorPositionInSpacelessString = *cursorPosition;
    
    for (NSUInteger i = 0; i < [string length]; i++) {
        if ((i > 0) && (i == 6 || i == 14)) {
            [stringWithAddedSpaces appendString:@" "];
            if (i < cursorPositionInSpacelessString) {
                (*cursorPosition)++;
            }
        }
        unichar     characterToAdd = [string characterAtIndex:i];
        NSString    *stringToAdd =
        [NSString stringWithCharacters:&characterToAdd length:1];
        [stringWithAddedSpaces appendString:stringToAdd];
    }
    
    return stringWithAddedSpaces;
}



#pragma mark - 键盘控制
- (BOOL)becomeFirstResponder
{
    
    return [super becomeFirstResponder];
    
}

- (NSRange)selectedRangeAnd
{
    UITextPosition* beginning = self.beginningOfDocument;
    
    UITextRange* selectedRange = self.selectedTextRange;
    UITextPosition* selectionStart = selectedRange.start;
    UITextPosition* selectionEnd = selectedRange.end;
    
    const NSInteger location = [self offsetFromPosition:beginning toPosition:selectionStart];
    const NSInteger length = [self offsetFromPosition:selectionStart toPosition:selectionEnd];
    
    return NSMakeRange(location, length);
}

- (void)insertTheText:(NSString *)text
{
    
    if ([self.delegate respondsToSelector:@selector(textField:shouldChangeCharactersInRange:replacementString:)]) {
        NSRange range = [self selectedRangeAnd];
        range.length = 0;
        BOOL can = [self.delegate textField:self shouldChangeCharactersInRange:range replacementString:text];
        if (can) {
            [super insertText:text];
            [self sendActionsForControlEvents:UIControlEventEditingChanged];
        }
    }
    else
    {
        [super insertText:text];
       // [self sendActionsForControlEvents:UIControlEventEditingChanged];
    }
}

- (void)deleteTheBackward
{
    if ([self.delegate respondsToSelector:@selector(textField:shouldChangeCharactersInRange:replacementString:)]) {
        NSRange range = [self selectedRangeAnd];
        if (range.location > 0) {
            range.location--;
        }else {
            return;
        }
        range.length = 1;
        BOOL can = [self.delegate textField:self shouldChangeCharactersInRange:range replacementString:@""];
        if (can) {
            [super deleteBackward];
            [self sendActionsForControlEvents:UIControlEventEditingChanged];
        }
    }
    else
    {
        [super deleteBackward];
       // [self sendActionsForControlEvents:UIControlEventEditingChanged];  // lmz
    }
}

- (void)choiceTheTextFieldInputView:(NSInteger )choiceType
{
    if (choiceType == KFlightCustomTextFieldInputView) {
        self.inputView = _customInputView;
    }else {
        self.inputView = nil;
    }
}

#pragma mark -  TrainAuthenticInputViewDelegate

-(void)AuthenticKeyboardBackspace
{
    [self deleteTheBackward];
}

-(void)AuthenticKeyboardInput:(NSString *)string
{
    [self insertTheText:string];
}

-(void)AuthenticKeyboardClearTheInput
{
    self.text = @"";
}

@end
