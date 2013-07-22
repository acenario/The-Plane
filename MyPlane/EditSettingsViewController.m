//
//  EditSettingsViewController.m
//  MyPlane
//
//  Created by Arjun Bhatnagar on 7/13/13.
//  Copyright (c) 2013 Acubed Productions. All rights reserved.
//

#import "EditSettingsViewController.h"
#import <QuartzCore/QuartzCore.h>

@interface EditSettingsViewController ()


@property (nonatomic) UIImagePickerController *imagePickerController;
@property (strong, nonatomic) IBOutlet UIImageView *profilePictureSet;
@property (strong, nonatomic) IBOutlet UITextField *firstNameField;
@property (strong, nonatomic) IBOutlet UITextField *lastNameField;
@property (strong, nonatomic) IBOutlet UITextField *emailField;
@property (strong, nonatomic) IBOutlet UITextField *passwordField;
@property (strong, nonatomic) IBOutlet UITextField *passwordReEnter;


@end

@implementation EditSettingsViewController {
    BOOL check;
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

    self.firstNameField.placeholder = self.firstname;
    self.lastNameField.placeholder = self.lastname;
    self.emailField.placeholder = self.email;
    self.profilePictureSet.image = self.profilePicture;
    [self configureTable];
    
    check = YES;
    
}

-(void)configureTable {
    UIImageView *av = [[UIImageView alloc] init];
    av.backgroundColor = [UIColor clearColor];
    av.opaque = NO;
    UIImage *background = [UIImage imageNamed:@"tableBackground"];
    av.image = background;
    
    self.tableView.backgroundView = av;
    
    UIColor *regColor = [UIColor colorFromHexCode:@"FF7140"];
    UIColor *selColor = [UIColor colorFromHexCode:@"FF9773"];
    
    self.setPic.buttonColor = regColor;
    self.setPic.shadowColor = selColor;
    self.setPic.shadowHeight = 3.0f;
    self.setPic.cornerRadius = 6.0f;
    self.setPic.titleLabel.font = [UIFont boldFlatFontOfSize:22];
    
    
    [self.setPic setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.setPic setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)showAlertwithString:(NSString *)message {
    
    check = NO;
    
    UIColor *barColor = [UIColor colorFromHexCode:@"FF4100"];
    
    FUIAlertView *alertView = [[FUIAlertView alloc] initWithTitle:@"Error!"
                                                          message:message
                                                         delegate:nil cancelButtonTitle:@"Okay"
                                                otherButtonTitles:nil];
    alertView.titleLabel.textColor = [UIColor cloudsColor];
    alertView.titleLabel.font = [UIFont boldFlatFontOfSize:16];
    alertView.messageLabel.textColor = [UIColor cloudsColor];
    alertView.messageLabel.font = [UIFont flatFontOfSize:14];
    alertView.backgroundOverlay.backgroundColor = [UIColor clearColor];
    alertView.alertContainer.backgroundColor = barColor;
    alertView.defaultButtonColor = [UIColor cloudsColor];
    alertView.defaultButtonShadowColor = [UIColor asbestosColor];
    alertView.defaultButtonFont = [UIFont boldFlatFontOfSize:16];
    alertView.defaultButtonTitleColor = [UIColor asbestosColor];
    
    
    [alertView show];
    
}

- (void)updateAlltheMethods {
    PFUser *user = [PFUser currentUser];
    PFQuery *personQuery = [UserInfo query];
    [personQuery whereKey:@"user" equalTo:[PFUser currentUser].username];
    [personQuery getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error) {
    
        
        //PROFILE PICTURE
        
        if (self.profilePictureSet.image != nil) {
            NSData *data = UIImagePNGRepresentation(self.profilePictureSet.image);
            PFFile *imageupload = [PFFile fileWithName:@"myProfilePicture.png" data:data];
            [object setObject:imageupload forKey:@"profilePicture"];
            [object saveInBackground];
            NSLog(@"SUCCESS!");
            check = YES;
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
                    check = YES;
                    NSLog(@"SUCCESS!");
                } else {
                    [self showAlertwithString:@"Your name must only contain letters!"];
                }
            } else {
                [self showAlertwithString:@"Your name must be greater than one character!"];
            }
            
        } else {
            NSLog(@"EMPTY!");
        }
        
        //LAST NAME
        
        if (![self.lastNameField.text isEqualToString:@""]) {
            if ([self.lastNameField.text length] > 1) {
                BOOL isValid = [self NSStringIsNameValid:self.lastNameField.text];
                if (isValid) {
                    [object setObject:self.lastNameField.text forKey:@"lastName"];
                    [object saveInBackground];
                    check = YES;
                    NSLog(@"SUCCESS!");
                } else {
                    [self showAlertwithString:@"Your name must only contain letters!"];
                }
            } else {
                [self showAlertwithString:@"Your name must be greater than one character!"];
            }
            
        } else {
            NSLog(@"EMPTY!");
        }
        
        //EMAIL
        
        if (![self.emailField.text isEqualToString:@""]) {
            
            BOOL isValid = [self NSStringIsValidEmail:self.emailField.text];
            if (isValid) {
                [user setEmail:self.emailField.text];
                [user saveInBackground];
                check = YES;
                NSLog(@"SUCCESS!");
            } else {
                NSLog(@"NOT VALID EMAIL");
                [self showAlertwithString:@"You have entered an invalid email!"];
            }
            
        } else {
            NSLog(@"EMPTY!");
        }
        
        //PASSWORD
        
        if (![self.passwordField.text isEqualToString:@""] && ![self.passwordReEnter.text isEqualToString:@""]) {
            
            if (([self.passwordField.text length] >= 8) && ([self.passwordReEnter.text length] >= 8)) {
                
                if (([self.passwordField.text length] <=32) && ([self.passwordReEnter.text length] <=32)) {
                    
                    BOOL isValid = [self NSStringIsPasswordValid:self.passwordReEnter.text];
                    if (isValid) {
                        [user setPassword:self.passwordReEnter.text];
                        [user saveInBackground];
                        check = YES;
                        NSLog(@"SUCCESS!");
                    } else {
                        [self showAlertwithString:@"Your passwords do not match"];
                    }
                    
                } else {
                    [self showAlertwithString:@"Your password must be less than 32 characters!"];
                }
                
            } else {
                [self showAlertwithString:@"Your password must be 8 character or more!"];
            }

        } else {
            NSLog(@"EMPTY!");
        }
        
        if (check == YES) {
            [self dismissViewControllerAnimated:YES completion:nil];
        } else {
            NSLog(@"NO!");
        }
        
    }];
    
    
    
        
    
}

