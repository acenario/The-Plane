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
#import "Reachability.h"


@interface RemindersViewController ()

@property (nonatomic, strong) NSMutableDictionary *seenReminders;

@end


@implementation RemindersViewController {
    PFObject *selectedReminderObject;
    NSString *displayName;
    NSString *theUsername;
    UIImage *defaultPic;
    //NSString *tempUsername;
    //PFObject *meObject;
    NSDateFormatter *dateFormatter;
    Reachability *reachability;

}

- (id)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
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
    
    self.seenReminders = [NSMutableDictionary dictionary];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receiveAddNotification:)
                                                 name:@"mpCenterTabbarItemTapped"
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receiveAddNotification:)
                                                 name:@"reloadObjects"
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reachabilityChanged:) name:kReachabilityChangedNotification object:nil];

    reachability = [Reachability reachabilityForInternetConnection];
    [reachability startNotifier];
    
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


-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:YES];
    
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if (![PFUser currentUser]) { // No user logged in
        [KGStatusBar dismiss];
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
        [self presentViewController:logInViewController animated:NO completion:nil];
    } else {
        //CurrentUser *sharedManager = [CurrentUser sharedManager];
        
        
        if (reachability.currentReachabilityStatus == NotReachable) {
            NSLog(@"No internet connection!");
        } else {
//            if ((sharedManager.currentUser.firstName == nil || sharedManager.currentUser.lastName == nil)) {
//             [self performSegueWithIdentifier:@"firstTimeSettings" sender:nil];
//             [SVProgressHUD showErrorWithStatus:@"You must enter a first name and last name!"];
//             } else {
//             [self loadObjects];
//             }
            //ARJUN ELSE IF WHAT?
//            [self loadObjects];
        }
 
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleSeen)
                                                 name:@"handleseen"
                                               object:nil];
}

- (void)reachabilityChanged:(NSNotification*)notification
{
    //CurrentUser *sharedManager = [CurrentUser sharedManager];
    
    if (reachability.currentReachabilityStatus == NotReachable) {
        NSLog(@"No internet connection!");
    } else {
//        if ((sharedManager.currentUser.firstName == nil || sharedManager.currentUser.lastName == nil)) {
//            [self performSegueWithIdentifier:@"firstTimeSettings" sender:nil];
//            [SVProgressHUD showErrorWithStatus:@"You must enter a first name and last name!"];
//        } else {
//            [self loadObjects];
//        }
        [self loadObjects];
    }

}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:YES];
    [self handleSeen];
}

- (void)firstTimePresentTutorial:(firstTimeSettingsViewController *)controller {
//    [self performSelector:@selector(checkHasFriends) withObject:nil afterDelay:1];
    
//    NSString *message = @"Would you like to a see a walkthrough of the app?";
//    
//    UIColor *barColor = [UIColor colorFromHexCode:@"F87056"];
//    
//    FUIAlertView *alertView = [[FUIAlertView alloc]
//                               initWithTitle:@"Walkthrough"
//                               message:message
//                               delegate:self
//                               cancelButtonTitle:@"No"
//                               otherButtonTitles:@"Yes", nil];
//    
//    alertView.titleLabel.textColor = [UIColor cloudsColor];
//    alertView.titleLabel.font = [UIFont boldFlatFontOfSize:17];
//    alertView.messageLabel.textColor = [UIColor whiteColor];
//    alertView.messageLabel.font = [UIFont flatFontOfSize:15];
//    alertView.backgroundOverlay.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.2f];
//    alertView.alertContainer.backgroundColor = barColor;
//    alertView.defaultButtonColor = [UIColor cloudsColor];
//    alertView.defaultButtonShadowColor = [UIColor clearColor];
//    alertView.defaultButtonFont = [UIFont boldFlatFontOfSize:16];
//    alertView.defaultButtonTitleColor = [UIColor asbestosColor];
//    
//    
//    [alertView show];
}

