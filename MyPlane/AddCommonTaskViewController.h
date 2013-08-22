//
//  AddCommonTaskViewController.h
//  MyPlane
//
//  Created by Arjun Bhatnagar on 8/15/13.
//  Copyright (c) 2013 Acubed Productions. All rights reserved.
//

#import <Parse/Parse.h>
#import "SubclassHeader.h"

@class AddCommonTaskViewController;

@protocol AddCommonTaskViewControllerDelegate <NSObject>

@end

@interface AddCommonTaskViewController : PFQueryTableViewController <UITextFieldDelegate>

@property (nonatomic, strong) CommonTasks *task;
@property (nonatomic, strong) UserInfo *currentUser;
@property (nonatomic, strong) UITextField *textField;
@property (nonatomic, strong) UIBarButtonItem *doneButton;
@property (nonatomic, weak) id <AddCommonTaskViewControllerDelegate> delegate;

@end
