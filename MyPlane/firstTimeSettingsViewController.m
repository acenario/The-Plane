//
//  firstTimeSettingsViewController.m
//  MyPlane
//
//  Created by Arjun Bhatnagar on 7/14/13.
//  Copyright (c) 2013 Acubed Productions. All rights reserved.
//

#import "firstTimeSettingsViewController.h"

@interface firstTimeSettingsViewController ()

@property (nonatomic) UIImagePickerController *imagePickerController;


@end

@implementation firstTimeSettingsViewController {
    BOOL checkFirstName;
    BOOL checkLastName;
    NSArray *friendsArray;
}

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
} 

- (void)getUserandSetObjects {
    PFQuery *queryUser = [PFQuery queryWithClassName:@"UserInfo"];
    [queryUser whereKey:@"user" equalTo:[PFUser currentUser].username];
    [queryUser includeKey:@"friends"];
    
    [queryUser getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error) {
        NSString *objectID = [object objectId];
        PFObject *userFriendObject = [PFObject objectWithoutDataWithClassName:@"UserInfo" objectId:objectID];
        
        [object addObject:userFriendObject forKey:@"friends"];
        [object saveInBackground];
        
    }];
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UITapGestureRecognizer *gestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideKeyboard)];
    [self.tableView addGestureRecognizer:gestureRecognizer];
    gestureRecognizer.cancelsTouchesInView = NO;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)showAlertwithString:(NSString *)message {
    
    NSInteger red   = 178;
    NSInteger green = 8;
    NSInteger blue  = 56;
    
    
    FUIAlertView *alertView = [[FUIAlertView alloc] initWithTitle:@"Error!"
                                                          message:message
                                                         delegate:nil cancelButtonTitle:@"Okay"
                                                otherButtonTitles:nil];
    alertView.titleLabel.textColor = [UIColor cloudsColor];
    alertView.titleLabel.font = [UIFont boldFlatFontOfSize:16];
    alertView.messageLabel.textColor = [UIColor cloudsColor];
    alertView.messageLabel.font = [UIFont flatFontOfSize:14];
    alertView.backgroundOverlay.backgroundColor = [UIColor clearColor];
    alertView.alertContainer.backgroundColor = [UIColor colorWithRed:red/255.0f green:green/255.0f blue:blue/255.0f alpha:1.0];
    alertView.defaultButtonColor = [UIColor cloudsColor];
    alertView.defaultButtonShadowColor = [UIColor asbestosColor];
    alertView.defaultButtonFont = [UIFont boldFlatFontOfSize:16];
    alertView.defaultButtonTitleColor = [UIColor asbestosColor];
    
    
    [alertView show];
}

- (void)updateAlltheMethods {
    PFQuery *personQuery = [UserInfo query];
    [personQuery whereKey:@"user" equalTo:[PFUser currentUser].username];
    [personQuery includeKey:@"friends"];
    
    
    
    [personQuery getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error) {                
//        //Add Self Friend
//        
//        NSString *objectID = [object objectId];
//        PFObject *userFriendObject = [PFObject objectWithoutDataWithClassName:@"UserInfo" objectId:objectID];
//        
//        [object addObject:userFriendObject forKey:@"friends"];
//        [object saveInBackground];

        
        
        //PROFILE PICTURE
        
        if (self.profilePictureSet.image != nil) {
            NSData *data = UIImagePNGRepresentation(self.profilePictureSet.image);
            PFFile *imageupload = [PFFile fileWithName:@"myProfilePicture.png" data:data];
            [object setObject:imageupload forKey:@"profilePicture"];
            [object saveInBackground];
            NSLog(@"SUCCESS!");
        } else {
            NSLog(@"EMPTY!");
        }
        
        //FIRST NAME
        
        if (![self.firstNameField.text isEqualToString:@""]) {
            if ([self.firstNameField.text length] > 1) {
                BOOL isValid = [self NSStringIsNameValid:self.firstNameField.text];
                if (isValid) {
                    [object setObject:self.firstNameField.text forKey:@"firstName"];
                    [object saveInBackground];
                    checkFirstName = YES;
                    NSLog(@"SUCCESS!");
                } else {
                    [self showAlertwithString:@"Your name must only contain letters!"];
                }
            } else {
                [self showAlertwithString:@"Your name must be greater than one character!"];
            }
            
        } else {
            [self showAlertwithString:@"You must enter a first name!"];
        }
        
        //LAST NAME
        
        if (![self.lastNameField.text isEqualToString:@""]) {
            if ([self.lastNameField.text length] > 1) {
                BOOL isValid = [self NSStringIsNameValid:self.firstNameField.text];
                if (isValid) {
                    [object setObject:self.lastNameField.text forKey:@"lastName"];
                    [object saveInBackground];
                    checkLastName = YES;
                    NSLog(@"SUCCESS!");
                } else {
                    [self showAlertwithString:@"Your name must only contain letters!"];
                }
            } else {
                [self showAlertwithString:@"Your name must be greater than one character!"];
            }
            
        } else {
            [self showAlertwithString:@"You must enter a last name!"];
        }
        
        
        
        if ((checkFirstName) && (checkLastName)) {
            
            [self dismissViewControllerAnimated:YES completion:^{
                [[NSNotificationCenter defaultCenter] postNotificationName:@"reloadProfile" object:nil];
            }];
            
        }
        
    }];
    
    
    
    
}


-(BOOL) NSStringIsNameValid:(NSString *)checkString
{
    NSString *myRegex = @"[A-Za-z]*";
    NSPredicate *myTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", myRegex];
    
    return [myTest evaluateWithObject:checkString];
    
}





- (IBAction)doneButton:(id)sender {
    
    
    [self updateAlltheMethods];
    
    
}





- (IBAction)imagePicker:(id)sender {
    
    UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
    imagePickerController.modalPresentationStyle = UIModalPresentationCurrentContext;
    imagePickerController.delegate = self;
    
    self.imagePickerController = imagePickerController;
    
    [self presentViewController:self.imagePickerController animated:YES completion:nil];
}



#pragma mark - UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    UIImage *image = [info valueForKey:UIImagePickerControllerOriginalImage];
    
    
    /*CGSize newSize = CGSizeMake(88, 88);
    UIGraphicsBeginImageContext(newSize);
    [image drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();*/
    
    
    self.profilePictureSet.image = image;
    
    self.imagePickerController = nil;
    
    [self dismissViewControllerAnimated:YES completion:nil];
    
    
    
    
    
}


- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    
    
    [self dismissViewControllerAnimated:YES completion:NULL];
}

- (void)hideKeyboard
{
    [self.firstNameField resignFirstResponder];
    [self.lastNameField resignFirstResponder];
}


@end
