//
//  SettingsViewController.h
//  MyPlane
//
//  Created by Arjun Bhatnagar on 7/13/13.
//  Copyright (c) 2013 Acubed Productions. All rights reserved.
//

#import <UIKit/UIKit.h>
//#import <MessageUI/MessageUI.h>
#import <AddressBook/AddressBook.h>
#import <AddressBookUI/AddressBookUI.h>


#import "EditSettingsViewController.h"
#import "UzysSlideMenu.h"
#import "CommonTasksViewController.h"
#import "MZFormSheetController.h"
#import "firstTimeSettingsViewController.h"


@interface SettingsViewController : UITableViewController <EditSettingsViewControllerDelegate, PFLogInViewControllerDelegate, PFSignUpViewControllerDelegate, firstTimeSettingsViewControllerDelegate, FUIAlertViewDelegate, ABPeoplePickerNavigationControllerDelegate, UIActionSheetDelegate>

@property (strong, nonatomic) IBOutlet UITextField *firstNameField;
@property (strong, nonatomic) IBOutlet UITextField *lastNameField;
@property (strong, nonatomic) IBOutlet UITextField *fullNameField;
@property (strong, nonatomic) IBOutlet UITextField *usernameField;
@property (strong, nonatomic) IBOutlet UITextField *emailField;
@property (strong, nonatomic) IBOutlet PFImageView *profilePicture;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *editButton;


- (IBAction)unwindToSettings:(UIStoryboardSegue *)unwindSegue;
- (IBAction)showMenu:(id)sender;

@end
