//
//  ReminderInclosureViewController.h
//  MyPlane
//
//  Created by Abhijay Bhatnagar on 7/15/13.
//  Copyright (c) 2013 Acubed Productions. All rights reserved.
//

#import <Parse/Parse.h>
#import "ReminderObjectViewController.h"
#import "UserInfo.h"
#import "Comments.h"

@class ReminderDisclosureViewController;

@protocol ReminderDisclosureViewControllerDelegate

@end


@interface ReminderDisclosureViewController : PFQueryTableViewController <ReminderObjectViewController, UITextFieldDelegate>

@property (nonatomic, weak) id <ReminderDisclosureViewControllerDelegate> delegate;

@property (nonatomic, strong) PFObject *reminderObject;
- (IBAction)cancel:(id)sender;
- (IBAction)done:(id)sender;

//SOMETHING NEED - CONNECTIONS

//@property (strong, nonatomic) NSString *userName;
//@property (strong, nonatomic) NSString *userUsername;
//@property (strong, nonatomic) NSString *taskText;
//@property (strong, nonatomic) NSString *descriptionText;
//@property (strong, nonatomic) UIImage *userUserImage;

@end