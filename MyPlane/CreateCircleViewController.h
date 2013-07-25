//
//  CreateCircleViewController.h
//  MyPlane
//
//  Created by Abhijay Bhatnagar on 7/22/13.
//  Copyright (c) 2013 Acubed Productions. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "InviteMembersToCircleViewController.h"
#import "SubclassHeader.h"

@interface CreateCircleViewController : UITableViewController <UITextFieldDelegate, InviteMembersToCircleViewControllerDelegate>
- (IBAction)cancel:(id)sender;
- (IBAction)done:(id)sender;

@end
