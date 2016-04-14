#import "MoreViewController.h"
#import "PilotingViewController.h"
#import <libARController/ARController.h>
#import <uthash/uthash.h>
#import "FFUtility.h"
#import "FFButton.h"

@implementation MoreViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    NSLog(@"More view controller loaded");
    
}

- (IBAction)takeoff:(id)sender
{
    _moreController->miniDrone->sendPilotingTakeOff(_moreController->miniDrone);

}

- (IBAction)landing:(id)sender
{
    _moreController->miniDrone->sendPilotingLanding(_moreController->miniDrone);
}


- (IBAction)flip:(id)sender
{
    _moreController->miniDrone->sendAnimationsFlip(_moreController->miniDrone, (eARCOMMANDS_MINIDRONE_ANIMATIONS_FLIP_DIRECTION)1);
}

- (IBAction)takePic:(id)sender
{
    _moreController->miniDrone->sendMediaRecordPicture(_moreController->miniDrone, 0);
}


@end
