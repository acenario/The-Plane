//
//  EditSettingsViewController.m
//  MyPlane
//
//  Created by Arjun Bhatnagar on 7/13/13.
//  Copyright (c) 2013 Acubed Productions. All rights reserved.
//

#import "EditSettingsViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "CurrentUser.h"

@interface EditSettingsViewController ()


@property (nonatomic) UIImagePickerController *imagePickerController;
@property (strong, nonatomic) IBOutlet UIImageView *profilePictureSet;
@property (strong, nonatomic) IBOutlet UITextField *firstNameField;
@property (strong, nonatomic) IBOutlet UITextField *lastNameField;
@property (strong, nonatomic) IBOutlet UITextField *emailField;
@property (strong, nonatomic) IBOutlet UITextField *passwordField;
@property (strong, nonatomic) IBOutlet UITextField *passwordReEnter;
@property (strong, nonatomic) IBOutlet UITextField *phoneField;
@property (strong, nonatomic) IBOutlet UILabel *gracePeriodField;


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
    PFUser *user = [PFUser currentUser];
    NSString *phone = [user objectForKey:@"phone"];
//    self.gracePeriod = self.cu;
    
    self.firstNameField.delegate = self;
//    [self.firstNameField addTarget:self action:@selector(textFieldValidate:) forControlEvents:UIControlEventEditingChanged];

    self.firstNameField.placeholder = self.firstname;
    self.lastNameField.placeholder = self.lastname;
    self.emailField.placeholder = self.email;
    self.profilePictureSet.image = self.profilePicture;
    if (phone != nil){
        self.phoneField.placeholder = phone;
    }
    [self configureTable];
    
//    check = YES;
    
    
    UITapGestureRecognizer *gestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideKeyboard)];
    [self.tableView addGestureRecognizer:gestureRecognizer];
    gestureRecognizer.cancelsTouchesInView = NO;
}

