//
//  UsersListViewController.m
//  backendlessDemos
//
//  Created by Yury Yaschenko on 3/27/13.
//  Copyright (c) 2013 BACKENDLESS.COM. All rights reserved.
//

#import "UsersListViewController.h"
#import "ViewController.h"
#import "Backendless.h"
#import "ChatUserInfo.h"
#import "AppDelegate.h"


@interface UsersListViewController () <IResponder>
{
    NSMutableArray *data;
    NSTimer *timer;
    Responder *responder;
    NSUInteger isAnimated;
    BOOL isInChat;
}

-(void)delRows:(NSArray *)rows;
-(void)addRows:(NSArray *)rows;
-(void)setAnimationNo;
-(void)ping;
-(void)publishTo:(NSString *)messageChannel;
-(void)bye;
@end


@implementation UsersListViewController
@synthesize streamNamePublisher=_streamNamePublisher, tableView=_tableView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    NSLog(@"UsersListViewController -> viewDidLoad");

    isAnimated = 0;
    data = [NSMutableArray arrayWithArray:[(AppDelegate *)[UIApplication sharedApplication].delegate getUsersList]];
    responder = [Responder responder:self selResponseHandler:@selector(responseHandler:) selErrorHandler:@selector(errorHandler:)];
}

-(void)viewDidAppear:(BOOL)animated
{    
    
    NSLog(@"UsersListViewController -> viewDidAppear:");
    isInChat = NO;
    data = [NSMutableArray arrayWithArray:[(AppDelegate *)[UIApplication sharedApplication].delegate getUsersList]];
    timer = [NSTimer scheduledTimerWithTimeInterval:PING_INTERVAL/PING_RESERVE target:self selector:@selector(ping) userInfo:nil repeats:YES];
    
    [self ping];
    
    [(AppDelegate *)[UIApplication sharedApplication].delegate setChainResponder:responder];
    [(AppDelegate *)[UIApplication sharedApplication].delegate setUsersListVC:self];
}

