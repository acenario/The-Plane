//
//  FriendsQueryViewController.m
//  MyPlane
//
//  Created by Arjun Bhatnagar on 7/17/13.
//  Copyright (c) 2013 Acubed Productions. All rights reserved.
//

#import "FriendsQueryViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "CurrentUser.h"
#import "Reachability.h"
#import "CurrentUser.h"

#define TAG_NOFRIENDS 1

@interface FriendsQueryViewController ()

@property CurrentUser *sharedManager;

@end

@implementation FriendsQueryViewController {
    UserInfo *meObject;
    Reachability *reachability;
}

- (id)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        self.loadingViewEnabled = NO;
        self.pullToRefreshEnabled = NO;
        
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
    [self configureViewController];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reachabilityChanged:) name:kReachabilityChangedNotification object:nil];
    reachability = [Reachability reachabilityForInternetConnection];
    [reachability startNotifier];
    
    
    [self performSelector:@selector(checkHasFriends) withObject:nil afterDelay:1];
	// Do any additional setup after loading the view.
}

- (void) reachabilityChanged:(NSNotification*) notification
{    
	if (reachability.currentReachabilityStatus == NotReachable) {
        self.requestsBtn.enabled = NO;
    } else {
        self.requestsBtn.enabled = YES;
        [self loadObjects];
    }
}

-(void)configureViewController {
    UIImageView *av = [[UIImageView alloc] init];
    av.backgroundColor = [UIColor clearColor];
    av.opaque = NO;
    UIImage *background = [UIImage imageNamed:@"tableBackground"];
    av.image = background;
    
    self.tableView.backgroundView = av;
    
    self.tableView.rowHeight = 70;
    
    self.segmentedController.selectedFont = [UIFont boldFlatFontOfSize:16];
    self.segmentedController.selectedFontColor = [UIColor cloudsColor];
    self.segmentedController.deselectedFont = [UIFont flatFontOfSize:16];
    self.segmentedController.deselectedFontColor = [UIColor cloudsColor];
    self.segmentedController.selectedColor = [UIColor colorFromHexCode:@"FF7140"];
    self.segmentedController.deselectedColor = [UIColor colorFromHexCode:@"FF9773"];
    self.segmentedController.dividerColor = [UIColor colorFromHexCode:@"FF7140"];
    self.segmentedController.cornerRadius = 5.0f;
}

-(void)getUserInfo {
//    PFQuery *query = [PFQuery queryWithClassName:@"UserInfo"];
//    [query whereKey:@"user" equalTo:[PFUser currentUser].username];
//    [query includeKey:@"friends"];
//    query.cachePolicy = kPFCachePolicyCacheThenNetwork;
//    [query getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error) {
//        meObject = (UserInfo *)object;
//    }];
//    
//    if (self.objects.count == 0) {
//        query.cachePolicy = kPFCachePolicyCacheThenNetwork;
//    }
    self.sharedManager = [CurrentUser sharedManager];
    meObject = self.sharedManager.currentUser;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receiveAddNotification:)
                                                 name:@"reloadFriends"
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receiveAddNotification:)
                                                 name:@"increaseFriend"
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(viewDidAppearInContainer:)
                                                 name:@"showFriends"
                                               object:nil];
    self.segmentedController.selectedSegmentIndex = 0;
    [self checkFriendRequests];
    self.sharedManager = [CurrentUser sharedManager];
    //self.requestsBtn.title = [NSString stringWithFormat:@"%d Pending", self.sharedManager.currentUser.receivedFriendRequests.count];
    
    if (reachability.currentReachabilityStatus == NotReachable) {
        self.requestsBtn.enabled = NO;
    } else {
        self.requestsBtn.enabled = YES;
        [self loadObjects];
    }
    
    [self getUserInfo];
}

- (void)receiveAddNotification:(NSNotification *) notification
{
    // [notification name] should always be @"TestNotification"
    // unless you use this method for observation of other notifications
    // as well.
    
    if ([[notification name] isEqualToString:@"reloadFriends"]) {
        [self loadObjects];
    }
    
    else if ([[notification name] isEqualToString:@"increaseFriend"]) {
        [self checkFriendRequests];
    }
}

