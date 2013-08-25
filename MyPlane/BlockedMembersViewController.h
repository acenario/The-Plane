//
//  BlockedMembersViewController.h
//  MyPlane
//
//  Created by Abhijay Bhatnagar on 8/25/13.
//  Copyright (c) 2013 Acubed Productions. All rights reserved.
//

#import <Parse/Parse.h>
#import "SubclassHeader.h"

@interface BlockedMembersViewController : PFQueryTableViewController
@property (strong, nonatomic) IBOutlet UIBarButtonItem *unblockButton;
- (IBAction)unblock:(id)sender;

@end
