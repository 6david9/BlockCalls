//
//  CBAppDelegate.m
//  BlockCalls
//
//  Created by ly on 1/12/13.
//  Copyright (c) 2013 Lei Yan. All rights reserved.
//

#import "CBAppDelegate.h"

#import "Header.h"
#import <AudioToolbox/AudioToolbox.h>
#import "CBBlackViewController.h"
#import "CBWhiteViewController.h"
#import "CBPreferenceViewController.h"
#import "FMDatabase.h"
#import "FMDatabaseQueue.h"
#import "FMResultSet.h"
#import "CBRecord.h"

@implementation CBAppDelegate

void callBack(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef userInfo)
{
    // 是否开启?
    BOOL open = [[NSUserDefaults standardUserDefaults] boolForKey:kOpen];
    if (!open)
        return;
    
    BOOL callVibrate = [[NSUserDefaults standardUserDefaults] boolForKey:kCallVibrate];
    if ([(__bridge NSString *)name isEqualToString:@"kCTCallStatusChangeNotification"]) {
        int callstate = [[(__bridge NSDictionary *)userInfo objectForKey:@"kCTCallStatus"] intValue];
        
        // 电话接通
        if (callstate == 1 && callVibrate)
        {       
            AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);   // 震动
        }
        
        // 有电话呼入时
        else if( callstate == 4 )
        {           
            CTCall *call = (CTCall *)[(__bridge NSDictionary *)userInfo objectForKey:@"kCTCall"];
            
            // 来电号码
            NSString *number = CTCallCopyAddress(NULL, call);
            
            /**********************************************
             *                    拦截模式                 *
             **********************************************/
            NSInteger blockMode = [[NSUserDefaults standardUserDefaults] integerForKey:kModes];
            
            // 全部拦截
            if (blockMode == kAll)
            {
                CTCallDisconnect(call);
            }
            
            // 不拦截
            else if (blockMode == kNone)
            {
                // do nothing
            }
            
            // 黑名单
            else if (blockMode == kBlacklist)      
            {
                NSArray *array = [NSKeyedUnarchiver unarchiveObjectWithFile:pathInDocumentDirectory(kBlacklistArchive)];
                CBRecord *person;
                for ( person in array )
                    if ([person.number isEqualToString:number])
                        CTCallDisconnect(call);
            }
            
            // 白名单
            else if (blockMode == kWhitelist)      
            {
                BOOL found = NO;
                CBRecord *person;
                NSArray *array = [NSKeyedUnarchiver unarchiveObjectWithFile:pathInDocumentDirectory(kWhitelistArchive)];
                
                for ( person in array )
                    if ([person.number isEqualToString:number]) {
                        found = YES;
                        break;
                    }
                
                if (!found) {
                    CTCallDisconnect(call);
                }
                
            }
            
            // 拦截陌生人
            else if ( blockMode == kStranger)         
            {
                // not implement
            }
        }
    }
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
   
    // 创建 tab bar controller
    self.viewController = [[UITabBarController alloc] init];
    CBBlackViewController *blackViewController =
        [[CBBlackViewController alloc] initWithNibName:@"CBBlackViewController" bundle:nil];
    CBWhiteViewController *whiteViewController =
        [[CBWhiteViewController alloc] initWithNibName:@"CBWhiteViewController" bundle:nil];
    CBPreferenceViewController *preferenceViewController =
        [[CBPreferenceViewController alloc] initWithNibName:@"CBPreferenceViewController" bundle:nil];
    [self.viewController setViewControllers:@[blackViewController, whiteViewController, preferenceViewController]];
    
    // 设置 root view controller
    self.window.rootViewController = self.viewController;
    [self.window makeKeyAndVisible];
    
    // 添加电话事件观察者
    CTTelephonyCenterAddObserver(CTTelephonyCenterGetDefault(), NULL, &callBack, CFSTR("kCTCallStatusChangeNotification"), NULL, CFNotificationSuspensionBehaviorHold);
    
    // 创建数据库和默认配置(如果需要)
    [self performSelectorOnMainThread:@selector(createTables) withObject:nil waitUntilDone:NO];
    [self preparePreference];
    
    return YES;
}

- (void)preparePreference
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    if ([userDefaults stringForKey:kReturnStatus] == nil) {         // 第一次打开程序
        NSDictionary *defaultPref = @{ kOpen:@(YES),                // 是否开启拦截功能
                                       kCallVibrate:@(YES),         // 是否开启接通震动
                                       kModes:@kNone,                 // 拦截模式
                                       kReturnStatus:@kDefault};     // 拦截返回状态
        
        // 注册默认值
        [userDefaults registerDefaults:defaultPref];
        
        // 保存默认值到磁盘
        [userDefaults synchronize];
    }
}

- (void)createTables
{
    NSString *blacklistSql = @"create table if not exists blacklist (id integer primary key autoincrement, name nvarchar(30), number varchar(20) unique)";
    NSString *whitelistSql = @"create table if not exists whitelist (id integer primary key autoincrement, name nvarchar(30), number varchar(20) unique)";
    NSString *databasePath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:kDatabaseName];
    FMDatabase *db = [FMDatabase databaseWithPath:databasePath];
    if ([db open]) {
        [db executeUpdate:blacklistSql];
        [db executeUpdate:whitelistSql];
        [db close];
    } else {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:@"发生未知错误" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alertView show];
        alertView = nil;
    }
}

NSString *pathInDocumentDirectory(NSString *fileName)
{
    // 获取沙盒中的文档目录
    NSArray *documentDirectories = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
                                                                  NSUserDomainMask, YES);
    
    // 从返回数组中得到第一个，也是唯一的一个文档目录
    NSString *documentDirectory = [documentDirectories objectAtIndex:0];
    
    // 将传入的文件名加在目录路径后面并返回
    return [documentDirectory stringByAppendingPathComponent:fileName];
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    
    CTTelephonyCenterRemoveObserver(CTTelephonyCenterGetDefault(), NULL, CFSTR("kCTCallStatusChangeNotification"), NULL);
}

@end
