//
//  ViewController.h
//  CoolPop
//
//  Created by ryan on 13-1-29.
//  Copyright (c) 2013年 ryan. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController<UITableViewDataSource,UITableViewDelegate>

@property (nonatomic,retain) IBOutlet UILabel *titleLabel;
@property (nonatomic,retain) IBOutlet UITableView *tableView;

- (IBAction)push:(id)sender;
- (IBAction)pop:(id)sender;

@end
