//
//  ReminderActionCell.m
//  MyPlane
//
//  Created by Arjun Bhatnagar on 12/31/13.
//  Copyright (c) 2013 Acubed Productions. All rights reserved.
//

#import "ReminderActionCell.h"

@implementation ReminderActionCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}


- (void)awakeFromNib
{
    [super awakeFromNib];
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
