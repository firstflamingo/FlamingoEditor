//  Copyright (c) 2012-2015 First Flamingo Enterprise B.V.
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//
//  ABOServiceWindowController.m
//  FlamingoEditor
//
//  Created by Berend Schotanus on 10-08-12.
//

#import "ABOServiceWindowController.h"
#import "NSManagedObjectContext+FFEUtilities.h"
#import "ABOAppDelegate.h"

#import "ATLDataController.h"
#import "ABOOrganizationWindowController.h"
#import "ABOSeriesWindowController.h"

#import "ATLSeries.h"
#import "ATLSeriesRef.h"
#import "ATLService.h"
#import "ATLServicePoint.h"
#import "ATLServiceRef.h"
#import "ATLServiceRule.h"
#import "ATLRoute.h"
#import "ATLLocation.h"
#import "ATLStation.h"
#import "ATLJunction.h"
#import "ATLPathNode.h"

typedef enum {
    topConnectionRow,
    routePointRow,
    bottomConnectionRow
} ABOServiceRowType;

@implementation ABOServiceWindowController

#pragma mark - Object lifecycle

- (void)windowDidLoad
{
    [super windowDidLoad];
    [self.upPointsTableView registerForDraggedTypes:@[ROUTE_ITEM_UTI]];
    [self.downPointsTableView registerForDraggedTypes:@[ROUTE_ITEM_UTI]];
}

- (void)awakeFromNib
{
    self.upPointsTableView.intercellSpacing = CGSizeMake(3.0, 0.0);
    self.downPointsTableView.intercellSpacing = CGSizeMake(3.0, 0.0);
    [self.servicesArrayController addObserver:self forKeyPath:@"selection" options:NSKeyValueObservingOptionNew context:nil];
}

- (void)dealloc
{
    [self.servicesArrayController removeObserver:self forKeyPath:@"selection"];
}

#pragma mark - Connecting to the environment

- (ABOAppDelegate *)appDelegate
{
    return (ABOAppDelegate*)[[NSApplication sharedApplication] delegate];
}

- (NSManagedObjectContext *)managedObjectContext
{
    return self.dataController.managedObjectContext;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if (object == self.servicesArrayController && [keyPath isEqualToString:@"selection"]) {
        [self reloadData];
    }
}

#pragma mark - Services table

- (ATLService *)selectedService
{
    ATLService *selectedService = nil;
    NSArray *services = [self.servicesArrayController selectedObjects];
    if ([services count] == 1) selectedService = services[0];
    return selectedService;
}

- (IBAction)linkOperator:(id)sender
{
    
    NSManagedObject *serviceOperator = (NSManagedObject*)self.appDelegate.organisationWindowController.selectedOrganization;
    if (serviceOperator) {
        NSError *error;
        [self.selectedService setValue:serviceOperator forKey:@"serviceOperator"];
        if (![self.selectedService validateForUpdate:&error]) {
            NSLog(@"Error while validating operator %@ - %@", error, [error localizedDescription]);
        }
        if (![serviceOperator validateForUpdate:&error]) {
            NSLog(@"Error while validating operator %@ - %@", error, [error localizedDescription]);
        }
    }
}

- (IBAction)linkGrantor:(id)sender
{
    NSManagedObject *grantor = (NSManagedObject*)self.appDelegate.organisationWindowController.selectedOrganization;
    if (grantor) {
        NSError *error;
        [self.selectedService setValue:grantor forKey:@"grantor"];
        if (![self.selectedService validateForUpdate:&error]) {
            NSLog(@"Error while validating grantor %@ - %@", error, [error localizedDescription]);
        }
        if (![grantor validateForUpdate:&error]) {
            NSLog(@"Error while validating grantor %@ - %@", error, [error localizedDescription]);
        }
    }
}

- (IBAction)connectServices:(id)sender {
    NSArray *services = [self.servicesArrayController selectedObjects];
    if ([services count] == 2) {
        ATLService *serviceA = services[0];
        ATLService *serviceB = services[1];
        if (serviceA.lastStation == serviceB.firstStation) {
            ATLServiceRef *connection = (ATLServiceRef*)[self.managedObjectContext createManagedObjectOfType:@"ATLServiceRef"];
            connection.previousService = serviceA;
            connection.nextService = serviceB;
            [self reloadData];
        }
        if (serviceB.lastStation == serviceA.firstStation) {
            ATLServiceRef *connection = (ATLServiceRef*)[self.managedObjectContext createManagedObjectOfType:@"ATLServiceRef"];
            connection.previousService = serviceB;
            connection.nextService = serviceA;
            [self reloadData];
        }
    }
}

