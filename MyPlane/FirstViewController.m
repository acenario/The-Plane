//
//  FirstViewController.m
//  MyPlane
//
//  Created by Arjun Bhatnagar on 7/6/13.
//  Copyright (c) 2013 Acubed Productions. All rights reserved.
//

#import "FirstViewController.h"
//Login Code
#import "MyLoginViewController.h"
#import "MySignUpViewController.h"


@interface FirstViewController ()

@end

@implementation FirstViewController {
    NSString *displayName;
    NSString *theUsername;
    UIImage *defaultPic;
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
}

- (void)viewDidLoad
{
    [super viewDidLoad];
        
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receiveAddNotification2:)
                                                 name:@"spCenterTabbarItemTapped"
                                               object:nil];
    
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)receiveAddNotification2:(NSNotification *) notification
{
    // [notification name] should always be @"TestNotification"
    // unless you use this method for observation of other notifications
    // as well.
    
    if ([[notification name] isEqualToString:@"spCenterTabbarItemTapped"])
        NSLog (@"Successfully received the add notification for First!");
}



- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)logOut:(id)sender {
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

#pragma mark - LoginViewController Delegates

- (void)logInViewController:(PFLogInViewController *)logInController didFailToLogInWithError:(NSError *)error
{
    NSLog(@"Failed to log in...");
}

- (void)logInViewController:(PFLogInViewController *)logInController didLogInUser:(PFUser *)user
{
    PFInstallation *currentInstallation = [PFInstallation currentInstallation];
    [currentInstallation setObject:[PFUser currentUser].username forKey:@"user"];
    [currentInstallation saveInBackground];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"reloadFriends" object:nil];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"reloadProfile" object:nil];
    
    
    
    
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
    
    [self dismissViewControllerAnimated:YES completion:nil];
    [self performSegueWithIdentifier:@"firstTimeSettings" sender:nil];
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
