//
//  SettingsViewController.m
//  MyPlane
//
//  Created by Arjun Bhatnagar on 7/13/13.
//  Copyright (c) 2013 Acubed Productions. All rights reserved.
//

#import "SettingsViewController.h"
#import "UserInfo.h"
#import "MyLoginViewController.h"
#import "MySignUpViewController.h"
#import "CurrentUser.h"
#import "AddReminderViewController.h"
#import "Reachability.h"
#import <Social/Social.h>
#import <Accounts/Accounts.h>

#import "ShareMailViewController.h"


@interface SettingsViewController ()

@property (nonatomic,strong) UzysSlideMenu *uzysSMenu;
@property (nonatomic, strong) CurrentUser *sharedManager;

@end

@implementation SettingsViewController {
    NSString *firstName;
    NSString *lastName;
    NSString *Username;
    NSString *displayName;
    NSString *theUsername;
    UIImage *defaultPic;
    //BOOL menuCheck;
    BOOL isForMessages;
    Reachability *reachability;
    SLComposeViewController *mySLComposerSheet;
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
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reachabilityChanged:) name:kReachabilityChangedNotification object:nil];
    reachability = [Reachability reachabilityForInternetConnection];
    [reachability startNotifier];
    
    UIImageView *av = [[UIImageView alloc] init];
    av.backgroundColor = [UIColor clearColor];
    av.opaque = NO;
    UIImage *background = [UIImage imageNamed:@"tableBackground"];
    av.image = background;
    
    self.tableView.backgroundView = av;
    [self configureFlatUI];
    
    UzysSMMenuItem *item0 = [[UzysSMMenuItem alloc] initWithTitle:@"Edit Common Tasks" image:[UIImage imageNamed:@"a0.png"] action:^(UzysSMMenuItem *item) {
        [self showCommon];
    }];
    item0.tag = 0;
    
    //    UzysSMMenuItem *item1 = [[UzysSMMenuItem alloc] initWithTitle:@"Favr Store" image:[UIImage imageNamed:@"a1.png"] action:^(UzysSMMenuItem *item) {
    //        [SVProgressHUD showErrorWithStatus:@"Implement the Store!"];
    //    }];
    //    item0.tag = 1;
    //
    UzysSMMenuItem *item2 = [[UzysSMMenuItem alloc] initWithTitle:@"Log Out" image:[UIImage imageNamed:@"a2.png"] action:^(UzysSMMenuItem *item) {
        [self logOut];
    }];
    item0.tag = 2;
    
    UzysSMMenuItem *item3 = [[UzysSMMenuItem alloc] initWithTitle:@"Blocked Users" image:[UIImage imageNamed:@"a2.png"] action:^(UzysSMMenuItem *item) {
        [self performSegueWithIdentifier:@"BlockedUsers" sender:nil];
    }];
    item0.tag = 3;

    
    self.uzysSMenu = [[UzysSlideMenu alloc] initWithItems:@[item0,item3,item2]];
    [self.view addSubview:self.uzysSMenu];
    
    self.editButton.enabled = NO;
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receiveAddNotification:)
                                                 name:@"reloadFriends"
                                               object:nil];
    
    self.firstNameField.hidden = YES;
    self.fullNameField.placeholder = @"";
    self.usernameField.placeholder = @"";
    self.emailField.placeholder = @"";
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receiveAddNotification:)
                                                 name:@"settingsCenterTabbarItemTapped"
                                               object:nil];
    
    [self getUserInfo];
    
    
    
    /*self.infoCell = [UITableViewCell configureFlatCellWithColor:[UIColor greenSeaColor]
     selectedColor:[UIColor cloudsColor]
     style:UITableViewCellStyleDefault
     reuseIdentifier:@"Cell"];
     
     self.infoCell.cornerRadius = 5.0f;
     
     self.infoCell.separatorHeight = 2.0f; // optional*/
    
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    //menuCheck = YES;
    //self.uzysSMenu.hidden = YES;
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
        self.sharedManager = [CurrentUser sharedManager];
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receiveAddNotification:)
                                                 name:@"reloadProfile"
                                               object:nil];
    
    if (reachability.currentReachabilityStatus == NotReachable) {
        self.editButton.enabled = NO;
    }
}

