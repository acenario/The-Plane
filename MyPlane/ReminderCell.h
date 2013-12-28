//
//  ReminderCell.h
//  MyPlane
//
//  Created by Abhijay Bhatnagar on 12/26/13.
//  Copyright (c) 2013 Acubed Productions. All rights reserved.
//

#import <Parse/Parse.h>

@interface ReminderCell : PFTableViewCell

@property (nonatomic, weak) IBOutlet UILabel *usernameLabel;
@property (nonatomic, weak) IBOutlet UILabel *dateLabel;
@property (nonatomic, weak) IBOutlet UILabel *taskLabel;
@property (nonatomic, weak) IBOutlet PFImageView *userImage;

@end
