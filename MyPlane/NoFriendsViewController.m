//
//  NoFriendsViewController.m
//  MyPlane
//
//  Created by Abhijay Bhatnagar on 9/4/13.
//  Copyright (c) 2013 Acubed Productions. All rights reserved.
//

#import "NoFriendsViewController.h"
#import "Reachability.h"

@interface NoFriendsViewController ()

@end

@implementation NoFriendsViewController {
    NSMutableArray *friendsArray;
    NSMutableArray *sentFriendRequestsArray;
    NSMutableArray *friendsObjectId;
    NSMutableArray *sentFriendRequestsObjectId;
    Reachability *reachability;
    UserInfo *userObject;
    BOOL isForMessages;
}

- (id)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        self.pullToRefreshEnabled = NO;
        self.loadingViewEnabled = YES;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
//    NSLog(@"%@", self.emails);
    
    //self.searchResults = [NSMutableArray array];
    //friendsUNArray = [NSMutableArray array];
    [self configureViewController];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reachabilityChanged:) name:kReachabilityChangedNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(close) name:@"closeNoFriend" object:nil];
    reachability = [Reachability reachabilityForInternetConnection];
    [reachability startNotifier];
    
    if(reachability.currentReachabilityStatus == NotReachable) {
        [self dismissViewControllerAnimated:YES completion:^{
            [SVProgressHUD showErrorWithStatus:@"Internet Connect Failed"];
        }];
	}
    
    [self getIDs];
    
}

- (void)reachabilityChanged:(NSNotification*)notification
{
	if(reachability.currentReachabilityStatus == NotReachable) {
        [self dismissViewControllerAnimated:YES completion:^{
            [SVProgressHUD showErrorWithStatus:@"Internet Connect Failed"];
        }];
	}
}

-(void)configureViewController {
    UIImageView *av = [[UIImageView alloc] init];
    av.backgroundColor = [UIColor clearColor];
    av.opaque = NO;
    UIImage *background = [UIImage imageNamed:@"tableBackground"];
    av.image = background;
    
    self.tableView.rowHeight = 70;
    
    self.tableView.backgroundView = av;
}

- (PFQuery *)queryForTable
{
//    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"%@ CONTAINS email OR %@ CONTAINS phone", self.emails, self.emails];
//    PFQuery *userQuery = [PFQuery queryWithClassName:@"User" predicate:predicate];
    PFQuery *userQuery = [PFUser query];
    [userQuery whereKey:@"email" containedIn:self.emails];
    
    PFQuery *que2 = [PFUser query];
    [que2 whereKey:@"phone" containedIn:self.emails];
    
    PFQuery *newQuery = [PFQuery orQueryWithSubqueries:[NSArray arrayWithObjects:userQuery, que2, nil]];
    
    PFQuery *query = [UserInfo query];
    [query whereKey:@"user" matchesKey:@"username" inQuery:newQuery];
    [query includeKey:@"friends"];
    [query includeKey:@"sentFriendRequests"];
    
    [query orderByDescending:@"lastName"];
    
    if (self.objects.count == 0) {
        query.cachePolicy = kPFCachePolicyNetworkOnly;
    }
    
    return query;
}

-(void)objectsWillLoad {
    [super objectsWillLoad];
    
}

