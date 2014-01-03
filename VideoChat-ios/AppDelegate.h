//
//  AppDelegate.h
//  VideoChat
//
//  Created by Yury Yaschenko on 3/26/13.
//  Copyright (c) 2013 BACKENDLESS.COM. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Backendless.h"


#define CONTROL_STREAM_MESSAGING @"ControlStreamMessaging"
#define ACTION_KEY @"action"
#define STATUS_KEY @"status"

@class UsersListViewController, ViewController, ChatUserInfo;

@interface AppDelegate : UIResponder <UIApplicationDelegate>
@property (nonatomic, strong) NSString *userName;
@property (strong, nonatomic) UIWindow *window;
@property (weak, nonatomic) UsersListViewController *usersListVC;
@property (weak, nonatomic) ViewController *chatVC;

- (void)setChainResponder:(id)chainResponder;
- (NSArray *)getUsersList;
- (ChatUserInfo *)isInList:(NSString *)userName;
@end
