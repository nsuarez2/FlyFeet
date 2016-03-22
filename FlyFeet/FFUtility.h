//
//  FFUtility.h
//  FlyFeet
//
//  Created by Nico Suarez on 3/21/16.
//  Copyright © 2016 Nico Suarez. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface FFUtility : NSObject

@property (strong, nonatomic) NSArray *buttons;

+ (instancetype)sharedUtility;
- (UIBezierPath *)bezierPathForButton:(UIButton *)button;
- (UIColor *)colorForButton:(UIButton *)button;

@end
