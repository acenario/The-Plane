//
//  AddReminderViewController.h
//  MyPlane
//
//  Created by Abhijay Bhatnagar on 7/8/13.
//  Copyright (c) 2013 Acubed Productions. All rights reserved.
//

#import <Parse/Parse.h>
#import "FriendsForRemindersViewController.h"
#import "ReminderDateViewController.h"

@class AddReminderViewController;

@protocol AddReminderViewControllerDelegate

@end


@interface AddReminderViewController : UITableViewController <UITextFieldDelegate, UITextViewDelegate, FriendsForRemindersDelegate, ReminderDateViewControllerDelegate, UITextViewDelegate>

-(IBAction)done:(id)sender;
-(IBAction)cancel:(id)sender;

@property (strong, nonatomic) IBOutlet UIBarButtonItem *doneBarItem;
@property (strong, nonatomic) IBOutlet UITextField *taskTextField;
@property (strong, nonatomic) IBOutlet UITextView *descriptionTextView;
@property (weak, nonatomic) IBOutlet UILabel *name;
@property (weak, nonatomic) IBOutlet UILabel *username;
@property (strong, nonatomic) IBOutlet UIImageView *userImage;
@property (strong, nonatomic) IBOutlet UILabel *dateDetail;

@property (nonatomic, weak) id <AddReminderViewControllerDelegate> delegate;


@end