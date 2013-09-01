//
//  EditReminderViewController.h
//  MyPlane
//
//  Created by Abhijay Bhatnagar on 9/1/13.
//  Copyright (c) 2013 Acubed Productions. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SubclassHeader.h"
#import "MZFormSheetController.h"
#import "CommonTasksViewController.h"
#import "ReminderDateViewController.h"

@class EditReminderViewController;

@protocol EditReminderViewControllerDelegate <NSObject>

- (void)editReminderViewController:(EditReminderViewController *)controller didFinishWithReminder:(Reminders *)reminders;

@end

@interface EditReminderViewController : UITableViewController <UITextFieldDelegate, UITextViewDelegate, CommonTasksViewControllerDelegate, ReminderDateViewControllerDelegate>

@property (nonatomic, strong) Reminders *reminder;
@property (nonatomic, strong) id <EditReminderViewControllerDelegate> delegate;
@property (strong, nonatomic) IBOutlet UITextField *taskTextField;
@property (strong, nonatomic) IBOutlet UILabel *dateLabel;
@property (strong, nonatomic) IBOutlet UITextView *descTextView;
@property (strong, nonatomic) IBOutlet UILabel *taskLimit;
@property (strong, nonatomic) IBOutlet UILabel *descLimit;
- (IBAction)cancel:(id)sender;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *doneButton;
- (IBAction)taskValidation:(id)sender;
- (IBAction)done:(id)sender;
- (IBAction)commonTasks:(id)sender;

@end
