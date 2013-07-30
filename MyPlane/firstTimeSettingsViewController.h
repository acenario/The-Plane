//
//  firstTimeSettingsViewController.h
//  MyPlane
//
//  Created by Arjun Bhatnagar on 7/14/13.
//  Copyright (c) 2013 Acubed Productions. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UserInfo.h"

@class firstTimeSettingsViewController;

@protocol firstTimeSettingsViewControllerDelegate <NSObject>

@end

@interface firstTimeSettingsViewController : UITableViewController <UIImagePickerControllerDelegate,UITextFieldDelegate, UINavigationControllerDelegate>

- (IBAction)doneButton:(id)sender;


@property (nonatomic, weak) id <firstTimeSettingsViewControllerDelegate> delegate;
@property (strong, nonatomic) IBOutlet UIImageView *profilePictureSet;
@property (strong, nonatomic) IBOutlet UITextField *firstNameField;
@property (strong, nonatomic) IBOutlet UITextField *lastNameField;
@property (strong, nonatomic) IBOutlet UIButton *doneButton;


@end
 