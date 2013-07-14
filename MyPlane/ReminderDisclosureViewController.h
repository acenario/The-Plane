//
//  ReminderDisclosureViewController.h
//  MyPlane
//
//  Created by Arjun Bhatnagar on 7/14/13.
//  Copyright (c) 2013 Acubed Productions. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ReminderObjectViewController.h"

@class ReminderDisclosureViewController;

@protocol ReminderDisclosureViewControllerDelegate <NSObject>

@end

@interface ReminderDisclosureViewController : UITableViewController <ReminderObjectViewControllerDelegate>

@property (nonatomic, strong) id <ReminderDisclosureViewControllerDelegate> delegate;

@end
