#import "PilotingViewController.h"
#import <libARDiscovery/ARDiscovery.h>
#import <libARController/ARController.h>
#import <uthash/uthash.h>
#import "FFUtility.h"
#import "FFButton.h"
#import "MoreViewController.h"
#import "AppDelegate.h"

void stateChanged (eARCONTROLLER_DEVICE_STATE newState, eARCONTROLLER_ERROR error, void *customData);
void onCommandReceived (eARCONTROLLER_DICTIONARY_KEY commandKey, ARCONTROLLER_DICTIONARY_ELEMENT_t *elementDictionary, void *customData);

@interface PilotingViewController ()
@property (nonatomic) ARCONTROLLER_Device_t *deviceController;
@property (nonatomic, strong) UIAlertView *alertView;
@property (nonatomic) dispatch_semaphore_t stateSem;
@end

@implementation PilotingViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    NSLog(@"Piloting view loaded");
    
    [_batteryLabel setText:@"waiting"];
    
    _alertView = [[UIAlertView alloc] initWithTitle:[_service name] message:@"Connecting ..."
                                           delegate:self cancelButtonTitle:nil otherButtonTitles:nil, nil];
    
    NSArray *buttons = @[self.button0, self.button1, self.button2, self.button3, self.button4, self.button5, self.button6, self.path0, self.path1, self.path2, self.path3];
    FFUtility *utility = [FFUtility sharedUtility];
    utility.buttons = buttons;
    
    _deviceController = NULL;
    _stateSem = dispatch_semaphore_create(0);
    
    _isFlying = false;
}

- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];

    [_alertView show];
    
    // create the device controller
    [self createDeviceControllerWithService:_service];
}

- (ARDISCOVERY_Device_t *)createDiscoveryDeviceWithService:(ARService*)service
{
    ARDISCOVERY_Device_t *device = NULL;
    
    eARDISCOVERY_ERROR errorDiscovery = ARDISCOVERY_OK;
    
    NSLog(@"Init discovey device");
    
    device = ARDISCOVERY_Device_New (&errorDiscovery);
    if ((errorDiscovery != ARDISCOVERY_OK) || (device == NULL))
    {
        NSLog(@"device : %p", device);
        NSLog(@"Discovery error :%s", ARDISCOVERY_Error_ToString(errorDiscovery));
    }
    
    if (errorDiscovery == ARDISCOVERY_OK)
    {
        // get the ble service from the ARService
        ARBLEService* bleService = service.service;
        
        // create a RollingSpider discovery device (ARDISCOVERY_PRODUCT_MINIDRONE)
        errorDiscovery = ARDISCOVERY_Device_InitBLE (device, ARDISCOVERY_PRODUCT_MINIDRONE, (__bridge ARNETWORKAL_BLEDeviceManager_t)(bleService.centralManager), (__bridge ARNETWORKAL_BLEDevice_t)(bleService.peripheral));
        
        if (errorDiscovery != ARDISCOVERY_OK)
        {
            NSLog(@"Discovery error :%s", ARDISCOVERY_Error_ToString(errorDiscovery));
        }
    }
    
    return device;
}

- (void)createDeviceControllerWithService:(ARService*)service
{
    // first get a discovery device
    ARDISCOVERY_Device_t *discoveryDevice = [self createDiscoveryDeviceWithService:service];
    
    if (discoveryDevice != NULL)
    {
        eARCONTROLLER_ERROR error = ARCONTROLLER_OK;
        
        // create the device controller
        NSLog(@"-ARCONTROLLER_Device_New");
        _deviceController = ARCONTROLLER_Device_New (discoveryDevice, &error);
        
        AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        
        appDelegate.delegateController = self.deviceController;
        
        if ((error != ARCONTROLLER_OK) || (_deviceController == NULL))
        {
            NSLog(@"Error :%s", ARCONTROLLER_Error_ToString(error));
        }
        
        // add the state change callback to be informed when the device controller starts, stops...
        if (error == ARCONTROLLER_OK)
        {
            NSLog(@"ARCONTROLLER_Device_AddStateChangedCallback");
            error = ARCONTROLLER_Device_AddStateChangedCallback(_deviceController, stateChanged, (__bridge void *)(self));
            
            if (error != ARCONTROLLER_OK)
            {
                NSLog(@"Error :%s", ARCONTROLLER_Error_ToString(error));
            }
        }
        
        // add the command received callback to be informed when a command has been received from the device
        if (error == ARCONTROLLER_OK)
        {
            NSLog(@"ARCONTROLLER_Device_AddCommandRecievedCallback");
            error = ARCONTROLLER_Device_AddCommandReceivedCallback(_deviceController, onCommandReceived, (__bridge void *)(self));
            
            if (error != ARCONTROLLER_OK)
            {
                NSLog(@"Error :%s", ARCONTROLLER_Error_ToString(error));
            }
        }
        
        // start the device controller (the callback stateChanged should be called soon)
        if (error == ARCONTROLLER_OK)
        {
            NSLog(@"ARCONTROLLER_Device_Start");
            error = ARCONTROLLER_Device_Start (_deviceController);
            
            if (error != ARCONTROLLER_OK)
            {
                NSLog(@"Error :%s", ARCONTROLLER_Error_ToString(error));
            }
        }
        
        // we don't need the discovery device anymore
        ARDISCOVERY_Device_Delete (&discoveryDevice);
        
        // if an error occured, go back
        if (error != ARCONTROLLER_OK)
        {
            [self goBack];
        }
    }
}

