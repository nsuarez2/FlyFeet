#import "ViewController.h"
#import <libARDiscovery/ARDISCOVERY_BonjourDiscovery.h>
#import "PilotingViewController.h"

@interface CellData ()
@end

@implementation CellData
@end

@interface ViewController ()

@property (nonatomic, strong) ARService *serviceSelected;
@property (nonatomic, strong) NSArray *tableData;

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _tableData = [NSArray array];
    _serviceSelected = nil;
    
}

- (void) viewDidAppear:(BOOL)animated
{
    NSLog(@"Main view appeared");
    [super viewDidAppear:animated];
    
    [self registerApplicationNotifications];
    // start the discovery
    
    NSLog(@"Start discovery ");
    [[ARDiscovery sharedInstance] start];
}

- (void) viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    [self unregisterApplicationNotifications];
    [[ARDiscovery sharedInstance] stop];
}

- (void)registerApplicationNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(enteredBackground:) name: UIApplicationDidEnterBackgroundNotification object: nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(enterForeground:) name: UIApplicationWillEnterForegroundNotification object: nil];
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(discoveryDidUpdateServices:) name:kARDiscoveryNotificationServicesDevicesListUpdated object:nil];
}

- (void)unregisterApplicationNotifications
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name: UIApplicationDidEnterBackgroundNotification object: nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name: UIApplicationWillEnterForegroundNotification object: nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kARDiscoveryNotificationServicesDevicesListUpdated object:nil];
}

#pragma mark - application notifications
- (void)enteredBackground:(NSNotification*)notification
{
    [[ARDiscovery sharedInstance] stop];
}

- (void)enterForeground:(NSNotification*)notification
{
    [[ARDiscovery sharedInstance] start];
}

#pragma mark ARDiscovery notification
- (void)discoveryDidUpdateServices:(NSNotification *)notification
{
    // Called when the list of discovered services has changed
    dispatch_async(dispatch_get_main_queue(), ^{
        [self updateServicesList:[[notification userInfo] objectForKey:kARDiscoveryServicesList]];
    });
}

- (void)updateServicesList:(NSArray *)services
{
    NSMutableArray *serviceArray = [NSMutableArray array];
    
    for (ARService *service in services)
    {
        // only display the ble services
        if ([service.service isKindOfClass:[ARBLEService class]])
        {
            CellData *cellData = [[CellData alloc]init];
            
            [cellData setService:service];
            [cellData setName:service.name];
            [serviceArray addObject:cellData];
        }
    }
    
    _tableData = serviceArray;
    [_tableView reloadData];
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_tableData count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *simpleTableIdentifier = @"SimpleTableItem";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
    
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:simpleTableIdentifier];
    }
    
    //cell.textLabel.text = [(CellData *)[_tableData objectAtIndex:indexPath.row] name];
    cell.textLabel.text = @"Tommy's drone";
    cell.textLabel.font = [UIFont systemFontOfSize:25.0];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    _serviceSelected = [(CellData *)[_tableData objectAtIndex:indexPath.row] service];
    
    [self performSegueWithIdentifier:@"pilotingSegue" sender:self];
}

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if(([segue.identifier isEqualToString:@"pilotingSegue"]) && (_serviceSelected != nil))
    {
        PilotingViewController *pilotingViewController = (PilotingViewController *)[segue destinationViewController];
        
        [pilotingViewController setService: _serviceSelected];
    }
}

@end
