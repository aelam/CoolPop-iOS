//
//  ViewController.m
//  CoolPop
//
//  Created by ryan on 13-1-29.
//  Copyright (c) 2013年 ryan. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

@synthesize titleLabel;

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
	// Do any additional setup after loading the view, typically from a nib.
    UIButton *pushButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    pushButton.frame = CGRectMake(50, 150, 200, 50);
    [pushButton setTitle:@"PUSH" forState:UIControlStateNormal];
//    [pushButton setImage:[UIImage imageNamed:@"Contact_Buddy_lg.png"] forState:UIControlStateNormal];
    [self.view addSubview:pushButton];
    [pushButton addTarget:self action:@selector(push:) forControlEvents:UIControlEventTouchUpInside];

    UIButton *popButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    popButton.frame = CGRectMake(50, 280, 200, 50);
//    [popButton setImage:[UIImage imageNamed:@"Contact_Buddy_lg.png"] forState:UIControlStateNormal];
    [popButton setTitle:@"POP" forState:UIControlStateNormal];
    [self.view addSubview:popButton];
    [popButton addTarget:self action:@selector(pop:) forControlEvents:UIControlEventTouchUpInside];

    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.titleLabel.text = [NSString stringWithFormat:@"count: %d",self.navigationController.viewControllers.count];
    self.title = [NSString stringWithFormat:@"Level: %d",self.navigationController.viewControllers.count];
    
    
}

- (BOOL)isSupportSwipePop {
    return YES;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



- (IBAction)push:(id)sender {
    ViewController *vc = [[ViewController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
    [vc release];
}


- (IBAction)pop:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

@end
