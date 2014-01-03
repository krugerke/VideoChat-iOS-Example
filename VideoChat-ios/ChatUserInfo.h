//
//  UserOnline.h
//  backendlessDemos
//
//  Created by Yury Yaschenko on 3/27/13.
//  Copyright (c) 2013 BACKENDLESS.COM. All rights reserved.
//

#import "BackendlessEntity.h"

#define PING_INTERVAL 100.0
#define PING_RESERVE 5
#define NEED_REMOVE_USER @"NEED_BE_REMOVED"

@interface ChatUserInfo : NSObject
@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) NSString *status;
@property (nonatomic) NSUInteger index;

+(id)chatUser:(NSString*)name status:(NSString*)status;
-(BOOL)needRemove;
-(void)ping;
@end
