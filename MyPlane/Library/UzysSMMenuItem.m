//
//  UzysSMMenuItem.m
//  UzysSlideMenu
//
//  Created by Jaehoon Jung on 13. 2. 21..
//  Copyright (c) 2013년 Uzys. All rights reserved.
//

#import "UzysSMMenuItem.h"

@implementation UzysSMMenuItem

-(id)initWithTitle:(NSString *)title image:(UIImage *)image action:(actionBlock)block; {
    self = [super init];
    if(self) {
        self.title = title;
        self.image = image;
        self.block = block;
    }
    
    return self;
}

-(void)dealloc {
    [self.title release];
    [self.image release];
    [self.block release];
    [super ah_dealloc];
}

#pragma mark - For debug
-(NSString *)description {
    return [NSString stringWithFormat:@"Title:%@, tag:%d",self.title,self.tag];
}
@end
