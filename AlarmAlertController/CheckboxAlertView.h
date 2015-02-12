//
//  CheckboxAlertView.h
//  AlarmAlertController
//
//  Created by Hao Zheng on 2/11/15.
//  Copyright (c) 2015 Hao Zheng. All rights reserved.
//

#import "AlarmAlertView.h"

@interface CheckboxButtonItem : AlarmAlertButtonItem

typedef void(^CheckBoxHandler) (CheckboxButtonItem *item, NSArray* selectedCheckboxItems);

@property (nonatomic, strong) CheckBoxHandler checkboxHandler;

@end

@interface CheckboxAlertView : AlarmAlertView




- (instancetype)initWithTitle:(NSString *)title
                      message:(NSString *)message
                   checkItems:(NSArray *)checkItems
               preferredStyle:(AlarmAlertStyle)style
                subViewOfView:(UIView *)superView;

- (void)addActionCheckBoxWithTitle:(NSString *)title titleColor:(UIColor *)color style:(AlertButtonStyle)style handler:(void (^)(CheckboxButtonItem *item, NSArray* selectedCheckboxItems))handle;


@end