- (void)reachabilityChanged:(NSNotification*) notification
{
    if (reachability.currentReachabilityStatus == NotReachable) {
        self.editButton.enabled = NO;
    } else {
        [self reloadInfo];
    }
}

- (void)firstTimePresentTutorial:(firstTimeSettingsViewController *)controller {
    NSString *message = @"Would you like to a see a walkthrough of the app?";
    
    UIColor *barColor = [UIColor colorFromHexCode:@"A62A00"];
    
    FUIAlertView *alertView = [[FUIAlertView alloc]
                               initWithTitle:@"Walkthrough"
                               message:message
                               delegate:self
                               cancelButtonTitle:@"No"
                               otherButtonTitles:@"Yes", nil];
    
    alertView.titleLabel.textColor = [UIColor cloudsColor];
    alertView.titleLabel.font = [UIFont boldFlatFontOfSize:17];
    alertView.messageLabel.textColor = [UIColor whiteColor];
    alertView.messageLabel.font = [UIFont flatFontOfSize:15];
    alertView.backgroundOverlay.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.2f];
    alertView.alertContainer.backgroundColor = barColor;
    alertView.defaultButtonColor = [UIColor colorFromHexCode:@"FF9773"];
    alertView.defaultButtonShadowColor = [UIColor colorFromHexCode:@"BF5530"];
    alertView.defaultButtonFont = [UIFont boldFlatFontOfSize:16];
    alertView.defaultButtonTitleColor = [UIColor whiteColor];
    
    
    [alertView show];
}

- (void)alertView:(FUIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 1) {
        [self performSegueWithIdentifier:@"Tutorial" sender:nil];
    }
}

-(void)configureFlatUI {
    UIFont *myFont = [UIFont flatFontOfSize:16];
    UIColor *myColor = [UIColor colorFromHexCode:@"FF7140"];
    UIColor *unColor = [UIColor colorFromHexCode:@"A62A00"];
    
    
    self.fullNameField.font = myFont;
    self.fullNameField.textColor = unColor;
    self.fullNameField.adjustsFontSizeToFitWidth = YES;
    
    self.lastNameField.font = myFont;
    self.lastNameField.textColor = myColor;
    self.lastNameField.adjustsFontSizeToFitWidth = YES;
    
    self.emailField.font = myFont;
    self.emailField.textColor = myColor;
    self.emailField.adjustsFontSizeToFitWidth = YES;
    
    self.usernameField.font = myFont;
    self.usernameField.textColor = myColor;
    self.usernameField.adjustsFontSizeToFitWidth = YES;
    
    
    
}

-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    if (self.uzysSMenu.state == STATE_FULL_MENU) {
        [self.uzysSMenu setState:STATE_ICON_MENU animated:YES];
    }
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (self.uzysSMenu.state == STATE_FULL_MENU) {
        [self.uzysSMenu setState:STATE_ICON_MENU animated:YES];
    }
}

- (IBAction)showMenu:(id)sender {
    //self.uzysSMenu.hidden = NO;
    
    if (self.uzysSMenu.state == STATE_FULL_MENU) {
        [self.uzysSMenu setState:STATE_ICON_MENU animated:YES];
    } else {
        [self.uzysSMenu setState:STATE_FULL_MENU animated:YES];
    }
    
//    if (menuCheck == YES) {
//        //[self.uzysSMenu toggleMenu];
//        [self.uzysSMenu setState:STATE_FULL_MENU animated:YES];
//        menuCheck = NO;
//    } else {
//        //[self.uzysSMenu openIconMenu];
//        [self.uzysSMenu setState:STATE_ICON_MENU animated:YES];
//        menuCheck = YES;
//        
//    }
    
}

