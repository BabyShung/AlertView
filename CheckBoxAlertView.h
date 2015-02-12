//
//  CheckBoxAlertView.h
//  AlarmAlertController
//
//  Created by Hao Zheng on 2/12/15.
//  Copyright (c) 2015 Hao Zheng. All rights reserved.
//

#import "AlarmAlertView.h"

@interface CheckBoxAlertView : AlarmAlertView

- (instancetype)initWithTitle:(NSString *)title
                      message:(NSString *)message
                   checkItems:(NSArray *)checkItems
               preferredStyle:(AlarmAlertStyle)style
                subViewOfView:(UIView *)superView;

@end
