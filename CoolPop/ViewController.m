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
@synthesize tableView = _tableView;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.canCancelContentTouches = YES;
    [self.view addSubview:_tableView];
    
//    UIView *aView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 460)];
//    aView.backgroundColor = [UIColor cyanColor];
//    [self.view addSubview:aView];
    
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

    
    UIButton *push5Button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    push5Button.frame = CGRectMake(50, 350, 200, 50);
    [push5Button setTitle:@"PUSH 5" forState:UIControlStateNormal];
    //    [pushButton setImage:[UIImage imageNamed:@"Contact_Buddy_lg.png"] forState:UIControlStateNormal];
    [self.view addSubview:push5Button];
    [push5Button addTarget:self action:@selector(push5:) forControlEvents:UIControlEventTouchUpInside];

}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.titleLabel.text = [NSString stringWithFormat:@"count: %d",self.navigationController.viewControllers.count];
    self.title = [NSString stringWithFormat:@"Level: %d",self.navigationController.viewControllers.count];
    
    
}

- (BOOL)isSupportSwipePop {
    return YES;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 100;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *identifier = @"1";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier] autorelease];
    }
    
    cell.textLabel.text = [NSString stringWithFormat:@"%d",indexPath.row];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self push:nil];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)push5:(id)sender {
    for(int i = 0 ; i < 5; i ++) {
        ViewController *vc = [[ViewController alloc] init];
        [self.navigationController pushViewController:vc animated:i==4?YES:NO];
        [vc release];
    }
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