- (void)receiveAddNotification:(NSNotification *) notification
{
    // [notification name] should always be @"TestNotification"
    // unless you use this method for observation of other notifications
    // as well.
    
    if ([[notification name] isEqualToString:@"reloadProfile"]) {
        NSLog (@"Successfully received the reload command!");
        [self reloadInfo];
    } else if ([[notification name] isEqualToString:@"settingsCenterTabbarItemTapped"]) {
        
        [self performSegueWithIdentifier:@"AddReminder" sender:nil];
        
    }
}


-(void)getUserInfo {
    PFQuery *userQuery = [UserInfo query];
    [userQuery whereKey:@"user" equalTo:[PFUser currentUser].username];
    userQuery.cachePolicy = kPFCachePolicyCacheThenNetwork;
    [userQuery getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error) {
        
        [self updateLabelsForObject:object];
        
        if (error) {
            NSLog(@"There was an error in GetUserInfo of Settings: %@", error);
        }
        
        
    }];
    
}

-(void)reloadInfo {
    PFQuery *reloadUserQuery = [UserInfo query];
    [reloadUserQuery whereKey:@"user" equalTo:[PFUser currentUser].username];
    reloadUserQuery.cachePolicy = kPFCachePolicyNetworkOnly;
    [reloadUserQuery getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error) {
        
        [self updateLabelsForObject:object];
        
        if (error) {
            NSLog(@"There was an error in GetUserInfo of Settings: %@", error);
        }
        
        
    }];
    
}


-(void)updateLabelsForObject:(PFObject *)object {
    
    PFUser *user = [PFUser currentUser];
    NSString *FName = [object objectForKey:@"firstName"];
    NSString *LName = [object objectForKey:@"lastName"];
    
    if (!(FName == NULL || LName == NULL)) {
        self.fullNameField.text = [NSString stringWithFormat:@"%@ %@", FName, LName];
    }
    self.firstNameField.text = [object objectForKey:@"firstName"];
    self.lastNameField.text = [object objectForKey:@"lastName"];
    self.usernameField.text = [object objectForKey:@"user"];
    self.emailField.text = [user email];
    self.profilePicture.file = [object objectForKey:@"profilePicture"];
    if (reachability.currentReachabilityStatus == NotReachable) {
        self.editButton.enabled = NO;
    } else {
        self.editButton.enabled = YES;
    }
    [self.profilePicture loadInBackground];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)updateUserInfo:(EditSettingsViewController *)controller {
    [self reloadInfo];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"editInfo"]) {
        UINavigationController *navController = (UINavigationController *)[segue destinationViewController];
        EditSettingsViewController *controller = (EditSettingsViewController *)navController.topViewController;
        controller.delegate = self;
        
        controller.firstname = self.firstNameField.text;
        controller.lastname = self.lastNameField.text;
        controller.email = self.emailField.text;
        controller.profilePicture = self.profilePicture.image;
        controller.gracePeriod = self.sharedManager.currentUser.gracePeriod;
    } else if ([segue.identifier isEqualToString:@"EditCommonTasks"]) {
        CommonTasksViewController *controller = [segue destinationViewController];
        controller.isFromSettings = YES;
    } else if ([segue.identifier isEqualToString:@"AddReminder"]) {
        UINavigationController *nav = (UINavigationController *)[segue destinationViewController];
        AddReminderViewController *controller = (AddReminderViewController *)nav.topViewController;
        controller.recipient = self.sharedManager.currentUser;
        controller.currentUser = self.sharedManager.currentUser;
    } else if ([segue.identifier isEqualToString:@"firstTimeSettings"]) {
        UINavigationController *nav = (UINavigationController *)[segue destinationViewController];
        firstTimeSettingsViewController *controller = (firstTimeSettingsViewController *)nav.topViewController;
        controller.delegate = self;
    } else if ([segue.identifier isEqualToString:@"Mail"]) {
        UINavigationController *nav = (UINavigationController *)[segue destinationViewController];
        ShareMailViewController *controller = (ShareMailViewController *)nav.topViewController;
        controller.dictionary = sender;
        controller.isForMessages = isForMessages;
    }
}

