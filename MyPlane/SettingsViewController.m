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


@interface SettingsViewController ()

@end

@implementation SettingsViewController {
    NSString *firstName;
    NSString *lastName;
    NSString *Username;
    NSString *displayName;
    NSString *theUsername;
    UIImage *defaultPic;

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
    
    UIImageView *av = [[UIImageView alloc] init];
    av.backgroundColor = [UIColor clearColor];
    av.opaque = NO;
    UIImage *background = [UIImage imageNamed:@"tableBackground"];
    av.image = background;
    
    self.tableView.backgroundView = av;
    [self configureFlatUI];
    
    self.editButton.enabled = NO;
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receiveAddNotification:)
                                                 name:@"reloadFriends"
                                               object:nil];
    
    self.firstNameField.hidden = YES;
    self.fullNameField.placeholder = @"";
    self.usernameField.placeholder = @"";
    self.emailField.placeholder = @"";
    
    
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
    }

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receiveAddNotification:)
                                                 name:@"reloadProfile"
                                               object:nil];

    
}

-(void)configureFlatUI {
    UIFont *myFont = [UIFont flatFontOfSize:16];
    UIColor *myColor = [UIColor colorFromHexCode:@"FF7140"];
    UIColor *unColor = [UIColor colorFromHexCode:@"A62A00"];

    
    self.fullNameField.font = myFont;
    self.fullNameField.textColor = unColor;
    
    self.lastNameField.font = myFont;
    self.lastNameField.textColor = myColor;
    
    self.emailField.font = myFont;
    self.emailField.textColor = myColor;
    
    self.usernameField.font = myFont;
    self.usernameField.textColor = myColor;
    
    
    
}

- (void)receiveAddNotification:(NSNotification *) notification
{
    // [notification name] should always be @"TestNotification"
    // unless you use this method for observation of other notifications
    // as well.
    
     if ([[notification name] isEqualToString:@"reloadProfile"]) {
        NSLog (@"Successfully received the reload command!");
         [self reloadInfo];
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
    self.editButton.enabled = YES;
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

#pragma mark - Log In/Out Code

- (IBAction)logOut {
    [PFUser logOut];
    PFLogInViewController *logInViewController = [[PFLogInViewController alloc] init];
    logInViewController.delegate = self; // Set ourselves as the delegate
    
    // Create the sign up view controller
    PFSignUpViewController *signUpViewController = [[PFSignUpViewController alloc] init];
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
    
    [self dismissViewControllerAnimated:YES completion:nil];
    
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





@end
