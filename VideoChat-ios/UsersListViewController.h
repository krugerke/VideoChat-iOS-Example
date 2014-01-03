//
//  UsersListViewController.h
//  backendlessDemos
//
//  Created by Yury Yaschenko on 3/27/13.
//  Copyright (c) 2013 BACKENDLESS.COM. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UsersListViewController : UIViewController<UITableViewDataSource, UITableViewDelegate>
@property (strong, nonatomic) NSString *streamNamePublisher;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

- (void)removeRowWithIndexPath:(NSArray *)indexPath;
- (void)addRowWithIndexPath:(NSArray *)indexPath;
- (void)renewUserList;
@end
