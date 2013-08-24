//
//  AddCircleReminderViewController.h
//  MyPlane
//
//  Created by Abhijay Bhatnagar on 8/19/13.
//  Copyright (c) 2013 Acubed Productions. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SubclassHeader.h"
#import "ACRPickCircleViewController.h"
#import "PickMembersViewController.h"
#import "ReminderDateViewController.h"
#import "CommonTasksViewController.h"
#import "MZFormSheetController.h"

@class AddCircleReminderViewController;

@protocol AddCircleReminderViewControllerDelegate <NSObject>

- (void)addCircleReminderViewController:(AddCircleReminderViewController *)controller
        didFinishAddingReminderInCircle:(Circles *)circle
                              withUsers:(NSArray *)users
                               withTask:(NSString *)task
                        withDescription:(NSString *)description
                               withDate:(NSDate *)date;

@end

@interface AddCircleReminderViewController : UITableViewController <ACRPickCircleViewControllerDelegate, PickMembersViewControllerDelegate, UITextFieldDelegate, UITextViewDelegate, ReminderDateViewControllerDelegate,CommonTasksViewControllerDelegate>

#pragma mark - Public Properties
@property (nonatomic, weak) id <AddCircleReminderViewControllerDelegate> delegate;
@property (nonatomic, strong) Circles *circle;
@property (nonatomic, strong) NSArray *circles;
@property (nonatomic, strong) UserInfo *currentUser;
@property (nonatomic, strong) NSArray *invitedMembers;
@property (nonatomic, strong) NSArray *invitedUsernames;
@property BOOL circleCheck;

#pragma mark - Storyboard Outlets
@property (strong, nonatomic) IBOutlet FUISegmentedControl *segmentedControl;
@property (strong, nonatomic) IBOutlet UIView *segmentView;
@property (strong, nonatomic) IBOutlet UITableViewCell *circleCell;

#pragma mark Labels, Text Views, and Text Fields
@property (strong, nonatomic) IBOutlet UILabel *circleName;
@property (strong, nonatomic) IBOutlet UILabel *memberCountDisplay;
@property (strong, nonatomic) IBOutlet UILabel *dateTextLabel;
@property (weak, nonatomic) IBOutlet UILabel *taskInd;
@property (weak, nonatomic) IBOutlet UILabel *descriptionLabel;
@property (strong, nonatomic) IBOutlet UITextView *descriptionTextView;
@property (strong, nonatomic) IBOutlet UITextField *taskTextField;

#pragma mark Buttons
@property (strong, nonatomic) IBOutlet UIBarButtonItem *doneButton;
@property (strong, nonatomic) IBOutlet UIButton *commonTasksButton;

#pragma mark - Actions
- (IBAction)cancel:(id)sender;
- (IBAction)done:(id)sender;
- (IBAction)showCommon:(id)sender;
- (IBAction)segmentChange:(id)sender;
- (IBAction)unwindToAddCircleReminder:(UIStoryboardSegue *)unwindSegue;

@end
