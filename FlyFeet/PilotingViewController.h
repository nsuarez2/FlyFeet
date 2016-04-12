#import <UIKit/UIKit.h>
#import <libARDiscovery/ARDISCOVERY_BonjourDiscovery.h>
#import "FFButton.h"
#import "PilotingViewController.h"
#import <libARDiscovery/ARDiscovery.h>
#import <libARController/ARController.h>
#import <uthash/uthash.h>
#import "FFUtility.h"

@interface PilotingViewController : UIViewController

// the service we want to connect with (in this sample, this is a service.service is a ARBLEService)
@property (nonatomic, strong) ARService* service;

@property (nonatomic, strong) IBOutlet UILabel *batteryLabel;

@property (strong, nonatomic) IBOutlet FFButton *button0;
@property (strong, nonatomic) IBOutlet FFButton *button1;
@property (strong, nonatomic) IBOutlet FFButton *button2;
@property (strong, nonatomic) IBOutlet FFButton *button3;
@property (strong, nonatomic) IBOutlet FFButton *button4;
@property (strong, nonatomic) IBOutlet FFButton *button5;
@property (strong, nonatomic) IBOutlet FFButton *button6;

@property (strong, nonatomic) IBOutlet FFButton *path1;
@property (strong, nonatomic) IBOutlet FFButton *path2;
@property (strong, nonatomic) IBOutlet FFButton *path3;
@property (strong, nonatomic) IBOutlet FFButton *path0;

@property Boolean isFlying;

- (IBAction)emergencyClick:(id)sender;
- (IBAction)takeoffClick:(id)sender;
- (IBAction)landingClick:(id)sender;

- (IBAction)gazUpTouchDown:(id)sender;
- (IBAction)gazDownTouchDown:(id)sender;

- (IBAction)gazUpTouchUp:(id)sender;
- (IBAction)gazDownTouchUp:(id)sender;


- (IBAction)yawLeftTouchDown:(id)sender;
- (IBAction)yawRightTouchDown:(id)sender;

- (IBAction)yawLeftTouchUp:(id)sender;
- (IBAction)yawRightTouchUp:(id)sender;


- (IBAction)rollLeftTouchDown:(id)sender;
- (IBAction)rollRightTouchDown:(id)sender;

- (IBAction)rollLeftTouchUp:(id)sender;
- (IBAction)rollRightTouchUp:(id)sender;


- (IBAction)pitchForwardTouchDown:(id)sender;
- (IBAction)pitchBackTouchDown:(id)sender;

- (IBAction)pitchForwardTouchUp:(id)sender;
- (IBAction)pitchBackTouchUp:(id)sender;

-(void)land;

@end

