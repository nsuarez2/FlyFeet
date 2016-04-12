#import "FFButton.h"
#import "FFUtility.h"

@implementation FFButton

- (id)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}


- (void)drawRect:(CGRect)rect {
    
    UIBezierPath *path = [[FFUtility sharedUtility] bezierPathForButton:self];
    [[[FFUtility sharedUtility] colorForButton:self] setFill];
    [path fill];
}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    
    UIBezierPath *path = [[FFUtility sharedUtility] bezierPathForButton:self];
    if ([path containsPoint:point]) {
        return self;
    } else {
        return nil;
    }
}

@end