- (UIImage *)imageWithRoundedCornersSize:(float)cornerRadius usingImage:(UIImage *)original
{
    UIImageView *imageView = [[UIImageView alloc] initWithImage:original];
    
    // Begin a new image that will be the new image with the rounded corners
    // (here with the size of an UIImageView)
    UIGraphicsBeginImageContextWithOptions(imageView.bounds.size, NO, 1.0);
    
    // Add a clip before drawing anything, in the shape of an rounded rect
    [[UIBezierPath bezierPathWithRoundedRect:imageView.bounds
                                cornerRadius:cornerRadius] addClip];
    // Draw your image
    [original drawInRect:imageView.bounds];
    
    // Get the image, here setting the UIImageView image
    imageView.image = UIGraphicsGetImageFromCurrentImageContext();
    
    // Lets forget about that we were drawing
    UIGraphicsEndImageContext();
    
    return imageView.image;
}

-(UITableViewCell *)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    UIColor *selectedColor = [UIColor colorFromHexCode:@"FF7140"];
    
    
    UIImageView *av = [[UIImageView alloc] init];
    av.backgroundColor = [UIColor clearColor];
    av.opaque = NO;
    UIImage *background = [UIImage imageWithColor:[UIColor whiteColor] cornerRadius:5.0f];
    av.image = background;
    cell.backgroundView = av;
    
    
    UIView *bgView = [[UIView alloc]init];
    bgView.backgroundColor = selectedColor;
    
    
    [cell setSelectedBackgroundView:bgView];
    
    
    
    
    return cell;
    
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 2) {
        if (indexPath.row == 0) {
            [self showActionSheet];
        }
    }
    
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - Log In/Out Code

- (IBAction)logOut {
    [self resetAllTabs];
    [PFUser logOut];
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
    
}

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

