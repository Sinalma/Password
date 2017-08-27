//
//  KeyView.m
//  Password
//
//  Created by apple on 20/03/2017.
//  Copyright © 2017 sinalma. All rights reserved.
//

#import "KeyView.h"

#define ScreenH [UIScreen mainScreen].bounds.size.height
#define ScreenW [UIScreen mainScreen].bounds.size.width

#define KeyViewNumBtnCount 11
#define KeyNumMaxCount 10

#define DefaultKeyNums @"123456"

@interface KeyView ()

@property (nonatomic,strong) UITextField *pwdTextField;

@property (nonatomic,strong) UIView *keyboardView;

@property (nonatomic,strong) NSArray *numBtns;

#pragma mark - data
// save already input numbers
@property (nonatomic,strong) NSMutableArray *curNumbers;

@property (nonatomic,strong) NSTimer *timer;

@end

@implementation KeyView

- (instancetype)init
{
    if (self = [super init]) {
        [self setup];
        [self setupNumBtns];
        [self setupFieldTimer];
    }
    return self;
}

static int fieldAnimaIndex = 0;
- (void)setupFieldTimer
{
    self.timer = [NSTimer timerWithTimeInterval:0.1 target:self selector:@selector(fieldAnim) userInfo:nil repeats:YES];
    [[NSRunLoop mainRunLoop] addTimer:self.timer forMode:NSDefaultRunLoopMode];
}

- (void)fieldAnim
{
    if (fieldAnimaIndex == self.pwdTextField.placeholder.length-2) {
        fieldAnimaIndex = 0;
    }
    NSMutableAttributedString *attStrM = [[NSMutableAttributedString alloc] initWithString:self.pwdTextField.placeholder];
    
    [attStrM addAttribute:NSForegroundColorAttributeName value:[UIColor whiteColor] range:NSMakeRange(0, self.pwdTextField.placeholder.length)];
    [attStrM addAttribute:NSForegroundColorAttributeName value:[UIColor redColor] range:NSMakeRange(fieldAnimaIndex, 3)];
    
    [attStrM addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:15] range:NSMakeRange(0, self.pwdTextField.placeholder.length)];
    [attStrM addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:17] range:NSMakeRange(fieldAnimaIndex, 1)];
    fieldAnimaIndex += 1;
    self.pwdTextField.attributedPlaceholder = attStrM;
}

