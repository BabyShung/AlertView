//
//  CheckboxAlertView.m
//  AlarmAlertController
//
//  Created by Hao Zheng on 2/11/15.
//  Copyright (c) 2015 Hao Zheng. All rights reserved.
//

#import "CheckboxAlertView.h"

#pragma mark - CheckboxButtonItem



@implementation CheckboxButtonItem

@end

#pragma mark - CheckboxAlertView

@interface CheckboxAlertView ()

@property (nonatomic, strong) NSMutableArray *mutableSelectedItems;

@end

@implementation CheckboxAlertView

- (instancetype)initWithTitle:(NSString *)title
                      message:(NSString *)message
                   checkItems:(NSArray *)checkItems
               preferredStyle:(AlarmAlertStyle)style
                subViewOfView:(UIView *)superView
{
    UIView *customView = [[UIView alloc] init];
    customView.translatesAutoresizingMaskIntoConstraints = NO;
    customView.backgroundColor = [UIColor purpleColor];
    [customView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[customView(200)]" options:kNilOptions metrics:nil views:NSDictionaryOfVariableBindings(customView)]];
    
    
    
    self = [self initWithTitle:title message:message customView:customView preferredStyle:style subViewOfView:superView];
    if (self) {
        
    }
    return self;
}

- (void)addActionCheckBoxWithTitle:(NSString *)title titleColor:(UIColor *)color style:(AlertButtonStyle)style handler:(void (^)(CheckboxButtonItem *item, NSArray* selectedCheckboxItems))handle
{
    CheckboxButtonItem * item = [[CheckboxButtonItem alloc] initWithTitle:title andButtonTitleColor:color andStyle:style];
    item.checkboxHandler = handle;
    item.selector = @selector(newActionButtonPressed:);
    [self addAction:item];
}

- (void)newActionButtonPressed:(CheckboxButtonItem *)sender
{
    
//    if (sender.item.checkboxHandler) {
//        sender.item.checkboxHandler(sender.item,@[@"aa",@"bb"]);
//    }
//    [self dismiss];
}

- (UIView *)getLineView
{
    UIView *view = [[UIView alloc] init];
    [view setTranslatesAutoresizingMaskIntoConstraints:NO];
    view.backgroundColor = [UIColor colorWithRed:0.824 green:0.827 blue:0.831 alpha:1.000];
    return view;
}


@end