- (void)objectsDidLoad:(NSError *)error
{
    [super objectsDidLoad:error];
//    [self.tableView reloadData];
    if (self.objects.count == 0) {
        FUIAlertView *alertView = [[FUIAlertView alloc]
                                   initWithTitle:@"No friends"
                                   message:@"You currently have no friends using this app. Would you like to invite them?"
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

- (void)alertView:(FUIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1) {
        [self showActionSheet];
    } else {
        [self done:nil];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)getIDs {
    friendsObjectId = [[NSMutableArray alloc]init];
    sentFriendRequestsObjectId = [[NSMutableArray alloc] init];
    
    PFQuery *query = [PFQuery queryWithClassName:@"UserInfo"];
    [query whereKey:@"user" equalTo:[PFUser currentUser].username];
    [query includeKey:@"friends"];
    query.cachePolicy = kPFCachePolicyCacheThenNetwork;
    [query getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error) {
        userObject = (UserInfo *)object;
        
        for (PFObject *object in userObject.friends) {
            [friendsObjectId addObject:[object objectId]];
        }
        for (PFObject *object in userObject.sentFriendRequests) {
            [sentFriendRequestsObjectId addObject:[object objectId]];
        }
        
        [self.tableView reloadData];
    }];
    
    //CurrentUser *sharedManager = [CurrentUser sharedManager];
    //userObject = sharedManager.currentUser;
    
//    friendsObjectId = [[NSMutableArray alloc]init];
//    sentFriendRequestsObjectId = [[NSMutableArray alloc] init];
//    
//    for (PFObject *object in userObject.friends) {
//        [friendsObjectId addObject:[object objectId]];
//    }
//    for (PFObject *object in userObject.sentFriendRequests) {
//        [sentFriendRequestsObjectId addObject:[object objectId]];
//    }
//    
//    [self.tableView reloadData];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath object:(PFObject *)object
{
    static NSString *uniqueIdentifier = @"Cell";
    
    PFTableViewCell *cell = (PFTableViewCell *) [self.tableView dequeueReusableCellWithIdentifier:uniqueIdentifier];
    
    UILabel *name = (UILabel *)[cell viewWithTag:2101];
    UILabel *username = (UILabel *)[cell viewWithTag:2102];
    PFImageView *picImage = (PFImageView *)[cell viewWithTag:2111];
    UIButton *addButton = (UIButton *)[cell viewWithTag:2121];
    addButton.enabled = YES;
    
    UserInfo *searchedUser = (UserInfo *)object;
    name.text = [NSString stringWithFormat:@"%@ %@", searchedUser.firstName, searchedUser.lastName];
    name.font = [UIFont flatFontOfSize:15];
    username.font = [UIFont flatFontOfSize:13];
    
    username.text = searchedUser.user;
    picImage.file = searchedUser.profilePicture;
    
    [picImage loadInBackground];
    
    if ([friendsObjectId containsObject:searchedUser.objectId] || [sentFriendRequestsObjectId containsObject:searchedUser.objectId]) {
        addButton.enabled = NO;
    }
    
    [addButton addTarget:self action:@selector(adjustButtonState:) forControlEvents:UIControlEventTouchUpInside];

    return cell;
}

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
    
    UILabel *nameLabel = (UILabel *)[cell viewWithTag:2101];
    UILabel *usernameLabel = (UILabel *)[cell viewWithTag:2101];
    
    nameLabel.font = [UIFont flatFontOfSize:16];
    usernameLabel.font = [UIFont flatFontOfSize:14];
    nameLabel.adjustsFontSizeToFitWidth = YES;
    usernameLabel.adjustsFontSizeToFitWidth = YES;
    
    nameLabel.textColor = [UIColor colorFromHexCode:@"A62A00"];
    
    
    return cell;
}

- (IBAction)adjustButtonState:(id)sender
{
    UITableViewCell *clickedCell = (UITableViewCell *)[[sender superview] superview];
    NSIndexPath *clickedButtonPath = [self.tableView indexPathForCell:clickedCell];
    UserInfo *friendAdded = (UserInfo *)[self.objects objectAtIndex:clickedButtonPath.row];
    //NSString *friendAddedName = friendAdded.user;
    NSString *friendObjectID = friendAdded.objectId;
    NSString *userID = userObject.objectId;
    
    UserInfo *friendToAdd = [UserInfo objectWithoutDataWithClassName:@"UserInfo" objectId:friendObjectID];
    UserInfo *userObjectID = [UserInfo objectWithoutDataWithClassName:@"UserInfo" objectId:userID];
    
    [sentFriendRequestsObjectId addObject:friendAdded.objectId];
    //[userObject addObject:friendAdded forKey:@"sentFriendRequests"];
    [userObject addObject:friendToAdd forKey:@"sentFriendRequests"];
    [userObject saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        CurrentUser *sharedManager = [CurrentUser sharedManager];
        sharedManager.currentUser = userObject;
        //[friendAdded addObject:userObject forKey:@"receivedFriendRequests"];
        [friendAdded addObject:userObjectID forKey:@"receivedFriendRequests"];
        [friendAdded saveInBackground];
        
        [SVProgressHUD showSuccessWithStatus:@"Friend Request Sent"];
        
        //        NSDictionary *data = @{
        //                               @"f": @"add"
        //                               };
        //
        //        PFQuery *pushQuery = [PFInstallation query];
        //        [pushQuery whereKey:@"user" equalTo:friendAddedName];
        //
        //        PFPush *push = [[PFPush alloc] init];
        //        [push setQuery:pushQuery];
        //        [push setData:data];
        //        [push sendPushInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        //        }];
        
    }];
    
    UIButton *addFriendButton = (UIButton *)sender;
    addFriendButton.enabled = NO;
    
}

- (IBAction)done:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)showTexts //deprecated for now
{
    ABAddressBookRef addressBook = ABAddressBookCreateWithOptions(NULL, NULL);
    ABAddressBookRequestAccessWithCompletion(addressBook, ^(bool granted, CFErrorRef error) {
        if (granted) {
    //    CFArrayRef people = ABAddressBookCopyArrayOfAllPeople(addressBook);
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
    
    //    NSMutableArray *array1 = [[NSMutableArray alloc] initWithCapacity:abContactArray.count];
    //    NSMutableArray *array2 = [[NSMutableArray alloc] initWithCapacity:abContactArray.count];
    //    NSMutableArray *array3 = [[NSMutableArray alloc] initWithCapacity:abContactArray.count];
    
    NSMutableArray *allObjects = [[NSMutableArray alloc] initWithCapacity:abContactArray.count];
    
    for (id object in abContactArray) {
        ABRecordRef record = (__bridge ABRecordRef)object; // get address book record
        NSString *firstname = CFBridgingRelease(ABRecordCopyValue(record, kABPersonFirstNameProperty));
        NSString *lastname = CFBridgingRelease(ABRecordCopyValue(record, kABPersonLastNameProperty));
        ABMultiValueRef emails = ABRecordCopyValue(record, kABPersonPhoneProperty);
        
        for (CFIndex j=0; j < ABMultiValueGetCount(emails); j++) {
            NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] initWithCapacity:1];
            NSString* email = (__bridge NSString *)(ABMultiValueCopyValueAtIndex(emails, j));
            [dictionary setObject:email forKey:@"email"];
            [dictionary setObject:firstname forKey:@"first"];
            [dictionary setObject:lastname forKey:@"last"];
            [allObjects addObject:dictionary];
        }
        CFRelease(emails);
    }
    
    isForMessages = YES;
    
    [self performSegueWithIdentifier:@"Mail" sender:allObjects];
        } else {
                NSLog(@"Address book error!!!: %@",error);
            }
        });
}

