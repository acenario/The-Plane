//
//  AddReminderViewController.m
//  MyPlane
//
//  Created by Abhijay Bhatnagar on 7/8/13.
//  Copyright (c) 2013 Acubed Productions. All rights reserved.
//

#import "AddReminderViewController.h"
#import "MZFormSheetController.h"
#import "CommonTasksViewController.h"

@interface AddReminderViewController ()

@property (nonatomic, strong) Circles *retainedCircle;
@property (nonatomic, strong) NSArray *retainedUsers;
@property (nonatomic, strong) PFQuery *retainedQuery;

@end

@implementation AddReminderViewController {
    NSString *nameOfUser;
    NSString *descriptionPlaceholderText;
    
    NSDateFormatter *mainFormatter;
    NSDate *reminderDate;
    
    NSArray *batchFriends;
    
    ///Checks if text is less than or equal to 35 characters and isn't just spaces.
    BOOL textCheck;
    BOOL descCheck;
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
    
    mainFormatter = [[NSDateFormatter alloc] init];
    [mainFormatter setDateStyle:NSDateFormatterShortStyle];
    [mainFormatter setTimeStyle:NSDateFormatterShortStyle];

    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *components = [calendar components:NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit|NSHourCalendarUnit|NSMinuteCalendarUnit fromDate:[NSDate date]];
    [components setSecond:0];
    
    reminderDate = [[calendar dateFromComponents:components] dateByAddingTimeInterval:300];
    self.dateDetail.text = [mainFormatter stringFromDate:reminderDate];
    
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
//        receivedObjectID = self.recipient;
    } else {
        if (self.templateReminder) {
            self.taskTextField.text = self.templateReminder.title;
            self.descriptionTextView.text = [self.templateReminder objectForKey:@"description"];
            [self textViewDidChange:self.descriptionTextView];
            
//            self.segmentUIView.hidden = YES;
//            self.segmentUIView.frame = CGRectMake(0,0,0,0);
        }
        self.name.hidden = YES;
        self.username.hidden = YES;
        self.userImage.hidden = YES;
        self.userFrame.hidden = YES;
        self.selectAFriendLabel.hidden = NO;
        self.friendCell.userInteractionEnabled = YES;
        friendCheck = NO;
    }
    
    [self configureViewController];
    
    
    if (self.descriptionTextView.text.length == 0) {
        descriptionPlaceholderText = @"Enter more information about the reminder...";
        
        self.descriptionTextView.text = descriptionPlaceholderText;
        self.descriptionTextView.textColor = [UIColor lightGrayColor];
    }
    
    self.taskTextField.delegate = self;
    self.descriptionTextView.delegate = self;
    
    if (self.taskTextField.text.length == 0) {
        
        self.limitLabel.hidden = YES;
        textCheck = NO;
    } else {
        [self textValidation:nil];
    }
    descCheck = YES;
    
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

#pragma mark - Table View Methods

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

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
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
    
    UIImageView *bottomView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"separator2"]];
    bottomView.frame = CGRectMake(-1, -1, 302, 1);
    
    
    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            
            self.taskInd.font = [UIFont flatFontOfSize:16];
            self.taskTextField.font = [UIFont flatFontOfSize:14];
            self.limitLabel.font = [UIFont flatFontOfSize:14];
            
            self.limitLabel.adjustsFontSizeToFitWidth = YES;
            
            self.commonTasks.buttonColor = [UIColor colorFromHexCode:@"FF7140"];
            self.commonTasks.shadowColor = [UIColor colorFromHexCode:@"FF9773"];
            self.commonTasks.shadowHeight = 2.0f;
            self.commonTasks.cornerRadius = 3.0f;
            self.commonTasks.titleLabel.font = [UIFont boldFlatFontOfSize:15];
            
            [self.commonTasks setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            [self.commonTasks setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
            
            
            
            [cell.contentView addSubview:imgView];
            
        } else if (indexPath.row == 1) {
            cell.textLabel.font = [UIFont flatFontOfSize:16];
            cell.detailTextLabel.font = [UIFont flatFontOfSize:16];
            cell.textLabel.backgroundColor = [UIColor whiteColor];
            cell.detailTextLabel.backgroundColor = [UIColor whiteColor];
            
            [cell.contentView addSubview:bottomView];
            [cell.contentView addSubview:imgView];
            
        } else {
            self.selectAFriendLabel.font = [UIFont flatFontOfSize:17];
            self.name.font = [UIFont flatFontOfSize:16];
            self.username.font = [UIFont flatFontOfSize:14];
        }
    } else {
        self.descriptionLabel.font = [UIFont flatFontOfSize:16];
        self.descriptionTextView.font = [UIFont flatFontOfSize:14];
        self.descLabel.font = [UIFont flatFontOfSize:14];
        self.descLabel.adjustsFontSizeToFitWidth = YES;
    }
    
    
}

