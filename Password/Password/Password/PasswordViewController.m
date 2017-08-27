//
//  PasswordViewController.m
//  Password
//
//  Created by apple on 19/03/2017.
//  Copyright © 2017 sinalma. All rights reserved.
//

#import "PasswordViewController.h"
#import "KeyView.h"

// 初始化的字符串和单双两串数字，需要加密保存
#define DefaultStr @"abcdefg" // sinalma
#define OddNumberStr @"12" // 09
#define EvenNumberStr @"34" // 18

// 沙盒存储的路径和key
#define CachePath [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) firstObject]
#define SandboxOddNumberStrKey @"OddNumberStrKey"
#define SandboxEvenNumberStrKey @"EvenNumberStrKey"
#define SandboxDefaultStrKey @"DefaultStrKey"

#define ScreenH [UIScreen mainScreen].bounds.size.height
#define ScreenW [UIScreen mainScreen].bounds.size.width
#define GroundViewWH 300
#define TextFieldH 35
#define ParameterViewWH 300
#define KeyboardDuration 0.25

@interface PasswordViewController () <UITextFieldDelegate>

#pragma mark - View
// Password View
@property (nonatomic,strong) UIView *groundView;
@property (nonatomic,strong) UITextField *pointStrField;
@property (nonatomic,strong) UIButton *okBtn;
@property (nonatomic,strong) UILabel *resultLabel;
@property (nonatomic,strong) UIButton *modifyBtn;

// Remind Regular For View Bottom
@property (nonatomic,strong) UILabel *remindLabel;

// Parameter View
@property (nonatomic,strong) UIView *parameterView;
@property (nonatomic,strong) UITextField *defaultField;
@property (nonatomic,strong) UITextField *oddNumberField;
@property (nonatomic,strong) UITextField *evenNumberField;
@property (nonatomic,strong) UIButton *modifyOkBtn;

// Record Fisrt Respond TextField
@property (nonatomic,strong) UITextField *curTextField;

#pragma mark - Data
// Save Parameter For User
@property (nonatomic,strong) NSString *defaultStr;
@property (nonatomic,strong) NSString *oddNumberStr;
@property (nonatomic,strong) NSString *evenNumberStr;
@property (nonatomic,strong) NSDictionary *paramterDict;

// Password view to in the point key view.
@property (nonatomic,strong) KeyView *keyView;

@end

@implementation PasswordViewController

#pragma mark - Application Enter
- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setup];
    
    [self sandboxParamter];
}

#pragma mark - Sandbox Operation
- (void)sandboxParamter
{
    NSLog(@"%@",[self paramterFilePath]);
    NSDictionary *paramterDict = [NSDictionary dictionaryWithContentsOfFile:[self paramterFilePath]];
    // 沙盒没有plist文件
    if (!paramterDict) {
        // 使用默认值
        paramterDict = @{SandboxDefaultStrKey:DefaultStr,SandboxOddNumberStrKey:OddNumberStr,SandboxEvenNumberStrKey:EvenNumberStr};
    }
    // 沙盒有plist文件
    self.paramterDict = paramterDict;
    self.defaultField.text = paramterDict[SandboxDefaultStrKey];
    self.oddNumberField.text = paramterDict[SandboxOddNumberStrKey];
    self.evenNumberField.text = paramterDict[SandboxEvenNumberStrKey];
}

- (NSString *)paramterFilePath
{
    return [self fielPathWithName:@"paramterDict.plist"];
}

- (NSString *)fielPathWithName:(NSString *)fileName
{
    return [CachePath stringByAppendingPathComponent:fileName];
}

- (NSString *)oddNumberStr
{
    if (!_oddNumberStr.length) {
        _oddNumberStr = self.paramterDict[SandboxOddNumberStrKey];
        return _oddNumberStr.length ? _oddNumberStr : OddNumberStr;
    }
    return _oddNumberStr;
}

- (NSString *)evenNumberStr
{
    if (!_evenNumberStr.length) {
        _evenNumberStr = self.paramterDict[SandboxEvenNumberStrKey];
        return _evenNumberStr.length ? _evenNumberStr : EvenNumberStr;
    }
    return _evenNumberStr;
}

- (NSString *)defaultStr
{
    if (!_defaultStr.length) {
        _defaultStr = self.paramterDict[SandboxDefaultStrKey];
        return _defaultStr.length ? _defaultStr : DefaultStr;
    }
    return _defaultStr;
}

