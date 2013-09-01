//
//  AttachReminderViewController.h
//  MyPlane
//
//  Created by Abhijay Bhatnagar on 8/30/13.
//  Copyright (c) 2013 Acubed Productions. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ReminderDateViewController.h"
#import "CommonTasksViewController.h"
#import "MZFormSheetController.h"

@class AttachReminderViewController;

@protocol AttachReminderViewControllerDelegate <NSObject>

- (void)attachReminderViewController:(AttachReminderViewController *)controller withTask:(NSString *)task withDescription:(NSString *)description withDate:(NSDate *)date withFormatter:(NSDateFormatter *)formatter;

@end

@interface AttachReminderViewController : UITableViewController <UITextFieldDelegate, UITextViewDelegate, ReminderDateViewControllerDelegate, CommonTasksViewControllerDelegate>
@property (strong, nonatomic) IBOutlet UITextField *taskTextField;
- (IBAction)commonTasks:(id)sender;
@property (strong, nonatomic) IBOutlet UILabel *dateLabel;
@property (strong, nonatomic) IBOutlet UITextView *descriptionTextView;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *doneBarItem;
@property (nonatomic, weak) id <AttachReminderViewControllerDelegate> delegate;
@property (nonatomic, strong) NSString *taskText;
@property (nonatomic, strong) NSString *descText;
@property (nonatomic, strong) NSDate *dateText;
@property (strong, nonatomic) IBOutlet UILabel *limitLabel;
@property (strong, nonatomic) IBOutlet UILabel *descLimit;


- (IBAction)cancel:(id)sender;
- (IBAction)done:(id)sender;

@end
