//
//  EditReminderViewController.m
//  MyPlane
//
//  Created by Abhijay Bhatnagar on 9/1/13.
//  Copyright (c) 2013 Acubed Productions. All rights reserved.
//

#import "EditReminderViewController.h"

@interface EditReminderViewController ()

@end

@implementation EditReminderViewController {
    BOOL textCheck;
    BOOL descCheck;
    NSDate *reminderDate;
    NSString *descriptionPlaceholderText;
    NSDateFormatter *mainFormatter;
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
    
    reminderDate = self.reminder.date;
    self.taskTextField.text = self.reminder.title;
    self.dateLabel.text = [mainFormatter stringFromDate:reminderDate];
    self.taskLimit.hidden = YES;
    self.taskLimit.text = [NSString stringWithFormat:@"%d", 35 - self.taskTextField.text.length];
    if ([[self.reminder objectForKey:@"description"] length] > 0) {
        //        NSLog(@"%@", self.reminder.description);
        self.descTextView.text = [self.reminder objectForKey:@"description"];
        self.descLimit.text = [NSString stringWithFormat:@"%d", 250 - self.descTextView.text.length ];
    } else {
        descriptionPlaceholderText = @"Enter more information about the reminder";
        self.descTextView.text = descriptionPlaceholderText;
        self.descTextView.textColor = [UIColor lightGrayColor];
        self.descTextView.userInteractionEnabled = NO;
    }
    
    descCheck = YES;
    textCheck = YES;
    self.descTextView.delegate = self;
    self.taskTextField.delegate = self;
    

    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (IBAction)cancel:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)taskValidation:(id)sender
{
    self.taskLimit.hidden = NO;
    NSString *removedSpaces = [self.taskTextField.text stringByReplacingOccurrencesOfString:@" " withString:@""];
    int limit = 35 - self.taskTextField.text.length;
    self.taskLimit.text = [NSString stringWithFormat:@"%d characters left", limit];
    textCheck = ((removedSpaces.length > 0) && (limit >= 0));
    [self configureDoneButton];
}

- (IBAction)done:(id)sender
{
    [SVProgressHUD showWithStatus:@"Editing..."];
    if (![self.descTextView.text isEqualToString:descriptionPlaceholderText]) {
        [self.reminder setObject:self.descTextView.text forKey:@"description"];
    }
    self.reminder.date = reminderDate;
    self.reminder.title = self.taskTextField.text;
    
    [self.reminder saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        [SVProgressHUD showSuccessWithStatus:@"Done"];
        [self.delegate editReminderViewController:self didFinishWithReminder:self.reminder];
        [self dismissViewControllerAnimated:YES completion:nil];
    }];
    
}

- (void)textViewDidChange:(UITextView *)textView
{
    int limit = 250 - self.descTextView.text.length;
    self.descLimit.text = [NSString stringWithFormat:@"%d characters left", limit];
    descCheck = ((limit >= 0));
    [self configureDoneButton];
}

- (IBAction)commonTasks:(id)sender
{
    UINavigationController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"commonTasks"];
    CommonTasksViewController *cVC = (CommonTasksViewController *)[vc topViewController];
    cVC.delegate = self;
    cVC.isFromSettings = NO;
    MZFormSheetController *formSheet = [[MZFormSheetController alloc] initWithViewController:vc];
    formSheet.shouldDismissOnBackgroundViewTap = YES;
    formSheet.transitionStyle = MZFormSheetTransitionStyleSlideAndBounceFromRight;
    formSheet.cornerRadius = 9.0;
    formSheet.portraitTopInset = 6.0;
    formSheet.landscapeTopInset = 6.0;
    formSheet.presentedFormSheetSize = CGSizeMake(320, 200);
    
    
    formSheet.willPresentCompletionHandler = ^(UIViewController *presentedFSViewController){
        presentedFSViewController.view.autoresizingMask = presentedFSViewController.view.autoresizingMask | UIViewAutoresizingFlexibleWidth;
    };
    
    [formSheet presentAnimated:YES completionHandler:^(UIViewController *presentedFSViewController) {
        
    }];
    
}

- (void)commonTasksViewControllerDidFinishWithTask:(NSString *)task
{
    self.taskTextField.text = task;
    self.taskLimit.text = [NSString stringWithFormat:@"%d characters left", 35 - self.taskTextField.text.length];
    textCheck = YES;
    [self configureDoneButton];
}

- (void)configureDoneButton
{
    self.doneButton.enabled = ((textCheck) && (descCheck));
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ((indexPath.section == 0) && (indexPath.row == 0)) {
        [self.taskTextField becomeFirstResponder];
        
    } else if ((indexPath.section == 0) && (indexPath.row == 2)) {
        if ([self.descTextView.text isEqualToString:descriptionPlaceholderText]) {
            self.descTextView.text = @"";
            self.descTextView.textColor = [UIColor blackColor];
        }
        self.descTextView.userInteractionEnabled = YES;
        [self.descTextView becomeFirstResponder];
    }
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
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


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"PickDate"]) {
        ReminderDateViewController *controller = [segue destinationViewController];
        controller.displayDate = self.dateLabel.text;
        controller.delegate = self;
    }
}

@end
