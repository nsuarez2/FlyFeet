//
//  ViewController.h
//  FlyFeet
//
//  Created by Nico Suarez on 3/21/16.
//  Copyright © 2016 Nico Suarez. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <libARDiscovery/ARDISCOVERY_BonjourDiscovery.h>

@interface ViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) IBOutlet UITableView *tableView;

@end

@interface CellData : NSObject

@property (nonatomic, strong) ARService* service;
@property (nonatomic, strong) NSString* name;

@end