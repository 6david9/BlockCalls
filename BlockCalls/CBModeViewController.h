//
//  CBModeViewController.h
//  BlockCalls
//
//  Created by ly on 1/21/13.
//  Copyright (c) 2013 Lei Yan. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CBModeViewController : UIViewController
 <UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end
