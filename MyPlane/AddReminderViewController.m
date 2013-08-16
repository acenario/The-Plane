//
//  AddReminderViewController.m
//  MyPlane
//
//  Created by Abhijay Bhatnagar on 7/8/13.
//  Copyright (c) 2013 Acubed Productions. All rights reserved.
//

#import "AddReminderViewController.h"
#import "MZFormSheetController.h"

@interface AddReminderViewController ()

@end

@implementation AddReminderViewController {
    NSString *nameOfUser;
    PFObject *recievedObjectID;
    UserInfo *recipient;
    NSString *descriptionPlaceholderText;
    NSDateFormatter *mainFormatter;
    NSDate *reminderDate;
    BOOL textCheck;
    BOOL friendCheck;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
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
    
    reminderDate = [[calendar dateFromComponents:components] dateByAddingTimeInterval:300];
    self.dateDetail.text = [mainFormatter stringFromDate:reminderDate];
    
    descriptionPlaceholderText = @"Enter more information about the reminder.";
    self.descriptionTextView.text = descriptionPlaceholderText;
    self.descriptionTextView.textColor = [UIColor lightGrayColor];
    
    self.taskTextField.delegate = self;
    
    textCheck = NO;
    friendCheck = NO;
    // Do any additional setup after loading the view.
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)done:(id)sender
{
    PFObject *reminder = [PFObject objectWithClassName:@"Reminders"];
    
    //[reminder setObject:[NSDate date] forKey:@"date"];
    [reminder setObject:reminderDate forKey:@"date"];
    [reminder setObject:self.taskTextField.text forKey:@"title"];
    [reminder setObject:self.username.text forKey:@"user"];
    [reminder setObject:recievedObjectID forKey:@"fromFriend"];
    [reminder setObject:recipient forKey:@"recipient"];
    [reminder setObject:[PFUser currentUser].username forKey:@"fromUser"];
    if (![self.descriptionTextView.text isEqualToString:descriptionPlaceholderText]) {
        [reminder setObject:self.descriptionTextView.text forKey:@"description"];
    } else {
        [reminder setObject:@"No description available." forKey:@"description"];
    }

     
    [reminder saveEventually:^(BOOL succeeded, NSError *error) {
        [SVProgressHUD showSuccessWithStatus:@"Reminder Sent!"];
       
    }];
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)cancel:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)textValidation:(id)sender {
    if ([self.taskTextField.text length] > 0) {
        textCheck = YES;
    } else {
        textCheck = NO;
    }
    [self configureDoneButton];
}

- (void)configureDoneButton
{
    if ((textCheck) && (friendCheck)) {
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

-(void)friendsForReminders:(FriendsForRemindersViewController *)controller didFinishSelectingContactWithUsername:(NSString *)username withName:(NSString *)name withProfilePicture:(UIImage *)image withObjectId:(PFObject *)objectID
{
    [self dismissViewControllerAnimated:YES completion:nil];
    self.name.text = name;
    self.username.text = username;
    self.userImage.image = image;
    recievedObjectID = objectID;
    friendCheck = YES;
    recipient = [UserInfo objectWithoutDataWithObjectId:recievedObjectID.objectId];
    [self configureDoneButton];
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"FriendsForReminders"]) {
        FriendsForRemindersViewController *controller = [segue destinationViewController];
        controller.delegate = self;
    } else if ([segue.identifier isEqualToString:@"ReminderDate"]) {
        ReminderDateViewController *controller = [segue destinationViewController];
        controller.delegate = self;
        controller.displayDate = self.dateDetail.text;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ((indexPath.section == 0) && (indexPath.row == 0)) {
        [self.taskTextField becomeFirstResponder];
        
        [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
        
    } else if ((indexPath.section == 0) && (indexPath.row == 1)) {
        if ([self.descriptionTextView.text isEqualToString:descriptionPlaceholderText]) {
            self.descriptionTextView.text = @"";
            self.descriptionTextView.textColor = [UIColor blackColor];
        }
        
        self.descriptionTextView.userInteractionEnabled = YES;
        [self.descriptionTextView becomeFirstResponder];
        
        [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    }
}

- (void)reminderDateViewController:(ReminderDateViewController *)controller didFinishSelectingDate:(NSDate *)date
{
    reminderDate = date;
    self.dateDetail.text = [mainFormatter stringFromDate:date];
}

- (void)reminderViewControllerDidCancel:(ReminderDateViewController *)controller
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(IBAction)showCommon:(id)sender {
    UIViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"commonTasks"];
    
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


@end
