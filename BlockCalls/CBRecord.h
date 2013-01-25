//
//  CBRecord.h
//  BlockCalls
//
//  Created by ly on 1/22/13.
//  Copyright (c) 2013 Lei Yan. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CBRecord : NSObject <NSCoding>

@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) NSString *number;
@property (assign, nonatomic) NSInteger mode;

- (void)savaToDatabase;

@end
