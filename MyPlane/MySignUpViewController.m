//
//  MySignUpViewController.m
//  MyPlane
//
//  Created by Arjun Bhatnagar on 7/14/13.
//  Copyright (c) 2013 Acubed Productions. All rights reserved.
//

#import "MySignUpViewController.h"
#import "KGStatusBar.h"
#import <QuartzCore/QuartzCore.h>

const double suscale = 0.74f;

@interface MySignUpViewController ()
@property (nonatomic, strong) UIImageView *unUnderline;
@property (nonatomic, strong) UIImageView *pwUnderline;
@property (nonatomic, strong) UIImageView *emUnderline;

@end

@implementation MySignUpViewController

@synthesize unUnderline,pwUnderline,emUnderline;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
 
- (void)viewDidLoad
{
    [super viewDidLoad];
    [KGStatusBar dismiss];
    //[self.logInView setLogo:[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"favrMockup"]]];
    [self.signUpView setLogo:[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"logo2"]]];
    
    [self.signUpView setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"main_background.png"]]];
    //[self.signUpView.dismissButton setImage:nil forState:UIControlStateNormal];
    //[self.signUpView.dismissButton setImage:nil forState:UIControlStateHighlighted];
    
    
    
    // Remove text shadow
    CALayer *layer = self.signUpView.usernameField.layer;
    layer.shadowOpacity = 0.0;
    layer = self.signUpView.passwordField.layer;
    layer.shadowOpacity = 0.0;
    layer = self.signUpView.emailField.layer;
    layer.shadowOpacity = 0.0;
    
    //Add Underlines
    unUnderline = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"loginLines2"]];
    pwUnderline = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"loginLines2"]];
    emUnderline = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"loginLines2"]];
    
    [self.signUpView addSubview:self.unUnderline];
    [self.signUpView sendSubviewToBack:self.unUnderline];
    
    [self.signUpView addSubview:self.pwUnderline];
    [self.signUpView sendSubviewToBack:self.pwUnderline];
    
    [self.signUpView addSubview:self.emUnderline];
    [self.signUpView sendSubviewToBack:self.emUnderline];
    
    
    //Set Placeholder
    [self.signUpView.usernameField setPlaceholder:@"USERNAME"];
    [self.signUpView.passwordField setPlaceholder:@"PASSWORD"];
    [self.signUpView.emailField setPlaceholder:@"EMAIL"];
    
    //Customize Textfields
    self.signUpView.usernameField.font = [UIFont flatFontOfSize:20];
    self.signUpView.passwordField.font = [UIFont flatFontOfSize:20];
    self.signUpView.emailField.font = [UIFont flatFontOfSize:20];
    
    self.signUpView.usernameField.textAlignment = NSTextAlignmentLeft;
    self.signUpView.passwordField.textAlignment = NSTextAlignmentLeft;
    self.signUpView.emailField.textAlignment = NSTextAlignmentLeft;
    
    [self.signUpView.usernameField setTextColor:[UIColor whiteColor]];
    [self.signUpView.passwordField setTextColor:[UIColor whiteColor]];
    [self.signUpView.emailField setTextColor:[UIColor whiteColor]];
    
    //Customize Place Holder
    [self.signUpView.usernameField setValue:[UIColor colorWithWhite:1.0f alpha:0.44f] forKeyPath:@"_placeholderLabel.textColor"];
    [self.signUpView.passwordField setValue:[UIColor colorWithWhite:1.0f alpha:0.44f] forKeyPath:@"_placeholderLabel.textColor"];
    [self.signUpView.emailField setValue:[UIColor colorWithWhite:1.0f alpha:0.44f] forKeyPath:@"_placeholderLabel.textColor"];
    
    
	// Do any additional setup after loading the view.
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    // Set frame for elements
    if (IS_IPHONE5) {
        [self.signUpView.logo setFrame:CGRectMake(45.0f, 32.0f, 235.0f, 145.0f)];
        
        [self.signUpView.usernameField setFrame:CGRectMake(29.5f, 182.0f, 260.0f, 20.0f)];
        [self.unUnderline setFrame:CGRectMake(27.5f, 204.0f, 226.0f, 5.0f)];
        
        [self.signUpView.passwordField setFrame:CGRectMake(29.5f, 224.0f, 260.0f, 20.0f)];
        [self.pwUnderline setFrame:CGRectMake(27.5f, 245.0f, 226.0f, 5.0f)];
        
        [self.signUpView.emailField setFrame:CGRectMake(29.5f, 265.0f, 260.0f, 20.0f)];
        [self.emUnderline setFrame:CGRectMake(27.5f, 286.0f, 226.0f, 5.0f)];
        
        
        [self.signUpView.signUpButton setFrame:CGRectMake(53.0f, 308.0f, 108.375f, 44.625f)];
        [self.signUpView.dismissButton setFrame:CGRectMake(161.375f, 308.0f, 108.375f, 44.625f)];
                
    } else {
        [self.signUpView.logo setFrame:CGRectMake(70.0f, 17.0f*suscale, 235.0f*suscale, 145.0f*suscale)];
        
        [self.signUpView.usernameField setFrame:CGRectMake(29.5f, 161.0f, 260.0f, 30.0f)];
        [self.unUnderline setFrame:CGRectMake(27.5f, 192.0f, 226.0f, 5.0f)];
        
        [self.signUpView.passwordField setFrame:CGRectMake(29.5f, 204.0f, 260.0f, 30.0f)];
        [self.pwUnderline setFrame:CGRectMake(27.5f, 233.0f, 226.0f, 5.0f)];
        
        [self.signUpView.emailField setFrame:CGRectMake(29.5f, 245.0f, 260.0f, 30.0f)];
        [self.emUnderline setFrame:CGRectMake(27.5f, 274.0f, 226.0f, 5.0f)];
        
        
        [self.signUpView.signUpButton setFrame:CGRectMake(53.0f, 308.0f, 108.375f, 44.625f)];
        [self.signUpView.dismissButton setFrame:CGRectMake(161.375f, 308.0f, 108.375f, 44.625f)];
        
    }
        
    [self.signUpView.dismissButton setTitle:@"" forState:UIControlStateNormal];
    [self.signUpView.dismissButton setTitle:@"" forState:UIControlStateHighlighted];
    
    [self.signUpView.signUpButton setTitle:@"" forState:UIControlStateNormal];
    [self.signUpView.signUpButton setTitle:@"" forState:UIControlStateHighlighted];
    
    [self.signUpView.dismissButton setImage:[UIImage imageNamed:@"cancelBtn"] forState:UIControlStateNormal];
    [self.signUpView.signUpButton setBackgroundImage:[UIImage imageNamed:@"SignupBtn"] forState:UIControlStateNormal];
    [self.signUpView.dismissButton setImage:[UIImage imageNamed:@"cancelSelected"] forState:UIControlStateHighlighted];
    [self.signUpView.signUpButton setBackgroundImage:[UIImage imageNamed:@"signupSelected"] forState:UIControlStateHighlighted];
    
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField {
    if (textField == self.signUpView.usernameField) {
        textField.text = [textField.text lowercaseString];
    }
        return YES;
}

@end
