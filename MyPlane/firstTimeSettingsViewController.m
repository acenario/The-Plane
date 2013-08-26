//
//  firstTimeSettingsViewController.m
//  MyPlane
//
//  Created by Arjun Bhatnagar on 7/14/13.
//  Copyright (c) 2013 Acubed Productions. All rights reserved.
//

#import "firstTimeSettingsViewController.h"
#import "CurrentUser.h"
#import "Reachability.h"

@interface firstTimeSettingsViewController ()

@property (nonatomic) UIImagePickerController *imagePickerController;


@end

@implementation firstTimeSettingsViewController {
    BOOL checkFirstName;
    BOOL checkLastName;
    NSArray *friendsArray;
    Reachability *reachability;
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
    queryUser.cachePolicy = kPFCachePolicyNetworkElseCache;
    
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
    reachability = [Reachability reachabilityForInternetConnection];
    
    UITapGestureRecognizer *gestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideKeyboard)];
    [self.tableView addGestureRecognizer:gestureRecognizer];
    gestureRecognizer.cancelsTouchesInView = NO;
    
    [self configureViewController];
    
}

-(void)configureViewController {
    UIImageView *av = [[UIImageView alloc] init];
    av.backgroundColor = [UIColor clearColor];
    av.opaque = NO;
    UIImage *background = [UIImage imageNamed:@"tableBackground"];
    av.image = background;
    
    self.tableView.backgroundView = av;
    
    UIColor *regColor = [UIColor colorFromHexCode:@"FF7140"];
    //UIColor *selColor = [UIColor colorFromHexCode:@"FF9773"];
    
    self.setPic.buttonColor = regColor;
    self.setPic.shadowColor = regColor;
    self.setPic.shadowHeight = 2.0f;
    self.setPic.cornerRadius = 3.0f;
    self.setPic.titleLabel.font = [UIFont boldFlatFontOfSize:17];
    
    [self.setPic setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.setPic setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];

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
    personQuery.cachePolicy = kPFCachePolicyNetworkOnly;
    
    
    [personQuery getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error) {                
//        //Add Self Friend
//        
//        NSString *objectID = [object objectId];
//        PFObject *userFriendObject = [PFObject objectWithoutDataWithClassName:@"UserInfo" objectId:objectID];
//        
//        [object addObject:userFriendObject forKey:@"friends"];
//        [object saveInBackground];

        
        
        //PROFILE PICTURE
        
        if ((self.profilePictureSet.image != nil) && (self.profilePictureSet.image != self.profilePictureSet.image)) {
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
            CurrentUser *sharedManager = [CurrentUser sharedManager];
            sharedManager.currentUser = (UserInfo *)object;
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
    
    if (reachability.currentReachabilityStatus == NotReachable) {
        [SVProgressHUD showErrorWithStatus:@"No Internet Connection!"];
    } else {
        [self updateAlltheMethods];
    }
    
    
    
}

-(UITableViewCell *)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    UIColor *selectedColor = [UIColor colorFromHexCode:@"FF7140"];
    
    UIImageView *av = [[UIImageView alloc] init];
    av.backgroundColor = [UIColor clearColor];
    av.opaque = NO;
    UIImage *background = [UIImage imageWithColor:[UIColor whiteColor] cornerRadius:1.0f];
    av.image = background;
    cell.backgroundView = av;
    
    
    UIView *bgView = [[UIView alloc]init];
    bgView.backgroundColor = selectedColor;
    
    
    [cell setSelectedBackgroundView:bgView];
    
    UIImageView *imgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"separator2"]];
    imgView.frame = CGRectMake(-1, (cell.frame.size.height - 1), 302, 1);
    
    self.firstTitle.font = [UIFont flatFontOfSize:16];
    self.lastTitle.font = [UIFont flatFontOfSize:16];
    self.firstTitle.textColor = [UIColor colorFromHexCode:@"A62A00"];
    self.lastTitle.textColor = [UIColor colorFromHexCode:@"A62A00"];
    self.firstTitle.backgroundColor = [UIColor whiteColor];
    self.lastTitle.backgroundColor = [UIColor whiteColor];
    self.firstNameField.font = [UIFont flatFontOfSize:14];
    self.lastNameField.font = [UIFont flatFontOfSize:14];
    self.firstNameField.backgroundColor = [UIColor whiteColor];
    self.lastNameField.backgroundColor = [UIColor whiteColor];
    
    if (indexPath.section == 1) {
        if (indexPath.row == 0)
        [cell.contentView addSubview:imgView];
        
    }
    
    
    return cell;
    
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
