//
//  CircleRemindersViewController.h
//  MyPlane
//
//  Created by Abhijay Bhatnagar on 8/18/13.
//  Copyright (c) 2013 Acubed Productions. All rights reserved.
//

#import <Parse/Parse.h>
#import "SubclassHeader.h"
#import "AddCircleReminderViewController.h"
#import "ReminderDisclosureViewController.h"

@class CircleRemindersViewController;

@protocol CircleRemindersViewControllerDelegate <NSObject>

@end

@interface CircleRemindersViewController : PFQueryTableViewController <AddCircleReminderViewControllerDelegate, ReminderDisclosureViewControllerDelegate>

@property (nonatomic, weak) id <CircleRemindersViewControllerDelegate> delegate;
@property (nonatomic, strong) Circles *circle;
@property (nonatomic, strong) UserInfo *currentUser;
@property (nonatomic, strong) NSArray *circles;

@end
