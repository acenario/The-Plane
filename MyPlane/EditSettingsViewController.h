//
//  EditSettingsViewController.h
//  MyPlane
//
//  Created by Arjun Bhatnagar on 7/13/13.
//  Copyright (c) 2013 Acubed Productions. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UserInfo.h"

@class EditSettingsViewController;

@protocol EditSettingsViewControllerDelegate <NSObject>

- (void)updateUserInfo:(EditSettingsViewController *)controller;



@end

@interface EditSettingsViewController : UITableViewController <UIImagePickerControllerDelegate,UITextFieldDelegate, UINavigationControllerDelegate>

- (IBAction)doneButton:(id)sender;
- (IBAction)cancelButton:(id)sender;

- (IBAction)imagePicker:(id)sender;

@property (nonatomic, weak) id <EditSettingsViewControllerDelegate> delegate;
 
@property (nonatomic, strong) NSString *firstname;
@property (nonatomic, strong) NSString *lastname;
@property (nonatomic, strong) NSString *email;
@property (nonatomic, strong) UIImage *profilePicture;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *done;
@property (strong, nonatomic) IBOutlet FUIButton *setPic;








@end