-(void)configureTable {
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
    self.setPic.titleLabel.font = [UIFont boldFlatFontOfSize:18];
    
    
    [self.setPic setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.setPic setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
//    [self configureGracePeriod];
    
    self.gracePeriodField.textColor = [UIColor lightGrayColor];
    [self configureGracePeriod];
}

- (void)configureGracePeriod
{
    if (self.gracePeriod == 0) {
        self.gracePeriodField.text = @"Instantly";
    } else if (self.gracePeriod < 60 * 60) {
        self.gracePeriodField.text = [NSString stringWithFormat:@"%d minutes", self.gracePeriod / 60];
    } else if (self.gracePeriod == 60 * 60) {
        self.gracePeriodField.text = [NSString stringWithFormat:@"1 hour"];
    } else if (self.gracePeriod < 1440 * 60) {
        self.gracePeriodField.text = [NSString stringWithFormat:@"%d hours", self.gracePeriod / 3600];
    } else {
        self.gracePeriodField.text = @"1 day";
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)showAlertwithString:(NSString *)message {
    
    check = NO;
    
    //UIColor *barColor = [UIColor colorFromHexCode:@"FF4100"];
    UIColor *barColor = [UIColor colorFromHexCode:@"F87056"];
    
    //NSInteger red   = 178;
    //NSInteger green = 8;
    //NSInteger blue  = 56;
    
    //UIColor *barColor = [UIColor colorWithRed:red/255.0f green:green/255.0f blue:blue/255.0f alpha:1.0];
    
    FUIAlertView *alertView = [[FUIAlertView alloc] initWithTitle:@"Error!"
                                                          message:message
                                                         delegate:nil cancelButtonTitle:@"Okay"
                                                otherButtonTitles:nil];
    
    
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

- (void)updateAlltheMethods {
    PFUser *user = [PFUser currentUser];
    PFQuery *personQuery = [UserInfo query];
    [personQuery whereKey:@"user" equalTo:[PFUser currentUser].username];
    personQuery.cachePolicy = kPFCachePolicyNetworkOnly;
    [personQuery getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error) {
        check = NO;
        BOOL errorCheck;
        errorCheck = NO;
//        UserInfo *userObject = (UserInfo *)object;
        
        NSString *firstName = nil;
        NSString *lastName = nil;
        NSString *email = nil;
        NSString *phone = nil;
        NSString *password = nil;
        NSNumber *grace = [NSNumber numberWithInt:1];
        PFFile *imageFile = nil;
        
        //PROFILE PICTURE
        
        if (self.profilePictureSet.image != nil && self.profilePictureSet.image != self.profilePicture) {
            NSData *data = UIImagePNGRepresentation(self.profilePictureSet.image);
            PFFile *imageupload = [PFFile fileWithName:@"myProfilePicture.png" data:data];
//            [object setObject:imageupload forKey:@"profilePicture"];
//            [object saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
////                NSLog(@"SUCCESS!");
//                check = NO;
//            }];
            imageFile = imageupload;
            check = YES;
        } else {
//            NSLog(@"EMPTY!");
        }
        
        //FIRST NAME
        
        if (![self.firstNameField.text isEqualToString:@""]) {
            if (([self.firstNameField.text length] > 1) && ([self.firstNameField.text length] < 33)) {
                BOOL isValid = [self NSStringIsNameValid:self.firstNameField.text];
                if (isValid) {
//                    [object setObject:self.firstNameField.text forKey:@"firstName"];
//                    [object saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
//                        if (succeeded) {
//                            check = YES;
//                            NSLog(@"%@", [object objectForKey:@"firstName"]);
//                        }
//                        
//                    }];
                    firstName = self.firstNameField.text;
                    check = YES;
                    
                } else {
                    [self showAlertwithString:@"Your name must only contain letters!"];
                    errorCheck = YES;
                }
            } else {
                [self showAlertwithString:@"Your name must be greater than one character and less than 32!"];
                errorCheck = YES;
            }
            
        } else {
//            NSLog(@"EMPTY!");
        }
        
        //LAST NAME
        
        if (![self.lastNameField.text isEqualToString:@""]) {
            if (([self.lastNameField.text length] > 1) && ([self.lastNameField.text length] < 33)) {
                BOOL isValid = [self NSStringIsNameValid:self.lastNameField.text];
                if (isValid) {
//                    [object setObject:self.lastNameField.text forKey:@"lastName"];
//                    [object saveInBackground];
                    lastName = self.lastNameField.text;
                    check = YES;
//                    NSLog(@"SUCCESS!");
                } else {
                    [self showAlertwithString:@"Your name must only contain letters!"];
                    errorCheck = YES;
                }
            } else {
                [self showAlertwithString:@"Your name must be greater than one character and less than 32!"];
                errorCheck = YES;
            }
            
        } else {
//            NSLog(@"EMPTY!");
        }
        
        //EMAIL
        
        if (![self.emailField.text isEqualToString:@""]) {
            BOOL isValid = [self NSStringIsValidEmail:self.emailField.text];
            if (isValid) {
//                [user setEmail:self.emailField.text];
//                [user saveInBackground];
                email = self.emailField.text;
                check = YES;
//                NSLog(@"SUCCESS!");
            } else {
                NSLog(@"NOT VALID EMAIL");
                [self showAlertwithString:@"You have entered an invalid email!"];
                errorCheck = YES;
            }
            
        } else {
//            NSLog(@"EMPTY!");
        }
        
        //PHONE
        
        if (![self.phoneField.text isEqualToString:@""]) {
            if (([self.phoneField.text length] > 1) && ([self.phoneField.text length] < 33)) {
                BOOL isValid = [self NSStringIsNumberValid:self.phoneField.text];
                if (isValid) {
                    //                    [object setObject:self.lastNameField.text forKey:@"lastName"];
                    //                    [object saveInBackground];
                    phone = self.phoneField.text;
                    check = YES;
                    //                    NSLog(@"SUCCESS!");
                } else {
                    [self showAlertwithString:@"Your number must only contain numbers!"];
                    errorCheck = YES;
                }
            } else {
                [self showAlertwithString:@"Your number must be greater than one character and less than 32!"];
                errorCheck = YES;
            }
            
        } else {
            //            NSLog(@"EMPTY!");
        }
        
        //PASSWORD
        
        if (![self.passwordField.text isEqualToString:@""] && ![self.passwordReEnter.text isEqualToString:@""]) {
            if (([self.passwordField.text length] >= 8) && ([self.passwordReEnter.text length] >= 8)) {
                
                if (([self.passwordField.text length] <=32) && ([self.passwordReEnter.text length] <=32)) {
                    
                    BOOL isValid = [self NSStringIsPasswordValid:self.passwordReEnter.text];
                    if (isValid) {
//                        [user setPassword:self.passwordReEnter.text];
//                        [user saveInBackground];
                        password = self.passwordField.text;
                        check = YES;
//                        NSLog(@"SUCCESS!");
                    } else {
                        [self showAlertwithString:@"Your passwords do not match"];
                        errorCheck = YES;
                    }
                    
                } else {
                    [self showAlertwithString:@"Your password must be less than 32 characters!"];
                    errorCheck = YES;
                }
                
            } else {
                [self showAlertwithString:@"Your password must be 8 characters or more!"];
                errorCheck = YES;
            }

        } else {
//            NSLog(@"EMPTY!");
        }
        
        if (![self.gracePeriodField.textColor isEqual:[UIColor lightGrayColor]]) {
            check = YES;
            grace = [NSNumber numberWithInt:self.gracePeriod];
//            NSLog(@"test");
        }
        
        if (check && !errorCheck) {
            [self saveAllFieldswithObject:object withFirstName:firstName withLastName:lastName withEmail:email withPassword:password withImageFile:imageFile withUser:user withGrace:grace withNumber:phone];
        }
//        else {
//            [self dismissViewControllerAnimated:YES completion:nil];
//        }
        
    }];
}

- (void)saveAllFieldswithObject:(PFObject *)object withFirstName:(NSString *)firstName withLastName:(NSString *)lastName withEmail:(NSString *)email withPassword:(NSString *)password withImageFile:(PFFile *)imageFile withUser:(PFUser *)user withGrace:(NSNumber *)gracePeriod withNumber:(NSString *)number;
{
    BOOL usersave = NO;
    BOOL objectsave = NO;
    
    if (firstName != nil) {
        objectsave = YES;
        [object setObject:firstName forKey:@"firstName"];
    }
    
    if (lastName != nil) {
        objectsave = YES;
        [object setObject:lastName forKey:@"lastName"];
    }
    
    if (email != nil) {
        usersave = YES;
        [user setEmail:email];
    }
    
    if (number != nil) {
        usersave = YES;
        [user setObject:number forKey:@"phone"];
    }
    
    if (password != nil) {
        usersave = YES;
        [user setPassword:password];
    }
    
    if (imageFile != nil) {
        objectsave = YES;
        [object setObject:imageFile forKey:@"profilePicture"];
    }

    if (![gracePeriod isEqualToNumber:[NSNumber numberWithInt:1]]) {
        objectsave = YES;
        [object setObject:gracePeriod forKey:@"gracePeriod"];
    }
    
    if ((usersave) && (objectsave)) {
        [user saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if (succeeded) {
            [object saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                CurrentUser *sharedManager = [CurrentUser sharedManager];
                sharedManager.currentUser = (UserInfo *)object;
                [self.delegate updateUserInfo:self];
            }];
                
            } else {
                if (error.code == 203) {
                    [SVProgressHUD showErrorWithStatus:@"Email already taken!"];
                } else {
                    NSLog(@"Error editing user: %@",error);
                }
            }
        }];
    } else if (usersave) {
        [user saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if (succeeded) {
            [self.delegate updateUserInfo:self];
            } else {
                if (error.code == 203) {
                [SVProgressHUD showErrorWithStatus:@"Email already taken!"];
                } else {
                    NSLog(@"Error editing user: %@",error);
                }
            }
        }];
    } else {
        [object saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            CurrentUser *sharedManager = [CurrentUser sharedManager];
            sharedManager.currentUser = (UserInfo *)object;
            [self.delegate updateUserInfo:self];
        }];
    }
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

