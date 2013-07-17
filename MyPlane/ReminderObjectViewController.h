//
//  ReminderDateViewController.h
//  MyPlane
//
//  Created by Abhijay Bhatnagar on 7/12/13.
//  Copyright (c) 2013 Acubed Productions. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Comments.h"
#import "UserInfo.h"

@class ReminderObjectViewController;

@protocol ReminderObjectViewControllerDelegate <NSObject>
@end


@interface ReminderObjectViewController : UITableViewController <UITextFieldDelegate>

@property (nonatomic, weak) id <ReminderObjectViewControllerDelegate> delegate;
@property (strong, nonatomic) IBOutlet PFImageView *userImage;
@property (strong, nonatomic) IBOutlet UILabel *name;
@property (strong, nonatomic) IBOutlet UILabel *username;
@property (strong, nonatomic) IBOutlet UILabel *taskLabel;
@property (strong, nonatomic) IBOutlet UILabel *descriptionLabel;

@property (strong, nonatomic) NSString *userName;
@property (strong, nonatomic) NSString *userUsername;
@property (strong, nonatomic) NSString *taskText;
@property (strong, nonatomic) NSString *descriptionText;
@property (strong, nonatomic) PFFile *userUserImage;



- (IBAction)remindAgain:(id)sender;

@end