- (void)showEmail //deprecated for now
{
    ABAddressBookRef addressBook = ABAddressBookCreateWithOptions(NULL, NULL);
    ABAddressBookRequestAccessWithCompletion(addressBook, ^(bool granted, CFErrorRef error) {
        if (granted) {
    //    CFArrayRef people = ABAddressBookCopyArrayOfAllPeople(addressBook);
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
        NSString *firstname = CFBridgingRelease(ABRecordCopyValue(record, kABPersonFirstNameProperty));
        NSString *lastname = CFBridgingRelease(ABRecordCopyValue(record, kABPersonLastNameProperty));
        for (CFIndex j=0; j < ABMultiValueGetCount(emails); j++) {
            NSString* email = (__bridge NSString*)ABMultiValueCopyValueAtIndex(emails, j);
            NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] initWithCapacity:1];
            [dictionary setObject:email forKey:@"email"];
            [dictionary setObject:firstname forKey:@"first"];
            [dictionary setObject:lastname forKey:@"last"];
            [allObjects addObject:dictionary];
        }
        CFRelease(emails);
    }
    
    isForMessages = NO;
    
    [self performSegueWithIdentifier:@"Mail" sender:allObjects];
    
    //    ABPeoplePickerNavigationController *picker =
    //    [[ABPeoplePickerNavigationController alloc] init];
    //    picker.peoplePickerDelegate = self;
    //
    //    [self presentViewController:picker animated:YES completion:nil];
    //    MFMailComposeViewController *mViewController = [[MFMailComposeViewController alloc] init];
    //    mViewController.mailComposeDelegate = self;
    //    [mViewController setSubject:@"Try out Hey! Heads Up"];
    //    [mViewController setMessageBody:@"I am going to kill myself writing this" isHTML:NO];
    //    [mViewController setToRecipients:nil];
    //    [self presentViewController:mViewController animated:YES completion:nil];
        } else {
            NSLog(@"Address book error!!!: %@",error);
        }
    });
}

