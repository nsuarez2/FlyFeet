#import <UIKit/UIKit.h>
#import <ModelIO/ModelIO.h>
#import <libARDiscovery/ARDISCOVERY_BonjourDiscovery.h>
#import "FFButton.h"
#import "PilotingViewController.h"

@interface MoreViewController : UIViewController

@property (strong, nonatomic) IBOutlet UIButton *backButton;
@property (strong, nonatomic) IBOutlet UIButton *landButton;
@property (strong, nonatomic) IBOutlet UIButton *takeOffButton;
@property (strong, nonatomic) IBOutlet UIButton *flipButton;
@property (strong, nonatomic) IBOutlet UIButton *cameraButton;

@property Boolean isFlying;

@property (nonatomic) ARCONTROLLER_Device_t *moreController;

- (IBAction)takeoff:(id)sender;
- (IBAction)landing:(id)sender;
- (IBAction)flip:(id)sender;
- (IBAction)takePic:(id)sender;

@end