#pragma mark - UITextFieldDelegate
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if ([textField isEqual:self.pointStrField]) {
        [self okBtnClick];
    }
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    self.curTextField = textField;
    
    // ground view in the bottom ,_pointStrField is fisrt respond ,transLatation up
    if ([textField isEqual:self.pointStrField] && self.remindLabel.alpha < 0.1) {
        [UIView animateWithDuration:KeyboardDuration animations:^{
            self.groundView.transform = CGAffineTransformIdentity;
            self.parameterView.alpha = 0.001;
        }];
    }
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    if ([textField isEqual:self.pointStrField] && self.remindLabel.alpha < 0.1) {
        [UIView animateWithDuration:KeyboardDuration animations:^{
            self.groundView.transform = CGAffineTransformMakeTranslation(0, ScreenH - GroundViewWH + 50);;
            self.parameterView.alpha = 1.0;
        }];
    }
}

#pragma mark - Event
/**
 * OK Btn Click For Parameter Interface
 */
- (void)modifyOkBtnClick
{
    self.defaultStr = self.defaultField.text;
    self.oddNumberStr = self.oddNumberField.text;
    self.evenNumberStr = self.evenNumberField.text;
    
    // sandbox data
    NSDictionary *paramterDict = @{SandboxDefaultStrKey : self.defaultStr,SandboxOddNumberStrKey : self.oddNumberStr,SandboxEvenNumberStrKey : self.evenNumberStr};
    self.paramterDict = paramterDict;
    [paramterDict writeToFile:[self paramterFilePath] atomically:YES];
    
    self.modifyBtn.enabled = YES;
    [UIView animateWithDuration:1.0 animations:^{
        [self.curTextField endEditing:YES];
        self.parameterView.transform = CGAffineTransformMakeTranslation(0, -ParameterViewWH * 2);
        self.groundView.transform = CGAffineTransformIdentity;
        self.groundView.transform = CGAffineTransformMakeRotation(M_PI * 2);
        self.remindLabel.alpha = 1.0;
    }];
}

/**
 * OK Btn Click Method For Password Interface
 */
- (void)okBtnClick
{
    [self.pointStrField endEditing:YES];
    // show password
    self.resultLabel.text = [self transformWithPointkey:self.pointStrField.text];
    self.pointStrField.text = nil;
}

- (void)modifyBtnClick
{
    self.keyView.hidden = NO;
    __weak PasswordViewController *weakSelf = self;
    self.keyView.modifyBlock = ^(){
        weakSelf.modifyBtn.enabled = NO;
        [UIView animateWithDuration:1.0 animations:^{
            
            [weakSelf.curTextField endEditing:YES];
            weakSelf.keyView.hidden = YES;
            weakSelf.groundView.transform = CGAffineTransformMakeTranslation(0, ScreenH - GroundViewWH + 50);
            weakSelf.remindLabel.alpha = 0.001;
            weakSelf.parameterView.hidden = NO;
            weakSelf.parameterView.transform = CGAffineTransformIdentity;
        }];
    };
}

- (void)parameterViewClick:(UITapGestureRecognizer *)tap
{
    [self.curTextField endEditing:YES];
    
    // can not click ok ,resume pre text field value.
    self.defaultField.text = self.defaultStr;
    self.oddNumberField.text = self.oddNumberStr;
    self.evenNumberField.text = self.evenNumberStr;
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self.pointStrField endEditing:NO];
}

- (void)didReceiveMemoryWarning
{
    self.evenNumberStr = nil;
    self.oddNumberStr = nil;
    self.defaultStr = nil;
    self.paramterDict = nil;
}

#pragma mark - Core Code
/**
 * Create password according to point key.
 * regular:First
 */
