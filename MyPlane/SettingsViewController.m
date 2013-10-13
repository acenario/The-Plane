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
#import "KGStatusBar.h"

#import "ShareMailViewController.h"

#define TAG_WALKTHROUGH 1
#define TAG_NOFRIENDS 2
#define TAG_REPORT 3

@interface SettingsViewController ()

@property (nonatomic,strong) UzysSlideMenu *uzysSMenu;
@property (nonatomic,strong) UzysSlideMenu *adminMenu;
@property (nonatomic, strong) CurrentUser *sharedManager;

@end

@implementation SettingsViewController {
    NSString *firstName;
    NSString *lastName;
    NSString *Username;
    NSString *displayName;
    NSString *theUsername;
    //    UITextField *flagUserTextField;
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
    self.sharedManager = [CurrentUser sharedManager];
    reachability = [Reachability reachabilityForInternetConnection];
    [reachability startNotifier];
    
    UIImageView *av = [[UIImageView alloc] init];
    av.backgroundColor = [UIColor clearColor];
    av.opaque = NO;
    UIImage *background = [UIImage imageNamed:@"tableBackground"];
    av.image = background;
    
    self.tableView.backgroundView = av;
    [self configureFlatUI];
    
    UzysSMMenuItem *item0 = [[UzysSMMenuItem alloc] initWithTitle:@"Edit Common Tasks" image:[UIImage imageNamed:@"editTasks3"] action:^(UzysSMMenuItem *item) {
        [self showCommon];
    }];
    item0.tag = 0;
    
    UzysSMMenuItem *item1 = [[UzysSMMenuItem alloc] initWithTitle:@"Report User" image:[UIImage imageNamed:@"reportUsers3"] action:^(UzysSMMenuItem *item) {
        [self report];
    }];
    item0.tag = 1;
    
    UzysSMMenuItem *item2 = [[UzysSMMenuItem alloc] initWithTitle:@"Log Out" image:[UIImage imageNamed:@"logout3"] action:^(UzysSMMenuItem *item) {
        [self logOut];
    }];
    item0.tag = 2;
    
    UzysSMMenuItem *item3 = [[UzysSMMenuItem alloc] initWithTitle:@"Blocked Users" image:[UIImage imageNamed:@"blocked3"] action:^(UzysSMMenuItem *item) {
        [self performSegueWithIdentifier:@"BlockedUsers" sender:nil];
    }];
    item0.tag = 3;
    
    self.uzysSMenu = [[UzysSlideMenu alloc] initWithItems:@[item0,item3,item1,item2]];
    
    //Admin Code
    UzysSMMenuItem *item4 = [[UzysSMMenuItem alloc] initWithTitle:@"Admin Panel" image:[UIImage imageNamed:@"kickUsers3"] action:^(UzysSMMenuItem *item) {
        [self performSegueWithIdentifier:@"AdminPanel" sender:nil];
    }];
    
    self.adminMenu = [[UzysSlideMenu alloc] initWithItems:@[item0,item3,item1,item2,item4]];
    //
    
    
//    if (self.sharedManager.currentUser.adminRank > 0) {
//        UzysSMMenuItem *item4 = [[UzysSMMenuItem alloc] initWithTitle:@"Admin Panel" image:[UIImage imageNamed:@"kickUsers3"] action:^(UzysSMMenuItem *item) {
//            [self performSegueWithIdentifier:@"AdminPanel" sender:nil];
//        }];
//        self.uzysSMenu = [[UzysSlideMenu alloc] initWithItems:@[item0,item3,item1,item2,item4]];
//    } else {
//        self.uzysSMenu = [[UzysSlideMenu alloc] initWithItems:@[item0,item3,item1,item2]];
//    }
    
    
    [self.view addSubview:self.uzysSMenu];
    [self.view addSubview:self.adminMenu];
    
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
        [self presentViewController:logInViewController animated:YES completion:nil];
    } else {
        self.sharedManager = [CurrentUser sharedManager];
        [self reloadInfo];
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
    [self performSelector:@selector(checkHasFriends) withObject:nil afterDelay:1];
    
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
    //    alertView.tag = TAG_WALKTHROUGH;
    //
    //    [alertView show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (alertView.tag == TAG_WALKTHROUGH) {
        if (buttonIndex == 1) {
            [self performSegueWithIdentifier:@"Tutorial" sender:nil];
        } else {
            [self performSelector:@selector(checkHasFriends) withObject:nil afterDelay:1];
        }
    } else if (alertView.tag == TAG_NOFRIENDS){
        if (buttonIndex == 1) {
            [self noFriends];
        }
    } else if (alertView.tag == TAG_REPORT){
        if (buttonIndex == 1) {
            NSString *username = [alertView textFieldAtIndex:0].text;
            NSString *strippedUserName = [username stringByReplacingOccurrencesOfString:@" " withString:@""];
            NSString *reason = [alertView textFieldAtIndex:1].text;
            if (strippedUserName.length > 0) {
                PFQuery *userQuery = [UserInfo query];
                [userQuery whereKey:@"user" equalTo:strippedUserName];
                [userQuery getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error) {
                    [object setObject:[NSNumber numberWithBool:YES] forKey:@"flagged"];
                    [object setObject:reason forKey:@"fReason"];
                    
                    [object saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                        if (succeeded) {
                            [SVProgressHUD showSuccessWithStatus:@"Reported User!"];
                        } else {
                            NSLog(@"%@",error);
                        }
                    }];
                    
                    if (error) {
                        [SVProgressHUD showErrorWithStatus:@"User does not exist!"];
                    }
                    
                }];
                
            }
            
        }
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
    if (self.adminMenu.state == STATE_FULL_MENU) {
        [self.adminMenu setState:STATE_ICON_MENU animated:YES];
    }
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (self.uzysSMenu.state == STATE_FULL_MENU) {
        [self.uzysSMenu setState:STATE_ICON_MENU animated:YES];
    }
    if (self.adminMenu.state == STATE_FULL_MENU) {
        [self.adminMenu setState:STATE_ICON_MENU animated:YES];
    }
}