- (void)checkHasFriends
{
    CurrentUser *sharedManager = [CurrentUser sharedManager];
    if (sharedManager.currentUser.friends.count == 1) {
        
        FUIAlertView *alertView = [[FUIAlertView alloc]
                                   initWithTitle:@"Add Friends"
                                   message:@"You currently have no friends. Would you like to import friends from your contacts?"
                                   delegate:self
                                   cancelButtonTitle:@"No"
                                   otherButtonTitles:@"Yes", nil];
        
        UIColor *barColor = [UIColor colorFromHexCode:@"F87056"];
        alertView.titleLabel.textColor = [UIColor cloudsColor];
        alertView.titleLabel.font = [UIFont boldFlatFontOfSize:17];
        alertView.messageLabel.textColor = [UIColor whiteColor];
        alertView.messageLabel.font = [UIFont flatFontOfSize:15];
        alertView.backgroundOverlay.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.2f];
        alertView.alertContainer.backgroundColor = barColor;
        alertView.defaultButtonColor = [UIColor cloudsColor];
        alertView.defaultButtonShadowColor = [UIColor clearColor];
        alertView.defaultButtonFont = [UIFont boldFlatFontOfSize:16];
        alertView.defaultButtonTitleColor = [UIColor asbestosColor];
        
        [alertView show];
        
    }
}


