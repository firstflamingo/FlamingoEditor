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
//  ABORoutesWindowController.m
//  FlamingoEditor
//
//  Created by Berend Schotanus on 01-03-12.
//

#import "ABORoutesWindowController.h"
#import "ABOAppDelegate.h"
#import "ABOLocationWindowController.h"
#import "ABOOrganizationWindowController.h"

#import "ABOTableCellView.h"

#import "ATLDataController.h"
#import "ATLSubRoute.h"
#import "ATLLocation.h"
#import "ATLStation.h"
#import "ATLJunction.h"
#import "ATLRoutePosition.h"
#import "ATLDataController.h"
#import "ATLNode.h"

#import "NSManagedObjectContext+FFEUtilities.h"

@implementation ABORoutesWindowController

#pragma mark - Application lifecycle

- (void)awakeFromNib
{
    self.routeItemsTable.intercellSpacing = CGSizeMake(3.0, 0.0);
    [self.routesArrayController addObserver:self forKeyPath:@"selection" options:NSKeyValueObservingOptionNew context:nil];
}

- (void)windowDidLoad
{
    [super windowDidLoad];
    [self.addRoutePanel orderOut:self];
    [self.addItemPanel orderOut:self];
}

- (void)dealloc
{
    [self.routesArrayController removeObserver:self forKeyPath:@"selection"];
}

#pragma mark - Connections to the environment

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
    if (object == self.routesArrayController && [keyPath isEqualToString:@"selection"]) {
        self.arrangedRoutePositions = nil;
        [self.routeItemsTable reloadData];
    }
}

#pragma mark - Methods called from menu (firstresponder)

- (void)connectRouteWithRouteItems:(id)sender
{
    NSManagedObject *route = self.selectedRoute;
    if (route) {
        NSError *error;
        for (NSManagedObject *item in [self.appDelegate.locationWindowController.itemsArrayController selectedObjects]) {
            NSManagedObject *position = [self.appDelegate.dataController.managedObjectContext createManagedObjectOfType:@"ATLRoutePosition"];
            [position setValue:route forKey:@"route"];
            [position setValue:item forKey:@"location"];
            if (![item validateForUpdate:&error]) NSLog(@"Error while validating subroute %@ - %@", error, [error localizedDescription]);
        }
        if (![route validateForUpdate:&error]) NSLog(@"Error while validating subroute %@ - %@", error, [error localizedDescription]);
    }
}

- (void)connectRoutesWithBuilder:(id)sender
{
    NSManagedObject *builder = (NSManagedObject*)self.appDelegate.organisationWindowController.selectedOrganization;
    if (builder) {
        NSError *error;
        for (NSManagedObject *route in self.selectedRoutes) {
            [route setValue:builder forKey:@"builder"];
            if (![route validateForUpdate:&error]) NSLog(@"Error while validating subroute %@ - %@", error, [error localizedDescription]);
        }
        if (![builder validateForUpdate:&error]) NSLog(@"Error while validating subroute %@ - %@", error, [error localizedDescription]);
    }
}

- (void)connectSubroutesWithManager:(id)sender
{
    NSManagedObject *manager = (NSManagedObject*)self.appDelegate.organisationWindowController.selectedOrganization;
    if (manager) {
        NSError *error;
        for (NSManagedObject *subroute in self.selectedSubroutes) {
            [subroute setValue:manager forKey:@"infraManager"];
            if (![subroute validateForUpdate:&error]) NSLog(@"Error while validating subroute %@ - %@", error, [error localizedDescription]);
        }
        if (![manager validateForUpdate:&error]) NSLog(@"Error while validating subroute %@ - %@", error, [error localizedDescription]);
    }
}

- (void)connectSubroutesWithOperators:(id)sender
{
    NSSet *operators = [NSSet setWithArray: self.appDelegate.organisationWindowController.selectedOrganizations];
    for (NSManagedObject *subroute in self.selectedSubroutes) {
        [subroute setValue:operators forKey:@"operators"];
        NSError *error;
        if (![subroute validateForUpdate:&error]) NSLog(@"Error while validating subroute %@ - %@", error, [error localizedDescription]);
    }
}

#pragma mark - UI connections in Routes box

