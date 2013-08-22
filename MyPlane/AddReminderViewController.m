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
    PFObject *receivedObjectID;
//    UserInfo *recipient;
    NSString *descriptionPlaceholderText;
    NSDateFormatter *mainFormatter;
    NSDate *reminderDate;
    BOOL textCheck;
    BOOL friendCheck;
    BOOL isFromFriends;
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
    
    if (self.recipient) {
        friendCheck = YES;
        self.name.text = [NSString stringWithFormat:@"%@ %@", self.recipient.firstName, self.recipient.lastName];
        self.username.text = self.recipient.user;
        
        self.userImage.file = self.recipient.profilePicture;
        [self.userImage loadInBackground];
        self.friendCell.accessoryType = UITableViewCellAccessoryNone;
        self.friendCell.userInteractionEnabled = NO;
        self.segmentUIView.hidden = YES;
        self.segmentUIView.frame = CGRectMake(0,0,0,0);
        receivedObjectID = self.recipient;
    } else {
        self.name.hidden = YES;
        self.username.hidden = YES;
        self.userImage.hidden = YES;
        self.userFrame.hidden = YES;
        self.selectAFriendLabel.hidden = NO;
        self.friendCell.userInteractionEnabled = YES;
        friendCheck = NO;
    }
    
    [self configureViewController];
    
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
    self.segmentedControl.selectedColor = [UIColor colorFromHexCode:@"0A67A3"];
    self.segmentedControl.deselectedColor = [UIColor colorFromHexCode:@"3E97D1"];
    self.segmentedControl.dividerColor = [UIColor wetAsphaltColor];
    self.segmentedControl.cornerRadius = 15.0;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    [self.segmentedControl setSelectedSegmentIndex:0];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)done:(id)sender
{
    [self hideKeyboard];
    PFObject *reminder = [PFObject objectWithClassName:@"Reminders"];
    
    //[reminder setObject:[NSDate date] forKey:@"date"];
    [reminder setObject:reminderDate forKey:@"date"];
    [reminder setObject:self.taskTextField.text forKey:@"title"];
    [reminder setObject:self.username.text forKey:@"user"];
    [reminder setObject:self.currentUser forKey:@"fromFriend"];
    [reminder setObject:self.recipient forKey:@"recipient"];
    [reminder setObject:[PFUser currentUser].username forKey:@"fromUser"];
    if (![self.descriptionTextView.text isEqualToString:descriptionPlaceholderText]) {
        [reminder setObject:self.descriptionTextView.text forKey:@"description"];
    } else {
        [reminder setObject:@"No description available." forKey:@"description"];
    }

     
    [reminder saveEventually:^(BOOL succeeded, NSError *error) {
        [SVProgressHUD showSuccessWithStatus:@"Reminder Sent!"];
        NSString *message = [NSString stringWithFormat:@"New Reminder: %@ from: %@", self.taskTextField.text, self.currentUser.user];
        NSDictionary *data = @{
                               @"r": @"n"
                               };
        
        PFQuery *pushQuery = [PFInstallation query];
        [pushQuery whereKey:@"user" equalTo:self.recipient.user];
        
        PFPush *push = [[PFPush alloc] init];
        [push setQuery:pushQuery];
        [push setData:data];
        [push setMessage:message];
        [push sendPushInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            NSString *success = [NSString stringWithFormat:@"%@ has Received the reminder", self.recipient.user];
            [SVProgressHUD showSuccessWithStatus:success];
        }];
       
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

-(void)friendsForReminders:(FriendsForRemindersViewController *)controller didFinishSelectingContactWithUsername:(NSString *)username withName:(NSString *)name withProfilePicture:(UIImage *)image withObjectId:(PFObject *)objectID selfUserObject:(UserInfo *)userObject
{
    [self dismissViewControllerAnimated:YES completion:nil];
    self.name.text = name;
    self.username.text = username;
    self.userImage.image = image;
    receivedObjectID = objectID;
    self.currentUser = userObject;
    friendCheck = YES;
    self.recipient = [UserInfo objectWithoutDataWithObjectId:receivedObjectID.objectId];
    self.name.hidden = NO;
    self.userImage.hidden = NO;
    self.userFrame.hidden = NO;
    self.username.hidden = NO;
    self.selectAFriendLabel.hidden = YES;
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
            self.selectAFriendLabel.font = [UIFont flatFontOfSize:17];
            self.name.font = [UIFont flatFontOfSize:16];
            self.username.font = [UIFont flatFontOfSize:14];
        }
    } else {
        self.descriptionLabel.font = [UIFont boldFlatFontOfSize:16];
        self.descriptionTextView.font = [UIFont flatFontOfSize:14];
    }
    
    return cell;
    
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


- (IBAction)segmentChanged:(id)sender {
    if (self.segmentedControl.selectedSegmentIndex == 1) {
        [self performSegueWithIdentifier:@"CircleReminder" sender:nil];
    }
}

- (void)hideKeyboard
{
    [self.taskTextField resignFirstResponder];
    [self.descriptionTextView resignFirstResponder];
}

@end