- (NSString *)transformWithPointkey:(NSString *)pointKey
{
    // transform small letter
    pointKey = [pointKey lowercaseString];
    
    NSArray *pointKeyArr = [self characterWithStr:pointKey];
    NSArray *oddNumberArr = [self characterWithStr:self.oddNumberStr];
    NSArray *evenNumberArr = [self characterWithStr:self.evenNumberStr];
    NSArray *defaultArr = [self characterWithStr:self.defaultStr];
    
    NSMutableString *strM = [NSMutableString string];
    
    for (int i = 0; i < pointKeyArr.count; i++) {
        
        [strM appendString:defaultArr[i]];
        [strM appendString:pointKeyArr[i]];

        if (i == 1) {
            [strM appendString:pointKeyArr[i-1]];
        }
        
        if (i == pointKeyArr.count - 1) {
            [strM appendString:defaultArr[i+1]];
        }
    }
    
    NSInteger defaultLeftIndex = 0;
    NSInteger insertIndex = 0;
    for (NSInteger i = pointKeyArr.count+1; i < defaultArr.count; i++) {
        if (defaultLeftIndex % 2 == 1) {
            [strM appendString:defaultArr[i]];
        }else if (defaultLeftIndex % 2 == 0)
        {
            [strM insertString:defaultArr[i] atIndex:insertIndex];
            insertIndex += 1;
        }
        defaultLeftIndex += 1;
    }
    
    NSArray *numberArr = pointKeyArr.count % 2 == 0 ? evenNumberArr : oddNumberArr;
    
    for (int i = 0; i < numberArr.count; i++) {
    
        [strM appendString:numberArr[i]];
        
        if (i == 0) {
            [strM appendFormat:@"%ld",(unsigned long)pointKeyArr.count];
        }
        
        if (i == numberArr.count - 1) {
            [strM appendFormat:@"%d",(int)pointKeyArr.count + 5];
            [strM appendFormat:@"%d",abs((int)pointKeyArr.count - 3)];
        }
    }
    NSString *resultStr = strM;
    resultStr = [resultStr capitalizedString];
    
    return resultStr;
}

/**
 * Return String Array
 *
 * @Parameter one (str) : NSString
 */
- (NSArray *)characterWithStr:(NSString *)str
{
    NSMutableArray *arrM = [NSMutableArray array];
    NSString *c = nil;
    for (int i = 0; i < [str length]; i++) {
        c = [str substringWithRange:NSMakeRange(i, 1)];
        [arrM addObject:c];
    }
    return arrM;
}

- (void)setup
{
    self.view.backgroundColor = [UIColor purpleColor];
    
    [self.parameterView addSubview:self.defaultField];
    [self.parameterView addSubview:self.oddNumberField];
    [self.parameterView addSubview:self.evenNumberField];
    [self.parameterView addSubview:self.modifyOkBtn];
    
    [self.groundView addSubview:self.pointStrField];
    [self.groundView addSubview:self.okBtn];
    [self.groundView addSubview:self.resultLabel];
    [self.view addSubview:self.remindLabel];
    [self.groundView addSubview:self.modifyBtn];
    
    [self.view addSubview:self.keyView];
}

- (UITextField *)createTextFieldWithPlaceholder:(NSString *)placeholder frame:(CGRect)frame
{
    UITextField *textfield = [[UITextField alloc] init];
    textfield.delegate = self;
    textfield.placeholder = placeholder;
    textfield.backgroundColor = [UIColor whiteColor];
    textfield.frame = frame;
    textfield.layer.cornerRadius = 5;
    return textfield;
}

#pragma mark - Lazy load
- (UIView *)groundView
{
    if (!_groundView) {
        _groundView = [[UIView alloc] init];
        _groundView.layer.masksToBounds = YES;
        _groundView.layer.borderWidth = 2;
        _groundView.layer.borderColor = [UIColor redColor].CGColor;
        _groundView.backgroundColor = [UIColor purpleColor];
        _groundView.frame = CGRectMake((ScreenW-GroundViewWH)*0.5, 15, GroundViewWH, GroundViewWH);
        _groundView.layer.cornerRadius = GroundViewWH*0.5;
        [self.view addSubview:_groundView];
        
    }
    return _groundView;
}

- (UITextField *)pointStrField
{
    if (!_pointStrField) {
        CGRect frame = CGRectMake(2, (GroundViewWH*0.5-TextFieldH*0.5), GroundViewWH, TextFieldH);
        _pointStrField = [self createTextFieldWithPlaceholder:@"Please input the point key" frame:frame];
        _pointStrField.textAlignment = NSTextAlignmentCenter;
    }
    return _pointStrField;
}

- (UIButton *)okBtn
{
    if (!_okBtn) {
        _okBtn = [[UIButton alloc] init];
        [_okBtn setTitle:@"OK" forState:UIControlStateNormal];
        _okBtn.backgroundColor = [UIColor redColor];
        _okBtn.frame = CGRectMake(25, (GroundViewWH*0.5+TextFieldH*0.5+20), GroundViewWH-50, TextFieldH);
        _okBtn.layer.cornerRadius = 5;
        [_okBtn addTarget:self action:@selector(okBtnClick) forControlEvents:UIControlEventTouchUpInside];
    }
    return _okBtn;
}

