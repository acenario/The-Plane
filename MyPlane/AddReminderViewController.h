//
//  AddReminderViewController.h
//  MyPlane
//
//  Created by Abhijay Bhatnagar on 7/8/13.
//  Copyright (c) 2013 Acubed Productions. All rights reserved.
//

#import <Parse/Parse.h>
#import "SubclassHeader.h"
#import "FriendsForRemindersViewController.h"
#import "ReminderDateViewController.h"
#import "AddCircleReminderViewController.h"
#import "CommonTasksViewController.h"

@class AddReminderViewController;

@protocol AddReminderViewControllerDelegate

@end


@interface AddReminderViewController : UITableViewController <UITextFieldDelegate, UITextViewDelegate, FriendsForRemindersDelegate, ReminderDateViewControllerDelegate, UITextViewDelegate, CommonTasksViewControllerDelegate, AddCircleReminderViewControllerDelegate>

-(IBAction)done:(id)sender;
-(IBAction)cancel:(id)sender;
- (IBAction)textValidation:(id)sender;
-(IBAction)showCommon:(id)sender;

#pragma mark Labels
@property (weak, nonatomic) IBOutlet UILabel *name;
@property (weak, nonatomic) IBOutlet UILabel *username;
@property (strong, nonatomic) IBOutlet UILabel *dateDetail;
@property (strong, nonatomic) IBOutlet UILabel *selectAFriendLabel;
@property (weak, nonatomic) IBOutlet UILabel *taskInd;
@property (weak, nonatomic) IBOutlet UILabel *descriptionLabel;
@property (strong, nonatomic) IBOutlet UILabel *limitLabel;
@property (strong, nonatomic) IBOutlet UILabel *descLabel;

#pragma mark TextViews/Fields
@property (strong, nonatomic) IBOutlet UITextField *taskTextField;
@property (strong, nonatomic) IBOutlet UITextView *descriptionTextView;

#pragma mark Other
@property (strong, nonatomic) IBOutlet FUISegmentedControl *segmentedControl;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *doneBarItem;
@property (strong, nonatomic) IBOutlet UITableViewCell *friendCell;
@property (strong, nonatomic) IBOutlet FUIButton *commonTasks;
@property (strong, nonatomic) IBOutlet PFImageView *userImage;
@property (strong, nonatomic) IBOutlet UIView *segmentUIView;
@property (weak, nonatomic) IBOutlet UIImageView *userFrame;
@property (nonatomic, strong) UserInfo *recipient;
@property (nonatomic, strong) UserInfo *currentUser;

///---- 1: Reminders  2: Social  3:Connect  4:Settings
@property int unwinder; 

/// A template reminder from the Archive or Sent
@property (nonatomic, strong) Reminders *templateReminder;

- (IBAction)segmentChanged:(id)sender;

@property (nonatomic, weak) id <AddReminderViewControllerDelegate> delegate;

 
@end