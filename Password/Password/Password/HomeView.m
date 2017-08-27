//
//  HomeView.m
//  Password
//
//  Created by apple on 23/08/2017.
//  Copyright © 2017 sinalma. All rights reserved.
//

#import "HomeView.h"
#import "KeyView.h"

@interface HomeView ()

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

// Password view to in the point key view.
@property (nonatomic,strong) KeyView *keyView;

@end

@implementation HomeView

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self setup];
    }
    return self;
}
- (void)setup
{
    self.backgroundColor = [UIColor purpleColor];
    
    [self.parameterView addSubview:self.defaultField];
    [self.parameterView addSubview:self.oddNumberField];
    [self.parameterView addSubview:self.evenNumberField];
    [self.parameterView addSubview:self.modifyOkBtn];
    
    [self.groundView addSubview:self.pointStrField];
    [self.groundView addSubview:self.okBtn];
    [self.groundView addSubview:self.resultLabel];
    [self addSubview:self.remindLabel];
    [self.groundView addSubview:self.modifyBtn];
    
    [self addSubview:self.keyView];
}

@end