-(BOOL) NSStringIsPasswordValid:(NSString *)checkString
{
    if ([checkString isEqualToString:self.passwordField.text]) {
        return YES;
        
    } else {
        return NO;
    }
    
}

-(BOOL) NSStringIsNameValid:(NSString *)checkString
{
    NSString *myRegex = @"[A-Za-z]*";
    NSPredicate *myTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", myRegex];

    return [myTest evaluateWithObject:checkString];

}


-(BOOL) NSStringIsValidEmail:(NSString *)checkString
{
    BOOL stricterFilter = YES; 
    NSString *stricterFilterString = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    NSString *laxString = @".+@.+\\.[A-Za-z]{2}[A-Za-z]*";
    NSString *emailRegex = stricterFilter ? stricterFilterString : laxString;
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:checkString];
}


- (IBAction)doneButton:(id)sender {
    
    
    [self updateAlltheMethods];
    [self.delegate updateUserInfo:self];
    
    //[self dismissViewControllerAnimated:YES completion:nil];
        


}


- (IBAction)cancelButton:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
    
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
    
    /*CGSize newSize = CGSizeMake(120, 120);
    UIGraphicsBeginImageContext(newSize);
    [image drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    */
    
    self.profilePictureSet.image = image;
    
    self.imagePickerController = nil;
    
    [self dismissViewControllerAnimated:YES completion:nil];
    
    
    
    
}


- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    
    
    [self dismissViewControllerAnimated:YES completion:NULL];
}

-(UITableViewCell *)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    //UIColor *color = [UIColor colorFromHexCode:@"FF9773"];
    UIColor *color = [UIColor whiteColor];
    
    
    UIImageView *av = [[UIImageView alloc] init];
    av.backgroundColor = [UIColor clearColor];
    av.opaque = NO;
    
    UIImage *background = [UIImage imageWithColor:color cornerRadius:1.0f];
    av.image = background;
    cell.backgroundView = av;

    

    
    return cell;
    
}



@end
