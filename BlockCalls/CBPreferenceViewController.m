//
//  CBPreferenceViewController.m
//  BlockCalls
//
//  Created by ly on 1/20/13.
//  Copyright (c) 2013 Lei Yan. All rights reserved.
//

#import "CBPreferenceViewController.h"
#import "CBModeViewController.h"
#import "CBReturnStatusViewController.h"
#import "Header.h"

@interface CBPreferenceViewController ()

@property (strong, nonatomic) NSArray *descriptionArray;

@end

@implementation CBPreferenceViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        [self.tabBarItem setTitle:@"Preference"];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    NSString *listPath = [[NSBundle mainBundle] pathForResource:@"List" ofType:@"plist"];
    NSArray *tempListArray = [[NSArray alloc] initWithContentsOfFile:listPath];
    
    // 获取key的描述性文本
    @autoreleasepool {
        NSMutableArray *tempKeyArray = [[NSMutableArray alloc] initWithCapacity:4];
        for (NSInteger i = 0; i < [tempListArray count]; i++) {
            NSDictionary *itemDict = tempListArray[i];
            [tempKeyArray addObject:[itemDict valueForKey:kDescription]];
        }
        self.descriptionArray = [[NSArray alloc] initWithArray:tempKeyArray];
        tempKeyArray = nil;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.descriptionArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                       reuseIdentifier:CellIdentifier];
    }
    [self configureCell:cell atIndexPath:indexPath];
    
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger row = indexPath.row;
    
    if (row==0 || row == 1)     /* 前两行默认不高亮选中 */
        return NO;
    
    return YES;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger row = indexPath.row;
    if (row == 2) {     // 工作模式
        CBModeViewController *modeViewController = [[CBModeViewController alloc] initWithNibName:@"CBModeViewController" bundle:nil];
        [self presentModalViewController:modeViewController animated:YES];
    }
    
    else if (row == 3) {     // 拦截返回状态
        CBReturnStatusViewController *returnStatusViewController = [[CBReturnStatusViewController alloc] initWithNibName:@"CBReturnStatusViewController" bundle:nil];
        [self presentModalViewController:returnStatusViewController animated:YES];
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    NSInteger row = indexPath.row;
    
    cell.textLabel.text = [self.descriptionArray objectAtIndex:row];
    
    if (row==0 || row==1) {
        BOOL onOrOff;
        UISwitch *s = [[UISwitch alloc] initWithFrame:CGRectMake(240, 8, 60, 44)];
        s.tag = row;
        [s addTarget:self action:@selector(saveState:) forControlEvents:UIControlEventValueChanged];
        NSString *key = [self.descriptionArray objectAtIndex:row];
        // switch控件状态
        if (row == 0)
            onOrOff = [[NSUserDefaults standardUserDefaults] boolForKey:kOpen];
        else
            onOrOff = [[NSUserDefaults standardUserDefaults] boolForKey:kCallVibrate];
        
        [s setOn:onOrOff];
        [cell addSubview:s];
        s = nil;
        key = nil;
    }
}

- (void)saveState:(UISwitch *)sender
{
    switch (sender.tag) {
        case 0:
            [[NSUserDefaults standardUserDefaults] setBool:sender.on forKey:kOpen];
            break;
        case 1:
            [[NSUserDefaults standardUserDefaults] setBool:sender.on forKey:kCallVibrate];
            break;
    }
}

@end