- (NSArray *)selectedRoutes
{
    return [self.routesArrayController selectedObjects];
}

- (ATLRoute *)selectedRoute
{
    NSArray *theRoutes = self.selectedRoutes;
    if ([theRoutes count] == 1) {
        return theRoutes[0];
    }
    return nil;
}

- (IBAction)addRoute:(id)sender
{
    self.addRouteCountryBox.stringValue = @"nl";
    self.addRouteCodeField.stringValue = @"";
    self.addRouteFromField.stringValue = @"";
    self.addRouteToField.stringValue = @"";
    
    [self.addRoutePanel orderFront:self];
}

- (IBAction)removeBuilder:(id)sender {
    [self.selectedRoute setValue:nil forKey:@"builder"];
}

#pragma mark - UI connections for AddRoute panel

- (IBAction)confirmAddRoute:(id)sender
{
    if ([self.addRouteCountryBox.stringValue length] != 2) return;
    if ([self.addRouteCodeField.stringValue length] < 2) return;
    if ([self.addRouteFromField.stringValue length] < 2) return;
    if ([self.addRouteToField.stringValue length] < 2) return;
    
    ATLRoute *route = (ATLRoute*)[self.managedObjectContext createManagedObjectOfType:@"ATLRoute"];
    NSString *country = self.addRouteCountryBox.stringValue;
    NSString *code = self.addRouteCodeField.stringValue;
    route.id_ = [NSString stringWithFormat:@"%@.%@", country, code];
    route.origin = self.addRouteFromField.stringValue;
    route.destination = self.addRouteToField.stringValue;
    route.name = [NSString stringWithFormat:@"%@ - %@", route.origin, route.destination];
    
    [self.addRoutePanel orderOut:self];
}

- (IBAction)cancelAddRoute:(id)sender
{
    [self.addRoutePanel orderOut:self];
}

#pragma mark - UI connections in Route table

- (NSArray *)selectedPositions
{
    NSMutableArray *positions = [NSMutableArray arrayWithCapacity:5];
    [self.routeItemsTable.selectedRowIndexes enumerateIndexesUsingBlock:^(NSUInteger index, BOOL *stop){
        [positions addObject:self.arrangedRoutePositions[index]];
    }];
    return positions;
}

- (NSArray *)arrangedRoutePositions
{
    if (!_arrangedRoutePositions) {
        NSSortDescriptor *sortOrder = [NSSortDescriptor sortDescriptorWithKey:@"km" ascending:YES];
        self.arrangedRoutePositions = [self.selectedRoute.positions sortedArrayUsingDescriptors:@[sortOrder]];
    }
    return _arrangedRoutePositions;
}


- (IBAction)selectRoute:(id)sender {
    NSInteger row = [self.routeItemsTable rowForView:sender];
    ATLRoute *route = nil;
    if (row != -1) {
        ATLRoutePosition *currentPosition = self.arrangedRoutePositions[row];
        for (ATLRoutePosition *otherPosition in currentPosition.location.routePositions) {
            if (otherPosition != currentPosition) {
                route = otherPosition.route;
            }
        }
    }
    if (route) {
        [self.routesArrayController setSelectedObjects:@[route]];
    }
}

- (IBAction)addRouteItems:(id)sender {
    self.addItemPanel.title = [NSString stringWithFormat:@"New item on %@", self.selectedRoute.name];
    [self updateItemPosition:self];
    [self.addItemPanel orderFront:self];
}

- (void)removeSelectedRouteItems:(id)sender
{
    NSIndexSet *selection = self.routeItemsTable.selectedRowIndexes;
    [selection enumerateIndexesUsingBlock:^(NSUInteger index, BOOL *stop){
        ATLRoutePosition *routePosition = self.arrangedRoutePositions[index];
        [self.selectedRoute removePositionsObject:routePosition];
    }];
    self.arrangedRoutePositions = nil;
    [self.routeItemsTable reloadData];
}

- (void)addJunctions:(id)sender
{
    [self.appDelegate.dataController addJunctionsToRoute:self.selectedRoute];
    self.arrangedRoutePositions = nil;
    [self.routeItemsTable reloadData];
}

- (IBAction)updateItemPositioning:(id)sender {
    [self.selectedRoute updateItemPositioning];
    [self.routeItemsTable reloadData];
}