- (void)showActionSheet
{
    UIActionSheet *actionSheet = [[UIActionSheet alloc] init];
    actionSheet.title = @"Tell friends about Heads Up via";
    actionSheet.delegate = self;
    actionSheet.actionSheetStyle = UIActionSheetStyleAutomatic;
    [actionSheet addButtonWithTitle:@"Mail"];
    [actionSheet addButtonWithTitle:@"Text"];
    [actionSheet addButtonWithTitle:@"I'll do it later"];
    [actionSheet showInView:self.view];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0) {
        [self composeMail];
    } else if (buttonIndex == 1) {
        [self composeTexts];
    } else {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"Mail"]) {
        UINavigationController *nav = (UINavigationController *)[segue destinationViewController];
        ShareMailViewController *controller = (ShareMailViewController *)nav.topViewController;
        controller.dictionary = sender;
        controller.isFromNoFriend = YES;
        controller.isForMessages = isForMessages;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}

- (void)close
{
    [self dismissViewControllerAnimated:NO completion:nil];
}


- (void)composeMail
{
    MFMailComposeViewController *mViewController = [[MFMailComposeViewController alloc] init];
    mViewController.mailComposeDelegate = self;
    [mViewController setSubject:@"Hey! HeadsUp!"];
    [mViewController setMessageBody:@"Check out Hey! HeadsUp! on the app store at http://www.hupapp.com" isHTML:NO];
    //    [mViewController setToRecipients:self.selectedEmails];
    [self presentViewController:mViewController animated:YES completion:nil];
    
    [[mViewController navigationBar] setTintColor:[UIColor colorFromHexCode:@"FF4100"]];
    UIImage *image = [UIImage imageNamed: @"custom_nav_background.png"];
    UIImageView * iv = [[UIImageView alloc] initWithFrame:CGRectMake(0,0,320,42)];
    iv.image = image;
    iv.contentMode = UIViewContentModeCenter;
    [[[mViewController viewControllers] lastObject] navigationItem].titleView = iv;
    [[mViewController navigationBar] sendSubviewToBack:iv];
    
}

- (void)composeTexts{
    MFMessageComposeViewController *mViewController = [[MFMessageComposeViewController alloc] init];
    mViewController.messageComposeDelegate = self;
    [mViewController setBody:@"Check out Hey! HeadsUp! on the app store at http://www.hupapp.com"];
    //    [mViewController setRecipients:self.selectedEmails];
    if ([MFMessageComposeViewController canSendText]) {
        [self presentViewController:mViewController animated:YES completion:nil];
    } else {
        
    }
    
    [[mViewController navigationBar] setTintColor:[UIColor colorFromHexCode:@"FF4100"]];
    UIImage *image = [UIImage imageNamed: @"custom_nav_background.png"];
    UIImageView * iv = [[UIImageView alloc] initWithFrame:CGRectMake(0,0,320,42)];
    iv.image = image;
    iv.contentMode = UIViewContentModeCenter;
    [[[mViewController viewControllers] lastObject] navigationItem].titleView = iv;
    [[mViewController navigationBar] sendSubviewToBack:iv];
}

- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error
{
    [self becomeFirstResponder];
    [self dismissViewControllerAnimated:YES completion:^{
        //        [self dismissViewControllerAnimated:NO completion:^{
        //            if (self.isFromNoFriend) {
        //                [[NSNotificationCenter defaultCenter] postNotificationName:@"closeNoFriend" object:nil];
        //            }
        //        }];
    }];
}

- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result
{
    [self becomeFirstResponder];
    [self dismissViewControllerAnimated:YES completion:^{
        //        [self dismissViewControllerAnimated:NO completion:^{
        //            if (self.isFromNoFriend) {
        //                [[NSNotificationCenter defaultCenter] postNotificationName:@"closeNoFriend" object:nil];
        //            }
        //        }];
    }];
}

@end
