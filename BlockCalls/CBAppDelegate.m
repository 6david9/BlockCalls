//
//  CBAppDelegate.m
//  BlockCalls
//
//  Created by ly on 1/12/13.
//  Copyright (c) 2013 Lei Yan. All rights reserved.
//

#import "CBAppDelegate.h"

#import "CBViewController.h"
#import "Header.h"
#import <AudioToolbox/AudioToolbox.h>

@implementation CBAppDelegate

static void callBack(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef userInfo)
{
    if ([(NSString *)name isEqualToString:@"kCTCallStatusChangeNotification"]) {
        int callstate = [[(NSDictionary *)userInfo objectForKey:@"kCTCallStatus"] intValue];
        
        if (callstate == 1) {       // 电话接通
            AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);   // 震动
        }
        
        CTCall *call = (CTCall *)[(NSDictionary *)userInfo objectForKey:@"kCTCall"];
        NSString *caller = CTCallCopyAddress(NULL, call); // caller 便是来电号码
        //        CTCallDisconnect(call); //　挂断电话
        //        CTCallAnswer(call); // 接电话
        //        CTCallGetStatus(CTCall *call); // 获得电话状态　拨出电话时为３，有呼入电话时为４，挂断电话时为５
        //        CTCallGetGetRowIDOfLastInsert(void); // 获得最近一条电话记录在电话记录数据库（call_history.db)中的位置(ROWID)
        
        if ([caller isEqualToString:@"15910379497"]) {
            CTCallDisconnect(call);
        }
        NSLog(@"%@", caller);
    }
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    self.viewController = [[CBViewController alloc] initWithNibName:@"CBViewController" bundle:nil];
    self.window.rootViewController = self.viewController;
    [self.window makeKeyAndVisible];
    
    CTTelephonyCenterAddObserver(CTTelephonyCenterGetDefault(), NULL, &callBack, CFSTR("kCTCallStatusChangeNotification"), NULL, CFNotificationSuspensionBehaviorHold);
    
    return YES;
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
