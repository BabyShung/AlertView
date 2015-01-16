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
    
}
- (IBAction)presentOneButton:(id)sender {
    AlarmAlertView *al = [[AlarmAlertView alloc] initWithTitle:@"Title" message:@"Message"];
    [al addActionWithTitle:@"Cancel" style:AlertButtonCancel handler:^(AlarmAlertButtonItem *item) {
        NSLog(@"one button");
    }];
    [al show];
}

- (IBAction)presentTwoButtons:(id)sender {
    AlarmAlertView *al = [[AlarmAlertView alloc] initWithTitle:@"Are you sure you want to log out?" message:nil];
    //al.theme.titleFontSize = 15;//you can modify the theme (style of the contentView)
    [al addActionWithTitle:@"Cancel" handler:^(AlarmAlertButtonItem *item) {
        NSLog(@"Cancel");
    }];
    [al addActionWithTitle:@"Log out" titleColor:[UIColor orangeColor] style:AlertButtonStyleDefault handler:nil];
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

- (IBAction)appleDefault:(id)sender {
    UIAlertView *al = [[UIAlertView alloc] initWithTitle:@"Title" message:@"Message" delegate:nil cancelButtonTitle:@"Cancel" otherButtonTitles:@"Option",@"Option",@"Option",@"Option",@"Option",@"Option",@"Option",@"Option",@"Option",@"Option",@"Option",@"Option",@"Option",@"Option",@"Option",@"Option",nil];
    [al show];
}
@end