#pragma mark - Textfield/view Methods

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

- (IBAction)textValidation:(id)sender {
    self.limitLabel.hidden = NO;
    NSString *removedSpaces = [self.taskTextField.text stringByReplacingOccurrencesOfString:@" " withString:@""];
    int limit = 35 - self.taskTextField.text.length;
    self.limitLabel.text = [NSString stringWithFormat:@"%d", limit];
    if ((removedSpaces.length > 0) && (limit >= 0)) {
        textCheck = YES;
    } else {
        textCheck = NO;
        self.limitLabel.textColor = [UIColor redColor];
    }
    
    if (limit >= 0) {
        self.limitLabel.textColor = [UIColor lightGrayColor];
    }
    
    [self configureDoneButton];
}

- (void)textViewDidChange:(UITextView *)textView
{
    int limit = 250 - self.descriptionTextView.text.length;
    self.descLabel.text = [NSString stringWithFormat:@"%d characters left", limit];
    if ((limit >= 0)) {
        descCheck = YES;
        self.descLabel.textColor = [UIColor lightGrayColor];
    } else {
        descCheck = NO;
        self.descLabel.textColor = [UIColor redColor];
    }
    
    [self configureDoneButton];
}

#pragma mark - Button Methods

- (void)done:(id)sender
{
    [self hideKeyboard];
    
    if (!batchFriends.count) {
        
        Reminders *reminder = [Reminders object];
        //[reminder. = [NSDate date]  date"];
        reminder.date = reminderDate;
        
        reminder.title = self.taskTextField.text;
        reminder.user = self.username.text;
        reminder.fromUser = [PFUser currentUser].username;
        
        reminder.fromFriend = self.currentUser;
        reminder.recipient = self.recipient;
        
        reminder.popularity = 0;
        reminder.state = 0;
        reminder.amountOfChildren = 0;
        
        reminder.archived = NO;
        reminder.isChild = NO;
        reminder.isParent = NO;
        reminder.isShared = NO;

        NSString *removedSpaces = [self.descriptionTextView.text stringByReplacingOccurrencesOfString:@" " withString:@""];
        
        if (!([self.descriptionTextView.text isEqualToString:descriptionPlaceholderText]) && (removedSpaces.length > 0)) {
            reminder.description = self.descriptionTextView.text;
        } else {
            reminder.description = @"";
        }
        
        
        [reminder saveEventually:^(BOOL succeeded, NSError *error) {
            [SVProgressHUD showSuccessWithStatus:@"Reminder Sent!"];
            
            if (self.templateReminder) {
                [self.templateReminder incrementKey:@"popularity"];
                [self.templateReminder saveEventually];
            }
            
            NSString *message = [NSString stringWithFormat:@"New Reminder: %@ from: %@", self.taskTextField.text, self.currentUser.user];
            NSDictionary *data = [NSDictionary dictionaryWithObjectsAndKeys:
                                  message, @"alert",
                                  @"n", @"r",
                                  @"alertSound.caf", @"sound",
                                  nil];
            //        NSDictionary *data = @{
            //                               @"r": @"n",
            //                               @"alertSound.caf": @"sound"
            //                               };
            
            PFQuery *pushQuery = [PFInstallation query];
            [pushQuery whereKey:@"user" equalTo:self.recipient.user];
            
            PFPush *push = [[PFPush alloc] init];
            [push setQuery:pushQuery];
            [push setData:data];
            //[push setMessage:message];
            [push sendPushInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                if (succeeded) {
                    NSString *success = [NSString stringWithFormat:@"%@ has received the reminder", self.recipient.firstName];
                    [SVProgressHUD showSuccessWithStatus:success];
                } else {
                    NSLog(@"%@", error);
                }
            }];
            
        }];
    } else {
        
        Reminders *parentReminder = [Reminders object];
        
        parentReminder.isParent = YES;
        parentReminder.isChild = NO;
        parentReminder.date = reminderDate;
        parentReminder.title = self.taskTextField.text;
        parentReminder.user = @"group";
        parentReminder.fromFriend = self.currentUser;
        parentReminder.recipient = self.recipient;
        parentReminder.fromUser = [PFUser currentUser].username;
        parentReminder.archived = NO;
        parentReminder.popularity = 0;
        parentReminder.state = 0;
        parentReminder.amountOfChildren = batchFriends.count;
        parentReminder.isShared = YES;
        
        
        NSString *removedSpaces = [self.descriptionTextView.text stringByReplacingOccurrencesOfString:@" " withString:@""];
        
        if (!([self.descriptionTextView.text isEqualToString:descriptionPlaceholderText]) && (removedSpaces.length > 0)) {
            parentReminder.description = self.descriptionTextView.text;
        } else {
            parentReminder.description = @"";
        }
        
        [parentReminder saveEventually:^(BOOL succeeded, NSError *error) {
            
            if (self.templateReminder) {
                [self.templateReminder incrementKey:@"popularity"];
                [self.templateReminder saveEventually];
            }
            
            NSMutableArray *remindersToSave = [[NSMutableArray alloc] initWithCapacity:batchFriends.count];
            
            for (UserInfo *friend in batchFriends) {
                Reminders *childReminder = [Reminders object];
                
                childReminder.isParent = NO;
                childReminder.isChild = YES;
                childReminder.date = reminderDate;
                childReminder.recipient = friend;
                childReminder.user = friend.user;
                childReminder.fromFriend = self.currentUser;
                childReminder.fromUser = [PFUser currentUser].username;
                childReminder.archived = NO;
                childReminder.popularity = 0;
                childReminder.title = self.taskTextField.text;
                childReminder.state = 0;
                childReminder.amountOfChildren = 0;
                childReminder.isShared = YES;
                
                if (!([self.descriptionTextView.text isEqualToString:descriptionPlaceholderText]) && (removedSpaces.length > 0)) {
                    childReminder.description = self.descriptionTextView.text;
                } else {
                    childReminder.description = @"";
                }
                
                childReminder.parent = parentReminder;
                
                [remindersToSave addObject:childReminder];
            }
            
            [Reminders saveAllInBackground:remindersToSave block:^(BOOL succeeded, NSError *error) {
                
                [SVProgressHUD showSuccessWithStatus:@"Reminder Sent!"];
            }];
        }];
        
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)cancel:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)configureDoneButton
{
    
    if ((textCheck) && (friendCheck) && (descCheck)) {
        self.doneBarItem.enabled = YES;
    } else {
        self.doneBarItem.enabled = NO;
    }
}

