//
//  AddCircleReminderViewController.m
//  MyPlane
//
//  Created by Abhijay Bhatnagar on 8/19/13.
//  Copyright (c) 2013 Acubed Productions. All rights reserved.
//

#import "AddCircleReminderViewController.h"

@interface AddCircleReminderViewController ()

@end

@implementation AddCircleReminderViewController {
    BOOL isFromCircles;
    NSString *nameOfUser;
    NSString *descriptionPlaceholderText;
    NSDateFormatter *mainFormatter;
    NSDate *reminderDate;
    BOOL textCheck;
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
        self.memberCountDisplay.hidden = YES;
        self.circleName.text = @"Pick a circle...";
        isFromCircles = NO;
        currentUserQuery = [UserInfo query];
        [currentUserQuery whereKey:@"user" equalTo:[PFUser currentUser].username];
        currentUserQuery.cachePolicy = kPFCachePolicyCacheElseNetwork;
        [currentUserQuery getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error) {
            self.currentUser = (UserInfo *)object;
        }];
    }
    
    [self.segmentedControl setSelectedSegmentIndex:1];
    [self configureViewController];
    
    mainFormatter = [[NSDateFormatter alloc] init];
    [mainFormatter setDateStyle:NSDateFormatterShortStyle];
    [mainFormatter setTimeStyle:NSDateFormatterShortStyle];
    
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *components = [calendar components:NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit|NSHourCalendarUnit|NSMinuteCalendarUnit fromDate:[NSDate date]];
    [components setSecond:0];
    
    reminderDate = [[calendar dateFromComponents:components] dateByAddingTimeInterval:300];
    self.dateTextLabel.text = [mainFormatter stringFromDate:reminderDate];
    
    descriptionPlaceholderText = @"Enter more information about the reminder...";
    self.descriptionTextView.text = descriptionPlaceholderText;
    self.descriptionTextView.textColor = [UIColor lightGrayColor];
    
    self.taskTextField.delegate = self;
    
    textCheck = NO;
    if (!(self.invitedMembers)) {
        self.circleCheck = NO;
    } else {
        NSLog(@"test, ");
        self.circleName.text = self.circle.name;
        self.memberCountDisplay.hidden = NO;
        self.circleCell.userInteractionEnabled = NO;
        self.memberCountDisplay.text = [NSString stringWithFormat:@"%d members", self.invitedMembers.count];
    }
    
    UITapGestureRecognizer *gestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideKeyboard)];
    [self.tableView addGestureRecognizer:gestureRecognizer];
    gestureRecognizer.cancelsTouchesInView = NO;
}