- (void)alertView:(FUIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 1) {
        [self performSegueWithIdentifier:@"Tutorial" sender:nil];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Query Methods

- (PFQuery *)queryForTable {
    
    
    //PFQuery *photosFromCurrentUserQuery = [PFQuery queryWithClassName:@"UserInfo"];
    //[photosFromCurrentUserQuery whereKeyExists:@"user"];
    
    //NSString *username = [PFUser currentUser].username;
    
    //NSPredicate *predicate = [NSPredicate predicateWithFormat:@"user = %@ AND date >= %@",username,currentDate];
    
    
    PFQuery *query = [PFQuery queryWithClassName:@"Reminders"];
    
    CurrentUser *sharedManager = [CurrentUser sharedManager];
    //[query whereKey:@"date" greaterThanOrEqualTo:currentDate];
    
    if([PFUser currentUser]) {
        //Checks if logged in
        
        [query whereKey:@"user" equalTo:[PFUser currentUser].username];
        [query whereKey:@"fromUser" notContainedIn:sharedManager.currentUser.blockedUsernames];
        [query whereKey:@"archived" equalTo:[NSNumber numberWithBool:NO]]; //Searches for non-archived reminders (archive = false)
        [query whereKey:@"isParent" equalTo:[NSNumber numberWithBool:NO]];
    }
    
    [query includeKey:@"fromFriend"];
    [query includeKey:@"recipient"];
    [query includeKey:@"comments"];
    [query includeKey:@"socialPost"];
    [query includeKey:@"circle"];
    [query includeKey:@"parent"];
    [query includeKey:@"parent.fromFriend"];
    [query includeKey:@"parent.recipient"];
    
    [query orderByAscending:@"date"];
    
    if([PFUser currentUser]) {
        if (self.objects.count == 0) {
            query.cachePolicy = kPFCachePolicyCacheThenNetwork;
        }
    }
    
    [KGStatusBar dismiss];
    
    return query;
}

/*-(void)getUserInfo {
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
*/

#pragma mark - Table View Methods

///@param Are mirrors real if our eyes aren't real?
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath object:(PFObject *)object {
    static NSString *identifier = @"Cell";
    PFTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell = [[PFTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:identifier];
        
    }
    /*
     *No need for now to archive or delete old reminders
     CurrentUser *sharedManager = [CurrentUser sharedManager];
     PFObject *reminder = [self.objects objectAtIndex:indexPath.row];
     
     
     int grace = sharedManager.currentUser.gracePeriod;
     
     NSDate *currentDate = [NSDate date];
     NSComparisonResult result;
     
     result = [currentDate compare:[[object objectForKey:@"date"] dateByAddingTimeInterval:grace]];
     
     if (result == NSOrderedDescending) {
     [self checkDateforCell:cell withReminder:reminder];
     
     }*/
    
    
//    NSLog(@"UNCOMMENT THIS TO SEE REMINDER LOADED (BEFORE CHILD SWAP): %@", object);
    if (([object objectForKey:@"isChild"] == [NSNumber numberWithBool:YES]) && ([object objectForKey:@"isShared"] == [NSNumber numberWithBool:YES])) {
        if ([object objectForKey:@"parent"]) {
            PFObject *parent = [object objectForKey:@"parent"];
            object = parent;
        }
//        NSLog(@"children were swapped %@", [object objectForKey:@"user"]);
    }
    
    if ([[object objectForKey:@"state"] isEqualToNumber:[NSNumber numberWithInt:0]]) {
        [object setObject:[NSNumber numberWithInt:1] forKey:@"state"];
        [self.seenReminders setObject:object forKey:[object objectId]];
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

///@return Herobrine
- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    
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
    
    
    usernameLabel.font = [UIFont flatFontOfSize:14];
    dateLabel.font = [UIFont flatFontOfSize:13];
    reminderLabel.font = [UIFont flatFontOfSize:16];

    
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
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    selectedReminderObject = [self.objects objectAtIndex:indexPath.row];
    if (([selectedReminderObject objectForKey:@"isChild"] == [NSNumber numberWithBool:YES]) && ([selectedReminderObject objectForKey:@"isShared"] == [NSNumber numberWithBool:YES])) {
        if ([selectedReminderObject objectForKey:@"parent"]) {
            selectedReminderObject = [selectedReminderObject objectForKey:@"parent"];
        }
    }
    
    [self performSegueWithIdentifier:@"ReminderDisclosure" sender:selectedReminderObject];
//    [self performSegueWithIdentifier:@"Tutorial" sender:nil];
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)aTableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if (reachability.currentReachabilityStatus == NotReachable) {
        NSLog(@"No internet connection!");
        return UITableViewCellEditingStyleNone;
    } else {
        return UITableViewCellEditingStyleDelete;
    }
    
}


- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    //    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithContentsOfFile:[self dataFilePath]];
    //
    //    NSString *myObjectID = [dict objectForKey:@"objectID"];
    
    //IMPLEMENT ARCHIVE SUPPORT FOR CHILDREN
    Reminders *reminderToArchive = [self.objects objectAtIndex:indexPath.row];
    NSString *deleteName = [reminderToArchive objectForKey:@"fromUser"];
    NSString *tempName = [reminderToArchive objectForKey:@"user"];
    
    /*
    Reminders *deleteReminder = [self.objects objectAtIndex:indexPath.row];
    NSString *deleteName = [deleteReminder objectForKey:@"fromUser"];
    NSString *tempName = [deleteReminder objectForKey:@"user"];
    
    NSMutableArray *commentsToDelete = [[NSMutableArray alloc] init];
    
    for (Comments *comment in deleteReminder.comments) {
        [commentsToDelete addObject:[Comments objectWithoutDataWithObjectId:comment.objectId]];
    }
     
    
    SocialPosts *post;
    if ((deleteReminder.socialPost)) {
         post = (SocialPosts *)deleteReminder.socialPost;
        if (post.claimerUsernames.count == 1) {
            [post setIsClaimed:NO];
        }
        [post removeObject:[Reminders objectWithoutDataWithObjectId:deleteReminder.objectId] forKey:@"reminder"];
        [post removeObject:deleteReminder.user forKey:@"claimerUsernames"];
        [post removeObject:[UserInfo objectWithoutDataWithObjectId:deleteReminder.recipient.objectId] forKey:@"claimers"];
    }
    
    //ARJUN
    //DENYING SHOULD ARCHIVE NOT DELETE

    [deleteReminder deleteInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (succeeded) {
       //     [Comments deleteAllInBackground:commentsToDelete block:^(BOOL succeeded, NSError *error) {
       //         [post saveInBackground];
       //     }];
            NSArray *indexPaths = [NSArray arrayWithObject:indexPath];
            [self loadObjects];
            [self.tableView reloadRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationRight];
            [SVProgressHUD showSuccessWithStatus:@"Denied Reminder"];
            
            if (![deleteName isEqualToString:[PFUser currentUser].username]) {
            NSString *message = [NSString stringWithFormat:@"%@ has deleted your reminder", tempName];
            NSDictionary *data = [NSDictionary dictionaryWithObjectsAndKeys:
                                      message, @"alert",
                                      @"d", @"r",
                                      @"alertSound.caf", @"sound",
                                      nil];
//            NSDictionary *data = @{
//                                    @"r": @"d",
//                                    @"sound": @"alertSound.caf"
//                                  };
            
            PFQuery *pushQuery = [PFInstallation query];
            [pushQuery whereKey:@"user" equalTo:deleteName];
            
            PFPush *push = [[PFPush alloc] init];
            [push setQuery:pushQuery];
            //[push setMessage:message];
            [push setData:data];
            [push sendPushInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                if (succeeded) {
                NSString *message = [NSString stringWithFormat:@"%@ has been notified", deleteName];
                [SVProgressHUD showSuccessWithStatus:message];
                } else {
                    NSLog(@"%@", error);
                }
                }];
            }
     
        }
    }];
  */
    
    SocialPosts *post;
    if ((reminderToArchive.socialPost)) {
        post = (SocialPosts *)reminderToArchive.socialPost;
        if (post.claimerUsernames.count == 1) {
            [post setIsClaimed:NO];
        }
        [post removeObject:[Reminders objectWithoutDataWithObjectId:reminderToArchive.objectId] forKey:@"reminder"];
        [post removeObject:reminderToArchive.user forKey:@"claimerUsernames"];
        [post removeObject:[UserInfo objectWithoutDataWithObjectId:reminderToArchive.recipient.objectId] forKey:@"claimers"];
    }
    
    reminderToArchive.archived = YES;
    reminderToArchive.state = -1;
    
    [reminderToArchive saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (succeeded) {
            if (reminderToArchive.socialPost) {
                [post saveInBackground];
            }
            NSArray *indexPaths = [NSArray arrayWithObject:indexPath];
            [self loadObjects];
            [self.tableView reloadRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationRight];
            [SVProgressHUD showSuccessWithStatus:@"Denied and Archived Reminder!"];
            
            if (![deleteName isEqualToString:[PFUser currentUser].username]) {
                NSString *message = [NSString stringWithFormat:@"%@ has denied your reminder", tempName];
                NSDictionary *data = [NSDictionary dictionaryWithObjectsAndKeys:
                                      message, @"alert",
                                      @"d", @"r",
                                      @"alertSound.caf", @"sound",
                                      nil];
                
                PFQuery *pushQuery = [PFInstallation query];
                [pushQuery whereKey:@"user" equalTo:deleteName];
                
                PFPush *push = [[PFPush alloc] init];
                [push setQuery:pushQuery];
                //[push setMessage:message];
                [push setData:data];
                [push sendPushInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                    if (succeeded) {
                        NSString *message = [NSString stringWithFormat:@"%@ has been notified", deleteName];
                        [SVProgressHUD showSuccessWithStatus:message];
                    } else {
                        NSLog(@"%@", error);
                    }
                }];
            }
        
            [self loadObjects];
        }
        
    }];

}

