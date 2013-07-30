//
//  MySentReminderViewController.h
//  MyPlane
//
//  Created by Abhijay Bhatnagar on 7/14/13.
//  Copyright (c) 2013 Acubed Productions. All rights reserved.
//

#import <Parse/Parse.h>
#import "ReminderDisclosureViewController.h"
#import "UserInfo.h"


@interface MySentRemindersViewController : PFQueryTableViewController <ReminderDisclosureViewControllerDelegate>

- (IBAction)doneButton:(id)sender;

@end
 