-(void)viewDidAppearInContainer:(NSNotification *) notification {
    if ([[notification name] isEqualToString:@"showFriends"]) {
        self.segmentedController.selectedSegmentIndex = 0;
        [self checkFriendRequests];
        self.sharedManager = [CurrentUser sharedManager];
        //self.requestsBtn.title = [NSString stringWithFormat:@"%d Pending", self.sharedManager.currentUser.receivedFriendRequests.count];
        [self getUserInfo];
        if (reachability.currentReachabilityStatus == NotReachable) {
            self.requestsBtn.enabled = NO;
        } else {
            self.requestsBtn.enabled = YES;
            [self loadObjects];
        }
        
    }
    
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (PFQuery *)queryForTable {
    

    PFQuery *query = [PFQuery queryWithClassName:@"UserInfo"];
    [query whereKey:@"user" equalTo:[PFUser currentUser].username];
    [query includeKey:@"friends"];
    query.cachePolicy = kPFCachePolicyNetworkElseCache;
    
    PFQuery *friendQuery = [UserInfo query];
    [friendQuery whereKey:@"friends" matchesQuery:query];
        
    /*NSSortDescriptor * firstNameDescriptor = [[NSSortDescriptor alloc]
                                              initWithKey:@"firstName" ascending:YES selector:@selector(localizedCaseInsensitiveCompare:)];
    NSArray *sortDescriptors = @[firstNameDescriptor];
    [friendQuery orderBySortDescriptors:sortDescriptors];*/
    [friendQuery orderByAscending:@"firstName"];

    
    if (self.objects.count == 0) {
        friendQuery.cachePolicy = kPFCachePolicyCacheThenNetwork;
    }

    return friendQuery;    
    
}

-(void)checkFriendRequests {
    PFQuery *query = [PFQuery queryWithClassName:@"UserInfo"];
    [query whereKey:@"user" equalTo:[PFUser currentUser].username];
    
    [query getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error) {
        NSArray *array = [object objectForKey:@"receivedFriendRequests"];
        int count = array.count;
        self.requestsBtn.title = [NSString stringWithFormat:@"%d Pending", count];
    }];
}

- (void)addFriendViewControllerDidFinishAddingFriends:(AddFriendViewController *)controller
{
    [controller dismissViewControllerAnimated:YES completion:nil];
}

-(UITableViewCell *)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    UIImageView *av = [[UIImageView alloc] init];
    UILabel *nameLabel = (UILabel *)[cell viewWithTag:2001];
    UILabel *usernameLabel = (UILabel *)[cell viewWithTag:2002];

    av.backgroundColor = [UIColor clearColor];
    av.opaque = NO;
    UIImage *background = [UIImage imageNamed:@"list-item"];
    av.image = background;
    
    cell.backgroundView = av;
    
    UIColor *selectedColor = [UIColor colorFromHexCode:@"FF7140"];
    
    UIView *bgView = [[UIView alloc]init];
    bgView.backgroundColor = selectedColor;
    
    
    [cell setSelectedBackgroundView:bgView];
    
    nameLabel.font = [UIFont flatFontOfSize:17];
    usernameLabel.font = [UIFont flatFontOfSize:15];
    nameLabel.adjustsFontSizeToFitWidth = YES;
    usernameLabel.adjustsFontSizeToFitWidth = YES;
    
    return cell;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath object:(PFObject *)object {
    static NSString *identifier = @"Cell";
    PFTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell = [[PFTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:identifier];
        
    }
    
    
    
    
    PFImageView *picImage = (PFImageView *)[cell viewWithTag:2000];
    UILabel *contactText = (UILabel *)[cell viewWithTag:2001];
    UILabel *detailText = (UILabel *)[cell viewWithTag:2002];
    
    PFFile *pictureFile = [object objectForKey:@"profilePicture"];
    NSString *username = [object objectForKey:@"user"];
    NSString *firstName = [object objectForKey:@"firstName"];
    NSString *lastName = [object objectForKey:@"lastName"];
    
    picImage.file = pictureFile;
    contactText.text = [NSString stringWithFormat:@"%@ %@", firstName, lastName];
    detailText.text = username;
    
    [picImage loadInBackground];
    
    /*dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(queue, ^{
        PFFile *theImage = (PFFile *)[object objectForKey:@"profilePicture"];
        UIImage *fromUserImage = [[UIImage alloc] initWithData:theImage.getData];
        dispatch_async(dispatch_get_main_queue(), ^{
            picImage.file = pictureFile;
            contactText.text = [NSString stringWithFormat:@"%@ %@", firstName, lastName];
            detailText.text = username;
        });
        
        
    });*/
    

    
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self performSegueWithIdentifier:@"AddReminder" sender:[self.objects objectAtIndex:indexPath.row]];
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)aTableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if (reachability.currentReachabilityStatus == NotReachable) {
        NSLog(@"No internet connection!");
        return UITableViewCellEditingStyleNone;
    } else {
        UserInfo *friend = [self.objects objectAtIndex:indexPath.row];
        if (![friend.user isEqualToString:[PFUser currentUser].username]) {
            return UITableViewCellEditingStyleDelete;
        } else {
            return UITableViewCellEditingStyleNone;
        }
    }
    
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    PFObject *friendRemoved = [self.objects objectAtIndex:indexPath.row];
    //NSLog(@"deletion %@", [meObject objectForKey:@"user"]);
    
    PFObject *friendRemovedData = [PFObject objectWithoutDataWithClassName:@"UserInfo" objectId:[friendRemoved objectId]];
    
    [friendRemoved removeObject:[UserInfo objectWithoutDataWithObjectId:meObject.objectId] forKey:@"friends"];

    [friendRemoved saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        [meObject removeObject:friendRemovedData forKey:@"friends"];
        [meObject saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            CurrentUser *sharedManager = [CurrentUser sharedManager];
            sharedManager.currentUser = meObject;
        }];
        
    NSArray *indexPaths = [NSArray arrayWithObject:indexPath];
    indexPaths = [NSArray arrayWithObject:indexPath];
    [self loadObjects];
    [self.tableView reloadRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationRight];
        
        
    }];
    
    
}
 
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"AddFriend"]) {
        UINavigationController *navController = (UINavigationController *)[segue destinationViewController];
        AddFriendViewController *controller = (AddFriendViewController *)navController.topViewController;
        controller.delegate = self;
    } else if ([segue.identifier isEqualToString:@"ReceivedFriendRequests"]){
        ReceivedFriendRequestsViewController *controller = [segue destinationViewController];
        controller.delegate = self;
    } else if ([segue.identifier isEqualToString:@"AddReminder"]) {
        UINavigationController *nav = (UINavigationController *)[segue destinationViewController];
        AddReminderViewController *controller = (AddReminderViewController *)nav.topViewController;
        controller.recipient = sender;
        controller.currentUser = meObject;
        NSLog(@"%@", [meObject objectForKey:@"user"]);
    } else if ([segue.identifier isEqualToString:@"NoFriends"]) {
        UINavigationController *nav = (UINavigationController *)[segue destinationViewController];
        NoFriendsViewController *controller = (NoFriendsViewController *)nav.topViewController;
        controller.emails = sender;
    }
}


