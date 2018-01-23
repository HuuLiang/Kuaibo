//
//  KbHudManager.m
//  kuaibov
//
//  Created by Sean Yue on 15/9/10.
//  Copyright (c) 2015年 kuaibov. All rights reserved.
//

#import "KbHudManager.h"
#import <MBProgressHUD.h>

@interface KbHudManager ()
@property (nonatomic,retain) MBProgressHUD *textHud;
@end

@implementation KbHudManager

+(instancetype)manager {
    static KbHudManager *_instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[KbHudManager alloc] init];
    });
    return _instance;
}

- (UIView *)hudView {
    return self.textHud;
}

-(instancetype)init {
    self = [super init];
    if (!self) {
        return nil;
    }
    
    UIWindow *keyWindow = [[UIApplication sharedApplication].delegate window];
    self.textHud = [[MBProgressHUD alloc] initWithWindow:keyWindow];
    self.textHud.userInteractionEnabled = NO;
    self.textHud.mode = MBProgressHUDModeText;
    self.textHud.minShowTime = 2;
    self.textHud.detailsLabelFont = [UIFont systemFontOfSize:16.];
    self.textHud.labelFont = [UIFont systemFontOfSize:20.];
    //self.textHud.yOffset = [UIScreen mainScreen].bounds.size.height / 4;
    [keyWindow addSubview:self.textHud];
    
    return self;
}

-(void)showHudWithText:(NSString *)text {
    if (text) {
        if (text.length < 10) {
            self.textHud.labelText = text;
            self.textHud.detailsLabelText = nil;
        } else {
            self.textHud.labelText = nil;
            self.textHud.detailsLabelText = text;
        }
        
        [self.textHud show:YES];
        [self.textHud hide:YES];
    }
}

-(void)showHudWithTitle:(NSString *)title message:(NSString *)msg {
    self.textHud.labelText = title;
    self.textHud.detailsLabelText = msg;
    
    [self.textHud show:YES];
    [self.textHud hide:YES];
}

@end
