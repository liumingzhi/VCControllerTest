//
//  KeyBoardVC.m
//  VCControllerTest
//
//  Created by mingzhi.liu on 16/8/24.
//  Copyright © 2016年 mingzhi.liu. All rights reserved.
//

#import "KeyBoardVC.h"
#import "KeyBoardController.h"
#import "FlightCustomTextField.h"
#import "PHTextView.h"

typedef NS_ENUM(NSInteger,keyBoardTag)
{
    KeyBoardUITextFieldStyleTag = 0,
    KeyBoardCustomTextFieldTag,
    KeyBoardUITextViewTag,
    KeyBoardPHTextViewTag,

};


@interface KeyBoardVC () <KeyboardDelegate,UITextFieldDelegate,UIScrollViewDelegate,UITextViewDelegate>

@property (nonatomic, strong) KeyboardController *keyBoardControler;
@property (nonatomic, strong) FlightCustomTextField *textfieldAttributeValue; // 身份证键盘

@end

@implementation KeyBoardVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];


    UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 40, self.view.frame.size.width, self.view.frame.size.height- 40)];
    scrollView.delegate = self;
    scrollView.backgroundColor = [UIColor yellowColor];
    [self.view addSubview:scrollView];
    
    
    UIImageView *imageView = [[UIImageView alloc] init];
    [imageView setBackgroundColor:[UIColor redColor]];
    imageView.image = [UIImage imageNamed:@"FTTSOrderFillCamelBGNew.png"];
    //CGFloat imgW = imageView.image.size.width; // 图片的宽度
    CGFloat imgH = imageView.image.size.height; // 图片的高度
    imageView.frame = CGRectMake(0, 0, self.view.frame.size.width, imgH);
    [scrollView addSubview:imageView];
    [scrollView setContentSize:CGSizeMake(self.view.frame.size.width, imgH)];

    

    // 系统键盘
    UITextField *myField = [[UITextField alloc] initWithFrame:CGRectMake(20, self.view.frame.size.height - 140, 200, 30)];
    myField.backgroundColor = [UIColor whiteColor];
    [myField setKeyboardType:UIKeyboardTypeDefault];
    [myField setContentVerticalAlignment:UIControlContentVerticalAlignmentCenter];
    [myField setDelegate:self];
    [myField setClearsOnBeginEditing:NO];
    [myField setClearButtonMode:UITextFieldViewModeWhileEditing];
    [myField setPlaceholder:@"UITextField"];
    [myField addTarget:self action:@selector(textInputChange:) forControlEvents:UIControlEventEditingChanged];
    [myField addTarget:self action:@selector(textInputFinished:) forControlEvents:UIControlEventEditingDidEndOnExit];
    myField.tag = KeyBoardUITextFieldStyleTag;
    [scrollView addSubview:myField];
    
    // 身份证键盘
    _textfieldAttributeValue = [[FlightCustomTextField alloc] initWithFrame:CGRectZero];
    [_textfieldAttributeValue setFont:kCurBoldFontOfSize(15)];
    [_textfieldAttributeValue setTextColor:[UIColor blackColor]];
    [_textfieldAttributeValue setBackgroundColor:[UIColor whiteColor]];
    [_textfieldAttributeValue setBorderStyle:UITextBorderStyleNone];
    [_textfieldAttributeValue setAutocapitalizationType:UITextAutocapitalizationTypeAllCharacters];
    [_textfieldAttributeValue setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
    [_textfieldAttributeValue setContentVerticalAlignment:UIControlContentVerticalAlignmentCenter];
    [_textfieldAttributeValue setDelegate:self];
    [_textfieldAttributeValue setClearButtonMode:UITextFieldViewModeWhileEditing];
    [_textfieldAttributeValue setBorderStyle:UITextBorderStyleNone];
    [_textfieldAttributeValue setFrame:CGRectMake(20, self.view.frame.size.height - 100, 200, 30)];
    [_textfieldAttributeValue setPlaceholder:@"身份证必填"];
    [_textfieldAttributeValue setClearsOnBeginEditing:NO];
    [_textfieldAttributeValue setReturnKeyType:UIReturnKeyDone];
    _textfieldAttributeValue.adjustsFontSizeToFitWidth = YES;
    _textfieldAttributeValue.tag = KeyBoardCustomTextFieldTag;

    UIScreen *currentScreen = [UIScreen mainScreen];
    FlightAuthenticInputView *customInputView = [[FlightAuthenticInputView alloc] initWithFrame:CGRectMake(0, 0, currentScreen.applicationFrame.size.width, 216)];
    _textfieldAttributeValue.customInputView = customInputView;
    customInputView.delegate = _textfieldAttributeValue;
    
    [_textfieldAttributeValue addTarget:self
                                 action:@selector(textInputChange:)
                       forControlEvents:UIControlEventEditingChanged];
    [_textfieldAttributeValue addTarget:self
                                 action:@selector(textInputFinished:)
                       forControlEvents:UIControlEventEditingDidEndOnExit];
     // 必须写在最后！！！！！
    [_textfieldAttributeValue choiceTheTextFieldInputView:KFlightCustomTextFieldInputView];
    [scrollView addSubview:_textfieldAttributeValue];
    
    
    UITextView *myTextView = [[UITextView alloc] init];
    [myTextView setFont:kCurBoldFontOfSize(15)];
    [myTextView setDelegate:self];
    [myTextView setTag:KeyBoardUITextViewTag];
    [myTextView setReturnKeyType:UIReturnKeyDone];
    [myTextView setBackgroundColor:[UIColor whiteColor]];
    [myTextView setFrame:CGRectMake(20, self.view.frame.size.height - 60, 200, 30)];
    [scrollView addSubview:myTextView];
    
    PHTextView *phTextView = [[PHTextView alloc] init];
    [phTextView setReturnKeyType:UIReturnKeyDone];
    [phTextView setBackgroundColor:[UIColor whiteColor]];
    [phTextView setScrollEnabled:NO];
    [phTextView setFont:kCurBoldFontOfSize(14)];
    [phTextView setDelegate:self];
    [phTextView setPlaceHolder:@"PHTextView"];
    [phTextView setTag:KeyBoardPHTextViewTag];
    [phTextView setFrame:CGRectMake(20, self.view.frame.size.height - 200, 200, 30)];
    [scrollView addSubview:phTextView];
    


    _keyBoardControler = [[KeyboardController alloc] init];
    [_keyBoardControler setDelegate:self];
    [_keyBoardControler addInputView:myField withInScrollView:scrollView];
    [_keyBoardControler addInputView:_textfieldAttributeValue withInScrollView:scrollView];
    [_keyBoardControler addInputView:myTextView withInScrollView:scrollView];
    [_keyBoardControler addInputView:phTextView withInScrollView:scrollView];

    UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(10, 100, 60, 40)];
    btn.backgroundColor = [UIColor redColor];
    [btn setTitle:@"jsPatch" forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(jsPatchTest) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn];

}

