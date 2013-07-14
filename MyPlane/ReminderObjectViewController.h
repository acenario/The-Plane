//
//  ReminderObjectViewController.h
//  MyPlane
//
//  Created by Arjun Bhatnagar on 7/14/13.
//  Copyright (c) 2013 Acubed Productions. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ReminderObjectViewController;

@protocol ReminderObjectViewControllerDelegate <NSObject>

@end

@interface ReminderObjectViewController : UITableViewController

@property (nonatomic, strong) id <ReminderObjectViewControllerDelegate> delegate;

@end
