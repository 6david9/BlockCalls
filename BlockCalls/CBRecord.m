//
//  CBRecord.m
//  BlockCalls
//
//  Created by ly on 1/22/13.
//  Copyright (c) 2013 Lei Yan. All rights reserved.
//

#import "CBRecord.h"
#import "FMDatabaseQueue.h"
#import "FMDatabase.h"
#import "Header.h"

@implementation CBRecord

#pragma mark - NSCoding
- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.name forKey:@"name"];
    [aCoder encodeObject:self.number forKey:@"number"];
    [aCoder encodeInteger:self.mode forKey:@"mode"];
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    
    if (self != nil) {
        self.name = [aDecoder decodeObjectForKey:@"@name"];
        self.number = [aDecoder decodeObjectForKey:@"number"];
        self.mode = [aDecoder decodeIntegerForKey:@"mode"];
    }
    
    return self;
}

#pragma mark - Save to database
- (void)savaToDatabase
{
    FMDatabaseQueue *queue = [FMDatabaseQueue databaseQueueWithPath:pathInDocumentDirectory(kDatabaseName)];
    [queue inDatabase:^(FMDatabase *db){
        NSString *sqlStr;
        if (self.mode == kBlacklist) {
            sqlStr = [NSString stringWithFormat:@"replace into blacklist(name, number) values('%@', '%@')",
                      self.name, self.number];
        }
        else if (self.mode == kWhitelist) {
            sqlStr = [NSString stringWithFormat:@"replace into whitelist(name, number) values('%@', '%@')",
                      self.name, self.number];
        }

        if ([db executeUpdate:sqlStr]) {
            NSLog(@"保存成功");
        } else {
            NSLog(@"保存失败");
        }
    }];
    [queue close];
}

@end
