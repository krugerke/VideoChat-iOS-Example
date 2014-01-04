//
//  AppDelegate.m
//  VideoChat
//
//  Created by Yury Yaschenko on 3/26/13.
//  Copyright (c) 2013 BACKENDLESS.COM. All rights reserved.
//

#import "AppDelegate.h"
#import "ChatUserInfo.h"
#import "UsersListViewController.h"
#import "ViewController.h"

// *** YOU SHOULD SET THE FOLLOWING VALUES FROM YOUR BACKENDLESS APPLICATION ***
// *** COPY/PASTE APP ID and SECRET KET FROM BACKENDLESS CONSOLE (use the Manage > App Settings screen) ***
static NSString *APP_ID = @"";
static NSString *SECRET_KEY = @"";
static NSString *VERSION_NUM = @"v1";



@interface AppDelegate () <IResponder>
{
    NSTimer *timer;
    
    HashMap *haspMap;
    BESubscription *subscription;
    Responder *responder;
}

-(void)setUser:(NSString *)abonent message:(Message *)message;
-(void)deleteUser:(NSString *)abonent;
-(void)checkRemoveUser;
@end


@implementation AppDelegate

#pragma mark -
#pragma mark - Public Methods

-(void)setChainResponder:(id)chainResponder
{
    [responder setChained:chainResponder];
}

-(NSArray *)getUsersList
{
    return [haspMap values];
}

-(ChatUserInfo *)isInList:(NSString *)userName
{
    return [haspMap get:userName];
}

#pragma mark -
#pragma mark - Private Methods

-(void)setUser:(NSString *)abonent message:(Message *)message
{
    ChatUserInfo *user = [haspMap get:abonent];
    if (user) {
        
        user.status = [message.headers objectForKey:STATUS_KEY];
        [user ping];
    }
    else {
        
        user = [ChatUserInfo chatUser:abonent status:[message.headers objectForKey:STATUS_KEY]];
        if ([haspMap add:abonent withObject:user]) {
            NSLog(@"AppDelegate -> setUser: %@", user);
            if (self.usersListVC)
                [self.usersListVC performSelectorOnMainThread:@selector(renewUserList) withObject:nil waitUntilDone:NO];
        }
    }
    
    if (self.chatVC)
        [self.chatVC performSelectorOnMainThread:@selector(cancelChat:) withObject:abonent waitUntilDone:NO];
}

-(void)deleteUser:(NSString *)abonent
{
    if (!abonent)
        return;
    
    if ([haspMap del:abonent]) {
        NSLog(@"AppDelegate -> deleteUser: %@", abonent);
        if (self.usersListVC)
            [self.usersListVC performSelectorOnMainThread:@selector(renewUserList) withObject:nil waitUntilDone:NO];
    }
}

-(void)checkRemoveUser {
    
    BOOL renew = NO;
    NSArray *users = [haspMap values];
    for (ChatUserInfo *user in users) {
        
        if ([user needRemove]) {
            renew = YES;
            if ([haspMap del:user.name]) {
                NSLog(@"AppDelegate -> DELETE: %@", user);
            }
        }
    }
    
    if (renew && self.usersListVC)
        [self.usersListVC performSelectorOnMainThread:@selector(renewUserList) withObject:nil waitUntilDone:NO];
}


#pragma mark -
#pragma mark IResponder Methods

-(id)responseHandler:(id)response {
    
    //NSLog(@"AppDelegate ->responseHandler: RESPONSE = %@ <%@>", response, response?[response class]:@"NULL");
    
    NSArray *messages = (NSArray *)response;
    for (Message *message in messages) {
        
        if (![message isKindOfClass:[Message class]] || [message.data isEqualToString:self.userName])
            continue;
        
        NSString *action = [message.headers objectForKey:ACTION_KEY];
        NSString *abonent = (NSString *)message.data;
        
        NSLog(@"AppDelegate -> responseHandler: ACTION = %@, abonent '%@', userName = '%@'", action, abonent, self.userName);
        
        if (!action || !abonent)
            continue;
        
        if ([action isEqualToString:@"ping"])
            [self setUser:abonent message:message];
        
        if ([action isEqualToString:@"bye"])
            [self deleteUser:abonent];
    }
    
    return response;
}

-(void)errorHandler:(Fault *)fault {
    
    NSLog(@"AppDelegate -> errorHandler: FAULT = %@ <%@>", fault.message, fault.detail);
}

#pragma mark -

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    //[DebLog setIsActive:YES];
    
    [backendless initApp:APP_ID secret:SECRET_KEY version:VERSION_NUM];
    
    echoCancellationOn;
    
    self.usersListVC = nil;
    self.chatVC = nil;
    
    haspMap = [HashMap new];
    timer = [NSTimer scheduledTimerWithTimeInterval:PING_INTERVAL target:self selector:@selector(checkRemoveUser) userInfo:nil repeats:YES];
    
    responder = [[Responder alloc] initWithResponder:self
                                  selResponseHandler:@selector(responseHandler:)
                                     selErrorHandler:@selector(errorHandler:)];
    @try {
        subscription = [backendless.messagingService subscribe:CONTROL_STREAM_MESSAGING subscriptionResponder:responder];
    }
    @catch (Fault *fault)
    {
        NSLog(@"AppDelegate -> subscribe: FAULT = %@ <%@>", fault.message, fault.detail);
    }
    
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
}

@end
