//
//  RemindersViewController.m
//  MyPlane
//
//  Created by Arjun Bhatnagar on 7/7/13.
//  Copyright (c) 2013 Acubed Productions. All rights reserved.
//

#import "RemindersViewController.h"
#import "MyLoginViewController.h"
#import "MySignUpViewController.h"
#import "QuartzCore/CALayer.h"
#import <QuartzCore/QuartzCore.h>
#import "KGStatusBar.h"


@interface RemindersViewController ()

@end


@implementation RemindersViewController {
    PFObject *selectedReminderObject;
    NSString *displayName;
    NSString *theUsername;
    UIImage *defaultPic;
    //NSString *tempUsername;
    //PFObject *meObject;
    NSDateFormatter *dateFormatter;

}



- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.pullToRefreshEnabled = YES;
        self.paginationEnabled = YES;
        self.objectsPerPage = 25;
        
        
    }
    return self;
}

- (NSString *)documentsDirectory
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    return documentsDirectory;
}

- (NSString *)dataFilePath
{
    return [[self documentsDirectory] stringByAppendingPathComponent:
            @"UserProfile.plist"];
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receiveAddNotification:)
                                                 name:@"mpCenterTabbarItemTapped"
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receiveAddNotification:)
                                                 name:@"reloadObjects"
                                               object:nil];

    
    /*BOOL firstTime = [[NSUserDefaults standardUserDefaults] boolForKey:@"FirstTime"];
    if (firstTime) {
        [self performSegueWithIdentifier:@"firstTimeSettings" sender:nil];
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"FirstTime"];
    }*/
    
    self.tableView.rowHeight = 70;
    
    UIImageView *av = [[UIImageView alloc] init];
    av.backgroundColor = [UIColor clearColor];
    av.opaque = NO;
    UIImage *background = [UIImage imageNamed:@"tableBackground"];
    av.image = background;
    
    self.tableView.backgroundView = av;
    
    dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateStyle:NSDateFormatterShortStyle];
    [dateFormatter setTimeStyle:NSDateFormatterShortStyle];
    
    //[self getUserInfo];
    
    //[self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    //self.tableView.backgroundColor = [UIColor alizarinColor];

    //self.tableView.separatorColor = [UIColor blackColor];
    
	// Do any additional setup after loading the view.
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    if (![PFUser currentUser]) { // No user logged in
        // Create the log in view controller
        PFLogInViewController *logInViewController = [[MyLoginViewController alloc] init];
        logInViewController.delegate = self; // Set ourselves as the delegate
        
        // Create the sign up view controller
        PFSignUpViewController *signUpViewController = [[MySignUpViewController alloc] init];
        signUpViewController.delegate = self; // Set ourselves as the delegate
        signUpViewController.fields = PFSignUpFieldsUsernameAndPassword
        | PFSignUpFieldsSignUpButton
        | PFSignUpFieldsEmail
        | PFSignUpFieldsDismissButton;
        
        // Assign our sign up controller to be displayed from the login controller
        [logInViewController setSignUpController:signUpViewController];
        
        // Present the log in view controller
        [self presentViewController:logInViewController animated:YES completion:nil];
    } else {
    
    [self loadObjects];
        
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table View Methods

-(UITableViewCell *)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    
    UIImageView *av = [[UIImageView alloc] init];
    av.backgroundColor = [UIColor clearColor];
    av.opaque = NO;
    UIImage *background = [UIImage imageNamed:@"list-item"];
    av.image = background;
    
    cell.backgroundView = av;
    
    UIColor *selectedColor = [UIColor colorFromHexCode:@"FF7140"];
    
    UIView *bgView = [[UIView alloc]init];
    bgView.backgroundColor = selectedColor;
    
    
    [cell setSelectedBackgroundView:bgView];
    
    UILabel *reminderLabel = (UILabel *)[cell viewWithTag:1001];
    UILabel *usernameLabel = (UILabel *)[cell viewWithTag:1002];
    UILabel *dateLabel = (UILabel *)[cell viewWithTag:1003];

    reminderLabel.font = [UIFont flatFontOfSize:16];
    usernameLabel.font = [UIFont flatFontOfSize:14];
    dateLabel.font = [UIFont flatFontOfSize:14];
    
    reminderLabel.textColor = [UIColor colorFromHexCode:@"A62A00"];
    
    
    /*cell.textLabel.backgroundColor = [UIColor clearColor];
     if ([cell respondsToSelector:@selector(detailTextLabel)])
     cell.detailTextLabel.backgroundColor = [UIColor clearColor];
     
     //Guess some good text colors
     cell.textLabel.textColor = selectedColor;
     cell.textLabel.highlightedTextColor = color;
     if ([cell respondsToSelector:@selector(detailTextLabel)]) {
     cell.detailTextLabel.textColor = selectedColor;
     cell.detailTextLabel.highlightedTextColor = color;
     }*/
    
    return cell;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath object:(PFObject *)object {
    static NSString *identifier = @"Cell";
    PFTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell = [[PFTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:identifier];
        
    }
    
    PFObject *reminder = [self.objects objectAtIndex:indexPath.row];
    
    NSDate *currentDate = [NSDate date];
    NSComparisonResult result;
    
    result = [currentDate compare:[[object objectForKey:@"date"] dateByAddingTimeInterval:7200]];
    
    if (result == NSOrderedDescending) {
        [self checkDateforCell:cell withReminder:reminder];
        
    }
    
    
    
    
    PFImageView *picImage = (PFImageView *)[cell viewWithTag:1000];
    UILabel *reminderText = (UILabel *)[cell viewWithTag:1001];
    UILabel *detailText = (UILabel *)[cell viewWithTag:1002];
    UILabel *dateLabel = (UILabel *)[cell viewWithTag:1003];
    
    
    reminderText.text = [object objectForKey:@"title"];
    detailText.text = [object objectForKey:@"fromUser"];
    dateLabel.text = [dateFormatter stringFromDate:[object objectForKey:@"date"]];
    
    
    PFObject *fromFriend = [object objectForKey:@"fromFriend"];
    
    picImage.file = (PFFile *)[fromFriend objectForKey:@"profilePicture"]; // remote image
    
    [picImage loadInBackground];
    
    /*
     NSMutableArray *results = [[NSMutableArray alloc]initWithObjects:fromFriend, nil];
     
     dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
     dispatch_async(queue, ^{
     for (PFObject *object in results) {
     PFFile *theImage = (PFFile *)[object objectForKey:@"profilePicture"];
     UIImage *fromUserImage = [[UIImage alloc] initWithData:theImage.getData];
     
     dispatch_async(dispatch_get_main_queue(), ^{
     
     picImage.image = fromUserImage;
     
     });
     }
     
     });
     */
    
    
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    selectedReminderObject = [self.objects objectAtIndex:indexPath.row];
    [self performSegueWithIdentifier:@"ReminderDisclosure" sender:selectedReminderObject];
    
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    //    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithContentsOfFile:[self dataFilePath]];
    //
    //    NSString *myObjectID = [dict objectForKey:@"objectID"];
    
    
    PFObject *deleteReminder = [self.objects objectAtIndex:indexPath.row];
    NSString *deleteName = [deleteReminder objectForKey:@"fromUser"];
    NSString *tempName = [deleteReminder objectForKey:@"user"];
    
    
    [deleteReminder deleteInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (succeeded) {
            NSArray *indexPaths = [NSArray arrayWithObject:indexPath];
            [self loadObjects];
            [self.tableView reloadRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationRight];
            [SVProgressHUD showSuccessWithStatus:@"Denied Reminder"];
            
            
            NSString *message = [NSString stringWithFormat:@"%@ has deleted your reminder", tempName];
            
            PFQuery *pushQuery = [PFInstallation query];
            [pushQuery whereKey:@"user" equalTo:deleteName];
            
            PFPush *push = [[PFPush alloc] init];
            [push setQuery:pushQuery];
            [push setMessage:message];
            [push sendPushInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                NSString *message = [NSString stringWithFormat:@"%@ has been notified", deleteName];
                [SVProgressHUD showSuccessWithStatus:message];
            }];
            
        }
    }];
    
    
    
    
}

