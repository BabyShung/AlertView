//
//  ViewController.m
//  AlarmAlertController
//
//  Created by Hao Zheng on 1/14/15.
//  Copyright (c) 2015 Hao Zheng. All rights reserved.
//

#import "ViewController.h"
#import "AlarmAlertView.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    AlarmAlertButtonItem *item = nil;
    item.buttonStyle == 2?NSLog(@"a"):NSLog(@"b");
    
}
- (IBAction)presentOneButton:(id)sender {
    AlarmAlertView *al = [[AlarmAlertView alloc] initWithTitle:@"Title" message:@"Message"];
    [al addActionWithTitle:@"CancelCancelCancelncel" style:AlertButtonCancel handler:^(AlarmAlertButtonItem *item) {
        NSLog(@"one button");
    }];
    [al show];
    [al show];
    [al show];
    [al show];
    
    
    NSLog(@"######## %d",(int)al.buttonItems.count);
    NSLog(@"######## %@",al.buttonItems[0]);
    AlarmAlertButtonItem *item = (AlarmAlertButtonItem *)al.buttonItems[0];
    item.backgroundColor = [UIColor orangeColor];
    NSLog(@"######## %@",item.buttonTitle);
}

- (IBAction)presentTwoButtons:(id)sender {
    AlarmAlertView *al = [[AlarmAlertView alloc] initWithTitle:@"Are you sure you want to log out?" message:nil];
    //al.theme.titleFontSize = 15;//you can modify the theme (style of the contentView)
    [al addActionWithTitle:@"Cancel" style:AlertButtonCancel handler:^(AlarmAlertButtonItem *item) {
        NSLog(@"Cancel");
    }];
    [al addActionWithTitle:@"Passcode Settings" titleColor:[UIColor orangeColor] style:AlertButtonStyleDefault handler:nil];
    [al show];
}

- (IBAction)presentTwoButtons2:(id)sender {
    AlarmAlertView *al = [[AlarmAlertView alloc] initWithTitle:@"Log out" message:@"Are you sure?"];
    [al addActionWithTitle:@"Cancel" handler:^(AlarmAlertButtonItem *item) {
        NSLog(@"Cancel");
    }];
    [al addActionWithTitle:@"Log out" titleColor:[UIColor orangeColor] style:AlertButtonStyleDefault handler:nil];
    [al show];
}

- (IBAction)presentTwoButtons3:(id)sender {
    AlarmAlertView *al = [[AlarmAlertView alloc] initWithTitle:@"Setup Touch ID"
                                                       message:@"This app now supports Apple's Touch ID feature for quick and secure access to the app using your device's fingerprint reader. Would you like to set it up?"];
    //al.theme.ifTwoBtnsShouldInOneLine = NO;
    //al.theme.themeColor = [UIColor orangeColor];
    //al.theme.titleFontSize = 15;//you can modify the theme (style of the contentView)
    [al addActionWithTitle:@"Passcode Settings" handler:^(AlarmAlertButtonItem *item) {
        NSLog(@"Cancel");
    }];
    [al addActionWithTitle:@"Not now"];
    [al show];
}

- (IBAction)presentActionSheetOneButton:(id)sender {
    AlarmAlertView *al = [[AlarmAlertView alloc] initWithTitle:@"Title" message:@"Message" preferredStyle:AAActionSheet];
    [al addActionWithTitle:@"Option1" handler:^(AlarmAlertButtonItem *item) {
        NSLog(@"Option1");
    }];
    [al show];
}

- (IBAction)presentMultiButtons:(id)sender {
    AlarmAlertView *al = [[AlarmAlertView alloc] initWithTitle:@"Title" message:@"Message"];
    [al addActionWithTitle:@"Option1" handler:^(AlarmAlertButtonItem *item) {
        NSLog(@"Option1");
    }];
    [al addActionWithTitle:@"Option2"];
    [al addActionWithTitle:@"Option3"];
    [al addActionWithTitle:@"Option4"];
    [al addActionWithTitle:@"Option5"];
    [al addActionWithTitle:@"Cancel" handler:^(AlarmAlertButtonItem *item) {
        NSLog(@"Cancel");
    }];
    [al show];
}

- (IBAction)presentActionSheet:(id)sender {
    AlarmAlertView *al = [[AlarmAlertView alloc] initWithTitle:@"Title" message:@"Message" preferredStyle:AAActionSheet];
    al.theme.themeColor = [UIColor orangeColor];
    [al addActionWithTitle:@"Option1" handler:^(AlarmAlertButtonItem *item) {
        NSLog(@"Option1");
    }];
    [al addActionWithTitle:@"Option2"];
    //    [al addActionWithTitle:@"Option3"];
    //    [al addActionWithTitle:@"Cancel" handler:^(AlarmAlertButtonItem *item) {
    //        NSLog(@"Cancel");
    //    }];
    [al show];
}

- (IBAction)addCustomView:(id)sender {
    UIView *cView = [[UIView alloc] init];
    cView.translatesAutoresizingMaskIntoConstraints = NO;
    cView.backgroundColor = [UIColor orangeColor];
    [cView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[cView(300)]" options:kNilOptions metrics:nil views:NSDictionaryOfVariableBindings(cView)]];
    
    AlarmAlertView *al = [[AlarmAlertView alloc] initWithTitle:@"Custom" message:@"View" customView:cView preferredStyle:AACentered subViewOfView:nil];
    al.theme.themeColor = [UIColor blueColor];
    [al addActionWithTitle:@"Cancel" handler:^(AlarmAlertButtonItem *item) {
        NSLog(@"Option1");
    }];
    [al addActionWithTitle:@"Send"];
    [al show];
}

- (IBAction)customAction:(id)sender
{
//    AlarmAlertView *al = [[AlarmAlertView alloc] initWithTitle:@"Title" message:@"Message" preferredStyle:AAActionSheet];
//    al.theme.themeColor = [UIColor purpleColor];
//    
//    AlarmAlertButtonItem *myItem = [[AlarmAlertButtonItem alloc] initWithTitle:@"CustomBtn" andButtonTitleColor:[UIColor greenColor] andStyle:AlertButtonCancel];
//    
//    [al addAction:myItem andTarget:self andSelector:@selector(myActionButtonPressed:)];
//    [al show];
}


- (IBAction)appleDefault:(id)sender {
    UIAlertView *al = [[UIAlertView alloc] initWithTitle:@"Title" message:@"Message" delegate:nil cancelButtonTitle:@"Cancel" otherButtonTitles:@"OptionCancelCancelCancelCancelCancelCancelCancelCancelCancelCancelCancelCancelCancelCancel",@"Option",@"Option",@"Option",@"Option",@"Option",@"Option",@"Option",@"Option",nil];
    [al show];
}
@end
