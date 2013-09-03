//
//  EditSettingsViewController.h
//  MyPlane
//
//  Created by Arjun Bhatnagar on 7/13/13.
//  Copyright (c) 2013 Acubed Productions. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UserInfo.h"
#import "EditExpiryTimeViewController.h"

@class EditSettingsViewController;

@protocol EditSettingsViewControllerDelegate <NSObject>

- (void)updateUserInfo:(EditSettingsViewController *)controller;

@end

@interface EditSettingsViewController : UITableViewController <UIImagePickerControllerDelegate,UITextFieldDelegate, UINavigationControllerDelegate, EditExpiryTimeViewControllerDelegate, FUIAlertViewDelegate>

- (IBAction)doneButton:(id)sender;
- (IBAction)cancelButton:(id)sender;

- (IBAction)imagePicker:(id)sender;

@property (nonatomic, weak) id <EditSettingsViewControllerDelegate> delegate;
 
@property (strong, nonatomic) IBOutlet UILabel *firstnameLabel;
@property (strong, nonatomic) IBOutlet UILabel *lastNameLabel;
@property (strong, nonatomic) IBOutlet UILabel *emailLabel;
@property (nonatomic, strong) NSString *firstname;
@property (nonatomic, strong) NSString *lastname;
@property (nonatomic, strong) NSString *email;
@property int gracePeriod;
@property (nonatomic, strong) UIImage *profilePicture;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *done;
@property (strong, nonatomic) IBOutlet FUIButton *setPic;








@end
