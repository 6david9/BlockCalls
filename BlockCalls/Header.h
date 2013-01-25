//
//  Header.h
//  BlockCalls
//
//  Created by ly on 1/12/13.
//  Copyright (c) 2013 Lei Yan. All rights reserved.
//

#ifndef BlockCalls_Header_h
#define BlockCalls_Header_h

#import <CoreTelephony/CTCall.h>

CFNotificationCenterRef CTTelephonyCenterGetDefault(void); // 获得 TelephonyCenter (电话消息中心) 的引用
void CTTelephonyCenterAddObserver(CFNotificationCenterRef center, const void *observer, CFNotificationCallback callBack, CFStringRef name, const void *object, CFNotificationSuspensionBehavior suspensionBehavior);
void CTTelephonyCenterRemoveObserver(CFNotificationCenterRef center, const void *observer, CFStringRef name, const void *object);
NSString *CTCallCopyAddress(void *, CTCall *call); //获得来电号码
void CTCallDisconnect(CTCall *call); // 挂断电话
void CTCallAnswer(CTCall *call); // 接电话
void CTCallAddressBlocked(CTCall *call);
int CTCallGetStatus(CTCall *call); // 获得电话状态　拨出电话时为３，有呼入电话时为４，挂断电话时为５
int CTCallGetGetRowIDOfLastInsert(void); // 获得最近一条电话记录在电话记录数据库中的位置

extern void CTCallDial(NSString * number);  // 拨打电话

// 常用键名
#define kOpen           @"open"
#define kCallVibrate    @"callVibrate"
#define kModes          @"modes"
#define kReturnStatus   @"returnStatus"

#define kDescription    @"description"
#define kKey            @"key"

#define kDatabaseName       @"Storage.db"
#define kBlacklistArchive   @"blacklistArchive"
#define kWhitelistArchive   @"whitelistArchive"

// 工作模式
#define kAll            0
#define kNone           1
#define kBlacklist      2
#define kWhitelist      3
#define kStranger       4

// 拦截返回状态
#define kDefault        0
#define kEmpty          1
#define kOutOfService   2
#define kNotInService   3
#define kPoweredOff     4
#define kNoAnswered     5

// 自定义通知信息
#define kBlockBlacklistNotification     @"BlockBlacklistNotification"
#define kAllowWhitelistNotification     @"AllowWhitelistNotification"

extern NSString *pathInDocumentDirectory(NSString *fileName);

#endif