-(void)jsPatchTest
{

    NSLog(@"tttttt");

}

- (void)keyboardWillShowInputView:(UIView<UITextInputTraits> *)inputView
{

}
- (void)keyboardDidShowWithHeight:(CGFloat)height andInputView:(UIView<UITextInputTraits> *)inputView
{

}
- (void)keyboardWillHideWithInputView:(UIView<UITextInputTraits> *)inputView
{

}


#pragma mark - scrollViewDelegate
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [_keyBoardControler hideKeyboard];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{


}


-(void)textInputChange:(id)sender
{

    UITextField *textFieldName = (UITextField *)sender;

    
    
    if (textFieldName.tag == KeyBoardUITextFieldStyleTag)
    {
        NSLog(@"textFieldName----- %@",textFieldName.text);
        
        
    }
    else if (textFieldName.tag == KeyBoardCustomTextFieldTag)
    {
        NSLog(@"_textfieldAttributeValue----%@",textFieldName.text);

    
    }

}

// 输入结束
- (void)textInputFinished:(id)sender
{
    UITextField *textFieldName = (UITextField *)sender;
    [textFieldName resignFirstResponder];
}

#pragma mark -textViewDelegate
- (void)textViewDidBeginEditing:(UITextView *)textView
{
    // 滚动屏幕
    [self scrollContentView:textView];
}

- (void)textViewDidChange:(UITextView *)textView
{
    NSInteger textViewTag = [textView tag];
    
    if (textViewTag == KeyBoardUITextViewTag)
    {
        
    }
    else if (KeyBoardPHTextViewTag)
    {
    
        // 调整高度
        PHTextView *textViewStreet = (PHTextView *)textView;
        [textView setViewHeight:[textViewStreet contentHeight]];
        [textView setContentOffset:CGPointZero];
    
    }

    [self scrollContentView:textView];
}

// 滚动输入View
-(void)scrollContentView:(UIView *)viewFocus
{
//    if ([viewFocus isKindOfClass:[UITextField class]] == YES)
//    {
//        [_keyBoardControler changeResponseToInputView:(UITextField *)viewFocus];
//    }
//    else if ([viewFocus isKindOfClass:[UITextView class]] == YES)
//    {
//        [_keyBoardControler changeResponseToInputView:(UITextView *)viewFocus];
//
//    }
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