#pragma mark - Query Methods

- (PFQuery *)queryForTable {
    
    
    //PFQuery *photosFromCurrentUserQuery = [PFQuery queryWithClassName:@"UserInfo"];
    //[photosFromCurrentUserQuery whereKeyExists:@"user"];
    
    //NSString *username = [PFUser currentUser].username;
    
    //NSPredicate *predicate = [NSPredicate predicateWithFormat:@"user = %@ AND date >= %@",username,currentDate];
    
    
    PFQuery *query = [PFQuery queryWithClassName:@"Reminders"];
    //[query whereKey:@"date" greaterThanOrEqualTo:currentDate];
    if([PFUser currentUser]) {
        [query whereKey:@"user" equalTo:[PFUser currentUser].username];
    }
    
    [query includeKey:@"fromFriend"];
    [query includeKey:@"recipient"];
    
    [query orderByAscending:@"date"];
    
    
    if (self.objects.count == 0) {
        query.cachePolicy = kPFCachePolicyCacheThenNetwork;
    }
    
    [KGStatusBar dismiss];
    
    return query;
}

//-(void)getUserInfo {
//    PFQuery *query = [PFQuery queryWithClassName:@"UserInfo"];
//    [query whereKey:@"user" equalTo:[PFUser currentUser].username];
//    [query includeKey:@"friends"];
//    query.cachePolicy = kPFCachePolicyCacheThenNetwork;
//    [query getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error) {
//        meObject = object;
//        NSString *username = [object objectForKey:@"user"];
//        tempUsername = username;
//    }];
//    
//    if (self.objects.count == 0) {
//        query.cachePolicy = kPFCachePolicyNetworkElseCache;
//    }
//    
//}