- (IBAction)fillSchedule:(id)sender {
    for (ATLService *service in [self.servicesArrayController selectedObjects]) {
        NSLog(@"Fill service %@", service.id_);
        [service fillSchedule];
    }
    [self reloadData];
}

- (IBAction)clearSchedule:(id)sender {
    [self.selectedService clearServiceRules];
    [self.upRulesTableView reloadData];
    [self.downRulesTableView reloadData];
    
    for (ATLServicePoint *point in self.selectedService.servicePoints) {
        [point clearSchedule];
    }
    [self.upPointsTableView reloadData];
    [self.downPointsTableView reloadData];
}

#pragma mark - Route points table

- (NSArray *)upServicePoints
{
    if (!_upServicePoints) {
        NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"km" ascending:YES];
        self.upServicePoints = [self.selectedService.servicePoints sortedArrayUsingDescriptors:@[sort]];
    }
    return _upServicePoints;
}

- (NSArray *)downServicePoints
{
    if (!_downServicePoints) {
        NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"km" ascending:NO];
        self.downServicePoints = [self.selectedService.servicePoints sortedArrayUsingDescriptors:@[sort]];
    }
    return _downServicePoints;
}

- (NSArray *)previousConnections
{
    if (!_previousConnections) {
        NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"previousService.id_" ascending:YES];
        self.previousConnections = [self.selectedService.previousServiceRefs sortedArrayUsingDescriptors:@[sort]];
    }
    return _previousConnections;
}

- (NSArray *)nextConnections
{
    if (!_nextConnections) {
        NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"nextService.id_" ascending:YES];
        self.nextConnections = [self.selectedService.nextServiceRefs sortedArrayUsingDescriptors:@[sort]];
    }
    return _nextConnections;
}

- (IBAction)removeRoutePoint:(id)sender
{
    NSTableView *tableView = (BOOL)[sender tag] ? self.upPointsTableView : self.downPointsTableView;
    NSMutableSet *expiredObjects = [NSMutableSet setWithCapacity:5];
    NSMutableSet *expiredServicePoints = [NSMutableSet setWithCapacity:5];
    
    [tableView.selectedRowIndexes enumerateIndexesUsingBlock:^(NSUInteger row, BOOL *stop){
        NSManagedObject *expiredObject = [self objectForRow:row inTableView:tableView];
        [expiredObjects addObject:expiredObject];
        if ([expiredObject isKindOfClass:[ATLServicePoint class]]) {
            [expiredServicePoints addObject:expiredObject];
        }
    }];
    [self.selectedService removeServicePoints:expiredServicePoints];
    for (NSManagedObject *expiredObject in expiredObjects) {
        [self.managedObjectContext deleteObject:expiredObject];
    }
    [self performSelector:@selector(reloadData) withObject:nil afterDelay:0.1];
}

- (void)reloadData
{
    self.upServicePoints = nil;
    self.downServicePoints = nil;
    self.previousConnections = nil;
    self.nextConnections = nil;
    [self.upPointsTableView reloadData];
    [self.downPointsTableView reloadData];
}

- (NSUInteger)nrOfTopConnectionsInTableView:(NSTableView*)tableView
{
    if (tableView == self.upPointsTableView) {
        return [self.previousConnections count];
    } else {
        NSAssert(tableView == self.downPointsTableView, @"must be downPointsTableView");
        return [self.nextConnections count];
    }
}

- (NSUInteger)routePointIndexForRow:(NSUInteger)row inTableView:(NSTableView*)tableView
{
    NSUInteger offset = [self nrOfTopConnectionsInTableView:tableView];
    return MAX(0, row - offset);
}

- (NSUInteger)bottomConnectionIndexForRow:(NSUInteger)row inTableView:(NSTableView*)tableView
{
    NSUInteger offset = [self nrOfTopConnectionsInTableView:tableView] + [self.selectedService.servicePoints count];
    return MAX(0, row - offset);
}

- (ABOServiceRowType)rowTypeForRow:(NSUInteger)row inTableView:(NSTableView*)tableView
{
    NSUInteger sectionBorder = [self nrOfTopConnectionsInTableView:tableView];
    if (row < sectionBorder) {
        return topConnectionRow;
    }
    sectionBorder += [self.selectedService.servicePoints count];
    if (row < sectionBorder) {
        return routePointRow;
    }
    return bottomConnectionRow;
}