#pragma mark - Seen / Acknowledged System

-(void)handleSeen {
    NSMutableArray *remindersToSave = [[NSMutableArray alloc] init];
    
    //    NSLog(@"%@", self.seenReminders.allValues);
    
    for (Reminders *reminder in self.seenReminders.allValues) {
        [remindersToSave addObject:reminder];
    }
    
    [Reminders saveAllInBackground:remindersToSave block:^(BOOL succeeded, NSError *error) {
        if (succeeded) {
            NSLog(@"REMINdER SAVeD");
        } else {
            NSLog(@"%@", error);
        }
    }];
}

- (void)handleAccept:(Reminders *)reminder {
    reminder.state = 2;
    [reminder saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        NSLog(@"%@ ACCEPTED", [Reminders objectWithoutDataWithObjectId:reminder.objectId]);
    }];
}

- (void)handleCompletion:(Reminders *)reminder {
    reminder.state = 3;
    [reminder saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        NSLog(@"%@ Completed", [Reminders objectWithoutDataWithObjectId:reminder.objectId]);
    }];
}

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
    if (reachability.currentReachabilityStatus == NotReachable) {
        NSLog(@"No internet connection!");
    } else {
        Reminders *receivedReminder = (Reminders *)reminder;

            [SVProgressHUD showWithStatus:@"Archiving..."];
        
        /*
         
        NSMutableArray *commentsToDelete = [[NSMutableArray alloc] init];
         
         *Reason: Comments are children of reminders. No need to individually archive.
         
         if (receivedReminder.comments.count > 0) {
         for (Comments *comment in [reminder objectForKey:@"comments"]) {
            NSLog(@"comment: %@", comment);
            [commentsToDelete addObject:[Comments objectWithoutDataWithObjectId:comment.objectId]];
            }
        } 
         
         */
        
        SocialPosts *post;
        if ((receivedReminder.socialPost)) {
            post = (SocialPosts *)receivedReminder.socialPost;
            if (post.claimerUsernames.count == 1) {
                [post setIsClaimed:NO];
            }
            [post removeObject:[Reminders objectWithoutDataWithObjectId:receivedReminder.objectId] forKey:@"reminder"];
            [post removeObject:receivedReminder.user forKey:@"claimerUsernames"];
            [post removeObject:[UserInfo objectWithoutDataWithObjectId:receivedReminder.recipient.objectId] forKey:@"claimers"];
        }
        
        
//        [reminder deleteInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
//            if (succeeded) {
//                [Comments deleteAllInBackground:commentsToDelete];
        
        
        /*
         
         *No longer need to delete reminders
         
         
        [receivedReminder deleteInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if (succeeded) {
                [Comments deleteAllInBackground:commentsToDelete block:^(BOOL succeeded, NSError *error) {
                    [post saveInBackground];
                }];
                [SVProgressHUD dismiss];
                [KGStatusBar showWithStatus:@"Please Reload Reminders!"];
            } else {
                NSLog(@"There was an error deleting an old reminder!: %@", error);
                [SVProgressHUD dismiss];
            }
            
        }];
        
        */
        
        receivedReminder.archived = YES;
        //ARJUN
        [receivedReminder saveEventually:^(BOOL succeeded, NSError *error) {
            if (succeeded) {
                [SVProgressHUD dismiss];
                [KGStatusBar showWithStatus:@"Please Reload Reminders!"];
            } else {
                NSLog(@"There was an error archiving an old reminder!: %@", error);
                [SVProgressHUD dismiss];
            }
            
        }];
            
        }
    
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"AddReminder"]) {
        UINavigationController *nav = (UINavigationController *)[segue destinationViewController];
        AddReminderViewController *controller = (AddReminderViewController *)nav.topViewController;
        controller.delegate = self;
        controller.unwinder = 1;
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
    [self performSegueWithIdentifier:@"ArchiveReminder" sender:nil];
//    [self performSegueWithIdentifier:@"AddReminder" sender:nil];
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
                      cancelButtonTitle:@"OK"
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
    defaultPic = [UIImage imageNamed:@"defaultPic"];
    UserInfo *userObject = [UserInfo object];
    NSData *data = UIImagePNGRepresentation(defaultPic);
    PFFile *imageupload = [PFFile fileWithName:@"myProfilePicture.png" data:data];
    [userObject setObject:displayName forKey:@"user"];
    [userObject setObject:displayName forKey:@"displayName"];
    [userObject setObject:imageupload forKey:@"profilePicture"];
    [userObject setObject:[NSNumber numberWithInt:0] forKey:@"gracePeriod"];
    [userObject setObject:[NSNumber numberWithInt:0] forKey:@"adminRank"];
    [userObject setObject:@"New" forKey:@"firstName"];
    [userObject setObject:@"User" forKey:@"lastName"];
    userObject.hidden = NO;
    
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
    PFLogInViewController *logInViewController = [[MyLoginViewController alloc] init];
    [logInViewController dismissViewControllerAnimated:NO completion:nil];
    //[self dismissViewControllerAnimated:YES completion:nil];
}

- (BOOL)signUpViewController:(PFSignUpViewController *)signUpController
           shouldBeginSignUp:(NSDictionary *)info {
    
    NSString *password = [info objectForKey:@"password"];
    NSString *username = [info objectForKey:@"username"];
    NSString *email = [info objectForKey:@"email"];
    displayName = username;
    
    //    NSString *lowercaseUsername = [username lowercaseString];
    //    theUsername = lowercaseUsername;
    
    if (password.length >= 8 && username.length > 0 && email.length > 0) {
        return YES;
    }
    
    NSString *title;
    NSString *message;
    
    if (password.length < 8 && username.length > 0 && email.length > 0) {
        title = @"Pasword Too Short";
        message = @"Your password must be at least 8 characters!";
    } else {
        title = @"Missing Information";
        message = @"Make sure you fill out all of the information!";
    }
    
    [[[UIAlertView alloc] initWithTitle:title
                                message:message
                               delegate:nil
                      cancelButtonTitle:@"OK"
                      otherButtonTitles:nil] show];

    
    return NO;
    
    //return (BOOL)(password.length >= 8);
    
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

- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return @"Deny";
}


@end
