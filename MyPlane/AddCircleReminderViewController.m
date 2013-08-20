//
//  AddCircleReminderViewController.m
//  MyPlane
//
//  Created by Abhijay Bhatnagar on 8/19/13.
//  Copyright (c) 2013 Acubed Productions. All rights reserved.
//

#import "AddCircleReminderViewController.h"

@interface AddCircleReminderViewController ()

@property (nonatomic, strong) NSArray *invitedMembers;
@property (nonatomic, strong) NSArray *invitedUsernames;

@end

@implementation AddCircleReminderViewController {
    BOOL isFromCircles;
    NSString *nameOfUser;
    NSString *descriptionPlaceholderText;
    NSDateFormatter *mainFormatter;
    NSDate *reminderDate;
    BOOL textCheck;
    BOOL circleCheck;
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
    if (self.circle != nil) {
        self.circleName.text = self.circle.name;
        self.memberCountDisplay.text = @"Select members...";
        isFromCircles = YES;
    } else {
        self.circleName.hidden = YES;
        self.memberCountDisplay.hidden = YES;
        self.circleLeftLabel.text = @"Pick a circle...";
        isFromCircles = NO;
    }
    
    [self.segmentedControl setSelectedSegmentIndex:1];
    
    mainFormatter = [[NSDateFormatter alloc] init];
    [mainFormatter setDateStyle:NSDateFormatterShortStyle];
    [mainFormatter setTimeStyle:NSDateFormatterShortStyle];
    
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *components = [calendar components:NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit|NSHourCalendarUnit|NSMinuteCalendarUnit fromDate:[NSDate date]];
    [components setSecond:0];
    
    reminderDate = [[calendar dateFromComponents:components] dateByAddingTimeInterval:300];
    self.dateTextLabel.text = [mainFormatter stringFromDate:reminderDate];
    
    descriptionPlaceholderText = @"Enter more information about the reminder.";
    self.descriptionTextView.text = descriptionPlaceholderText;
    self.descriptionTextView.textColor = [UIColor lightGrayColor];
    
    self.taskTextField.delegate = self;
    
    textCheck = NO;
    circleCheck = NO;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source


#pragma mark - Table view delegate

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"PickCircle"]) {
        ACRPickCircleViewController *controller = [segue destinationViewController];
        controller.delegate = self;
        controller.circles = self.circles;
        controller.currentUser = self.currentUser;
    } else if ([segue.identifier isEqualToString:@"PickMembers"]) {
        UINavigationController *nav = (UINavigationController *)[segue destinationViewController];
        PickMembersViewController *controller = (PickMembersViewController *)nav.topViewController;
        controller.delegate = self;
        controller.circle = self.circle;
        controller.currentUser = self.currentUser;
    } else if ([segue.identifier isEqualToString:@"PickDate"]) {
        ReminderDateViewController *controller = [segue destinationViewController];
        controller.delegate = self;
        controller.displayDate = self.dateTextLabel.text;
    }
}

- (void)pickMembersViewController:(PickMembersViewController *)controller didFinishPickingMembers:(NSArray *)members withUsernames:(NSArray *)usernames
{
    self.invitedMembers = [[NSArray alloc] initWithArray:members];
    self.invitedUsernames = [[NSArray alloc] initWithArray:usernames];
    circleCheck = YES;
    
    [self configureDoneButton];
    [self.tableView reloadData];
}

- (IBAction)cancel:(id)sender {
    if (isFromCircles) {
        [self dismissViewControllerAnimated:YES completion:nil];
    } else {
        [self performSegueWithIdentifier:@"UnwindToReminders" sender:nil];
    }
}

- (IBAction)done:(id)sender {
    [self.delegate addCircleReminderViewController:self
                   didFinishAddingReminderInCircle:self.circle
                                         withUsers:self.invitedMembers
                                          withTask:self.taskTextField.text
                                   withDescription:self.descriptionTextView.text
                                          withDate:reminderDate
     ];
}

- (IBAction)validateText:(id)sender {
    if ([self.taskTextField.text length] > 0) {
        textCheck = YES;
    } else {
        textCheck = NO;
    }
    [self configureDoneButton];
}

- (void)configureDoneButton
{
    if ((textCheck) && (circleCheck)) {
        self.doneButton.enabled = YES;
    } else {
        self.doneButton.enabled = NO;
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ((indexPath.section == 0) && (indexPath.row == 0)) {
        [self.taskTextField becomeFirstResponder];
        
        [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
        
    } else if ((indexPath.section == 1) && (indexPath.row == 0)) {
        if ([self.descriptionTextView.text isEqualToString:descriptionPlaceholderText]) {
            self.descriptionTextView.text = @"";
            self.descriptionTextView.textColor = [UIColor blackColor];
        }
        
        self.descriptionTextView.userInteractionEnabled = YES;
        [self.descriptionTextView becomeFirstResponder];
        
        [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    } else if ((indexPath.section == 0) && (indexPath.row == 2)) {
            if (isFromCircles) {
                [self performSegueWithIdentifier:@"PickMembers" sender:nil];
            } else {
                [self performSegueWithIdentifier:@"PickCircle" sender:nil];
            }
        }
}

- (void)reminderDateViewController:(ReminderDateViewController *)controller didFinishSelectingDate:(NSDate *)date
{
    reminderDate = date;
    self.dateTextLabel.text = [mainFormatter stringFromDate:date];
    [self.tableView reloadData];
}

- (void)reminderViewControllerDidCancel:(ReminderDateViewController *)controller
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)segmentChange:(id)sender {
    if (self.segmentedControl.selectedSegmentIndex == 0) {
        [self dismissViewControllerAnimated:NO completion:nil];
    }
}

@end
