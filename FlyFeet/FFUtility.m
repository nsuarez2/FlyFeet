//
//  FFUtility.m
//  FlyFeet
//
//  Created by Nico Suarez on 3/21/16.
//  Copyright © 2016 Nico Suarez. All rights reserved.
//

#import "FFUtility.h"
#import <CoreGraphics/CoreGraphics.h>
#import <UIKit/UIKit.h>


@implementation FFUtility

//Coords are scaled to 1024x768
//Based at 515x385
const double x_mult = 1.988;
const double y_mult = 1.995;

#define p1 {0 * x_mult,0 * y_mult}
#define p2 {105.212 * x_mult,0 * y_mult}
#define p3 {409.788 * x_mult,0 * y_mult}
#define p4 {515 * x_mult,0 * y_mult}
#define p5 {217.078 * x_mult,142.257 * y_mult}
#define p6 {297.942 * x_mult,142.257 * y_mult}
#define p7 {217.078 * x_mult,242.745 * y_mult}
#define p8 {297.942 * x_mult,241.745 * y_mult}
#define p9 {0 * x_mult,385 * y_mult}
#define p10 {105.212 * x_mult,385 * y_mult}
#define p11 {409.788 * x_mult,385 * y_mult}
#define p12 {515 * x_mult,385 * y_mult}

CGPoint points1[7] = {p1, p3, p5, p2, p6, p7, p2};
CGPoint points2[7] = {p2, p4, p6, p3, p3, p8, p5};
CGPoint points3[7] = {p10, p12, p8, p6, p11, p11, p7};
CGPoint points4[7] = {p9, p11, p7, p5, p8, p10, p10};

+ (instancetype)sharedUtility {
    
    static FFUtility *sharedUtility = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedUtility = [[FFUtility alloc] init];
    });
    return sharedUtility;
}

- (UIBezierPath *)bezierPathForButton:(UIButton *)button {
    
    int index = [self.buttons indexOfObject:button];
    CGPoint point1  = points1[index % 7];
    CGPoint point2 = points2[(index) % 7];
    CGPoint point3  = points3[index % 7];
    CGPoint point4  = points4[index % 7];
    UIBezierPath *bezierPath = [UIBezierPath bezierPath];
    [bezierPath moveToPoint:point1];
    [bezierPath addLineToPoint:point2];
    [bezierPath addLineToPoint:point3];
    [bezierPath addLineToPoint:point4];
    [bezierPath closePath];
    return bezierPath;
}

- (UIColor *)colorForButton:(UIButton *)button {
    
    int index = [self.buttons indexOfObject:button];
    if (index == 0) {
        return [UIColor redColor];
    } else if (index == 1) {
        return [UIColor blackColor];
    } else if (index == 2) {
        return [UIColor yellowColor];
    } else if(index == 3) {
        return [UIColor greenColor];
    } else if (index == 4) {
        return [UIColor grayColor];
    } else if (index == 5) {
        return [UIColor cyanColor];
    } else if (index == 6) {
        return [UIColor blueColor];
    } else {
        return [UIColor magentaColor];
    }
}

@end
