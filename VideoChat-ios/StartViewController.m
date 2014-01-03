//
//  StartViewController.m
//  backendlessDemos
//
//  Created by Yury Yaschenko on 3/27/13.
//  Copyright (c) 2013 BACKENDLESS.COM. All rights reserved.
//

#import "StartViewController.h"
#import "UsersListViewController.h"
#import "ChatUserInfo.h"
#import "Backendless.h"
#import "AppDelegate.h"

@interface StartViewController ()
{
    NSString *userName;
}

-(void)showAlert:(NSString *)message;
@end

@implementation StartViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    @try {
        [backendless initAppFault];
    }
    @catch (Fault *fault) {
        NSLog(@"StartViewController -> backendless.initAppFault: FAULT = %@", fault.message);
        [self showAlert:fault.message];
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    self.navigationController.navigationBarHidden = YES;
}

-(void)viewWillDisappear:(BOOL)animated
{
    self.navigationController.navigationBarHidden = NO;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -
#pragma mark Private Methods

-(void)showAlert:(NSString *)message {
    UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Error:" message:message delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
    [av show];
}

#pragma mark -
#pragma mark UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

#pragma mark -
#pragma mark UISegue

- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender
{
    ChatUserInfo *user = [(AppDelegate *)[UIApplication sharedApplication].delegate isInList:self.publisherName.text];
    if (user)
    {
        [[[UIAlertView alloc] initWithTitle:@"Wrong User Name" message:@"Change Name" delegate:nil cancelButtonTitle:@"Done" otherButtonTitles:nil] show];
        return NO;
    }
    return YES;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    [(AppDelegate *)[UIApplication sharedApplication].delegate setUserName:self.publisherName.text];
    [(UsersListViewController *)segue.destinationViewController setStreamNamePublisher:self.publisherName.text];
}

@end
