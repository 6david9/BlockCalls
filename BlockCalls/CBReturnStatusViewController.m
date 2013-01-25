//
//  CBReturnStatusViewController.m
//  BlockCalls
//
//  Created by ly on 1/21/13.
//  Copyright (c) 2013 Lei Yan. All rights reserved.
//

#import "CBReturnStatusViewController.h"
#import "Header.h"

@interface CBReturnStatusViewController ()

@property (strong, nonatomic) NSArray *descArray;
@property (strong, nonatomic) NSArray *keyArray;
@property (strong, nonatomic) NSIndexPath *lastCheckedIndexPath;

@end

@implementation CBReturnStatusViewController
- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    @autoreleasepool {
        NSString *modesPath = [[NSBundle mainBundle] pathForResource:@"ReturnStatus" ofType:@"plist"];
        NSArray *tempModesArray = [[NSArray alloc] initWithContentsOfFile:modesPath];
        
        NSMutableArray *tempKeyArray = [[NSMutableArray alloc] initWithCapacity:6];
        NSMutableArray *tempDescArray = [[NSMutableArray alloc] initWithCapacity:6];
        for (NSInteger i=0; i < [tempModesArray count]; i++) {
            NSDictionary *itemDict = tempModesArray[i];
            
            [tempKeyArray addObject:[itemDict valueForKey:kKey]];
            [tempDescArray addObject:[itemDict valueForKey:kDescription]];
        }
        
        self.keyArray = tempKeyArray;
        self.descArray = tempDescArray;
        tempKeyArray = nil;
        tempDescArray = nil;
        
        NSInteger row = [[NSUserDefaults standardUserDefaults] integerForKey:kReturnStatus];
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
            [self restoreDefaultSettings];
            break;
        case 1:
            [self notExistentNumber];
            break;
        case 2:
            [self outOfService];
            break;
        case 3:
            [self notInService];
            break;
        case 4:
            [self poweredOff];
            break;
        case 5:
            [self noAnswered];
            break;
    }

    if ( ![indexPath isEqual:self.lastCheckedIndexPath] ) {     // 当前选中项与上次不同
        // 选中当前项
        UITableViewCell *newCell = [tableView cellForRowAtIndexPath:indexPath];
        newCell.accessoryType = UITableViewCellAccessoryCheckmark;
        
        // 取消选择上次选择项
        UITableViewCell *oldCell = [tableView cellForRowAtIndexPath:self.lastCheckedIndexPath];
        oldCell.accessoryType = UITableViewCellAccessoryNone;
        
        // 保存最后一次选中cell的indexPath
        self.lastCheckedIndexPath = nil;
        self.lastCheckedIndexPath = indexPath;
        
        // 保存配置文件
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        [userDefaults setInteger:row forKey:kReturnStatus];
        [userDefaults synchronize];
    }
    
    return NO;
}

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    NSInteger row = indexPath.row;
    cell.textLabel.text = self.descArray[row];
    
    if ( row == self.lastCheckedIndexPath.row )
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
}

#pragma mark - Return status
- (void)restoreDefaultSettings      /* 恢复默认设置 */
{
    /* ##002# */
    print_function_name();
    CTCallDial(@"##002#");
}

- (void)notExistentNumber           /* 是空号 */
{
    /* **67*13800013800*11# */
    print_function_name();
    CTCallDial(@"**67*13800013800*11#");
}

- (void)outOfService                /* 已失效 */
{
    /* **67*13528795183*11# */
    print_function_name();
    CTCallDial(@"**67*13528795183*11#");
}

- (void)notInService                /* 已停机 */
{
    /* **67*13999999999*11# */
    print_function_name();
    CTCallDial(@"**67*13999999999*11#");
}

- (void)poweredOff                  /* 已关机 */
{
    /* **67*13810538911*11# */
    print_function_name();
    CTCallDial(@"**67*13810538911*11#");
}

- (void)noAnswered                  /* 暂时无法接通 */
{
    /* **67*13800312309*11# */
    print_function_name();
    CTCallDial(@"**67*13800312309*11#");
}

#pragma mark - Item action
- (IBAction)close:(id)sender
{
    [self dismissModalViewControllerAnimated:YES];
}

@end
