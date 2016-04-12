#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface FFUtility : NSObject

@property (strong, nonatomic) NSArray *buttons;

+ (instancetype)sharedUtility;
- (UIBezierPath *)bezierPathForButton:(UIButton *)button;
- (UIColor *)colorForButton:(UIButton *)button;

@end
