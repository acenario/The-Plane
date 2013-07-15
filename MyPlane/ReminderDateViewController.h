//
//  ReminderDateViewController.h
//  MyPlane
//
//  Created by Abhijay Bhatnagar on 7/12/13.
//  Copyright (c) 2013 Acubed Productions. All rights reserved.
//

#import <UIKit/UIKit.h>


@class ReminderDateViewController;

@protocol ReminderDateViewControllerDelegate <NSObject>

- (void)reminderDateViewController:(ReminderDateViewController *)controller didFinishSelectingDate:(NSDate *)date;
- (void)reminderViewControllerDidCancel:(ReminderDateViewController *)controller;

@end



@interface ReminderDateViewController : UITableViewController

- (IBAction)cancel:(id)sender;
- (IBAction)done:(id)sender;
- (IBAction)dateAction:(id)sender;

@property (nonatomic, weak) id <ReminderDateViewControllerDelegate> delegate;
@property (strong, nonatomic) IBOutlet UILabel *dateDetail;
@property (strong, nonatomic) NSString *displayDate;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *doneButton;

@end