- (NSManagedObject*)objectForRow:(NSUInteger)row inTableView:(NSTableView*)tableView
{
    BOOL upDirection = (tableView == self.upPointsTableView);
    switch ([self rowTypeForRow:row inTableView:tableView]) {
        case topConnectionRow: {
            NSArray *connections = upDirection ? self.previousConnections : self.nextConnections;
            return connections[row];
        }
        case routePointRow: {
            NSUInteger pointIndex = [self routePointIndexForRow:row inTableView:tableView];
            NSArray *timeTablePoints = upDirection ? self.upServicePoints : self.downServicePoints;
            return timeTablePoints[pointIndex];
        }
        case bottomConnectionRow: {
            NSUInteger connectionIndex = [self bottomConnectionIndexForRow:row inTableView:tableView];
            NSArray *connections = upDirection ? self.nextConnections : self.previousConnections;
            return connections[connectionIndex];
        }
        default:
            return nil;
    }
}

#pragma mark NSTableView dataSource and delegate methods

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView
{
    NSUInteger nrOfConnections = [[self.selectedService previousServices] count] + [[self.selectedService nextServices] count];
    return [self.selectedService.servicePoints count] + nrOfConnections;
}

- (NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
    ABOTableCellView *cellView = nil;
    NSString *suffix = @"";
    if (row == 0) suffix = @"_top";
    if (row == [tableView numberOfRows] - 1) suffix = @"_bottom";
    BOOL upDirection = (tableView == self.upPointsTableView);
    
    switch ([self rowTypeForRow:row inTableView:tableView]) {
        case topConnectionRow:
        {
            NSArray *connections = upDirection ? self.previousConnections : self.nextConnections;
            ATLServiceRef *connection = connections[row];
            cellView = [tableView makeViewWithIdentifier:@"ServiceConnectionCell" owner:self];
            cellView.textField.stringValue = [connection destinationFor:self.selectedService];
            cellView.codeField.stringValue = [connection connectedCodeFor:self.selectedService];
            cellView.imageView.image = [NSImage imageNamed:[NSString stringWithFormat:@"sconnection1%@", suffix]];
            break;
        }
        case routePointRow:
        {
            NSUInteger pointIndex = [self routePointIndexForRow:row inTableView:tableView];
            NSArray *timeTablePoints = upDirection ? self.upServicePoints : self.downServicePoints;
            ATLServicePoint *servicePoint = timeTablePoints[pointIndex];
            if (!servicePoint.location) {
                NSLog(@"routePoint: %@", servicePoint);
                return [tableView makeViewWithIdentifier:@"ErrorCell" owner:self];
            }
            if ([servicePoint.location isKindOfClass:[ATLStation class]]) {
                cellView = [tableView makeViewWithIdentifier:@"ServiceStopCell" owner:self];
                ATLStation *station = (ATLStation*)servicePoint.location;
                cellView.textField.stringValue = station.name;
                cellView.imageView.image = [NSImage imageNamed:[NSString stringWithFormat:@"sstop%@", suffix]];
                if (upDirection) {
                    [cellView updateArrival:servicePoint.upArrival
                                  departure:servicePoint.upDeparture];
                } else {
                    [cellView updateArrival:servicePoint.downArrival
                                  departure:servicePoint.downDeparture];
                }
            } else {
                cellView = [tableView makeViewWithIdentifier:@"JunctionCell" owner:self];
                
                if (row > 0) {
                    ATLServicePoint *previousPoint = timeTablePoints[pointIndex - 1];
                    ATLRoute *route1 = [servicePoint.location commonRouteWithItem:previousPoint.location];
                    ATLRoute *route2 = [(ATLJunction*)servicePoint.location routeJoinedTo:route1];
                    cellView.textField.stringValue = [NSString stringWithFormat:@"%@\n%@", route1.name, route2.name];
                }
            }
            cellView.delegate = self;
            cellView.pointIndex = (int)pointIndex;
            cellView.upDirection = upDirection;
            cellView.kmTextField.stringValue = [NSString stringWithFormat:@"%.1f", servicePoint.km];
            break;
        }
        case bottomConnectionRow:
        {
            NSUInteger connectionIndex = [self bottomConnectionIndexForRow:row inTableView:tableView];
            NSArray *connections = upDirection ? self.nextConnections : self.previousConnections;
            ATLServiceRef *connection = connections[connectionIndex];
            cellView = [tableView makeViewWithIdentifier:@"ServiceConnectionCell" owner:self];
            cellView.textField.stringValue = [connection destinationFor:self.selectedService];
            cellView.codeField.stringValue = [connection connectedCodeFor:self.selectedService];
            cellView.imageView.image = [NSImage imageNamed:[NSString stringWithFormat:@"sconnection2%@", suffix]];
            break;
        }
    }
    return cellView;
}

