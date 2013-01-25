//
//  CBWhiteViewController.m
//  BlockCalls
//
//  Created by ly on 1/20/13.
//  Copyright (c) 2013 Lei Yan. All rights reserved.
//

#import "CBWhiteViewController.h"

#import "FMDatabaseQueue.h"
#import "FMDatabase.h"
#import "CBRecord.h"
#import "Header.h"

@interface CBWhiteViewController ()

@property (strong, nonatomic) NSMutableArray *list;

@end

@implementation CBWhiteViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        [self.tabBarItem setTitle:@"Whitelist"];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.list = [[NSMutableArray alloc] init];

    [self performSelectorOnMainThread:@selector(updateDataSource) withObject:nil waitUntilDone:NO];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.list count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1
                                       reuseIdentifier:CellIdentifier];
    }
    
    [self configureCell:cell atIndexPath:indexPath];
    
    return cell;
}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    return nil;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // 先删除数据库中的数据
        NSString *sqlStr = @"delete from whitelist where number=?";
        FMDatabaseQueue *queue = [FMDatabaseQueue databaseQueueWithPath:pathInDocumentDirectory(kDatabaseName)];
        
        CBRecord *person = [self.list objectAtIndex:indexPath.row];
        [queue inDatabase:^(FMDatabase *db){
            [db executeUpdate:sqlStr, person.number];
        }];
        [queue close];
        
        // 再删除list中的数据源
        [self.list removeObjectAtIndex:indexPath.row];
        
        // 在table中删除
        [self.tableView beginUpdates];
        [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
        [self.tableView endUpdates];
    }
}

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    NSInteger row = indexPath.row;
    CBRecord *record = self.list[row];
    
    cell.textLabel.text = record.number;
    cell.detailTextLabel.text = record.name;
}

#pragma mark - Update table data source
- (void)updateDataSource
{
    FMDatabaseQueue *queue = [FMDatabaseQueue databaseQueueWithPath:pathInDocumentDirectory(kDatabaseName)];
    [queue inDatabase:^(FMDatabase *db){
        // 查询数据
        NSString *sqlStr = @"select name, number from whitelist";
        FMResultSet *resultSet = [db executeQuery:sqlStr];
        
        // 保存数据
        NSMutableArray *blacklist = [[NSMutableArray alloc] init];
        while ([resultSet next]) {
            CBRecord *person = [[CBRecord alloc] init];
            person.name = [resultSet stringForColumn:@"name"];
            person.number = [resultSet stringForColumn:@"number"];
            person.mode = kBlacklist;
            [blacklist addObject:person];
        }
        // 在主线程中更新数据
        if ([blacklist count] > 0)
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.list removeAllObjects];
                [self.list addObjectsFromArray:blacklist];
                [self.tableView reloadData];
                [NSKeyedArchiver archiveRootObject:self.list toFile:pathInDocumentDirectory(kWhitelistArchive)];
            });
        
        blacklist = nil;
    }];
    [queue close];
}

#pragma mark - Bar button item selector
- (IBAction)addRecord:(id)sender
{
    CBPeoplePickerNavigationController *controller = [[CBPeoplePickerNavigationController alloc] init];
    controller.delegate = self;
    [self presentModalViewController:controller animated:YES];
    controller = nil;
}

#pragma mark People picker delegate
- (void)peoplePickerNavigationController:(CBPeoplePickerNavigationController *)controller
                    didSelectPhoneNumber:(NSString *)number
                                withName:(NSString *)name
{
    NSLog(@"%@, %@", number, name);
    
    CBRecord *person = [[CBRecord alloc] init];
    person.name = name;
    person.number = number;
    person.mode = kWhitelist;
    [person savaToDatabase];
    
    [controller dismissModalViewControllerAnimated:YES];
    
    [self performSelectorOnMainThread:@selector(updateDataSource) withObject:nil waitUntilDone:NO];
}

@end