#pragma mark - Custom Methods

- (void)receiveAddNotification:(NSNotification *) notification
{
    
    
    if ([[notification name] isEqualToString:@"mpCenterTabbarItemTapped"]) {
        NSLog (@"Successfully received the add notification for Reminders!");
        [self performSegueWithIdentifier:@"AddReminder" sender:nil];
    }
    
    else if ([[notification name] isEqualToString:@"reloadObjects"]) {
        NSLog (@"Successfully received the reload notification!");
        [self loadObjects];
        [SVProgressHUD showSuccessWithStatus:@"Received Reminder!"];
    }
}



- (void)checkDateforCell:(UITableViewCell *)cell withReminder:(PFObject *)reminder
{
    
    //NSLog(@"reminder: %@ from: %@", [reminder objectForKey:@"title"], [reminder objectForKey:@"fromUser"]);

        [SVProgressHUD showWithStatus:@"Cleanup..."];

    [reminder deleteInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (succeeded) {
            [SVProgressHUD dismiss];
            [KGStatusBar showWithStatus:@"Please Reload Reminders!"];
            //[SVProgressHUD showErrorWithStatus:@"ARJUN IMPLEMENT SOME SORT OF INDICATOR TO RELOAD"];
        } else {
            NSLog(@"There was an error deleting an old reminder!");
            [SVProgressHUD dismiss];
        }
        
    }];
        
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"AddReminder"]) {
        AddReminderViewController *controller = [segue destinationViewController];
        controller.delegate = self;
    }
    
    else if ([segue.identifier isEqualToString:@"firstTimeSettings"]) {
        UINavigationController *navController = (UINavigationController *)[segue destinationViewController];
        firstTimeSettingsViewController *controller = (firstTimeSettingsViewController *)navController.topViewController;
        controller.delegate = self;
        
        
    }
    
    else if ([segue.identifier isEqualToString:@"ReminderDisclosure"]) {
        ReminderDisclosureViewController *controller = [segue destinationViewController];
        controller.delegate = self;
        controller.reminderObject = sender;
    }

}


-(void)registerUserID:(NSString *)objectID {
    NSDictionary *userDict = [[NSDictionary alloc]init];
    [userDict setValue:objectID forKey:@"objectID"];
    [userDict writeToFile:[self dataFilePath] atomically:YES];

}

- (IBAction)addReminder:(id)sender {
    [self performSegueWithIdentifier:@"AddReminder" sender:nil];
}


#pragma mark - LoginViewController Delegates

- (void)logInViewController:(PFLogInViewController *)logInController didFailToLogInWithError:(NSError *)error
{
    NSLog(@"Failed to log in...");
}

