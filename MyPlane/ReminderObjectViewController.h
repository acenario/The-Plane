//
//  ReminderDateViewController.h
//  MyPlane
//
//  Created by Abhijay Bhatnagar on 7/12/13.
//  Copyright (c) 2013 Acubed Productions. All rights reserved.
//

#import <UIKit/UIKit.h>


@class ReminderObjectViewController;

@protocol ReminderObjectViewController <NSObject>

@end


@interface ReminderObjectViewController : UITableViewController

@property (nonatomic, weak) id <ReminderObjectViewController> delegate;
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

//SOMETHING NEEDED - CONNECTIONS

@end