-(void)addSelfToFriends {
    PFQuery *personQuery = [UserInfo query];
    [personQuery whereKey:@"user" equalTo:[PFUser currentUser].username];
    [personQuery includeKey:@"friends"];
    
    
    [personQuery getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error) {
        //Add Singleton reference
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


#pragma mark - SignUpViewController Delegates

- (void)signUpViewController:(PFSignUpViewController *)signUpController didSignUpUser:(PFUser *)user {
    defaultPic = [UIImage imageNamed:@"first"];
    UserInfo *userObject = [UserInfo object];
    NSData *data = UIImagePNGRepresentation(defaultPic);
    PFFile *imageupload = [PFFile fileWithName:@"myProfilePicture.png" data:data];
    [userObject setObject:displayName forKey:@"user"];
    [userObject setObject:displayName forKey:@"displayName"];
    [userObject setObject:imageupload forKey:@"profilePicture"];
    [userObject setObject:[NSNumber numberWithInt:0] forKey:@"gracePeriod"];
    [userObject setObject:[NSNumber numberWithInt:0] forKey:@"adminRank"];
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

- (void)showCommon
{
    //    UINavigationController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"commonTasks"];
    //    CommonTasksViewController *cVC = (CommonTasksViewController *)[vc topViewController];
    //    cVC.isFromSettings = YES;
    //    MZFormSheetController *formSheet = [[MZFormSheetController alloc] initWithViewController:vc];
    //    formSheet.shouldDismissOnBackgroundViewTap = YES;
    //    formSheet.transitionStyle = MZFormSheetTransitionStyleSlideAndBounceFromRight;
    //    formSheet.cornerRadius = 9.0;
    //    formSheet.portraitTopInset = 6.0;
    //    formSheet.landscapeTopInset = 6.0;
    //    formSheet.presentedFormSheetSize = CGSizeMake(320, 200);
    //
    //
    //    formSheet.willPresentCompletionHandler = ^(UIViewController *presentedFSViewController){
    //        presentedFSViewController.view.autoresizingMask = presentedFSViewController.view.autoresizingMask | UIViewAutoresizingFlexibleWidth;
    //    };
    //
    //
    //    [formSheet presentWithCompletionHandler:^(UIViewController *presentedFSViewController) {
    //
    //
    //    }];
    [self performSegueWithIdentifier:@"EditCommonTasks" sender:nil];
}

- (void)unwindToSettings:(UIStoryboardSegue *)unwindSegue
{
    
}

- (void)resetAllTabs{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"reloadTabs" object:nil];
    for (id controller in self.tabBarController.viewControllers) {
        if ([controller isMemberOfClass:[UINavigationController class]]) {
            [controller popToRootViewControllerAnimated:NO];
        }
    }
}

- (void)showTexts
{
    ABAddressBookRef addressBook = ABAddressBookCreateWithOptions(NULL, NULL);
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
        ABMultiValueRef emails = ABRecordCopyValue(record, kABPersonPhoneProperty);
        NSString *firstname = CFBridgingRelease(ABRecordCopyValue(record, kABPersonFirstNameProperty));
        NSString *lastname = CFBridgingRelease(ABRecordCopyValue(record, kABPersonLastNameProperty));
        
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
}

- (void)showEmail
{
    ABAddressBookRef addressBook = ABAddressBookCreateWithOptions(NULL, NULL);
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
}

- (void)peoplePickerNavigationControllerDidCancel:(ABPeoplePickerNavigationController *)peoplePicker
{
    [self dismissViewControllerAnimated:YES completion:nil];
}


- (BOOL)peoplePickerNavigationController:(ABPeoplePickerNavigationController *)peoplePicker
      shouldContinueAfterSelectingPerson:(ABRecordRef)person {
    
    //    NSMutableArray *phone = [[NSMutableArray alloc] init];
    //    ABMultiValueRef phoneNumbers = ABRecordCopyValue(person,
    //                                                     kABPersonEmailProperty);
    //    if (ABMultiValueGetCount(phoneNumbers) > 0) {
    //        int i;
    //        for (i = 0; i < ABMultiValueGetCount(phoneNumbers); i++) {
    //            [phone addObject:(__bridge_transfer NSString*)ABMultiValueCopyValueAtIndex(phoneNumbers, i)];
    //        }
    //    }
    //
    //    NSLog(@"%@", phone);
    //    [self dismissViewControllerAnimated:YES completion:nil];
    
    return YES;
}

- (void)showActionSheet
{
    UIActionSheet *actionSheet = [[UIActionSheet alloc] init];
    actionSheet.title = @"Tell friends about Heads Up via";
    actionSheet.delegate = self;
    actionSheet.actionSheetStyle = UIActionSheetStyleAutomatic;
    [actionSheet addButtonWithTitle:@"Mail"];
    [actionSheet addButtonWithTitle:@"Text"];
    [actionSheet addButtonWithTitle:@"Facebook"];
    [actionSheet addButtonWithTitle:@"Twitter"];
    [actionSheet addButtonWithTitle:@"I'll do it later"];
    [actionSheet showInView:self.tabBarController.view];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0) {
        [self showEmail];
    } else if (buttonIndex == 1) {
        [self showTexts];
    } else if (buttonIndex == 2) {
        [self showFacebook];
    } else if (buttonIndex == 3) {
        [self showTwitter];
    }
    
}

-(void)showFacebook {
    
    if([SLComposeViewController isAvailableForServiceType:SLServiceTypeFacebook]) //check if Facebook Account is linked
    {
        mySLComposerSheet = [[SLComposeViewController alloc] init]; //initiate the Social Controller
        mySLComposerSheet = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeFacebook]; //Tell him with what social plattform to use it, e.g. facebook or twitter
        [mySLComposerSheet setInitialText:@""]; //the message you want to post
        //[mySLComposerSheet addImage:yourimage]; //an image you could post
        [mySLComposerSheet addURL:[NSURL URLWithString:@"http://google.com"]];
        //for more instance methodes, go here:https://developer.apple.com/library/ios/#documentation/NetworkingInternet/Reference/SLComposeViewController_Class/Reference/Reference.html#//apple_ref/doc/uid/TP40012205
        [self presentViewController:mySLComposerSheet animated:YES completion:nil];
    }
    [mySLComposerSheet setCompletionHandler:^(SLComposeViewControllerResult result) {
//        NSString *output;
//        switch (result) {
//            case SLComposeViewControllerResultCancelled:
//                output = @"Post Unsuccessful";
//                break;
//            case SLComposeViewControllerResultDone:
//                output = @"Post Successful";
//                break;
//            default:
//                break;
//        } //check if everythink worked properly. Give out a message on the state.
//        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Facebook" message:output delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
//        [alert show];
    }];
    
}

