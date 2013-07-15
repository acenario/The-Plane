//
//  ReminderObjectViewController.m
//  MyPlane
//
//  Created by Arjun Bhatnagar on 7/14/13.
//  Copyright (c) 2013 Acubed Productions. All rights reserved.
//

#import "ReminderObjectViewController.h"

@interface ReminderObjectViewController ()

@end

@implementation ReminderObjectViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.username.text = self.userUsername;
    self.name.text = self.userName;
    self.taskLabel.text = self.taskText;
    self.descriptionLabel.text = self.descriptionText;
    self.userImage.file = self.userUserImage;
    
    [self.userImage loadInBackground];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)remindAgain:(id)sender {
    // Create our Installation query
    PFQuery *pushQuery = [PFInstallation query];
    [pushQuery whereKey:@"user" equalTo:self.userUsername];
    
    // Send push notification to query
    PFPush *push = [[PFPush alloc] init];
    [push setQuery:pushQuery]; // Set our Installation query
    [push setMessage:self.taskText];
    [push sendPushInBackground];
    
    
    NSLog(@"Arjun implement a notification here in \"remindAgain\"");
}

//SOMETHING NEEDED - CLOUD CODE


@end