-(BOOL) NSStringIsNumberValid:(NSString *)checkString
{
    NSString *myRegex = @"[0-9]*";
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
    
    [self hideKeyboard];
    [self updateAlltheMethods];
    
    
    //[self dismissViewControllerAnimated:YES completion:nil];
        


}

- (void)hideKeyboard
{
    [self.firstNameField resignFirstResponder];
    [self.lastNameField resignFirstResponder];
    [self.emailField resignFirstResponder];
    [self.passwordField resignFirstResponder];
    [self.passwordReEnter resignFirstResponder];
}

-(void)textFieldValidate:(id)sender {
    UITextField *textField = (UITextField *)sender;
    NSLog(@"hhh");
    if ([textField.text length] > 0) {
        NSLog(@"enable done");
    }
    
}

//work on
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
//    [super touchesBegan:touches withEvent:event];
    
    [self.firstNameField resignFirstResponder];  
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
    
    if ((image.size.height > 120) && (image.size.width > 120)) {
        CGSize newSize = CGSizeMake(120, 120);
        UIImage *scaledImage = [self imageWithImage:image scaledToSizeWithSameAspectRatio:newSize];
            
        self.profilePictureSet.image = scaledImage;
    } else if((image.size.height > 120) || (image.size.width > 120)) {
        CGSize newSize = CGSizeMake(120, 120);
        UIGraphicsBeginImageContext(newSize);
        [image drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
        UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
    
        self.profilePictureSet.image = newImage;
        
    } else {
        self.profilePictureSet.image = image;
    }
    
    self.imagePickerController = nil;
    
    [self dismissViewControllerAnimated:YES completion:nil];
    
    
    
    
}