-(void)showTwitter {
    if([SLComposeViewController isAvailableForServiceType:SLServiceTypeTwitter]) //check if Facebook Account is linked
    {
        mySLComposerSheet = [[SLComposeViewController alloc] init]; //initiate the Social Controller
        mySLComposerSheet = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeTwitter]; //Tell him with what social plattform to use it, e.g. facebook or twitter
        [mySLComposerSheet setInitialText:@"Check out Hey HeadsUp on the App Store! It lets people remind you so you won't need your own calendar!"];
        [mySLComposerSheet addURL:[NSURL URLWithString:@"http://google.com"]];
        //the message you want to post
        //[mySLComposerSheet addImage:yourimage]; //an image you could post
        //for more instance methodes, go here:https://developer.apple.com/library/ios/#documentation/NetworkingInternet/Reference/SLComposeViewController_Class/Reference/Reference.html#//apple_ref/doc/uid/TP40012205
        [self presentViewController:mySLComposerSheet animated:YES completion:nil];
    }
    [mySLComposerSheet setCompletionHandler:^(SLComposeViewControllerResult result) {
//        NSString *output;
//        switch (result) {
//            case SLComposeViewControllerResultCancelled:
//                output = @"Tweet Unsuccessful";
//                break;
//            case SLComposeViewControllerResultDone:
//                output = @"Tweet Successful";
//                break;
//            default:
//                break;
//        } //check if everythink worked properly. Give out a message on the state.
//        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Facebook" message:output delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
//        [alert show];
    }];
    
}

- (BOOL)peoplePickerNavigationController:(ABPeoplePickerNavigationController *)peoplePicker
      shouldContinueAfterSelectingPerson:(ABRecordRef)person
                                property:(ABPropertyID)property
                              identifier:(ABMultiValueIdentifier)identifier
{
    // Only inspect the value if it’s an email
    // Obtains the email addres ana localized label from a PeoplePicker
    if (property == kABPersonEmailProperty) {
        ABMultiValueRef emails = ABRecordCopyValue(person, property);
        CFStringRef emailValueSelected = ABMultiValueCopyValueAtIndex(emails, identifier);
        CFStringRef emailLabelSelected = ABMultiValueCopyLabelAtIndex(emails, identifier);
        CFStringRef emailLabelSelectedLocalized = ABAddressBookCopyLocalizedLabel(ABMultiValueCopyLabelAtIndex(emails, identifier));
        NSLog(@"\n EmailValueSelected = %@ \n EmailLabelSelected = %@ \n \EmailLabeSelectedlLocalized = %@", emailValueSelected, emailLabelSelected, emailLabelSelectedLocalized);
        //        self.emailLabel.text = (__bridge NSString *)emailLabelSelectedLocalized;
        //        self.emailValue.text = (__bridge NSString *)emailValueSelected;
        // Return to the main view controller.
        [self dismissViewControllerAnimated:YES completion:nil];
        return NO;
    }
    return YES;
    
}

@end