-(void)viewWillDisappear:(BOOL)animated
{
    
    NSLog(@"UsersListViewController -> viewWillDisappear:");
    if (!isInChat) {
        [self bye];
    }
    
    [timer invalidate];
    
    [(AppDelegate *)[UIApplication sharedApplication].delegate setUsersListVC:nil];
    [(AppDelegate *)[UIApplication sharedApplication].delegate setChainResponder:nil];
}
-(BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender
{
    isInChat = YES;
    return YES;
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -
#pragma mark Public Methods

- (void)addRowWithIndexPath:(NSArray *)indexPath
{
    if (isAnimated)
    {
        [self performSelector:@selector(addRows:) withObject:indexPath afterDelay:0.4*isAnimated];
    }
    else
    {
        [self addRows:indexPath];
    }
}

- (void)removeRowWithIndexPath:(NSArray *)indexPath
{
    if (isAnimated)
    {
        [self performSelector:@selector(delRows:) withObject:indexPath afterDelay:0.4*isAnimated];
    }
    else
    {
        [self delRows:indexPath];
    }
}

- (void)renewUserList
{
    data = [NSMutableArray arrayWithArray:[(AppDelegate *)[UIApplication sharedApplication].delegate getUsersList]];
    [self.tableView reloadData];
}

#pragma mark -
#pragma mark Private Methods

-(void)addRows:(NSArray *)rows
{
    isAnimated = YES;
    
    [data addObject:[rows objectAtIndex:0]];
    [_tableView beginUpdates];
    [_tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:data.count-1 inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
    [_tableView endUpdates];
    [self performSelector:@selector(setAnimationNo) withObject:nil afterDelay:0.4];
}

-(void)delRows:(NSArray *)rows
{
    isAnimated = YES;
    
    //NSLog(@"%@", rows.description);
    
    [data removeObjectAtIndex:[[rows objectAtIndex:0] row]];
    [_tableView beginUpdates];
    [_tableView deleteRowsAtIndexPaths:rows withRowAnimation:UITableViewRowAnimationFade];
    [_tableView endUpdates];
    [self performSelector:@selector(setAnimationNo) withObject:nil afterDelay:0.4];
}

-(void)setAnimationNo
{
    isAnimated = NO;
}

-(void)ping
{
    PublishOptions *options = [PublishOptions new];
    options.headers = @{STATUS_KEY: @"online", ACTION_KEY:@"ping"};
    [backendless.messagingService publish:CONTROL_STREAM_MESSAGING message:_streamNamePublisher publishOptions:options responder:nil];
    
    NSLog(@"UserListViewController -> Sent PING '%@': %@", _streamNamePublisher, [NSDate date]);
}

-(void)publishTo:(NSString *)userName
{
    
    NSString *message = _streamNamePublisher;
    if (!message || !message.length)
        return;
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    
    @try {
        PublishOptions *publishOptions = [PublishOptions new];
        publishOptions.headers = @{@"toUser":userName, ACTION_KEY:@"connect"};
        MessageStatus *status = [backendless.messagingService publish:CONTROL_STREAM_MESSAGING message:message publishOptions:publishOptions];
        
        NSLog(@"UserListViewController -> publishTo: PUBLISH STATUS: %@", status);
    }
    
    @catch (Fault *fault) {
        
        NSLog(@"UserListViewController -> publishTo: FAULT = %@ <%@>", fault.message, fault.detail);
    }
    
    @finally {
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    }
}

-(void)bye
{
    PublishOptions *options = [PublishOptions new];
    options.headers = @{STATUS_KEY: @"cancel", ACTION_KEY:@"bye"};
    [backendless.messagingService publish:CONTROL_STREAM_MESSAGING message:_streamNamePublisher publishOptions:options responder:nil];
    
    NSLog(@"UserListViewController -> Sent BYE '%@': %@", _streamNamePublisher, [NSDate date]);
}

#pragma mark -
#pragma mark IResponder Methods

-(id)responseHandler:(id)response {
    
    //NSLog(@"UsersListViewController -> responseHandler: RESPONSE = %@ <%@>", response, response?[response class]:@"NULL");
    
    NSArray *messages = (NSArray *)response;
    for (Message *message in messages) {
        
        if (![message isKindOfClass:[Message class]] || [message.data isEqualToString:_streamNamePublisher])
            continue;
        
        NSString *action = [message.headers objectForKey:ACTION_KEY];
        if (!action) 
            continue;
    
        if ([action isEqualToString:@"connect"] && [[message.headers objectForKey:@"toUser"] isEqualToString:_streamNamePublisher])
        {
            ViewController *VC = (ViewController *)[self.storyboard instantiateViewControllerWithIdentifier:@"ViewController"];
            [VC setStreamNamePublisher:_streamNamePublisher];
            [VC setStreamNamePlayer:message.data];
            isInChat = YES;
            [self.navigationController pushViewController:VC animated:YES];
            continue;
        }
    }
    
    return response;
}

-(void)errorHandler:(Fault *)fault {
    
    NSLog(@"UsersListViewController -> errorHandler: FAULT = %@ <%@>", fault.message, fault.detail);
}

#pragma mark -
#pragma mark UISegue

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    //send message to user with stream name
    NSIndexPath *indexPath = [_tableView indexPathForCell:sender];
    NSString *name = [(ChatUserInfo *)[data objectAtIndex:indexPath.row] name];
    [self publishTo:name];
    
    [(ViewController *)segue.destinationViewController setStreamNamePublisher:_streamNamePublisher];
    [(ViewController *)segue.destinationViewController setStreamNamePlayer:name];
}

#pragma mark -
#pragma mark UITableViewDelegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return data.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"userCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    
    cell.textLabel.font = [UIFont fontWithName:@"Alix2" size:19];
    cell.textLabel.text = [(ChatUserInfo *)[data objectAtIndex:indexPath.row] name];
    return cell;
}

@end
