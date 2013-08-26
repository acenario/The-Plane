//
//  CommonTasksViewController.h
//  MyPlane
//
//  Created by Arjun Bhatnagar on 8/15/13.
//  Copyright (c) 2013 Acubed Productions. All rights reserved.
//

#import <Parse/Parse.h>
#import "SubclassHeader.h"
#import "AddCommonTaskViewController.h"

@class CommonTasksViewController;

@protocol CommonTasksViewControllerDelegate <NSObject>

- (void)commonTasksViewControllerDidFinishWithTask:(NSString *)task;

@end

@interface CommonTasksViewController : PFQueryTableViewController <AddCommonTaskViewControllerDelegate>

//@property (nonatomic, strong) UserInfo *currentUser;
@property (nonatomic, strong) id <CommonTasksViewControllerDelegate> delegate;
- (IBAction)addTask:(id)sender;
- (IBAction)cancel:(id)sender;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *cancelButton;
@property BOOL isFromSettings;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *addBtn;

@end
