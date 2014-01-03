//
//  ViewController.h
//  VideoChat
//
//  Created by Yury Yaschenko on 3/26/13.
//  Copyright (c) 2013 BACKENDLESS.COM. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController
@property (strong, nonatomic) NSString *streamNamePublisher;
@property (strong, nonatomic) NSString *streamNamePlayer;
@property (strong, nonatomic) IBOutlet UIView *preview;
@property (strong, nonatomic) IBOutlet UIImageView *playbackView;
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *indicator;
@property (weak, nonatomic) IBOutlet UILabel *chattingWith;

- (IBAction)back:(id)sender;
- (void)cancelChat:(NSString *)abonent;
@end