- (void)logInViewController:(PFLogInViewController *)logInController didLogInUser:(PFUser *)user
{
    //NSString *username = user.username;
    
    PFInstallation *currentInstallation = [PFInstallation currentInstallation];
    [currentInstallation setObject:[PFUser currentUser].username forKey:@"user"];
    [currentInstallation saveInBackground];
    
        [[NSNotificationCenter defaultCenter] postNotificationName:@"reloadFriends" object:nil];
    
        [[NSNotificationCenter defaultCenter] postNotificationName:@"reloadProfile" object:nil];
    
    
    /*PFQuery *objectIdQuery = [UserInfo query];
    [objectIdQuery whereKey:@"user" equalTo:username];
    [objectIdQuery getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error) {
        [self registerUserID:[object objectId]];
        [self loadObjects];
        
    }];*/
    
    [self dismissViewControllerAnimated:YES completion:^{
        CurrentUser *sharedManager = [CurrentUser sharedManager];
        PFQuery *userObject = [UserInfo query];
        [userObject whereKey:@"user" equalTo:[PFUser currentUser].username];
        [userObject getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error) {
            sharedManager.currentUser = (UserInfo *)object;
        }];
        
        
    }];
    
    
}

- (void)logInViewControllerDidCancelLogIn:(PFLogInViewController *)logInController
{
    
}

- (BOOL)logInViewController:(PFLogInViewController *)logInController shouldBeginLogInWithUsername:(NSString *)username password:(NSString *)password {
    // Check if both fields are completed
    if (username && password && username.length != 0 && password.length != 0) {
        return YES; // Begin login process
    }
    
    [[[UIAlertView alloc] initWithTitle:@"Missing Information"
                                message:@"Make sure you fill out all of the information!"
                               delegate:nil
                      cancelButtonTitle:@"ok"
                      otherButtonTitles:nil] show];
    return NO; // Interrupt login process
}



#pragma mark - SignUpViewController Delegates

-(void)addSelfToFriends {
    PFQuery *personQuery = [UserInfo query];
    [personQuery whereKey:@"user" equalTo:[PFUser currentUser].username];
    [personQuery includeKey:@"friends"];
    
    
    [personQuery getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error) {
        //Singleton reference
        CurrentUser *sharedManager = [CurrentUser sharedManager];
        sharedManager.currentUser = (UserInfo *)object;
        
        //Add Self Friend
        
        NSString *objectID = [object objectId];
        PFObject *userFriendObject = [PFObject objectWithoutDataWithClassName:@"UserInfo" objectId:objectID];
        
        [object addObject:userFriendObject forKey:@"friends"];
        [object saveInBackground];
        //[self registerUserID:objectID];
        
    }];
}

- (void)signUpViewController:(PFSignUpViewController *)signUpController didSignUpUser:(PFUser *)user {
    defaultPic = [UIImage imageNamed:@"first"];
    UserInfo *userObject = [UserInfo object];
    NSData *data = UIImagePNGRepresentation(defaultPic);
    PFFile *imageupload = [PFFile fileWithName:@"myProfilePicture.png" data:data];
    [userObject setObject:displayName forKey:@"user"];
    [userObject setObject:displayName forKey:@"displayName"];
    [userObject setObject:imageupload forKey:@"profilePicture"];
    [userObject saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        [self addSelfToFriends];
    }];
    
    PFInstallation *currentInstallation = [PFInstallation currentInstallation];
    [currentInstallation setObject:[PFUser currentUser].username forKey:@"user"];
    
    [currentInstallation saveInBackground];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"reloadFriends" object:nil];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"reloadProfile" object:nil];
    
    [self dismissViewControllerAnimated:YES completion:^{
        [self performSegueWithIdentifier:@"firstTimeSettings" sender:nil];
    }];
    
}

- (void)signUpViewControllerDidCancelSignUp:(PFSignUpViewController *)signUpController {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (BOOL)signUpViewController:(PFSignUpViewController *)signUpController
           shouldBeginSignUp:(NSDictionary *)info {
    NSString *password = [info objectForKey:@"password"];
    NSString *username = [info objectForKey:@"username"];
    displayName = username;
    
    //    NSString *lowercaseUsername = [username lowercaseString];
    //    theUsername = lowercaseUsername;
    
    return (BOOL)(password.length >= 8);
    
}

- (IBAction)unwindToReminders:(UIStoryboardSegue *)unwindSegue
{
//    UIViewController* sourceViewController = unwindSegue.sourceViewController;
//    
//    if ([sourceViewController isKindOfClass:[AddReminderViewController class]])
//    {
//        NSLog(@"Coming from AR!");
//    }
//    else if ([sourceViewController isKindOfClass:[AddCircleReminderViewController class]])
//    {
//        NSLog(@"Coming from ACR!");
//    }
}




@end