- (IBAction)showMenu:(id)sender {
    //self.uzysSMenu.hidden = NO;
    
    if (self.sharedManager.currentUser.adminRank != 0) {
        self.adminMenu.hidden = NO;
        if (self.adminMenu.state == STATE_FULL_MENU) {
            [self.adminMenu setState:STATE_ICON_MENU animated:YES];
        } else {
            [self.adminMenu setState:STATE_FULL_MENU animated:YES];
        }
    } else {
        self.adminMenu.hidden = YES;
        if (self.uzysSMenu.state == STATE_FULL_MENU) {
            [self.uzysSMenu setState:STATE_ICON_MENU animated:YES];
        } else {
            [self.uzysSMenu setState:STATE_FULL_MENU animated:YES];
        }
    }
    
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
        //ARJUN
        //REMOVE CODE BELOW
//        UINavigationController *nav = (UINavigationController *)[segue destinationViewController];
//        AddReminderViewController *controller = (AddReminderViewController *)nav.topViewController;
//        controller.recipient = self.sharedManager.currentUser;
//        controller.currentUser = self.sharedManager.currentUser;
    } else if ([segue.identifier isEqualToString:@"firstTimeSettings"]) {
        UINavigationController *nav = (UINavigationController *)[segue destinationViewController];
        firstTimeSettingsViewController *controller = (firstTimeSettingsViewController *)nav.topViewController;
        controller.delegate = self;
    } else if ([segue.identifier isEqualToString:@"Mail"]) {
        UINavigationController *nav = (UINavigationController *)[segue destinationViewController];
        ShareMailViewController *controller = (ShareMailViewController *)nav.topViewController;
        controller.dictionary = sender;
        controller.isForMessages = isForMessages;
    }else if ([segue.identifier isEqualToString:@"NoFriends"]) {
        UINavigationController *nav = (UINavigationController *)[segue destinationViewController];
        NoFriendsViewController *controller = (NoFriendsViewController *)nav.topViewController;
        controller.emails = sender;
        //        controller.delegate = self;
    } else if ([segue.identifier isEqualToString:@"Tutorial"]) {
        TutorialViewController *controller = [segue destinationViewController];
        controller.delegate = self;
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
    cell.textLabel.font = [UIFont flatFontOfSize:17];
    
    if (indexPath.section == 3) {
        cell.textLabel.textColor = [UIColor pomegranateColor];
    }
    
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
    
    if (indexPath.section == 3) {
        [self contactSupport];
    }
    
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
}

