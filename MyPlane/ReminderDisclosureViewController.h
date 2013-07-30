//
//  AddReminderViewController.h
//  MyPlane
//
//  Created by Abhijay Bhatnagar on 7/8/13.
//  Copyright (c) 2013 Acubed Productions. All rights reserved.
//

#import "SubclassHeader.h"

@class ReminderDisclosureViewController;

@protocol ReminderDisclosureViewControllerDelegate

@end

@interface ReminderDisclosureViewController : PFQueryTableViewController <UITextFieldDelegate>

@property (nonatomic, weak) id <ReminderDisclosureViewControllerDelegate> delegate;

@property (nonatomic, strong) PFObject *reminderObject;
- (IBAction)cancel:(id)sender;
- (IBAction)done:(id)sender;
- (IBAction)addComment:(id)sender;



@end
 