#pragma mark UI Connections for AddItem panel

- (IBAction)updateItemPosition:(id)sender
{
    self.itemPositionField.stringValue = [NSString stringWithFormat:@"%.3f km", [self sliderKmValue]];
}

- (double)sliderKmValue
{
    double slider = self.itemPositionSlider.doubleValue / 100;
    return self.selectedRoute.start_km + slider * (self.selectedRoute.end_km - self.selectedRoute.start_km);
}

- (IBAction)confirmAddItem:(id)sender {
    NSString *type = nil;
    switch ([self.itemTypeChooser.selectedCell tag]) {
        case 1:
            type = @"ATLStation";
            break;
        case 2:
            type = @"ATLJunction";
            break;
        default:
            NSLog(@"Unsupported tag: %ld", (long)[self.itemTypeChooser.selectedCell tag]);
            return;
    }
    ATLLocation *item = (ATLLocation*)[self.managedObjectContext createManagedObjectOfType:type];
    item.code = self.itemCodeField.stringValue;
    if ([item isKindOfClass:[ATLStation class]]) {
        [(ATLStation*)item setName: self.itemNameField.stringValue];
    }
    double km = [self sliderKmValue];
    
    #pragma todo: inserting item in a route:
    
//    ATLGeoReference geoRef = [self.selectedRoute geoReferenceForPosition:km];
//    item.coordinate = geoRef.coordinate;
//    [self.selectedRoute insertItem:item atPosition:km];
    self.arrangedRoutePositions = nil;
    [self.routeItemsTable reloadData];
    [self.addItemPanel orderOut:self];
    NSLog(@"new %@ with id %@", type, item.id_);
}

- (IBAction)cancelAddItem:(id)sender {
    [self.addItemPanel orderOut:self];
}

#pragma mark NSTableView dataSource and delegate methods

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView
{
    NSInteger number = [self.arrangedRoutePositions count];
    return number;
}

- (NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
    ABOTableCellView *cellView = nil;
    ATLRoutePosition *currentPosition = self.arrangedRoutePositions[row];
    NSString *suffix = @"";
    if (row == [self.arrangedRoutePositions count] - 1) suffix = @"_bottom";
    if (row == 0) suffix = @"_top";
    
    if ([currentPosition.location isKindOfClass:[ATLJunction class]]) {
        ATLJunction *junction = (ATLJunction*)currentPosition.location;
        
        // Detecting trouble with Core Data version (2 instead of 4)....
        BOOL sameDirection = YES;
        if ([junction respondsToSelector:@selector(sameDirection)]) {
            sameDirection = junction.sameDirection;
        } else {
            NSLog(@"trouble with junction %@", junction.id_);
        }
        
        cellView = [tableView makeViewWithIdentifier:@"JunctionCell" owner:self];
        for (ATLRoutePosition *otherPosition in currentPosition.location.routePositions) {
            if (otherPosition != currentPosition) {
                if ([suffix isEqualToString:@"_top"]) {
                    cellView.textField.stringValue = sameDirection ? otherPosition.route.origin : otherPosition.route.destination;
                } else if ([suffix isEqualToString:@"_bottom"]) {
                    cellView.textField.stringValue = sameDirection ? otherPosition.route.destination : otherPosition.route.origin;
                } else {
                    if (fabs(otherPosition.km - otherPosition.route.start_km) < 0.5) {
                        cellView.textField.stringValue = otherPosition.route.destination;
                        suffix = sameDirection ? @"_out" : @"_in";
                    } else {
                        cellView.textField.stringValue = otherPosition.route.origin;
                        suffix = sameDirection ? @"_in" : @"_out";
                    }
                }
            }
        }
        
    } else if ([currentPosition.location isKindOfClass:[ATLStation class]]) {
        cellView = [tableView makeViewWithIdentifier:@"MainCell" owner:self];
        cellView.textField.stringValue = [(ATLStation*)currentPosition.location name];
    }
    cellView.kmTextField.stringValue = [NSString stringWithFormat:@"%.3f", currentPosition.km];
    cellView.imageView.image = [NSImage imageNamed:[NSString stringWithFormat:@"%@%@", currentPosition.location.symbolName, suffix]];
    
    return cellView;
}