- (UIImage *)imageWithImage:(UIImage*)sourceImage scaledToSizeWithSameAspectRatio:(CGSize)targetSize;
{
    CGSize imageSize = sourceImage.size;
    CGFloat width = imageSize.width;
    CGFloat height = imageSize.height;
    CGFloat targetWidth = targetSize.width;
    CGFloat targetHeight = targetSize.height;
    CGFloat scaleFactor = 0.0;
    CGFloat scaledWidth = targetWidth;
    CGFloat scaledHeight = targetHeight;
    CGPoint thumbnailPoint = CGPointMake(0.0,0.0);
    
    if (CGSizeEqualToSize(imageSize, targetSize) == NO) {
        CGFloat widthFactor = targetWidth / width;
        CGFloat heightFactor = targetHeight / height;
        
        if (widthFactor > heightFactor) {
            scaleFactor = widthFactor; // scale to fit height
        }
        else {
            scaleFactor = heightFactor; // scale to fit width
        }
        
        scaledWidth  = width * scaleFactor;
        scaledHeight = height * scaleFactor;
        
        // center the image
        if (widthFactor > heightFactor) {
            thumbnailPoint.y = (targetHeight - scaledHeight) * 0.5;
        }
        else if (widthFactor < heightFactor) {
            thumbnailPoint.x = (targetWidth - scaledWidth) * 0.5;
        }
    }
    
    CGImageRef imageRef = [sourceImage CGImage];
    CGBitmapInfo bitmapInfo = CGImageGetBitmapInfo(imageRef);
    CGColorSpaceRef colorSpaceInfo = CGImageGetColorSpace(imageRef);
    
    if (bitmapInfo == kCGImageAlphaNone) {
        bitmapInfo = (CGBitmapInfo)kCGImageAlphaNoneSkipLast;
    }
    
    CGContextRef bitmap;
    
    if (sourceImage.imageOrientation == UIImageOrientationUp || sourceImage.imageOrientation == UIImageOrientationDown) {
        bitmap = CGBitmapContextCreate(NULL, targetWidth, targetHeight, CGImageGetBitsPerComponent(imageRef), CGImageGetBytesPerRow(imageRef), colorSpaceInfo, bitmapInfo);
        
    } else {
        bitmap = CGBitmapContextCreate(NULL, targetHeight, targetWidth, CGImageGetBitsPerComponent(imageRef), CGImageGetBytesPerRow(imageRef), colorSpaceInfo, bitmapInfo);
        
    }
    
    // In the right or left cases, we need to switch scaledWidth and scaledHeight,
    // and also the thumbnail point
    if (sourceImage.imageOrientation == UIImageOrientationLeft) {
        thumbnailPoint = CGPointMake(thumbnailPoint.y, thumbnailPoint.x);
        CGFloat oldScaledWidth = scaledWidth;
        scaledWidth = scaledHeight;
        scaledHeight = oldScaledWidth;
        
        CGContextRotateCTM (bitmap, M_PI_2); // + 90 degrees
        CGContextTranslateCTM (bitmap, 0, -targetHeight);
        
    } else if (sourceImage.imageOrientation == UIImageOrientationRight) {
        thumbnailPoint = CGPointMake(thumbnailPoint.y, thumbnailPoint.x);
        CGFloat oldScaledWidth = scaledWidth;
        scaledWidth = scaledHeight;
        scaledHeight = oldScaledWidth;
        
        CGContextRotateCTM (bitmap, -M_PI_2); // - 90 degrees
        CGContextTranslateCTM (bitmap, -targetWidth, 0);
        
    } else if (sourceImage.imageOrientation == UIImageOrientationUp) {
        // NOTHING
    } else if (sourceImage.imageOrientation == UIImageOrientationDown) {
        CGContextTranslateCTM (bitmap, targetWidth, targetHeight);
        CGContextRotateCTM (bitmap, -M_PI); // - 180 degrees
    }
    
    CGContextDrawImage(bitmap, CGRectMake(thumbnailPoint.x, thumbnailPoint.y, scaledWidth, scaledHeight), imageRef);
    CGImageRef ref = CGBitmapContextCreateImage(bitmap);
    UIImage* newImage = [UIImage imageWithCGImage:ref];
    
    CGContextRelease(bitmap);
    CGImageRelease(ref);
    
    return newImage; 
}


- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    
    
    [self dismissViewControllerAnimated:YES completion:NULL];
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    //UIColor *color = [UIColor colorFromHexCode:@"FF9773"];
    UIColor *color = [UIColor whiteColor];
    
    
    UIImageView *av = [[UIImageView alloc] init];
    av.backgroundColor = [UIColor clearColor];
    av.opaque = NO;
    
    UIImage *background = [UIImage imageWithColor:color cornerRadius:1.0f];
    av.image = background;
    cell.backgroundView = av;
    
    UIColor *selectedColor = [UIColor colorFromHexCode:@"FF7140"];

    UIView *bgView = [[UIView alloc]init];
    bgView.backgroundColor = selectedColor;
    
    
    [cell setSelectedBackgroundView:bgView];
    
    
    
    
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"EditGrace"]) {
        UINavigationController *nav = (UINavigationController *)[segue destinationViewController];
        EditExpiryTimeViewController *controller = (EditExpiryTimeViewController *)nav.topViewController;
        controller.gracePeriod = self.gracePeriod;
        controller.delegate = self;
    }
}

- (void)editExpiryTimeViewController:(EditExpiryTimeViewController *)controller withGracePeriod:(int)gracePeriod
{
    self.gracePeriodField.textColor = [UIColor colorFromHexCode:@"324F85"];
    self.gracePeriod = gracePeriod;
    [self configureGracePeriod];
//    [self dismissViewControllerAnimated:YES completion:nil];
}


@end
