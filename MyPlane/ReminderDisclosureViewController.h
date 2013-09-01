//
//  AddReminderViewController.h
//  MyPlane
//
//  Created by Abhijay Bhatnagar on 7/8/13.
//  Copyright (c) 2013 Acubed Productions. All rights reserved.
//

#import "SubclassHeader.h"
#import "EditReminderViewController.h"

@class ReminderDisclosureViewController;

@protocol ReminderDisclosureViewControllerDelegate

@end

@interface ReminderDisclosureViewController : PFQueryTableViewController <UITextFieldDelegate, EditReminderViewControllerDelegate>

@property (nonatomic, weak) id <ReminderDisclosureViewControllerDelegate> delegate;

@property (nonatomic, strong) PFObject *reminderObject;
- (IBAction)addComment:(id)sender;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *editButton;


@end
 