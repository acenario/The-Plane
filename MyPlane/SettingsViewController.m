//
//  SettingsViewController.m
//  MyPlane
//
//  Created by Arjun Bhatnagar on 7/13/13.
//  Copyright (c) 2013 Acubed Productions. All rights reserved.
//

#import "SettingsViewController.h"
#import "UserInfo.h"

@interface SettingsViewController ()

@end

@implementation SettingsViewController {
    NSString *firstName;
    NSString *lastName;
    NSString *Username;

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
    self.editButton.enabled = NO;
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receiveAddNotification:)
                                                 name:@"reloadFriends"
                                               object:nil];
    [self getUserInfo];
    
}
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receiveAddNotification:)
                                                 name:@"reloadProfile"
                                               object:nil];

    
}

- (void)receiveAddNotification:(NSNotification *) notification
{
    // [notification name] should always be @"TestNotification"
    // unless you use this method for observation of other notifications
    // as well.
    
     if ([[notification name] isEqualToString:@"reloadProfile"]) {
        NSLog (@"Successfully received the reload command!");
        [self getUserInfo];
    }
}


-(void)getUserInfo {
    PFQuery *userQuery = [UserInfo query];
    [userQuery whereKey:@"user" equalTo:[PFUser currentUser].username];
    
    [userQuery getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error) {
        
        [self updateLabelsForObject:object];
        
        
    }];
    
    userQuery.cachePolicy = kPFCachePolicyCacheThenNetwork;
}

-(void)updateLabelsForObject:(PFObject *)object {
    PFUser *user = [PFUser currentUser];
    self.firstNameField.text = [object objectForKey:@"firstName"];
    self.lastNameField.text = [object objectForKey:@"lastName"];
    self.usernameField.text = [object objectForKey:@"user"];
    self.emailField.text = [user email];
    
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(queue, ^{
        PFFile *pictureFile = [object objectForKey:@"profilePicture"];
        UIImage *fromUserImage = [[UIImage alloc] initWithData:pictureFile.getData];
        dispatch_async(dispatch_get_main_queue(), ^{
            self.profilePicture.image = fromUserImage;
            self.editButton.enabled = YES;

        });
    });
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)updateUserInfo:(EditSettingsViewController *)controller {
    [self getUserInfo];
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





@end
