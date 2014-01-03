//
//  UserOnline.m
//  backendlessDemos
//
//  Created by Yury Yaschenko on 3/27/13.
//  Copyright (c) 2013 BACKENDLESS.COM. All rights reserved.
//

#import "ChatUserInfo.h"

@interface ChatUserInfo()
{
    int count;
}
@end

@implementation ChatUserInfo

-(id)init
{
    self = [super init];
    
    if (self)
    {
        self.name = nil;
        self.status = nil;
        self.index = 0;

        count = 0;
    }
    
    return self;
}

+(id)chatUser:(NSString *)name status:(NSString *)status
{
    ChatUserInfo *user = [ChatUserInfo new];
    user.name = name;
    user.status = status;
    
    return user;
}

-(void)dealloc
{
    NSLog(@"DEALLOC ChatUserInfo");
}

#pragma mark -
#pragma mark - Public Methods

-(BOOL)needRemove {
    BOOL result = !count;
    count = 0;
    return result;
}

-(void)ping
{
    count++;
   
    NSLog(@"ChatUserInfo -> ping: '%@', count = %d", self.name, count);
}

-(NSString *)description {
    return [NSString stringWithFormat:@"<%@>: name = %@, status = %@", [self class], self.name, self.status];
}

@end