- (void)receivedFriendRequests:(ReceivedFriendRequestsViewController *)controller
{
    NSLog(@"is this even being called?");
    //[self loadObjects];
    //[self checkFriendRequests];
    
}

- (IBAction)addFriend:(id)sender {
    [self performSegueWithIdentifier:@"AddFriend" sender:nil];
}

- (IBAction)segmentChanged:(id)sender {
    [self.delegate friendsSegmentChanged:self.segmentedController];
}

- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return @"Unfriend";
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
        alertView.tag = TAG_NOFRIENDS;
        
        [alertView show];
        
    }
}

- (void)noFriends
{
    ABAddressBookRef addressBook = ABAddressBookCreateWithOptions(NULL, NULL);
    if (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusNotDetermined) {
        ABAddressBookRequestAccessWithCompletion(addressBook, ^(bool granted, CFErrorRef error) {
            // First time access, request permission
            if (granted) {
                NSArray *abContactArray = [[NSArray alloc] init];
                NSArray *originalArray = CFBridgingRelease(ABAddressBookCopyArrayOfAllPeople(addressBook));
                abContactArray = [originalArray sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
                    ABRecordRef record1 = (__bridge ABRecordRef)obj1; // get address book record
                    NSString *firstName1 = CFBridgingRelease(ABRecordCopyValue(record1, kABPersonFirstNameProperty));
                    NSString *lastName1 = CFBridgingRelease(ABRecordCopyValue(record1, kABPersonLastNameProperty));
                    
                    ABRecordRef record2 = (__bridge ABRecordRef)obj2; // get address book record
                    NSString *firstName2 = CFBridgingRelease(ABRecordCopyValue(record2, kABPersonFirstNameProperty));
                    NSString *lastName2 = CFBridgingRelease(ABRecordCopyValue(record2, kABPersonLastNameProperty));
                    
                    NSComparisonResult result = [lastName1 compare:lastName2];
                    if (result != NSOrderedSame)
                        return result;
                    else
                        return [firstName1 compare:firstName2];
                }];
                
                NSMutableArray *allObjects = [[NSMutableArray alloc] initWithCapacity:abContactArray.count];
                
                for (id object in abContactArray) {
                    ABRecordRef record = (__bridge ABRecordRef)object; // get address book record
                    ABMultiValueRef emails = ABRecordCopyValue(record, kABPersonEmailProperty);
                    //        NSString *firstname = CFBridgingRelease(ABRecordCopyValue(record, kABPersonFirstNameProperty));
                    //        NSString *lastname = CFBridgingRelease(ABRecordCopyValue(record, kABPersonLastNameProperty));
                    for (CFIndex j=0; j < ABMultiValueGetCount(emails); j++) {
                        NSString* email = (__bridge NSString*)ABMultiValueCopyValueAtIndex(emails, j);
                        //            NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] initWithCapacity:1];
                        //            [dictionary setObject:email forKey:@"email"];
                        //            [dictionary setObject:firstname forKey:@"first"];
                        //            [dictionary setObject:lastname forKey:@"last"];
                        [allObjects addObject:email];
                    }
                    
                    ABMultiValueRef phones = ABRecordCopyValue(record, kABPersonPhoneProperty);
                    
                    for (CFIndex j=0; j < ABMultiValueGetCount(phones); j++) {
                        NSString* email = (__bridge NSString *)(ABMultiValueCopyValueAtIndex(phones, j));
                        email = [email stringByReplacingOccurrencesOfString:@" " withString:@""];
                        email = [email stringByReplacingOccurrencesOfString:@"(" withString:@""];
                        email = [email stringByReplacingOccurrencesOfString:@")" withString:@""];
                        email = [email stringByReplacingOccurrencesOfString:@"-" withString:@""];
                        [allObjects addObject:email];
                    }
                    
                }
                
                [self performSegueWithIdentifier:@"NoFriends" sender:allObjects];
                
            } else {
                [SVProgressHUD showErrorWithStatus:@"Please change your privacy settings to import!"];
            }
            
        });
    }
    else if (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusAuthorized) {
        // The user has previously given access skip check
        NSArray *abContactArray = [[NSArray alloc] init];
        NSArray *originalArray = CFBridgingRelease(ABAddressBookCopyArrayOfAllPeople(addressBook));
        abContactArray = [originalArray sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
            ABRecordRef record1 = (__bridge ABRecordRef)obj1; // get address book record
            NSString *firstName1 = CFBridgingRelease(ABRecordCopyValue(record1, kABPersonFirstNameProperty));
            NSString *lastName1 = CFBridgingRelease(ABRecordCopyValue(record1, kABPersonLastNameProperty));
            
            ABRecordRef record2 = (__bridge ABRecordRef)obj2; // get address book record
            NSString *firstName2 = CFBridgingRelease(ABRecordCopyValue(record2, kABPersonFirstNameProperty));
            NSString *lastName2 = CFBridgingRelease(ABRecordCopyValue(record2, kABPersonLastNameProperty));
            
            NSComparisonResult result = [lastName1 compare:lastName2];
            if (result != NSOrderedSame)
                return result;
            else
                return [firstName1 compare:firstName2];
        }];
        
        NSMutableArray *allObjects = [[NSMutableArray alloc] initWithCapacity:abContactArray.count];
        
        for (id object in abContactArray) {
            ABRecordRef record = (__bridge ABRecordRef)object; // get address book record
            ABMultiValueRef emails = ABRecordCopyValue(record, kABPersonEmailProperty);
            //        NSString *firstname = CFBridgingRelease(ABRecordCopyValue(record, kABPersonFirstNameProperty));
            //        NSString *lastname = CFBridgingRelease(ABRecordCopyValue(record, kABPersonLastNameProperty));
            for (CFIndex j=0; j < ABMultiValueGetCount(emails); j++) {
                NSString* email = (__bridge NSString*)ABMultiValueCopyValueAtIndex(emails, j);
                //            NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] initWithCapacity:1];
                //            [dictionary setObject:email forKey:@"email"];
                //            [dictionary setObject:firstname forKey:@"first"];
                //            [dictionary setObject:lastname forKey:@"last"];
                [allObjects addObject:email];
            }
            
            ABMultiValueRef phones = ABRecordCopyValue(record, kABPersonPhoneProperty);
            
            for (CFIndex j=0; j < ABMultiValueGetCount(phones); j++) {
                NSString* email = (__bridge NSString *)(ABMultiValueCopyValueAtIndex(phones, j));
                email = [email stringByReplacingOccurrencesOfString:@" " withString:@""];
                email = [email stringByReplacingOccurrencesOfString:@"(" withString:@""];
                email = [email stringByReplacingOccurrencesOfString:@")" withString:@""];
                email = [email stringByReplacingOccurrencesOfString:@"-" withString:@""];
                [allObjects addObject:email];
            }
            
        }
        
        [self performSegueWithIdentifier:@"NoFriends" sender:allObjects];
    } else {
        FUIAlertView *alertView = [[FUIAlertView alloc]
                                   initWithTitle:@"Error!"
                                   message:@"Please change privacy settings in the Settings App to import!"
                                   delegate:self
                                   cancelButtonTitle:@"Okay"
                                   otherButtonTitles:nil];
        
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
        // The user has previously denied access
        // Send an alert telling user to change privacy setting in settings app
    }
}

- (void)alertView:(FUIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == TAG_NOFRIENDS) {
        if (buttonIndex == 1) {
            [self noFriends];
        }
    }
}


@end
