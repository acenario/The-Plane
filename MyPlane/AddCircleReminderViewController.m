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
    PFQuery *currentUserQuery;
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
        self.segmentView.hidden = YES;
        self.segmentView.frame = CGRectMake(0,0,0,0);
        self.view.autoresizesSubviews = NO;
    } else {
        self.circleName.hidden = YES;
        self.memberCountDisplay.hidden = YES;
        self.circleLeftLabel.text = @"Pick a circle...";
        isFromCircles = NO;
        currentUserQuery = [UserInfo query];
        [currentUserQuery whereKey:@"user" equalTo:[PFUser currentUser].username];
        [currentUserQuery getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error) {
            self.currentUser = (UserInfo *)object;
        }];
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

#pragma mark - Table View Methods

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

#pragma mark - Text Field Methods

- (IBAction)validateText:(id)sender {
    if ([self.taskTextField.text length] > 0) {
        textCheck = YES;
    } else {
        textCheck = NO;
    }
    [self configureDoneButton];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

#pragma mark - Delegate Methods

#pragma mark Date Delegate

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

#pragma mark Pick Members Delegate

- (void)pickMembersViewController:(PickMembersViewController *)controller didFinishPickingMembers:(NSArray *)members withUsernames:(NSArray *)usernames withCircle:(Circles *)circle
{
    self.invitedMembers = [[NSArray alloc] initWithArray:members];
    self.invitedUsernames = [[NSArray alloc] initWithArray:usernames];
    circleCheck = YES;
    
    [self configureDoneButton];
    [self.tableView reloadData];
}

#pragma mark Pick Circle Delegate

- (void)acrPickCircleViewController:(ACRPickCircleViewController *)controller didFinishPickingMembers:(NSArray *)members withUsernames:(NSArray *)usernames withCircle:(Circles *)circle
{
    NSLog(@"test");
    self.invitedMembers = [[NSArray alloc] initWithArray:members];
    self.invitedUsernames = [[NSArray alloc] initWithArray:usernames];
    self.circle = circle;
    circleCheck = YES;
    
    [self configureDoneButton];
    [self.tableView reloadData];
}

#pragma mark - Bar Button Methods

- (IBAction)cancel:(id)sender {
    if (isFromCircles) {
        [self dismissViewControllerAnimated:YES completion:nil];
    } else {
        [self performSegueWithIdentifier:@"UnwindToReminders" sender:nil];
    }
}

- (IBAction)done:(id)sender {
    if (isFromCircles) {
        [self.delegate addCircleReminderViewController:self
                       didFinishAddingReminderInCircle:self.circle
                                             withUsers:self.invitedMembers
                                              withTask:self.taskTextField.text
                                       withDescription:self.descriptionTextView.text
                                              withDate:reminderDate
         ];
    } else {
        [self didFinishAddingReminderInCircle:self.circle
                                    withUsers:self.invitedMembers
                                     withTask:self.taskTextField.text
                              withDescription:self.descriptionTextView.text
                                     withDate:reminderDate
         ];
    }
}

#pragma mark - Other Methods

- (void)configureDoneButton
{
    if ((textCheck) && (circleCheck)) {
        self.doneButton.enabled = YES;
    } else {
        self.doneButton.enabled = NO;
    }
}



- (IBAction)segmentChange:(id)sender {
    if (self.segmentedControl.selectedSegmentIndex == 0) {
        [self dismissViewControllerAnimated:NO completion:nil];
    }
}

- (void)didFinishAddingReminderInCircle:(Circles *)circle withUsers:(NSArray *)users withTask:(NSString *)task withDescription:(NSString *)description withDate:(NSDate *)date
{
    NSMutableArray *toSave = [[NSMutableArray alloc] init];
    
    for (UserInfo *user in users) {
        Reminders *reminder = [Reminders object];
        reminder.date = date;
        reminder.description = description;
        reminder.fromFriend = self.currentUser;
        reminder.fromUser = self.currentUser.user;
        reminder.recipient = user;
        reminder.title = task;
        reminder.user = user.user;
        [reminder setObject:circle forKey:@"circle"];
        [toSave addObject:reminder];
    }
    
    [SVProgressHUD showWithStatus:@"Sending Reminders..."];
    [Reminders saveAllInBackground:toSave block:^(BOOL succeeded, NSError *error) {
        for (Reminders *reminder in toSave) {
            PFRelation *relation = [circle relationforKey:@"remTest"];
            [relation addObject:reminder];
        }
        [self.circle saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            [SVProgressHUD showSuccessWithStatus:[NSString stringWithFormat:@"Reminder Sent to %d Members of %@", toSave.count, circle.name]];
            wait((int *)1);
            [self performSegueWithIdentifier:@"UnwindToReminders" sender:nil];
        }];
    }];
}


#pragma mark - Segue Methods

- (IBAction)unwindToAddCircleReminder:(UIStoryboardSegue *)unwindSegue;
{
    //    UIViewController* sourceViewController = unwindSegue.sourceViewController;
    
    //    if ([sourceViewController isKindOfClass:[AddCircleReminderViewController class]]) {
    //        [self.delegate addCircleReminderViewController:self
    //                       didFinishAddingReminderInCircle:self.circle
    //                                             withUsers:self.invitedMembers
    //                                              withTask:self.taskTextField.text
    //                                       withDescription:self.descriptionTextView.text
    //                                              withDate:reminderDate
    //         ];
    //    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"PickCircle"]) {
        ACRPickCircleViewController *controller = [segue destinationViewController];
        controller.delegate = self;
        controller.currentUserQuery = currentUserQuery;
    } else if ([segue.identifier isEqualToString:@"PickMembers"]) {
        UINavigationController *nav = (UINavigationController *)[segue destinationViewController];
        PickMembersViewController *controller = (PickMembersViewController *)nav.topViewController;
        controller.delegate = self;
        controller.circle = self.circle;
        controller.isFromCircles = isFromCircles;
    } else if ([segue.identifier isEqualToString:@"PickDate"]) {
        ReminderDateViewController *controller = [segue destinationViewController];
        controller.delegate = self;
        controller.displayDate = self.dateTextLabel.text;
    }
}

@end
