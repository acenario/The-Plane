//
//  ReminderCell.m
//  MyPlane
//
//  Created by Abhijay Bhatnagar on 12/26/13.
//  Copyright (c) 2013 Acubed Productions. All rights reserved.
//

#import "ReminderCell.h"

@implementation ReminderCell

@synthesize taskLabel = _taskLabel;
@synthesize userImage = _userImage;
@synthesize usernameLabel = _usernameLabel;
@synthesize dateLabel = _dateLabel;

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    
    UIImageView *av = [[UIImageView alloc] init];
    av.backgroundColor = [UIColor clearColor];
    av.opaque = NO;
    UIImage *background = [UIImage imageNamed:@"list-item"];
    av.image = background;
    
    self.backgroundView = av;
    
    UIColor *selectedColor = [UIColor colorFromHexCode:@"FF7140"];
    
    UIView *bgView = [[UIView alloc]init];
    bgView.backgroundColor = selectedColor;
    
    
    [self setSelectedBackgroundView:bgView];
    
    UILabel *reminderLabel = _taskLabel;
    UILabel *usernameLabel = _usernameLabel;
    UILabel *dateLabel = _dateLabel;
    
    reminderLabel.font = [UIFont flatFontOfSize:16];
    usernameLabel.font = [UIFont flatFontOfSize:14];
    dateLabel.font = [UIFont flatFontOfSize:13];
    
    reminderLabel.textColor = [UIColor colorFromHexCode:@"A62A00"];
    reminderLabel.backgroundColor = [UIColor clearColor];
    usernameLabel.backgroundColor = [UIColor clearColor];
    dateLabel.backgroundColor = [UIColor clearColor];
    
}

@end
