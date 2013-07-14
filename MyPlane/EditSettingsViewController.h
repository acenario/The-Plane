//
//  EditSettingsViewController.h
//  MyPlane
//
//  Created by Arjun Bhatnagar on 7/13/13.
//  Copyright (c) 2013 Acubed Productions. All rights reserved.
//

#import <UIKit/UIKit.h>

@class EditSettingsViewController;

@protocol EditSettingsViewControllerDelegate <NSObject>

- (void)updateUserInfo:(EditSettingsViewController *)controller;



@end

@interface EditSettingsViewController : UITableViewController <UIImagePickerControllerDelegate, UINavigationControllerDelegate>

- (IBAction)doneButton:(id)sender;

- (IBAction)imagePicker:(id)sender;
@property (nonatomic, weak) id <EditSettingsViewControllerDelegate> delegate;


@end
