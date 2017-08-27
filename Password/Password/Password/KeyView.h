//
//  KeyView.h
//  Password
//
//  Created by apple on 20/03/2017.
//  Copyright © 2017 sinalma. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^ModifyBlock)();

@interface KeyView : UIView

@property (nonatomic,copy) ModifyBlock modifyBlock;

@end
