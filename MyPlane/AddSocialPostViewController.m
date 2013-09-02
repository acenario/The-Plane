//
//  AddSocialPostViewController.m
//  MyPlane
//
//  Created by Abhijay Bhatnagar on 7/18/13.
//  Copyright (c) 2013 Acubed Productions. All rights reserved.
//

#import "AddSocialPostViewController.h"
#import "Reachability.h"

@interface AddSocialPostViewController ()

@end

@implementation AddSocialPostViewController {
    BOOL textCheck;
    BOOL circleCheck;
//    BOOL reminderCheck;
    NSString *taskText;
    NSString *descriptionText;
    NSDate *reminderDate;
    Reachability *reachability;
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
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reachabilityChanged:) name:kReachabilityChangedNotification object:nil];
    reachability = [Reachability reachabilityForInternetConnection];
    [reachability startNotifier];
    
    NSString *placeholderText = @"Write a post here...";
    
    self.postTextField.text = placeholderText;
    self.postTextField.textColor = [UIColor grayColor];
    self.postTextField.delegate = self;
    
    if ((self.circle)) {
        self.circleLabel.text = self.circle.displayName;
        circleCheck = YES;
        self.pickCircleCell.userInteractionEnabled = NO;
        self.pickCircleCell.accessoryType = UITableViewCellAccessoryNone;
    }
    
//    self.limitLabel.hidden = YES;
    
    [self configureDoneButton];
    [self configureViewController];
    
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
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)reachabilityChanged:(NSNotification*) notification
{
    if (reachability.currentReachabilityStatus == NotReachable) {
        self.doneButton.enabled = NO;
    } else {
        [self configureDoneButton];
    }
}


#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ((indexPath.row == 0) && (indexPath.section == 0)) {
        self.postTextField.textColor = [UIColor blackColor];
        self.postTextField.text = @"";
        self.postTextField.userInteractionEnabled = YES;
        [self.postTextField becomeFirstResponder];
    } else {
        nil;
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
        
        self.postTextField.font = [UIFont flatFontOfSize:14];
        self.limitLabel.font = [UIFont flatFontOfSize:14];
        self.limitLabel.adjustsFontSizeToFitWidth = YES;
        
        [cell.contentView addSubview:imgView];
        
    } else if (indexPath.row == 1) {
        
        self.circleName.font = [UIFont flatFontOfSize:16];
        self.circleLabel.font = [UIFont flatFontOfSize:16];
        self.circleLabel.textColor = [UIColor colorFromHexCode:@"A62A00"];
        self.circleLabel.backgroundColor = [UIColor whiteColor];
        self.circleName.backgroundColor = [UIColor whiteColor];
        }
    } else {
            cell.textLabel.font = [UIFont flatFontOfSize:16];
            cell.detailTextLabel.font = [UIFont flatFontOfSize:14];
            cell.textLabel.adjustsFontSizeToFitWidth = YES;
            cell.textLabel.backgroundColor = [UIColor whiteColor];
            cell.detailTextLabel.backgroundColor = [UIColor whiteColor];
    }
    
    
    
    return cell;
    
}


- (IBAction)done:(id)sender {
    
    SocialPosts *post = [SocialPosts object];
    [post setObject:self.postTextField.text forKey:@"text"];
    [post setObject:self.circle forKey:@"circle"];
    [post setObject:self.currentUser forKey:@"user"];
    [post setUsername:self.currentUser.user];
    
    if (taskText.length > 0) {
        [post setObject:taskText forKey:@"reminderTask"];
        [post setObject:reminderDate forKey:@"reminderDate"];
        [post setObject:descriptionText forKey:@"reminderDescription"];
    }
    
    [post saveEventually:^(BOOL succeeded, NSError *error) {
        [self.circle addObject:[SocialPosts objectWithoutDataWithObjectId:post.objectId] forKey:@"posts"];
        [self.circle saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            [self dismissViewControllerAnimated:YES completion:^{
                [self.delegate addSocialDidFinishAdding:self];
            }];
        }];
    }];
}

- (IBAction)cancel:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"PickCircle"]) {
        UINavigationController *navController = (UINavigationController *)[segue destinationViewController];
        PickCircleViewController *controller = (PickCircleViewController *)navController.topViewController;
        controller.delegate = self;
        controller.userQuery = self.userQuery;
    } else if ([segue.identifier isEqualToString:@"Reminder"]) {
        UINavigationController *nav = [segue destinationViewController];
        AttachReminderViewController *controller = (AttachReminderViewController *)nav.topViewController;
        controller.delegate = self;
        controller.taskText = taskText;
        controller.descText = descriptionText;
        controller.dateText = reminderDate;
    }
}

- (void)pickCircleViewController:(PickCircleViewController *)controller didSelectCircle:(Circles *)circle
{
    self.circleLabel.text = circle.displayName;
    self.circle = circle;
    circleCheck = YES;
    [self configureDoneButton];
}

- (void)hideKeyboard
{
    [self.postTextField resignFirstResponder];
}

- (void)configureDoneButton {
//    if ((circleCheck) && (textCheck) && (reminderCheck)) {
    if ((circleCheck) && (textCheck)) {
        self.doneButton.enabled = YES;
    } else {
        self.doneButton.enabled = NO;
    }
}

- (void)textViewDidChange:(UITextView *)textView
{
//    self.limitLabel.hidden = NO;
    NSString *removedSpaces = [self.postTextField.text stringByReplacingOccurrencesOfString:@" " withString:@""];
    int limit = 140 - self.postTextField.text.length;
    self.limitLabel.text = [NSString stringWithFormat:@"%d characters left", limit];
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

- (void)attachReminderViewController:(AttachReminderViewController *)controller withTask:(NSString *)task withDescription:(NSString *)description withDate:(NSDate *)date withFormatter:(NSDateFormatter *)formatter
{
//    reminderCheck = YES;
//    
    taskText = task;
    descriptionText = description;
    reminderDate = date;
    
    self.reminderTextLabel.text = task;
    self.reminderSubtitle.text = [formatter stringFromDate:date];
    [self configureDoneButton];
}

@end