- (void) viewDidDisappear:(BOOL)animated
{
    
    _deviceController->miniDrone->sendPilotingLanding(_deviceController->miniDrone);
    
    if (_alertView && !_alertView.isHidden)
    {
        [_alertView dismissWithClickedButtonIndex:0 animated:NO];
    }
    _alertView = [[UIAlertView alloc] initWithTitle:[_service name] message:@"Disconnecting ..."
                                           delegate:self cancelButtonTitle:nil otherButtonTitles:nil, nil];
    [_alertView show];
    
    // in background
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        eARCONTROLLER_ERROR error = ARCONTROLLER_OK;
        
        // if the device controller is not stopped, stop it
        eARCONTROLLER_DEVICE_STATE state = ARCONTROLLER_Device_GetState(_deviceController, &error);
        if ((error == ARCONTROLLER_OK) && (state != ARCONTROLLER_DEVICE_STATE_STOPPED))
        {
            // after that, stateChanged should be called soon
            error = ARCONTROLLER_Device_Stop (_deviceController);
            
            if (error != ARCONTROLLER_OK)
            {
                NSLog(@"Error :%s", ARCONTROLLER_Error_ToString(error));
            }
            else
            {
                // wait for the state to change to stopped
                NSLog(@"Wait new state ... ");
                dispatch_semaphore_wait(_stateSem, DISPATCH_TIME_FOREVER);
            }
        }
        
        // once the device controller is stopped, we can delete it
        if (_deviceController != NULL)
        {
            ARCONTROLLER_Device_Delete(&_deviceController);
        }
        
        // dismiss the alert view in main thread
        dispatch_async(dispatch_get_main_queue(), ^{
            [_alertView dismissWithClickedButtonIndex:0 animated:TRUE];
        });
    });
}

