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

@class AddCircleReminderViewController;

@protocol AddCircleReminderViewControllerDelegate <NSObject>

- (void)addCircleReminderViewController:(AddCircleReminderViewController *)controller
        didFinishAddingReminderInCircle:(Circles *)circle
                              withUsers:(NSArray *)users
                               withTask:(NSString *)task
                        withDescription:(NSString *)description
                               withDate:(NSDate *)date;

@end

@interface AddCircleReminderViewController : UITableViewController <ACRPickCircleViewControllerDelegate, PickMembersViewControllerDelegate, UITextFieldDelegate, UITextViewDelegate, ReminderDateViewControllerDelegate>

@property (nonatomic, weak) id <AddCircleReminderViewControllerDelegate> delegate;
@property (nonatomic, strong) Circles *circle;
@property (nonatomic, strong) NSArray *circles;
@property (nonatomic, strong) UserInfo *currentUser;
@property (strong, nonatomic) IBOutlet UILabel *circleLeftLabel;
@property (strong, nonatomic) IBOutlet UILabel *circleName;
@property (strong, nonatomic) IBOutlet UILabel *memberCountDisplay;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *doneButton;
- (IBAction)cancel:(id)sender;
- (IBAction)done:(id)sender;
@property (strong, nonatomic) IBOutlet UILabel *dateTextLabel;
@property (strong, nonatomic) IBOutlet UITextView *descriptionTextView;
@property (strong, nonatomic) IBOutlet UITextField *taskTextField;
@property (strong, nonatomic) IBOutlet UISegmentedControl *segmentedControl;
- (IBAction)segmentChange:(id)sender;

@end
