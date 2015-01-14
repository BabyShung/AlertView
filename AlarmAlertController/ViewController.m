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

- (IBAction)click:(id)sender {
    AlarmAlertView *al = [[AlarmAlertView alloc] initWithTitle:@"Title" message:@"hello babe"];
    [al addActionWithTitle:@"Cancel" handler:^(AlarmAlertButtonItem *item) {
        NSLog(@"aaaa");
    }];
    [al addActionWithTitle:@"OK"];
    
    [al show];
}


@end
