//
//  ViewController.h
//  CoolPop
//
//  Created by ryan on 13-1-29.
//  Copyright (c) 2013年 ryan. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController

@property (nonatomic,retain) IBOutlet UILabel *titleLabel;

- (IBAction)push:(id)sender;
- (IBAction)pop:(id)sender;

@end
