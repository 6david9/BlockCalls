//
//  CBModeViewController.m
//  BlockCalls
//
//  Created by ly on 1/21/13.
//  Copyright (c) 2013 Lei Yan. All rights reserved.
//

#import "CBModeViewController.h"
#import "Header.h"

@interface CBModeViewController ()

@property (strong, nonatomic) NSArray *descArray;
@property (strong, nonatomic) NSArray *keyArray;
@property (strong, nonatomic) NSIndexPath *lastCheckedIndexPath;

@end

@implementation CBModeViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    @autoreleasepool {
        NSString *modesPath = [[NSBundle mainBundle] pathForResource:@"Modes" ofType:@"plist"];
        NSArray *tempModesArray = [[NSArray alloc] initWithContentsOfFile:modesPath];
        
        NSMutableArray *tempKeyArray = [[NSMutableArray alloc] initWithCapacity:5];
        NSMutableArray *tempDescArray = [[NSMutableArray alloc] initWithCapacity:5];
        for (NSInteger i=0; i < [tempModesArray count]; i++) {
            NSDictionary *itemDict = tempModesArray[i];
            
            [tempKeyArray addObject:[itemDict valueForKey:kKey]];
            [tempDescArray addObject:[itemDict valueForKey:kDescription]];
        }
        
        self.keyArray = tempKeyArray;
        self.descArray = tempDescArray;
        tempKeyArray = nil;
        tempDescArray = nil;
        
        NSInteger row = [[NSUserDefaults standardUserDefaults] integerForKey:kModes];
        self.lastCheckedIndexPath = [NSIndexPath indexPathForRow:row inSection:0];
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
    return [self.descArray count];
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
    
    switch (row) {
        case 0:
            [self blockAll];
            break;
        case 1:
            [self blockNoOne];
            break;
        case 2:
            [self blockBlackList];
            break;
        case 3:
            [self allowWhiteList];
            break;
        case 4:
            [self blockStranger];
            break;
    }
    
    if ( ![indexPath isEqual:self.lastCheckedIndexPath] ) {     // 当前选中项与上次不同
        // 选中当前项
        UITableViewCell *newCell = [tableView cellForRowAtIndexPath:indexPath];
        newCell.accessoryType = UITableViewCellAccessoryCheckmark;
        
        // 取消选择上次选择项
        UITableViewCell *oldCell = [tableView cellForRowAtIndexPath:self.lastCheckedIndexPath];
        oldCell.accessoryType = UITableViewCellAccessoryNone;
        
        // 更新最后一次选中cell的indexPath
        self.lastCheckedIndexPath = nil;
        self.lastCheckedIndexPath = indexPath;
        
        // 保存配置
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        [userDefaults setInteger:row forKey:kModes];
        [userDefaults synchronize];
    }
    
    return NO;
}

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    NSInteger row = indexPath.row;
    cell.textLabel.text = self.descArray[row];
    
    if ( row == self.lastCheckedIndexPath.row)
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
}


#pragma mark - Block mode
- (void)blockAll
{
    print_function_name();
}

- (void)blockNoOne
{
    print_function_name();
}

- (void)blockBlackList
{
    print_function_name();
}

- (void)allowWhiteList
{
    print_function_name();
}

- (void)blockStranger
{
    print_function_name();
}

#pragma mark - Item action
- (IBAction)close:(id)sender
{
    [self dismissModalViewControllerAnimated:YES];
}

@end
