//
//  CBBlackViewController.h
//  BlockCalls
//
//  Created by ly on 1/20/13.
//  Copyright (c) 2013 Lei Yan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CBPeoplePickerNavigationController.h"

@interface CBBlackViewController : UIViewController <UITableViewDataSource,
                                                     UITableViewDelegate,
                                                     CBPeoplePickerNavigationControllerDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end
