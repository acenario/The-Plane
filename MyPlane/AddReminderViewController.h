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


@interface AddReminderViewController : UITableViewController <UITextFieldDelegate, UITextViewDelegate, FriendsForRemindersDelegate, ReminderDateViewControllerDelegate, UITextViewDelegate, CommonTasksViewControllerDelegate>

-(IBAction)done:(id)sender;
-(IBAction)cancel:(id)sender;
- (IBAction)textValidation:(id)sender;
-(IBAction)showCommon:(id)sender;

@property (strong, nonatomic) IBOutlet UIBarButtonItem *doneBarItem;
@property (strong, nonatomic) IBOutlet UITextField *taskTextField;
@property (strong, nonatomic) IBOutlet UITextView *descriptionTextView;
@property (weak, nonatomic) IBOutlet UILabel *name;
@property (weak, nonatomic) IBOutlet UILabel *username;
@property (strong, nonatomic) IBOutlet PFImageView *userImage;
@property (strong, nonatomic) IBOutlet UILabel *dateDetail;
@property (strong, nonatomic) IBOutlet FUISegmentedControl *segmentedControl;
@property (strong, nonatomic) IBOutlet UIView *segmentUIView;
@property (strong, nonatomic) IBOutlet UITableViewCell *friendCell;
@property (strong, nonatomic) IBOutlet UILabel *selectAFriendLabel;
@property (nonatomic, strong) UserInfo *recipient;
@property (nonatomic, strong) UserInfo *currentUser;
@property (weak, nonatomic) IBOutlet UILabel *taskInd;
@property (weak, nonatomic) IBOutlet UIImageView *userFrame;
@property (weak, nonatomic) IBOutlet UILabel *descriptionLabel;

- (IBAction)segmentChanged:(id)sender;

@property (nonatomic, weak) id <AddReminderViewControllerDelegate> delegate;

 
@end