- (void)setupNumBtns
{
    CGFloat keyViewW = self.keyboardView.frame.size.width;
    CGFloat keyViewH = self.keyboardView.frame.size.height;
    int coloumCount = 3;
    CGFloat btnW = keyViewW / 3;
    int rowCount = KeyViewNumBtnCount / 3;
    rowCount = !KeyViewNumBtnCount % 3 ?:rowCount+1;
    CGFloat btnH = keyViewH / rowCount;
    CGFloat btnX = 0;
    CGFloat btnY = 0;
    int coloum = 0;
    int row = 0;
    
    CGFloat lineWH = 0.5;// line minmum width and height
    
    for (int i = 0; i < KeyViewNumBtnCount; i++) {
        UIButton *btn = [[UIButton alloc] init];
        NSString *titleStr = [NSString stringWithFormat:@"%d",i+1];
        btn.tag = i+1;
        if (i==9) {
            titleStr = @"0";
            btn.tag = 0;
        }else if (i==10)
        {
            titleStr = @"Delete";
        }
        [btn setTitle:titleStr forState:UIControlStateNormal];
        btn.backgroundColor = [UIColor blackColor];
        [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [btn setTitleColor:[UIColor redColor] forState:UIControlStateHighlighted];
        [btn addTarget:self action:@selector(numBtnClick:) forControlEvents:UIControlEventTouchUpInside];
        
        row = i / coloumCount;
        coloum = i % coloumCount;
    
        btnX = i>8?(coloum + 1)*btnW:coloum*btnW;
        btnY = row * btnH;
        
        btn.frame = CGRectMake(btnX, btnY, btnW, btnH);
        [self.keyboardView addSubview:btn];
        
        // crave line
        // horizontal
        for (int i = 0; i < rowCount+1; i++) {
            UIView *line = [[UIView alloc] init];
            line.backgroundColor = [UIColor whiteColor];
            line.frame = CGRectMake(0, btnH*i, keyViewW, lineWH);
            [self.keyboardView addSubview:line];
        }
        
        // vertical
        for (int i = 0; i < coloumCount+1; i++) {
            UIView *line = [[UIView alloc] init];
            line.backgroundColor = [UIColor whiteColor];
            line.frame = CGRectMake(btnW*i, 0, lineWH, keyViewH);
            [self.keyboardView addSubview:line];
        }
    }
}

- (void)numBtnClick:(UIButton *)btn
{
    NSString *fieldStr = [NSString stringWithFormat:@"%d",(int)btn.tag];
    if (btn.tag==10) {
        fieldStr = @"0";
    }
    
    if (self.curNumbers.count==KeyNumMaxCount && btn.tag!=11) {
        return;
    }
    
    if (btn.tag != 11) {
        [self.curNumbers addObject:fieldStr];
    }else
    {
        [self.curNumbers removeLastObject];
    }
    
    self.pwdTextField.text = [self stringWithstringArray:self.curNumbers];
    
    if ([self.pwdTextField.text isEqualToString:DefaultKeyNums]) {
        self.pwdTextField.text = nil;
        self.curNumbers = nil;
        [self.curNumbers removeAllObjects];
        
        // back block
        self.modifyBlock();
        }
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    self.hidden = YES;
    self.pwdTextField.text = nil;
    self.curNumbers = nil;
    [self.curNumbers removeAllObjects];
}

- (NSString *)stringWithstringArray:(NSArray *)stringArray
{
    NSMutableString *strM = [NSMutableString string];
    for (int i = 0 ; i < stringArray.count; i++) {
        [strM appendString:stringArray[i]];
    }
    return strM;
}

- (void)setup
{
    UIColor *col = [UIColor blackColor];
    self.backgroundColor = [col colorWithAlphaComponent:0.5];
    
    [self addSubview:self.pwdTextField];
    [self addSubview:self.keyboardView];
}

- (UIView *)keyboardView
{
    if (!_keyboardView) {
        _keyboardView = [[UIView alloc] init];
        _keyboardView.backgroundColor = [UIColor blackColor];
        _keyboardView.frame = CGRectMake(20, CGRectGetMaxY(self.pwdTextField.frame)+10, self.pwdTextField.frame.size.width, ScreenH*0.5-self.pwdTextField.frame.size.height-10);
    }
    return _keyboardView;
}

- (UITextField *)pwdTextField
{
    if (!_pwdTextField) {
        _pwdTextField = [[UITextField alloc] init];
        _pwdTextField.frame = CGRectMake(20, ScreenH*0.46, ScreenW - 20 * 2, 40);
        _pwdTextField.enabled = NO;
        [_pwdTextField setSecureTextEntry:YES];
        _pwdTextField.placeholder = @"Please input key password";
        NSMutableAttributedString *placeholderAtt = [[NSMutableAttributedString alloc] initWithString:_pwdTextField.placeholder];
        [placeholderAtt addAttribute:NSForegroundColorAttributeName
                           value:[UIColor whiteColor]
                               range:NSMakeRange(0, _pwdTextField.placeholder.length)];
        
        _pwdTextField.attributedPlaceholder = placeholderAtt;
        _pwdTextField.backgroundColor = [UIColor blackColor];
        _pwdTextField.textColor = [UIColor whiteColor];
        _pwdTextField.textAlignment = NSTextAlignmentCenter;
        _pwdTextField.layer.cornerRadius = 5;
        _pwdTextField.layer.borderColor = [UIColor whiteColor].CGColor;
        _pwdTextField.layer.borderWidth = 1;
    }
    return _pwdTextField;
}

- (NSMutableArray *)curNumbers
{
    if (!_curNumbers) {
        _curNumbers = [NSMutableArray array];
    }
    return _curNumbers;
}

@end
