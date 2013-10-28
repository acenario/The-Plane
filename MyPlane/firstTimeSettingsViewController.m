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
    BOOL overallCheck;
    NSArray *friendsArray;
    Reachability *reachability;
    UIImage *defaultimage;
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
    defaultimage = self.profilePictureSet.image;
    
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
    
    FUIAlertView *alertView = [[FUIAlertView alloc] initWithTitle:@"Error!"
                                                          message:message
                                                         delegate:nil cancelButtonTitle:@"Okay"
                                                otherButtonTitles:nil];
    alertView.titleLabel.textColor = [UIColor cloudsColor];
    alertView.titleLabel.font = [UIFont boldFlatFontOfSize:17];
    alertView.messageLabel.textColor = [UIColor whiteColor];
    alertView.messageLabel.font = [UIFont flatFontOfSize:15];
    alertView.backgroundOverlay.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.2f];
    alertView.alertContainer.backgroundColor = [UIColor colorFromHexCode:@"F87056"];
    alertView.defaultButtonColor = [UIColor cloudsColor];
    alertView.defaultButtonShadowColor = [UIColor clearColor];
    alertView.defaultButtonFont = [UIFont boldFlatFontOfSize:16];
    alertView.defaultButtonTitleColor = [UIColor asbestosColor];
    
    
    [alertView show];
}

- (void)updateAlltheMethods {
    PFQuery *personQuery = [UserInfo query];
    [personQuery whereKey:@"user" equalTo:[PFUser currentUser].username];
    [personQuery includeKey:@"friends"];
    personQuery.cachePolicy = kPFCachePolicyNetworkOnly;
    
    [SVProgressHUD showWithStatus:@"Saving..."];
    [personQuery getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error) {                
//        //Add Self Friend
//        
//        NSString *objectID = [object objectId];
//        PFObject *userFriendObject = [PFObject objectWithoutDataWithClassName:@"UserInfo" objectId:objectID];
//        
//        [object addObject:userFriendObject forKey:@"friends"];
//        [object saveInBackground];

        
        
        //PROFILE PICTURE
        
        if ((self.profilePictureSet.image != nil) && (self.profilePictureSet.image != defaultimage)) {
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
            if (([self.firstNameField.text length] > 1) && ([self.firstNameField.text length] < 33)) {
                BOOL isValid = [self NSStringIsNameValid:self.firstNameField.text];
                if (isValid) {
                    [object setObject:self.firstNameField.text forKey:@"firstName"];
                    [object saveInBackground];
                    checkFirstName = YES;
                    overallCheck = YES;
                    NSLog(@"SUCCESS!");
                } else {
                    [self showAlertwithString:@"Your name must only contain letters!"];
                }
            } else {
                [self showAlertwithString:@"Your name must be greater than one character and less than 32!"];
            }
            
        } else {
            [self showAlertwithString:@"You must enter a first name!"];
        }
        
        //LAST NAME
        
        if (![self.lastNameField.text isEqualToString:@""]) {
            if (([self.lastNameField.text length] > 1) && ([self.lastNameField.text length] < 33)) {
                BOOL isValid = [self NSStringIsNameValid:self.lastNameField.text];
                if (isValid) {
                    [object setObject:self.lastNameField.text forKey:@"lastName"];
                    [object saveInBackground];
                    checkLastName = YES;
                    overallCheck = YES;
                    NSLog(@"SUCCESS!");
                } else {
                    [self showAlertwithString:@"Your name must only contain letters!"];
                }
            } else {
                [self showAlertwithString:@"Your name must be greater than one character and less than 32!"];
            }
            
        } else {
            [self showAlertwithString:@"You must enter a last name!"];
        }
        
        //PHONE
        
        if (![self.phoneField.text isEqualToString:@""]) {
            if (([self.phoneField.text length] > 1) && ([self.phoneField.text length] < 33)) {
                BOOL isValid = [self NSStringIsNumberValid:self.phoneField.text];
                if (isValid) {
                    PFUser *user = [PFUser currentUser];
                    [user setObject:self.phoneField.text forKey:@"phone"];
                    [user saveInBackground];
                    overallCheck = YES;
                    NSLog(@"SUCCESS!");
                } else {
                    overallCheck = NO;
                    [self showAlertwithString:@"Your number must only contain numbers!"];
                }
            } else {
                overallCheck = NO;
                [self showAlertwithString:@"Your phone number must be more than one character and less than 32!"];
            }
            
        } else {
            NSLog(@"EMPTY PHONE!");
        }
        
        
        
        if ((checkFirstName) && (checkLastName) && (overallCheck)) {
            CurrentUser *sharedManager = [CurrentUser sharedManager];
            sharedManager.currentUser = (UserInfo *)object;
            [self dismissViewControllerAnimated:YES completion:^{
                [[NSNotificationCenter defaultCenter] postNotificationName:@"reloadProfile" object:nil];
                [self.delegate firstTimePresentTutorial:self];
                [SVProgressHUD dismiss];
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

-(BOOL) NSStringIsNumberValid:(NSString *)checkString
{
    NSString *myRegex = @"[0-9]*";
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
    self.phoneLabel.font = [UIFont flatFontOfSize:16];
    self.firstTitle.textColor = [UIColor colorFromHexCode:@"A62A00"];
    self.lastTitle.textColor = [UIColor colorFromHexCode:@"A62A00"];
    self.phoneLabel.textColor = [UIColor colorFromHexCode:@"A62A00"];
    self.firstTitle.backgroundColor = [UIColor whiteColor];
    self.lastTitle.backgroundColor = [UIColor whiteColor];
    self.phoneLabel.backgroundColor = [UIColor whiteColor];
    self.firstNameField.font = [UIFont flatFontOfSize:14];
    self.lastNameField.font = [UIFont flatFontOfSize:14];
    self.phoneField.font = [UIFont flatFontOfSize:14];
    self.firstNameField.backgroundColor = [UIColor whiteColor];
    self.lastNameField.backgroundColor = [UIColor whiteColor];
    self.phoneField.backgroundColor = [UIColor whiteColor];
    
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
        bitmapInfo = kCGImageAlphaNoneSkipLast;
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

- (void)hideKeyboard
{
    [self.firstNameField resignFirstResponder];
    [self.lastNameField resignFirstResponder];
    [self.phoneField resignFirstResponder];
}


@end