-(void)contactSupport {
    NSString *message = [NSString stringWithFormat:@"Hey! It's %@, \n \n",self.sharedManager.currentUser.user];
    NSArray *emailArray = [[NSArray alloc]initWithObjects:@"support@arjunb.com", nil];
        MFMailComposeViewController *mViewController = [[MFMailComposeViewController alloc] init];
        mViewController.mailComposeDelegate = self;
        [mViewController setSubject:@"[SUPPORT REQUEST]"];
        [mViewController setMessageBody:message isHTML:NO];
        [mViewController setToRecipients:emailArray];
        [self presentViewController:mViewController animated:YES completion:nil];
        
        [[mViewController navigationBar] setTintColor:[UIColor colorFromHexCode:@"FF4100"]];
        UIImage *image = [UIImage imageNamed: @"custom_nav_background.png"];
        UIImageView * iv = [[UIImageView alloc] initWithFrame:CGRectMake(0,0,320,42)];
        iv.image = image;
        iv.contentMode = UIViewContentModeCenter;
        [[[mViewController viewControllers] lastObject] navigationItem].titleView = iv;
        [[mViewController navigationBar] sendSubviewToBack:iv];
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
                      cancelButtonTitle:@"OK"
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

- (void)showTexts //deprecated for now
{
    //    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    //    dispatch_async(queue, ^{
    ABAddressBookRef addressBook = ABAddressBookCreateWithOptions(NULL, NULL);
    ABAddressBookRequestAccessWithCompletion(addressBook, ^(bool granted, CFErrorRef error) {
        if (granted) {
            //    dispatch_async(dispatch_get_main_queue(), ^{
            //    });
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
                    
                    if (email == nil) {
                        email = @"No email";
                    }
                    
                    if (firstname == nil) {
                        firstname = @"No Name";
                    }
                    
                    if (lastname == nil) {
                        lastname = @" ";
                    }
                    
                    [dictionary setObject:email forKey:@"email"];
                    [dictionary setObject:firstname forKey:@"first"];
                    [dictionary setObject:lastname forKey:@"last"];
                    [allObjects addObject:dictionary];
                }
                CFRelease(emails);
            }
            isForMessages = YES;
            //            dispatch_async(dispatch_get_main_queue(), ^{
            [SVProgressHUD dismiss];
            //            });
            [self performSegueWithIdentifier:@"Mail" sender:allObjects];
            
        } else {
            NSLog(@"Address book error!!!: %@",error);
        }
    });
    //    });
}

- (void)composeMail
{
    MFMailComposeViewController *mViewController = [[MFMailComposeViewController alloc] init];
    mViewController.mailComposeDelegate = self;
    [mViewController setSubject:@"Try out Hey! Heads Up"];
    [mViewController setMessageBody:@"Insert sample promotion code" isHTML:NO];
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
    [mViewController setBody:@"Insert sample promotion code"];
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
            
            if ((firstname) && !(lastname)) {
                lastname = firstname;
                firstname = @" ";
            }
            
            if (email == nil) {
                email = @"No email";
            }
            
            if (firstname == nil) {
                firstname = @"No Name";
            }
            
            if (lastname == nil) {
                lastname = @" ";
            }
            
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
//
//    NSString* someText = @"Default Text";
//    NSArray* dataToShare = @[someText]; 
//    
//    UIActivityViewController* activityViewController =
//    [[UIActivityViewController alloc] initWithActivityItems:dataToShare
//                                      applicationActivities:nil];
//    [self presentViewController:activityViewController animated:YES completion:^{}];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0) {
        [self composeMail];
    } else if (buttonIndex == 1) {
        [self composeTexts];
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

- (void)checkHasFriends
{
    if (self.sharedManager.currentUser.friends.count == 1) {
        
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

- (void)tutDidFinish:(TutorialViewController *)controller
{
    [self performSelector:@selector(checkHasFriends) withObject:nil afterDelay:1];
}

- (void)report
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Report User For Inappropriate Content" message:nil delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Report",nil];
    alert.alertViewStyle = UIAlertViewStyleLoginAndPasswordInput;
    alert.tag = TAG_REPORT;
    [[alert textFieldAtIndex:0] setPlaceholder:@"Username"];
    [[alert textFieldAtIndex:1] setSecureTextEntry:NO];
    [[alert textFieldAtIndex:1] setPlaceholder:@"Reason"];
    //    UITextField *textField = [alert textFieldAtIndex:0];
    
    //    flagUserTextField = textField;
    
    [alert show];
}


@end