-(IBAction)showCommon:(id)sender {
    UINavigationController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"commonTasks"];
    CommonTasksViewController *cVC = (CommonTasksViewController *)[vc topViewController];
    cVC.delegate = self;
    cVC.isFromSettings = NO;
    MZFormSheetController *formSheet = [[MZFormSheetController alloc] initWithViewController:vc];
    formSheet.shouldDismissOnBackgroundViewTap = YES;
    if (LESS_THAN_IPHONE5) {
        formSheet.transitionStyle = MZFormSheetTransitionStyleNone;
    } else {
        formSheet.transitionStyle = MZFormSheetTransitionStyleSlideAndBounceFromRight;
    }
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

#pragma mark - Delegate Methods

- (void)reminderDateViewController:(ReminderDateViewController *)controller didFinishSelectingDate:(NSDate *)date
{
    reminderDate = date;
    self.dateDetail.text = [mainFormatter stringFromDate:date];
}

- (void)reminderViewControllerDidCancel:(ReminderDateViewController *)controller
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)addCircleReminderViewController:(AddCircleReminderViewController *)controller didFinishAddingReminderInCircle:(Circles *)circle withUsers:(NSArray *)users withTask:(NSString *)task withDescription:(NSString *)description withDate:(NSDate *)date
{
    nil;
}

