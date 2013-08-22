//
//  CommonTasksViewController.h
//  MyPlane
//
//  Created by Arjun Bhatnagar on 8/15/13.
//  Copyright (c) 2013 Acubed Productions. All rights reserved.
//

#import <Parse/Parse.h>
#import "SubclassHeader.h"
#import "AddCommonTaskViewController.h"
#import "EditCommonTaskViewController.h"

@interface CommonTasksViewController : UITableViewController <AddCommonTaskViewControllerDelegate>

@property (nonatomic, strong) UserInfo *currentUser;

@end