- (void)goBack
{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark Device controller callbacks
// called when the state of the device controller has changed
void stateChanged (eARCONTROLLER_DEVICE_STATE newState, eARCONTROLLER_ERROR error, void *customData)
{
    PilotingViewController *pilotingViewController = (__bridge PilotingViewController *)customData;
    
    NSLog (@"newState: %d",newState);
    
    if (pilotingViewController != nil)
    {
        switch (newState)
        {
            case ARCONTROLLER_DEVICE_STATE_RUNNING:
            {
                // dismiss the alert view in main thread
                dispatch_async(dispatch_get_main_queue(), ^{
                    [pilotingViewController.alertView dismissWithClickedButtonIndex:0 animated:TRUE];
                });
                break;
            }
            case ARCONTROLLER_DEVICE_STATE_STOPPED:
            {
                dispatch_semaphore_signal(pilotingViewController.stateSem);
                
                // Go back
                dispatch_async(dispatch_get_main_queue(), ^{
                    [pilotingViewController goBack];
                });
                
                break;
            }
                
            case ARCONTROLLER_DEVICE_STATE_STARTING:
                break;
                
            case ARCONTROLLER_DEVICE_STATE_STOPPING:
                break;
                
            default:
                NSLog(@"new State : %d not known", newState);
                break;
        }
    }
}

// called when a command has been received from the drone
void onCommandReceived (eARCONTROLLER_DICTIONARY_KEY commandKey, ARCONTROLLER_DICTIONARY_ELEMENT_t *elementDictionary, void *customData)
{
    PilotingViewController *pilotingViewController = (__bridge PilotingViewController *)customData;
    
    // if the command received is a battery state changed
    if ((commandKey == ARCONTROLLER_DICTIONARY_KEY_COMMON_COMMONSTATE_BATTERYSTATECHANGED) && (elementDictionary != NULL))
    {
        ARCONTROLLER_DICTIONARY_ARG_t *arg = NULL;
        ARCONTROLLER_DICTIONARY_ELEMENT_t *element = NULL;
        
        // get the command received in the device controller
        HASH_FIND_STR (elementDictionary, ARCONTROLLER_DICTIONARY_SINGLE_KEY, element);
        if (element != NULL)
        {
            // get the value
            HASH_FIND_STR (element->arguments, ARCONTROLLER_DICTIONARY_KEY_COMMON_COMMONSTATE_BATTERYSTATECHANGED_PERCENT, arg);
            
            if (arg != NULL)
            {
                // update UI
                [pilotingViewController onUpdateBatteryLevel:arg->value.U8];
            }
        }
    }
}


#pragma mark events

- (IBAction)emergencyClick:(id)sender
{
    // send an emergency command to the RollingSpider
    _deviceController->miniDrone->sendPilotingEmergency(_deviceController->miniDrone);
}

//events for gaz:
- (IBAction)gazUpTouchDown:(id)sender
{
    // set the gaz value of the piloting command
    _deviceController->miniDrone->setPilotingPCMDGaz(_deviceController->miniDrone, 50);
}
- (IBAction)gazDownTouchDown:(id)sender
{
    _deviceController->miniDrone->setPilotingPCMDGaz(_deviceController->miniDrone, -50);
}

- (IBAction)gazUpTouchUp:(id)sender
{
    _deviceController->miniDrone->setPilotingPCMDGaz(_deviceController->miniDrone, 0);
}
- (IBAction)gazDownTouchUp:(id)sender
{
    _deviceController->miniDrone->setPilotingPCMDGaz(_deviceController->miniDrone, 0);

}

//events for yaw:
- (IBAction)yawLeftTouchDown:(id)sender
{
    _deviceController->miniDrone->setPilotingPCMDYaw(_deviceController->miniDrone, -50);
}
- (IBAction)yawRightTouchDown:(id)sender
{
    _deviceController->miniDrone->setPilotingPCMDYaw(_deviceController->miniDrone, 50);
}

- (IBAction)yawLeftTouchUp:(id)sender
{
    _deviceController->miniDrone->setPilotingPCMDYaw(_deviceController->miniDrone, 0);
}

- (IBAction)yawRightTouchUp:(id)sender
{
    _deviceController->miniDrone->setPilotingPCMDYaw(_deviceController->miniDrone, 0);
}

//events for yaw:
- (IBAction)rollLeftTouchDown:(id)sender
{
    _deviceController->miniDrone->setPilotingPCMDFlag(_deviceController->miniDrone, 1);
    _deviceController->miniDrone->setPilotingPCMDRoll(_deviceController->miniDrone, -50);
}
- (IBAction)rollRightTouchDown:(id)sender
{
    _deviceController->miniDrone->setPilotingPCMDFlag(_deviceController->miniDrone, 1);
    _deviceController->miniDrone->setPilotingPCMDRoll(_deviceController->miniDrone, 50);
}

- (IBAction)rollLeftTouchUp:(id)sender
{
    _deviceController->miniDrone->setPilotingPCMDFlag(_deviceController->miniDrone, 0);
    _deviceController->miniDrone->setPilotingPCMDRoll(_deviceController->miniDrone, 0);
}
- (IBAction)rollRightTouchUp:(id)sender
{
    _deviceController->miniDrone->setPilotingPCMDFlag(_deviceController->miniDrone, 0);
    _deviceController->miniDrone->setPilotingPCMDRoll(_deviceController->miniDrone, 0);
}

//events for pitch:
- (IBAction)pitchForwardTouchDown:(id)sender
{
    _deviceController->miniDrone->setPilotingPCMDFlag(_deviceController->miniDrone, 1);
    _deviceController->miniDrone->setPilotingPCMDPitch(_deviceController->miniDrone, 50);
}
- (IBAction)pitchBackTouchDown:(id)sender
{
    _deviceController->miniDrone->setPilotingPCMDFlag(_deviceController->miniDrone, 1);
    _deviceController->miniDrone->setPilotingPCMDPitch(_deviceController->miniDrone, -50);
}

- (IBAction)pitchForwardTouchUp:(id)sender
{
    _deviceController->miniDrone->setPilotingPCMDFlag(_deviceController->miniDrone, 0);
    _deviceController->miniDrone->setPilotingPCMDPitch(_deviceController->miniDrone, 0);
}
- (IBAction)pitchBackTouchUp:(id)sender
{
    _deviceController->miniDrone->setPilotingPCMDFlag(_deviceController->miniDrone, 0);
    _deviceController->miniDrone->setPilotingPCMDPitch(_deviceController->miniDrone, 0);
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{    if ([[segue identifier] isEqualToString:@"showMore"])
    {
        NSLog(@"PREPARE TO SEGUE");
        MoreViewController *vc = [segue destinationViewController];
        vc.moreController = self.deviceController;
    }
}

-(void)land {
    _deviceController->miniDrone->sendPilotingLanding(_deviceController->miniDrone);
}

#pragma mark UI updates from commands
- (void)onUpdateBatteryLevel:(uint8_t)percent;
{
    NSLog(@"onUpdateBattery ...");
    
    dispatch_async(dispatch_get_main_queue(), ^{
        NSString *text = [[NSString alloc] initWithFormat:@"%d%%", percent];
        [_batteryLabel setText:text];
    });
}

@end
