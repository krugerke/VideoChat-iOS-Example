//
//  ViewController.m
//  VideoChat
//
//  Created by Yury Yaschenko on 3/26/13.
//  Copyright (c) 2013 BACKENDLESS.COM. All rights reserved.
//

#import "ViewController.h"
#import "Backendless.h"
#import "AppDelegate.h"

#define _TUBE @"mediaTubeForWowza"

@interface ViewController ()<IMediaStreamerDelegate>
{
    MediaPublisher *_publisher;
    MediaPlayer *_player;
    UIActivityIndicatorView *_netActivity;
}

-(void)initNetActivity;
-(void)initPublisher;
-(void)initPlayer;
-(void)hangup;
-(void)cancel;
@end

@implementation ViewController
@synthesize streamNamePlayer, streamNamePublisher;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.chattingWith setFont:[UIFont fontWithName:@"Alix2" size:21]];
    self.chattingWith.text = [NSString stringWithFormat:@"Video Chatting With %@", self.streamNamePlayer];

    [self initNetActivity];
}

- (void)viewDidAppear:(BOOL)animated
{
    NSLog(@"ViewController -> viewDidAppear:");
    
    [super viewDidAppear:animated];
    
    [(AppDelegate *)[UIApplication sharedApplication].delegate setChatVC:self];
    
    [self initPublisher];
}

-(void)viewWillDisappear:(BOOL)animated
{
    NSLog(@"ViewController -> viewWillDisappear:");
    
    [(AppDelegate *)[UIApplication sharedApplication].delegate setChatVC:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -
#pragma mark IBAction

-(IBAction)back:(id)sender
{
    [self hangup];
}

#pragma mark -
#pragma mark Public Methods

- (void)cancelChat:(NSString *)abonent {
    
    NSLog(@"ViewController -> cancelChat: abonent = %@, self.streamNamePlayer = %@", abonent, self.streamNamePlayer);
    
    if (!abonent || ![abonent isEqualToString:self.streamNamePlayer])
        return;
    
    self.streamNamePublisher = nil;
    self.streamNamePlayer = nil;
    
    [self hangup];
}


#pragma mark -
#pragma mark Private Methods

-(void)initNetActivity {
    
    // Create and add the activity indicator
    _netActivity = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    _netActivity.center = CGPointMake(self.view.frame.size.width/2, self.view.frame.size.height/2);
    [self.view addSubview:_netActivity];
}

-(void)initPublisher
{
    if (_publisher)
        return;
    
    MediaPublishOptions *options = [MediaPublishOptions liveStream:self.preview];
    
    @try {
        _publisher = [backendless.mediaService publishStream:self.streamNamePublisher tube:_TUBE options:options responder:self];
    }
    @catch (Fault *fault) {
        NSLog(@"ViewController -> initPublisher: FAULT = %@ <%@>", fault.message, fault.detail);
    }
}

-(void)initPlayer
{
    if (_player)
        return;
    
    MediaPlaybackOptions *options = [MediaPlaybackOptions liveStream:self.playbackView];
    
    @try {
        _player = [backendless.mediaService playbackStream:self.streamNamePlayer tube:_TUBE options:options responder:self];
    }
    @catch (Fault *fault) {
        NSLog(@"ViewController -> initPlayer: FAULT = %@ <%@>", fault.message, fault.detail);
    }
}

-(void)hangup
{
    if (_publisher)
    {
        [_publisher disconnect];
        _publisher = nil;
    }
    
    if (_player)
    {
        [_player disconnect];
        _player = nil;
    }
}

-(void)cancel {
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark -
#pragma mark IMediaStreamerDelegate Methods

-(void)streamStateChanged:(id)sender state:(StateMediaStream)state description:(NSString *)description {
    
    NSLog(@"ViewController <IMediaStreamerDelegate> streamStateChanged: %d = %@", (int)state, description);
    
    switch (state) {
            
        case MEDIASTREAM_DISCONNECTED: {
            [self hangup];
            [self performSelectorOnMainThread:@selector(cancel) withObject:nil waitUntilDone:NO];
            break;
        }
            
        case MEDIASTREAM_CONNECTED: {
            [_indicator performSelectorOnMainThread:@selector(stopAnimating) withObject:nil waitUntilDone:NO];
            break;
        }
            
        case MEDIASTREAM_CREATED: {
            break;
        }
            
        case MEDIASTREAM_PLAYING: {
            [self initPlayer];
            break;
        }
            
        case MEDIASTREAM_PAUSED: {
            break;
        }
            
        default:
            break;
    }
}

-(void)streamConnectFailed:(id)sender code:(int)code description:(NSString *)description {
    
    NSLog(@"ViewController <IMediaStreamerDelegate> streamConnectFailed: %d = %@", code, description);

    [self hangup];
    [self performSelectorOnMainThread:@selector(cancel) withObject:nil waitUntilDone:YES];
}

@end
