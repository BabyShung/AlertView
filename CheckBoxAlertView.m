//
//  CheckBoxAlertView.m
//  AlarmAlertController
//
//  Created by Hao Zheng on 2/12/15.
//  Copyright (c) 2015 Hao Zheng. All rights reserved.
//

#import "CheckBoxAlertView.h"
#import "CheckCircleButton.h"
#import "ResizingLabel.h"

@interface CheckBoxAlertView ()

@property (nonatomic, copy) NSArray *checkItems;

@end

@implementation CheckBoxAlertView

- (instancetype)initWithTitle:(NSString *)title
                      message:(NSString *)message
                   checkItems:(NSArray *)checkItems
               preferredStyle:(AlarmAlertStyle)style
                subViewOfView:(UIView *)superView
{
    self.checkItems = checkItems;
    
    self = [self initWithTitle:title message:message customView:[self getCustomView] preferredStyle:AACentered subViewOfView:superView];
    if (self) {
    }
    return self;
}

- (UIView *)getCustomView
{
    if (self.checkItems.count == 0)
        return nil;
    UIView *customView = [[UIView alloc] init];
    customView.translatesAutoresizingMaskIntoConstraints = NO;
    
    UIView *preView = customView;
    
    NSDictionary *metric = @{@"buttonHeight":IS_IPHONE_5_OR_LESS?@(47):@(50),
                             @"labelHeight":IS_IPHONE_5_OR_LESS?@(30):@(35)};
    
    for (NSString *tmp in self.checkItems){
        AlarmAlertButtonItem *item = [[AlarmAlertButtonItem alloc] initWithTitle:tmp andButtonTitleColor:nil andStyle:AlertButtonStyleDefault andAlignment:NSTextAlignmentLeft];
        item.selectionHandler = nil;
        
        UIView *line = [self getLineView];
        UIButton *button = [self getAButton:item];
        UILabel *label = [self getLabel:item];
        
        [customView addSubview:line];
        
        [customView addSubview:button];
        
        [customView addSubview:label];
        
        if (preView == customView) {
            [customView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[line(0.5)]" options:kNilOptions metrics:nil views:NSDictionaryOfVariableBindings(line)]];
        }else{
            
            [customView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[preView][line(0.5)]" options:kNilOptions metrics:nil views:NSDictionaryOfVariableBindings(preView,line)]];
            
        }
        [customView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[line]|" options:kNilOptions metrics:nil views:NSDictionaryOfVariableBindings(line)]];
        
        preView = line;
        
        [customView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[preView][button(buttonHeight)]" options:kNilOptions metrics:metric views:NSDictionaryOfVariableBindings(preView,button)]];
        [customView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[button]|" options:kNilOptions metrics:nil views:NSDictionaryOfVariableBindings(button)]];
        
        preView = button;
        
        [customView addConstraint:[NSLayoutConstraint constraintWithItem:label attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:preView attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:-1]];
        [customView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[label(labelHeight)]" options:kNilOptions metrics:metric views:NSDictionaryOfVariableBindings(label)]];
        [customView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-(55)-[label]-(20)-|" options:kNilOptions metrics:nil views:NSDictionaryOfVariableBindings(label)]];
        
        //no need to set label as preView
    }
    
    [customView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[preView]|" options:kNilOptions metrics:nil views:NSDictionaryOfVariableBindings(preView)]];
    return customView;
}

#pragma mark - helpers

- (UIView *)getLineView
{
    UIView *view = [[UIView alloc] init];
    [view setTranslatesAutoresizingMaskIntoConstraints:NO];
    view.backgroundColor = [UIColor colorWithRed:0.824 green:0.827 blue:0.831 alpha:1.000];
    return view;
}

- (UILabel *)getLabel:(AlarmAlertButtonItem *)item
{
    ResizingLabel *label = [[ResizingLabel alloc] init];
    label.translatesAutoresizingMaskIntoConstraints = NO;
    label.textAlignment = NSTextAlignmentLeft;
    [label setAttributedText:item.buttonTitle];
    return label;
}

- (UIButton *)getAButton:(AlarmAlertButtonItem *)item
{
    CheckCircleButton *button = [[CheckCircleButton alloc] init];
    [button setTranslatesAutoresizingMaskIntoConstraints:NO];
    button.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    button.contentEdgeInsets = UIEdgeInsetsMake(0, 20, 0, 0);
    [button.layer setCornerRadius:item.cornerRadius];
    [button.layer setBorderColor:item.borderColor.CGColor];
    [button.layer setBorderWidth:item.borderWidth];
    [button addTarget:self action:@selector(myActionButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    return button;
}

- (void)myActionButtonPressed:(UIButton *)sender
{
    sender.selected = !sender.selected;
}

- (NSAttributedString*) attributedStringChangeColorAlpha:(NSAttributedString *)string
{
    NSMutableAttributedString* attributedString = [string mutableCopy];
    {
        [attributedString beginEditing];
        [attributedString enumerateAttribute:NSForegroundColorAttributeName inRange:NSMakeRange(0, attributedString.length) options:0 usingBlock:^(id value, NSRange range, BOOL *stop) {
            UIColor* alphaColor = value;
            UIColor *final = [alphaColor colorWithAlphaComponent:0.7];
            [attributedString removeAttribute:NSForegroundColorAttributeName range:range];
            [attributedString addAttribute:NSForegroundColorAttributeName value:final range:range];
        }];        [attributedString endEditing];
    }
    return [attributedString copy];
}

@end