-(void)configureViewController {
    UIImageView *av = [[UIImageView alloc] init];
    av.backgroundColor = [UIColor clearColor];
    av.opaque = NO;
    UIImage *background = [UIImage imageNamed:@"tableBackground"];
    av.image = background;
    
    self.tableView.backgroundView = av;
    
    self.segmentedControl.selectedFont = [UIFont boldFlatFontOfSize:16];
    self.segmentedControl.selectedFontColor = [UIColor cloudsColor];
    self.segmentedControl.deselectedFont = [UIFont flatFontOfSize:16];
    self.segmentedControl.deselectedFontColor = [UIColor cloudsColor];
//    self.segmentedControl.selectedColor = [UIColor colorFromHexCode:@"0A67A3"];
//    self.segmentedControl.deselectedColor = [UIColor colorFromHexCode:@"3E97D1"];
//    self.segmentedControl.dividerColor = [UIColor colorFromHexCode:@"0A67A3"];
    self.segmentedControl.selectedColor = [UIColor colorFromHexCode:@"FF7140"];
    self.segmentedControl.deselectedColor = [UIColor colorFromHexCode:@"FF9773"];
    self.segmentedControl.dividerColor = [UIColor colorFromHexCode:@"FF7140"];
    self.segmentedControl.cornerRadius = 15.0;

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
    } else if ((indexPath.section == 0) && (indexPath.row == 2)) {
        if (isFromCircles) {
            [self performSegueWithIdentifier:@"PickMembers" sender:nil];
        } else {
            [self performSegueWithIdentifier:@"PickCircle" sender:nil];
        }
        [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    } else if ((indexPath.section == 1) && (indexPath.row == 0)) {
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

-(UITableViewCell *)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    UIColor *selectedColor = [UIColor colorFromHexCode:@"FF7140"];
    
    UIImageView *av = [[UIImageView alloc] init];
    av.backgroundColor = [UIColor clearColor];
    av.opaque = NO;
    UIImage *background = [UIImage imageWithColor:[UIColor whiteColor] cornerRadius:1.0f];
    av.image = background;
    cell.backgroundView = av;
    
    
    UIView *bgView = [[UIView alloc]init];
    bgView.backgroundColor = selectedColor;
    
    
    [cell setSelectedBackgroundView:bgView];
    
    UIImageView *imgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"separator2"]];
    imgView.frame = CGRectMake(-1, (cell.frame.size.height - 1), 302, 1);
    
    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            
            self.taskInd.font = [UIFont flatFontOfSize:16];
            self.taskTextField.font = [UIFont flatFontOfSize:14];
            
            
            [cell.contentView addSubview:imgView];
            
        } else if (indexPath.row == 1) {
            cell.textLabel.font = [UIFont flatFontOfSize:16];
            cell.detailTextLabel.font = [UIFont flatFontOfSize:16];
            cell.textLabel.backgroundColor = [UIColor whiteColor];
            cell.detailTextLabel.backgroundColor = [UIColor whiteColor];
            
            [cell.contentView addSubview:imgView];
            
        } else {
            cell.textLabel.font = [UIFont flatFontOfSize:16];
            cell.detailTextLabel.font = [UIFont flatFontOfSize:16];
            cell.textLabel.backgroundColor = [UIColor whiteColor];
            cell.detailTextLabel.backgroundColor = [UIColor whiteColor];
        }
    } else {
        self.descriptionLabel.font = [UIFont boldFlatFontOfSize:16];
        self.descriptionTextView.font = [UIFont flatFontOfSize:14];
    }
    
    return cell;
    
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
    self.memberCountDisplay.text = [NSString stringWithFormat:@"%d members", self.invitedMembers.count];
    self.circleCheck = YES;
    
    [self configureDoneButton];
    [self.tableView reloadData];
}

#pragma mark Pick Circle Delegate

- (void)acrPickCircleViewController:(ACRPickCircleViewController *)controller didFinishPickingMembers:(NSArray *)members withUsernames:(NSArray *)usernames withCircle:(Circles *)circle
{
    self.invitedMembers = [[NSArray alloc] initWithArray:members];
    self.invitedUsernames = [[NSArray alloc] initWithArray:usernames];
    self.circle = circle;
    self.circleName.text = circle.name;
    self.memberCountDisplay.hidden = NO;
    self.memberCountDisplay.text = [NSString stringWithFormat:@"%d members", self.invitedMembers.count];
    self.circleCheck = YES;
    
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

- (IBAction)showCommon:(id)sender {
    UINavigationController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"commonTasks"];
    CommonTasksViewController *cVC = (CommonTasksViewController *)[vc topViewController];
    cVC.delegate = self;
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

#pragma mark - Other Methods

- (void)configureDoneButton
{
    if ((textCheck) && (self.circleCheck)) {
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
        if (![self.descriptionTextView.text isEqualToString:descriptionPlaceholderText]) {
            [reminder setObject:self.descriptionTextView.text forKey:@"description"];
        } else {
            [reminder setObject:@"No description available." forKey:@"description"];
        }
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
            PFRelation *relation = [circle relationforKey:@"reminders"];
            [relation addObject:reminder];
        }
        [self.circle saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            [SVProgressHUD showSuccessWithStatus:[NSString stringWithFormat:@"Reminder Sent to %d Members of %@", toSave.count, circle.name]];
            wait((int *)1);
            [self performSegueWithIdentifier:@"UnwindToReminders" sender:nil];
        }];
    }];
}

- (void)hideKeyboard
{
    [self.taskTextField resignFirstResponder];
    [self.descriptionTextView resignFirstResponder];
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

- (void)commonTasksViewControllerDidFinishWithTask:(NSString *)task
{
    self.taskTextField.text = task;
    textCheck = YES;
    [self hideKeyboard];
}

@end
