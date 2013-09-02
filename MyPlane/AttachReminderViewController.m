//
//  AttachReminderViewController.m
//  MyPlane
//
//  Created by Abhijay Bhatnagar on 8/30/13.
//  Copyright (c) 2013 Acubed Productions. All rights reserved.
//

#import "AttachReminderViewController.h"

@interface AttachReminderViewController ()

@end

@implementation AttachReminderViewController {
    NSString *descriptionPlaceholderText;
    NSDateFormatter *mainFormatter;
    NSDate *reminderDate;
    BOOL textCheck;
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

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    mainFormatter = [[NSDateFormatter alloc] init];
    [mainFormatter setDateStyle:NSDateFormatterShortStyle];
    [mainFormatter setTimeStyle:NSDateFormatterShortStyle];
    
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *components = [calendar components:NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit|NSHourCalendarUnit|NSMinuteCalendarUnit fromDate:[NSDate date]];
    [components setSecond:0];
    
    if (self.taskText.length > 0) {
        self.taskTextField.text = self.taskText;
        self.descriptionTextView.text = self.descText;
        self.dateLabel.text = [mainFormatter stringFromDate:self.dateText];
        reminderDate = self.dateText;
        textCheck = YES;
        int limit = 35 - self.taskText.length;
        self.limitLabel.text = [NSString stringWithFormat:@"%d characters left", limit];
        [self configureDoneButton];
    } else {
        reminderDate = [[calendar dateFromComponents:components] dateByAddingTimeInterval:1800];
        self.dateLabel.text = [mainFormatter stringFromDate:reminderDate];
        descriptionPlaceholderText = @"Enter more information about the reminder.";
        self.descriptionTextView.text = descriptionPlaceholderText;
        self.descriptionTextView.textColor = [UIColor lightGrayColor];
        textCheck = NO;
    }
    
    descCheck = YES;
    
    self.taskTextField.delegate = self;
    self.descriptionTextView.delegate = self;
    
    UITapGestureRecognizer *gestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideKeyboard)];
    [self.tableView addGestureRecognizer:gestureRecognizer];
    gestureRecognizer.cancelsTouchesInView = NO;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (IBAction)textValidation:(id)sender {
    NSString *removedSpaces = [self.taskTextField.text stringByReplacingOccurrencesOfString:@" " withString:@""];
    int limit = 35 - self.taskTextField.text.length;
    self.limitLabel.text = [NSString stringWithFormat:@"%d characters left", limit];
    if ((removedSpaces.length > 0) && (limit >= 0)) {
        textCheck = YES;
    } else {
        textCheck = NO;
    }
    
    [self configureDoneButton];
}

- (void)configureDoneButton
{
    if ((textCheck) && (descCheck)) {
        self.doneBarItem.enabled = YES;
    } else {
        self.doneBarItem.enabled = NO;
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
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
    
    
    [formSheet presentWithCompletionHandler:^(UIViewController *presentedFSViewController) {
        
        
    }];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"PickDate"]) {
        ReminderDateViewController *controller = [segue destinationViewController];
        controller.delegate = self;
        controller.displayDate = self.dateLabel.text;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ((indexPath.section == 0) && (indexPath.row == 0)) {
        [self.taskTextField becomeFirstResponder];
        
    } else if ((indexPath.section == 1) && (indexPath.row == 0)) {
        if ([self.descriptionTextView.text isEqualToString:descriptionPlaceholderText]) {
            self.descriptionTextView.text = @"";
            self.descriptionTextView.textColor = [UIColor blackColor];
        }
        self.descriptionTextView.userInteractionEnabled = YES;
        [self.descriptionTextView becomeFirstResponder];
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

- (void)commonTasksViewControllerDidFinishWithTask:(NSString *)task
{
    self.taskTextField.text = task;
    textCheck = YES;
    self.limitLabel.text = [NSString stringWithFormat:@"%d characters left", 35 - task.length];
    [self configureDoneButton];
}

- (void)hideKeyboard
{
    [self.taskTextField resignFirstResponder];
    [self.descriptionTextView resignFirstResponder];
}

- (IBAction)cancel:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)done:(id)sender
{
    NSString *removedSpaces = [self.descriptionTextView.text stringByReplacingOccurrencesOfString:@" " withString:@""];
    
    if (([self.descriptionTextView.text isEqualToString:descriptionPlaceholderText]) || (removedSpaces.length < 1)) {
        [self.delegate attachReminderViewController:self withTask:self.taskTextField.text withDescription:@"" withDate:[mainFormatter dateFromString:self.dateLabel.text] withFormatter:mainFormatter];
    } else {
        [self.delegate attachReminderViewController:self withTask:self.taskTextField.text withDescription:self.descriptionTextView.text withDate:[mainFormatter dateFromString:self.dateLabel.text] withFormatter:mainFormatter];
    }
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)textViewDidChange:(UITextView *)textView
{
    int limit = 250 - self.descriptionTextView.text.length;
    self.descLimit.text = [NSString stringWithFormat:@"%d characters left", limit];
    if ((limit >= 0)) {
        descCheck = YES;
    } else {
        descCheck = NO;
    }
    
    [self configureDoneButton];
}

@end
