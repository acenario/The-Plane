//
//  ReminderObjectViewController.m
//  MyPlane
//
//  Created by Arjun Bhatnagar on 7/14/13.
//  Copyright (c) 2013 Acubed Productions. All rights reserved.
//

#import "ReminderObjectViewController.h"

@interface ReminderObjectViewController ()

@end

@implementation ReminderObjectViewController {
    UserInfo *userObject;
}

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.username.text = self.userUsername;
    self.name.text = self.userName;
    self.taskLabel.text = self.taskText;
    self.descriptionLabel.text = self.descriptionText;
    self.userImage.file = self.userUserImage;
    
    [self.userImage loadInBackground];
    
    self.commentTextField.delegate = self;
    
    PFQuery *query = [UserInfo query];
    [query whereKey:@"user" equalTo:[PFUser currentUser].username];
    
    [query getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error) {
        userObject = (UserInfo *)object;
    }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)remindAgain:(id)sender {
    // Create our Installation query
    PFQuery *pushQuery = [PFInstallation query];
    [pushQuery whereKey:@"user" equalTo:self.userUsername];
    
    // Send push notification to query
    PFPush *push = [[PFPush alloc] init];
    [push setQuery:pushQuery]; // Set our Installation query
    [push setMessage:self.taskText];
    [push sendPushInBackground];
    
    
    NSLog(@"Arjun implement a notification here in \"remindAgain\"");
}

//- (void)textFieldDidEndEditing:(UITextField *)textField
//{
//    NSString *string = textField.text;
//
//    if ([string isEqualToString:@""]) {
//        self.addCommentButton.enabled = NO;
//    } else {
//        self.addCommentButton.enabled = YES;
//    }
//
//}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    NSString *textFieldText = [NSString stringWithFormat:@"%@%@", textField.text, string];
    
    if ([string isEqualToString:@""]) {
        if ((textFieldText.length - 1) > 0) {
            self.addCommentButton.enabled = YES;
        } else {
            self.addCommentButton.enabled = NO;
        }
    } else {
        if (textFieldText.length > 0) {
            self.addCommentButton.enabled = YES;
        } else {
            self.addCommentButton.enabled = NO;
        }
    }
    
    
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    [self.tableView reloadInputViews];
    
    return YES;
}

- (IBAction)addComment:(id)sender {
    Comments *comment = [Comments object];
    
    [comment setObject:self.reminderObject forKey:@"reminder"];
    [comment setObject:userObject forKey:@"user"];
    [comment setObject:self.commentTextField.text forKey:@"text"];
    
    [comment saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        self.commentTextField.text = @"";
        self.addCommentButton.enabled = NO;
        [self.commentTextField resignFirstResponder];
        [self.tableView reloadData];
        [self.delegate reminderObjectViewControllerDidAddComment:self];
    }];
}

@end
