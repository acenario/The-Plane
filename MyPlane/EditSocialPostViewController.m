//
//  EditSocialPostViewController.m
//  MyPlane
//
//  Created by Abhijay Bhatnagar on 9/1/13.
//  Copyright (c) 2013 Acubed Productions. All rights reserved.
//

#import "EditSocialPostViewController.h"

@interface EditSocialPostViewController ()

@end

@implementation EditSocialPostViewController {
    NSDateFormatter *mainFormatter;
    NSString *descriptionPlaceholderText;
    NSDate *reminderDate;
    BOOL hasTask;
    BOOL taskCheck;
    BOOL postCheck;
    BOOL descCheck;
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
    
    mainFormatter = [[NSDateFormatter alloc] init];
    [mainFormatter setDateStyle:NSDateFormatterShortStyle];
    [mainFormatter setTimeStyle:NSDateFormatterShortStyle];
    
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *components = [calendar components:NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit|NSHourCalendarUnit|NSMinuteCalendarUnit fromDate:[NSDate date]];
    [components setSecond:0];
    
    self.socialPostTextView.text = self.post.text;
    int limit = 140 - self.socialPostTextView.text.length;
    self.postLimit.text = [NSString stringWithFormat:@"%d", limit];
    
    if (self.post.reminderTask.length > 0) {
        self.reminderTextField.text = self.post.reminderTask;
        reminderDate = self.post.reminderDate;
        self.dateLabel.text = [mainFormatter stringFromDate:reminderDate];
        
        limit = 35 - self.reminderTextField.text.length;
        self.reminderLimit.text = [NSString stringWithFormat:@"%d", limit];
//        self.reminderLimit.hidden = YES;
        
        self.reminderTextField.delegate = self;
        self.descriptionTextView.delegate = self;

        [self.reminderTextField addTarget:self action:@selector(taskValidation:) forControlEvents:UIControlEventEditingChanged];
        if (self.post.reminderDescription.length > 0) {
            self.descriptionTextView.text = self.post.reminderDescription;
            limit = 250 - self.descriptionTextView.text.length;
            self.descLimit.text = [NSString stringWithFormat:@"%d characters left", limit];
        } else {
            descriptionPlaceholderText = @"Enter more information about the reminder.";
            self.descriptionTextView.text = descriptionPlaceholderText;
            self.descriptionTextView.textColor = [UIColor lightGrayColor];
            self.descriptionTextView.userInteractionEnabled = NO;
            limit = 250;
            self.descLimit.text = [NSString stringWithFormat:@"%d characters left", limit];
        }
        hasTask = YES;
    } else {
        self.descCell.hidden = YES;
        self.taskCell.hidden = YES;
        self.dateCell.hidden = YES;
        hasTask = NO;
    }
    
    taskCheck = YES;
    descCheck = YES;
    postCheck = YES;
    
    [self configureDoneButton];
    
    self.socialPostTextView.delegate = self;
    
    UITapGestureRecognizer *gestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideKeyboard)];
    [self.tableView addGestureRecognizer:gestureRecognizer];
    gestureRecognizer.cancelsTouchesInView = NO;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ((indexPath.section == 0) && (indexPath.row == 0)) {
        [self.socialPostTextView becomeFirstResponder];
        
        [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    } else if ((indexPath.section == 1) && (indexPath.row == 0)) {
        [self.reminderTextField becomeFirstResponder];
        
        [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    } else if ((indexPath.section == 1) && (indexPath.row == 2)) {
        if ([self.descriptionTextView.text isEqualToString:descriptionPlaceholderText]) {
            self.descriptionTextView.text = @"";
            self.descriptionTextView.textColor = [UIColor blackColor];
        }
        
        self.descriptionTextView.userInteractionEnabled = YES;
        [self.descriptionTextView becomeFirstResponder];
        
        [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    } else {
        [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    }
}

- (IBAction)cancel:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)done:(id)sender {
    if (![self.descriptionTextView.text isEqualToString:descriptionPlaceholderText]) {
        self.post.reminderDescription = self.descriptionTextView.text;
    }
    self.post.reminderDate = reminderDate;
    self.post.reminderTask = self.reminderTextField.text;
    self.post.text = self.socialPostTextView.text;
    
    [self.post saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        [self.delegate editSocialPostViewController:self didFinishWithPost:self.post];
        [self dismissViewControllerAnimated:YES completion:nil];
    }];
}

- (void)taskValidation:(id)sender
{
    int limit = 35 - self.reminderTextField.text.length;
    self.reminderLimit.text = [NSString stringWithFormat:@"%d", limit];
    if (limit >= 0) {
        taskCheck = YES;
    } else {
        taskCheck = NO;
    }
    
    [self configureDoneButton];
}

//- (void)postValidation:(id)sender
//{
//    int limit = 140 - self.socialPostTextView.text.length;
//    self.postLimit.text = [NSString stringWithFormat:@"%d characters left", limit];
//    if (limit >= 0) {
//        postCheck = YES;
//    } else {
//        postCheck = NO;
//    }
//    
//    [self configureDoneButton];
//}

- (void)descValidation:(id)sender
{
    int limit = 250 - self.descriptionTextView.text.length;
    self.descLimit.text = [NSString stringWithFormat:@"%d", limit];
    if (limit >= 0) {
        descCheck = YES;
    } else {
        descCheck = NO;
    }
    
    [self configureDoneButton];
}

- (void)textViewDidChange:(UITextView *)textView
{
    if (textView.tag == 1) {
        int limit = 140 - self.socialPostTextView.text.length;
        self.postLimit.text = [NSString stringWithFormat:@"%d", limit];
        if (limit >= 0) {
            postCheck = YES;
        } else {
            postCheck = NO;
        }
        
        [self configureDoneButton];
    } else if (textView.tag == 2) {
        int limit = 250 - self.descriptionTextView.text.length;
        self.descLimit.text = [NSString stringWithFormat:@"%d", limit];
        if (limit >= 0) {
            descCheck = YES;
        } else {
            descCheck = NO;
        }
        
        [self configureDoneButton];
    }
}

- (void)configureDoneButton
{
    if ((postCheck) && (taskCheck) && (descCheck)) {
        self.doneButton.enabled = YES;
    } else {
        self.doneButton.enabled = NO;
    }
}

- (void)hideKeyboard
{
    [self.reminderTextField resignFirstResponder];
    [self.descriptionTextView resignFirstResponder];
    [self.socialPostTextView resignFirstResponder];
}

- (void)reminderDateViewController:(ReminderDateViewController *)controller didFinishSelectingDate:(NSDate *)date
{
    reminderDate = date;
    self.dateLabel.text = [mainFormatter stringFromDate:date];
}

- (void)reminderViewControllerDidCancel:(ReminderDateViewController *)controller
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (section == 0) {
        return @"Post";
    } else {
        if (hasTask) {
            return @"Reminder";
        }
    }
    
    return nil;
}

//- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    if ((!hasTask) && (indexPath.section == 1)) {
//        return 1;
//    } else {
//        if (indexPath.section == 0) {
//            return 90;
//        } else {
//            if (indexPath.row == 2) {
//                return 131;
//            } else {
//                return 44;
//            }
//        }
//    }
//}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"PickDate"]) {
        ReminderDateViewController *controller = [segue destinationViewController];
        controller.delegate = self;
        controller.displayDate = self.dateLabel.text;
    }
}

@end