- (void)addCircleReminderViewControllerSwitchSegment:(AddCircleReminderViewController *)controller didFinishAddingReminderInCircle:(Circles *)circle withUsers:(NSArray *)users withTask:(NSString *)task withDescription:(NSString *)description withDate:(NSDate *)date withQuery:(PFQuery *)query withCurrentUser:(UserInfo *)user
{
    self.retainedCircle = circle;
    self.retainedUsers = users;
    self.retainedQuery = query;
    if (!self.currentUser) {
        self.currentUser = user;
    }
    
    if (task.length > 0) {
        
        self.taskTextField.text = task;
        [self textValidation:nil];
    }
    
    if (![description isEqualToString:descriptionPlaceholderText]) {
        self.descriptionTextView.text = description;
        self.descriptionTextView.textColor = [UIColor blackColor];
        self.descriptionTextView.userInteractionEnabled = YES;
        
        [self textViewDidChange:self.descriptionTextView];
    }
}

- (void)commonTasksViewControllerDidFinishWithTask:(NSString *)task
{
    self.taskTextField.text = task;
    self.limitLabel.text = [NSString stringWithFormat:@"%d", 35 - task.length];
    textCheck = YES;
    [self configureDoneButton];
}

-(void)friendsForReminders:(FriendsForRemindersViewController *)controller friend:(UserInfo *)friend currentUser:(UserInfo *)currentUser
{
    [self dismissViewControllerAnimated:YES completion:nil];
    
    self.name.text = [NSString stringWithFormat:@"%@ %@", friend.firstName, friend.lastName];
    self.username.text = friend.user;
    
    self.userImage.file = friend.profilePicture;
    self.currentUser = currentUser;
    
    friendCheck = YES;
    
    self.recipient = friend;
    
    self.name.hidden = NO;
    self.userImage.hidden = NO;
    self.userFrame.hidden = NO;
    self.username.hidden = NO;
    
    self.selectAFriendLabel.hidden = YES;
    [self configureDoneButton];
}

- (void)friendsForReminders:(FriendsForRemindersViewController *)controller didFinishSelectingFriends:(NSArray *)friends currentUser:(UserInfo *)currentUser
{
    //ARJUN
    ///FLAT FONT MAYBE NECESSARY
    
    UserInfo *group = [UserInfo objectWithoutDataWithObjectId:@"xB1e7MpbMQ"];
    
    self.recipient = group;
    self.currentUser = currentUser;
    
    self.name.text = @"Group Reminder";
    self.userImage.image = [UIImage imageNamed:@"defaultPic"];
    self.username.text = [NSString stringWithFormat:@"Shared by %d friends", friends.count];
    
    batchFriends = [NSArray arrayWithArray:friends];
    
    friendCheck = YES;
    
    self.name.hidden = NO;
    self.userImage.hidden = NO;
    self.userFrame.hidden = NO;
    self.username.hidden = NO;
    self.selectAFriendLabel.hidden = YES;
    
    [self configureDoneButton];
}

#pragma mark - Other

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

- (void)receiveAddNotification:(NSNotification *) notification
{
    if ([[notification name] isEqualToString:@"mpCenterTabbarItemTapped"]) {
        NSLog (@"Successfully received the add notification for Reminders!");
        
    }
}

#pragma mark - Segue Preparation

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"FriendsForReminders"]) {
        UINavigationController *nav = (UINavigationController *)[segue destinationViewController];
        FriendsForRemindersViewController *controller = (FriendsForRemindersViewController *)nav.topViewController;
        controller.delegate = self;
    } else if ([segue.identifier isEqualToString:@"ReminderDate"]) {
        ReminderDateViewController *controller = [segue destinationViewController];
        controller.delegate = self;
        controller.displayDate = self.dateDetail.text;
    } if ([segue.identifier isEqualToString:@"CircleReminder"]) {
        UINavigationController *nav = (UINavigationController *)[segue destinationViewController];
        AddCircleReminderViewController *controller = (AddCircleReminderViewController *)nav.topViewController;
        controller.delegate = self;
        controller.invitedMembers = self.retainedUsers;
        controller.circle = self.retainedCircle;
        controller.reminderDate = reminderDate;
        controller.retainedQuery = self.retainedQuery;
        controller.fromSegmentSwitch = YES;
        controller.currentUser = self.currentUser;
        
        
        controller.retainedTask = self.taskTextField.text;
        if (![self.descriptionTextView.text isEqualToString:descriptionPlaceholderText]) {
            controller.retainedDescription = self.descriptionTextView.text;
        }
        
        controller.unwinder = self.unwinder;
    }
}

@end
