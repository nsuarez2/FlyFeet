#import "FFUtility.h"
#import <CoreGraphics/CoreGraphics.h>
#import <UIKit/UIKit.h>


@implementation FFUtility

//Coords are scaled to 1024x768
//Based at 515x385
const double x_mult = 1.988;
const double y_mult = 1.995;

//const double x_mult = 1;
//const double y_mult = 1;

//Button points
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

//Line 1
#define pl0 {208/1.988 * x_mult,0 * y_mult}
#define pl1 {210/1.988 * x_mult,0 * y_mult}
#define pl2 {433/1.988 * x_mult,284/1.995 * y_mult}
#define pl3 {432/1.988 * x_mult,285/1.995 * y_mult}

//Line 2
#define pl4 {814/1.988 * x_mult,0 * y_mult}
#define pl5 {816/1.988 * x_mult,0 * y_mult}
#define pl6 {592/1.988 * x_mult,285/1.995 * y_mult}
#define pl7 {591/1.988 * x_mult,284/1.995 * y_mult}

//Line 3
#define pl8 {591/1.988 * x_mult,484/1.995 * y_mult}
#define pl9 {592/1.988 * x_mult,483/1.995 * y_mult}
#define pl10 {816/1.988 * x_mult,768/1.995 * y_mult}
#define pl11 {814/1.988 * x_mult,768/1.995 * y_mult}

//Line 4
#define pl12 {208/1.988 * x_mult,768/1.995 * y_mult}
#define pl13 {432/1.988 * x_mult,483/1.995 * y_mult}
#define pl14 {433/1.988 * x_mult,484/1.995 * y_mult}
#define pl15 {210/1.988 * x_mult,768/1.995 * y_mult}


CGPoint points1[7] = {p1, p3, p5, p2, p6, p7, p2};
CGPoint points2[7] = {p2, p4, p6, p3, p3, p8, p5};
CGPoint points3[7] = {p10, p12, p8, p6, p11, p11, p7};
CGPoint points4[7] = {p9, p11, p7, p5, p8, p10, p10};

CGPoint points5[4] = {pl0, pl4, pl8, pl12};
CGPoint points6[4] = {pl1, pl5, pl9, pl13};
CGPoint points7[4] = {pl2, pl6, pl10, pl14};
CGPoint points8[4] = {pl3, pl7, pl11, pl15};

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
    
    if (index < 7) {
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
    } else {
        CGPoint point1 = points5[index % 4];
        CGPoint point2 = points6[index % 4];
        CGPoint point3 = points7[index % 4];
        CGPoint point4 = points8[index % 4];
        
        UIBezierPath *bezierPath = [UIBezierPath bezierPath];
        [bezierPath moveToPoint:point1];
        [bezierPath addLineToPoint:point2];
        [bezierPath addLineToPoint:point3];
        [bezierPath addLineToPoint:point4];
        [bezierPath closePath];
        return bezierPath;
    }
    
    
}

- (UIColor *)colorForButton:(UIButton *)button {
    
    int index = [self.buttons indexOfObject:button];
    if (index == 0) {
        return [UIColor colorWithRed:0.961 green:0.89 blue:0.247 alpha:1];
    } else if (index == 1) {
        return [UIColor colorWithRed:0.961 green:0.89 blue:0.247 alpha:1];
    } else if (index == 2) {
        return [UIColor colorWithRed:0.961 green:0.89 blue:0.247 alpha:1];
    } else if(index == 3) {
        return [UIColor colorWithRed:0.247 green:0.247 blue:0.961 alpha:1];
    } else if (index == 4) {
        return [UIColor colorWithRed:0.247 green:0.247 blue:0.961 alpha:1];
    } else if (index == 5) {
        return [UIColor colorWithRed:0.247 green:0.247 blue:0.961 alpha:1];
    } else if (index == 6) {
        return [UIColor colorWithRed:0.247 green:0.247 blue:0.961 alpha:1];
    } else {
        return [UIColor colorWithRed:0.961 green:0.89 blue:0.247 alpha:1];
    }
}

@end
