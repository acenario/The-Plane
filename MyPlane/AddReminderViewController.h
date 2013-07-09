//
//  AddReminderViewController.h
//  MyPlane
//
//  Created by Abhijay Bhatnagar on 7/8/13.
//  Copyright (c) 2013 Acubed Productions. All rights reserved.
//

#import <Parse/Parse.h>

@class AddReminderViewController;

@protocol AddReminderViewControllerDelegate

@end


@interface AddReminderViewController : UITableViewController <UITextFieldDelegate, UITextViewDelegate>

-(IBAction)done:(id)sender;
-(IBAction)cancel:(id)sender;

@property (strong, nonatomic) IBOutlet UITextField *taskTextField;
@property (strong, nonatomic) IBOutlet UITextView *descriptionTextView;
@property (strong, nonatomic) IBOutlet UILabel *name;
@property (strong, nonatomic) IBOutlet UIImageView *userImage;
@property (nonatomic, weak) id <AddReminderViewControllerDelegate> delegate;