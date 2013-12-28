//
//  ArchivedRemindersViewController.h
//  MyPlane
//
//  Created by Abhijay Bhatnagar on 12/26/13.
//  Copyright (c) 2013 Acubed Productions. All rights reserved.
//

#import <Parse/Parse.h>
#import "AddReminderViewController.h"

@interface ArchivedRemindersViewController : PFQueryTableViewController

@property (strong, nonatomic) IBOutlet UISegmentedControl *popularitySegment;
- (IBAction)segmentChanged:(id)sender;

@end
