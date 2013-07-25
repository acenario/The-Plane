//
//  ProfileQueryViewController.h
//  MyPlane
//
//  Created by Arjun Bhatnagar on 7/22/13.
//  Copyright (c) 2013 Acubed Productions. All rights reserved.
//

#import <Parse/Parse.h>
#import "EditSettingsViewController.h"


@interface ProfileQueryViewController : PFQueryTableViewController <EditSettingsViewControllerDelegate>

@property (strong, nonatomic) IBOutlet UITextField *firstNameField;
@property (strong, nonatomic) IBOutlet UITextField *lastNameField;
@property (strong, nonatomic) IBOutlet UITextField *usernameField;
@property (strong, nonatomic) IBOutlet UITextField *emailField;
@property (strong, nonatomic) IBOutlet PFImageView *profilePicture;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *editButton;

@end
