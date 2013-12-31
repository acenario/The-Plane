//
//  ChildrenRemindersViewController.h
//  MyPlane
//
//  Created by Abhijay Bhatnagar on 12/27/13.
//  Copyright (c) 2013 Acubed Productions. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SubclassHeader.h"

@interface ChildrenRemindersViewController : UITableViewController

@property (nonatomic, strong) Reminders *parent;
@property (nonatomic, strong) NSArray *children;

@end