- (id <NSPasteboardWriting>)tableView:(NSTableView *)tableView pasteboardWriterForRow:(NSInteger)row {
    ATLRoutePosition *currentPosition = self.arrangedRoutePositions[row];
    return currentPosition.location;
}

#pragma mark - UI connections in Subroutes box

- (NSArray *)selectedSubroutes
{
    return [self.subroutesArrayController selectedObjects];
}

- (ATLSubRoute *)selectedSubroute
{
    NSArray *theSubroutes = self.selectedSubroutes;
    if ([theSubroutes count] == 1) {
        return theSubroutes[0];
    }
    return nil;
}

- (IBAction)addSubroute:(id)sender
{
    ATLRoute *route = self.selectedRoute;
    ATLSubRoute *subroute = self.selectedSubroute;
    if (route) {
        ATLSubRoute *newSubroute = (ATLSubRoute*)[self.managedObjectContext createManagedObjectOfType:@"ATLSubRoute"];
        if (subroute) {
            [newSubroute copyPropertiesFromSubroute:subroute];
            newSubroute.name = [NSString stringWithFormat:@"%@ copy", subroute.name];
            newSubroute.start = subroute.start;
            newSubroute.endKm = subroute.end;
        } else {
            newSubroute.route = route;
            newSubroute.name = @"subroute";
            newSubroute.endKm = route.lastNode.km_b;
        }
        NSError *error;
        if (![newSubroute validateForUpdate:&error]) NSLog(@"Error while validating subroute %@ - %@", error, [error localizedDescription]);
    }
}

- (IBAction)splitSubroute:(id)sender
{
    ATLRoute *route = self.selectedRoute;
    ATLSubRoute *subroute = self.selectedSubroute;
    if (route && subroute && [self.selectedPositions count] > 0) {
        BOOL validPositions = YES;
        float theKm = 0;
        for (ATLRoutePosition *position in self.selectedPositions) {
            if (position.km < subroute.start) validPositions = NO;
            if (position.km > subroute.end) validPositions = NO;
            if (position.km < theKm) validPositions = NO;
            theKm = position.km;
        }
        theKm = subroute.end;
        if (validPositions) {
            NSArray *nameComponents = [subroute.name componentsSeparatedByString:@" - "];
            if ([nameComponents count] > 0) subroute.name = nameComponents[0];
            NSString *destination = @"end";
            if ([nameComponents count] > 1) destination = nameComponents[1];
            
            for (ATLRoutePosition *position in self.selectedPositions) {
                subroute.endKm = position.km;
                subroute.name = [NSString stringWithFormat:@"%@ - %@", subroute.name, position.location.code];
                ATLSubRoute *newSubroute = (ATLSubRoute*)[self.managedObjectContext createManagedObjectOfType:@"ATLSubRoute"];
                [newSubroute copyPropertiesFromSubroute:subroute];
                newSubroute.name = position.location.code;
                newSubroute.start = position.km;
                newSubroute.endKm = theKm;
                NSError *error;
                if (![subroute validateForUpdate:&error]) NSLog(@"Error while validating subroute %@ - %@", error, [error localizedDescription]);
                if (![newSubroute validateForUpdate:&error]) NSLog(@"Error while validating new subroute %@ - %@", error, [error localizedDescription]);
                subroute = newSubroute;
            }
            subroute.name = [NSString stringWithFormat:@"%@ - %@", subroute.name, destination];
        }
    }
}

- (IBAction)removeInfraManager:(id)sender {
    [self.selectedSubroute setValue:nil forKey:@"infraManager"];
}


#pragma mark - Export Routes XML

- (void)exportXMLFile:(id)sender
{
    NSSavePanel *panel = [NSSavePanel savePanel];
    [panel setAllowedFileTypes:[NSArray arrayWithObject:@"xml"]];
    [panel beginWithCompletionHandler:^(NSInteger result){
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
    [output appendString:@"<routes version=\"1.0\">\n"];
    for (ATLRoute *route in self.routesArrayController.arrangedObjects) {
        [output appendString:route.xmlString];
    }
    [output appendString:@"</routes>\n"];
    return output;
}

@end