- (UILabel *)resultLabel
{
    if (!_resultLabel) {
        _resultLabel = [[UILabel alloc] init];
        _resultLabel.backgroundColor = [UIColor purpleColor];
        _resultLabel.numberOfLines = 0;
        _resultLabel.textAlignment = NSTextAlignmentCenter;
        _resultLabel.font = [UIFont systemFontOfSize:17];
        _resultLabel.textColor = [UIColor whiteColor];
        _resultLabel.frame = CGRectMake(25, (GroundViewWH*0.5-TextFieldH*0.5-20-TextFieldH*0.5), GroundViewWH-50, TextFieldH);
        _resultLabel.layer.cornerRadius = 5;
    }
    return _resultLabel;
}

- (UILabel *)remindLabel
{
    if (!_remindLabel) {
        _remindLabel = [[UILabel alloc] init];
        _remindLabel.textColor = [UIColor whiteColor];
        _remindLabel.numberOfLines = 0;
        _remindLabel.textAlignment = NSTextAlignmentJustified;
        _remindLabel.backgroundColor = [UIColor clearColor];
        _remindLabel.frame = CGRectMake(self.groundView.frame.origin.x, CGRectGetMaxY(self.groundView.frame), GroundViewWH, ScreenH-CGRectGetMaxY(self.groundView.frame));
        _remindLabel.text = [NSString stringWithFormat:@"Regular For Point Key : \n \n*    Just can input number and letter.\n*    The default string、odd number and even number is default,not propose change.\n*    If point key is empty,receive default password.\n*    Click 🔑 icon can change paramter."];
    }
    return _remindLabel;
}

- (UIButton *)modifyBtn
{
    if (!_modifyBtn) {
        _modifyBtn = [[UIButton alloc] init];
        [_modifyBtn setTitle:@"🔑" forState:UIControlStateNormal];
        _modifyBtn.backgroundColor = [UIColor greenColor];
        _modifyBtn.frame = CGRectMake(32, CGRectGetMaxY(self.okBtn.frame) + 20, GroundViewWH-64, TextFieldH + 20);
        _modifyBtn.layer.cornerRadius = 5;
        [_modifyBtn addTarget:self action:@selector(modifyBtnClick) forControlEvents:UIControlEventTouchUpInside];
    }
    return _modifyBtn;
}

- (UIView *)parameterView
{
    if (!_parameterView) {
        _parameterView = [[UIView alloc] init];
        _parameterView.hidden = YES;
        _parameterView.backgroundColor = [UIColor purpleColor];
        _parameterView.frame = CGRectMake((ScreenW-GroundViewWH)*0.5, 30, GroundViewWH, GroundViewWH);
        [self.view addSubview:_parameterView];
        _parameterView.transform = CGAffineTransformMakeTranslation(0, -ParameterViewWH * 2);
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(parameterViewClick:)];
        [_parameterView addGestureRecognizer:tap];
    }
    return _parameterView;
}

- (UITextField *)defaultField
{
    if (!_defaultField) {
        CGRect frame = CGRectMake(0, 20, ParameterViewWH, TextFieldH);
        _defaultField = [self createTextFieldWithPlaceholder:@"Please input the default string" frame:frame];
    }
    return _defaultField;
}

- (UITextField *)oddNumberField
{
    if (!_oddNumberField) {
          CGRect frame = CGRectMake(0, CGRectGetMaxY(self.defaultField.frame) + 20, ParameterViewWH, TextFieldH);
        _oddNumberField = [self createTextFieldWithPlaceholder:@"Please input the odd number" frame:frame];
    }
    return _oddNumberField;
}

- (UITextField *)evenNumberField
{
    if (!_evenNumberField) {
        CGRect frame = CGRectMake(0, CGRectGetMaxY(self.oddNumberField.frame) + 20, ParameterViewWH, TextFieldH);
        _evenNumberField = [self createTextFieldWithPlaceholder:@"Please input the even number" frame:frame];
    }
    return _evenNumberField;
}

- (UIButton *)modifyOkBtn
{
    if (!_modifyOkBtn) {
        _modifyOkBtn = [[UIButton alloc] init];
        [_modifyOkBtn setTitle:@"OK" forState:UIControlStateNormal];
        _modifyOkBtn.backgroundColor = [UIColor greenColor];
        _modifyOkBtn.frame = CGRectMake(ParameterViewWH*0.5-50, CGRectGetMaxY(self.evenNumberField.frame) + 20, 100, 100);
        _modifyOkBtn.layer.cornerRadius = 50;
        [_modifyOkBtn addTarget:self action:@selector(modifyOkBtnClick) forControlEvents:UIControlEventTouchUpInside];
    }
    return _modifyOkBtn;
}

- (KeyView *)keyView
{
    if (!_keyView) {
        _keyView = [[KeyView alloc] init];
        _keyView.frame = self.view.bounds;
        _keyView.hidden = YES;
    }
    return _keyView;
}

@end
