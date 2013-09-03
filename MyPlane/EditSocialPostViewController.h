//
//  EditSocialPostViewController.h
//  MyPlane
//
//  Created by Abhijay Bhatnagar on 9/1/13.
//  Copyright (c) 2013 Acubed Productions. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SubclassHeader.h"
#import "ReminderDateViewController.h"

@class EditSocialPostViewController;

@protocol EditSocialPostViewControllerDelegate <NSObject>

- (void)editSocialPostViewController:(EditSocialPostViewController *)controller didFinishWithPost:(SocialPosts *)post;

@end

@interface EditSocialPostViewController : UITableViewController <UITextFieldDelegate, UITextViewDelegate, ReminderDateViewControllerDelegate>

#pragma mark - Navigation Bar
- (IBAction)cancel:(id)sender;
- (IBAction)done:(id)sender;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *doneButton;

#pragma mark - TextFields/Views/OtherViews
@property (strong, nonatomic) IBOutlet UITextView *socialPostTextView;
@property (strong, nonatomic) IBOutlet UITextField *reminderTextField;
@property (strong, nonatomic) IBOutlet UITextView *descriptionTextView;
@property (strong, nonatomic) IBOutlet UILabel *dateLabel;
@property (strong, nonatomic) IBOutlet UILabel *descDisplayLabel;
@property (strong, nonatomic) IBOutlet UITableViewCell *taskCell;
@property (strong, nonatomic) IBOutlet UITableViewCell *dateCell;
@property (strong, nonatomic) IBOutlet UITableViewCell *descCell;

#pragma mark - Limits
@property (strong, nonatomic) IBOutlet UILabel *postLimit;
@property (strong, nonatomic) IBOutlet UILabel *reminderLimit;
@property (strong, nonatomic) IBOutlet UILabel *descLimit;

@property (nonatomic, strong) SocialPosts *post;
@property (nonatomic, strong) id <EditSocialPostViewControllerDelegate> delegate;

@end
