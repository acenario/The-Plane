//
//  AddReminderViewController.h
//  MyPlane
//
//  Created by Abhijay Bhatnagar on 7/8/13.
//  Copyright (c) 2013 Acubed Productions. All rights reserved.
//

#import "ReminderObjectViewController.h"


@class ReminderDisclosureViewController;

@protocol ReminderDisclosureViewControllerDelegate

@end


@interface ReminderDisclosureViewController : UITableViewController 

@property (nonatomic, weak) id <ReminderDisclosureViewControllerDelegate> delegate;

@end