- (NSDragOperation)tableView:(NSTableView *)tableView validateDrop:(id<NSDraggingInfo>)info proposedRow:(NSInteger)row
       proposedDropOperation:(NSTableViewDropOperation)dropOperation
{
    return NSDragOperationLink;
}

- (BOOL)tableView:(NSTableView *)tableView acceptDrop:(id<NSDraggingInfo>)info row:(NSInteger)row dropOperation:(NSTableViewDropOperation)dropOperation
{
    __block BOOL success = NO;
    NSPersistentStoreCoordinator *storeCoordinator = self.managedObjectContext.persistentStoreCoordinator;
    
    [info enumerateDraggingItemsWithOptions:0 forView:tableView classes:@[[ATLLocation class]] searchOptions:nil usingBlock:^(NSDraggingItem *draggingItem, NSInteger index, BOOL *stop) {
        NSManagedObjectID *theID = [storeCoordinator managedObjectIDForURIRepresentation:[NSURL URLWithString:draggingItem.item]];
        ATLLocation *location = (ATLLocation*)[self.managedObjectContext objectRegisteredForID:theID];
        if ([self.selectedService insertLocation:location]) success = YES;
        
    }];
    if (success) [self reloadData];
    
    return success;
}

#pragma mark - ABOTableCellDelegate method

- (void)updateUpArrival:(int16_t)arrival departure:(int16_t)departure forPointIndex:(int)pointIndex
{
    ATLServicePoint *servicePoint = self.upServicePoints[pointIndex];
    if ([servicePoint.location isKindOfClass:[ATLStation class]]) {
        [servicePoint setUpArrival:arrival departure:departure];
    }
}

- (void)updateDownArrival:(int16_t)arrival departure:(int16_t)departure forPointIndex:(int)pointIndex
{
    ATLServicePoint *servicePoint = self.downServicePoints[pointIndex];
    if ([servicePoint.location isKindOfClass:[ATLStation class]]) {
        [servicePoint setDownArrival:arrival departure:departure];
    }
}

#pragma mark SeriesRef table

- (ATLSeriesRef *)selectedReference
{
    ATLSeriesRef *reference = nil;
    NSArray *references = [self.seriesRefArrayController selectedObjects];
    if ([references count] == 1) reference = references[0];
    return reference;
}

- (IBAction)linkSeriesRef:(id)sender {
    if (self.selectedService) {
        NSArray *seriesArray = self.appDelegate.seriesWindowController.seriesArrayController.selectedObjects;
        if ([seriesArray count] > 0) {
            for (ATLSeries *series in seriesArray) {
                ATLSeriesRef *connection = (ATLSeriesRef*)[self.managedObjectContext createManagedObjectOfType:@"ATLSeriesRef"];
                connection.series = series;
                connection.service = self.selectedService;
            }
        }
    }
}

#pragma mark Export Services XML

- (void)exportXMLFile:(id)sender
{
    NSSavePanel *panel = [NSSavePanel savePanel];
    [panel setAllowedFileTypes:[NSArray arrayWithObject:@"xml"]];
    [panel beginSheetModalForWindow:self.window completionHandler:^(NSInteger result){
        if (result == NSFileHandlingPanelOKButton) {
            [[self xmlString] writeToURL:[panel URL]
                              atomically:NO
                                encoding:NSUTF8StringEncoding
                                   error:NULL];

        }
    }];
}

- (NSString *)xmlString
{
    NSMutableString *output = [NSMutableString stringWithCapacity:1000];
    [output appendString:@"<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n"];
    [output appendString:@"<timetable version=\"1.0\" year=\"2012\">\n"];
    for (ATLService *service in self.servicesArrayController.arrangedObjects) {
        [output appendString:service.xmlString];
    }
    [output appendString:@"</timetable>\n"];
    return output;
}

@end
