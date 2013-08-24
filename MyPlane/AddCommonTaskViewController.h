//
//  AddCommonTaskViewController.h
//  MyPlane
//
//  Created by Arjun Bhatnagar on 8/15/13.
//  Copyright (c) 2013 Acubed Productions. All rights reserved.
//

#import "SubclassHeader.h"

@class AddCommonTaskViewController;

@protocol AddCommonTaskViewControllerDelegate <NSObject>

- (void)didFinish;

@end

@interface AddCommonTaskViewController : UITableViewController <UITextFieldDelegate>

@property (nonatomic, strong) CommonTasks *task;
@property (nonatomic, strong) UserInfo *currentUser;
@property (strong, nonatomic) IBOutlet UITextField *textField;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *doneButton;
@property (weak, nonatomic) IBOutlet UILabel *taskLabel;
- (IBAction)done:(id)sender;
- (IBAction)cancel:(id)sender;
@property (nonatomic, weak) id <AddCommonTaskViewControllerDelegate> delegate;

@end
