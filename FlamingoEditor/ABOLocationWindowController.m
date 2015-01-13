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
//  ABOLocationWindowController.m
//  FlamingoEditor
//
//  Created by Berend Schotanus on 01-03-12.
//

#import "ABOLocationWindowController.h"
#import "ABOAppDelegate.h"
#import "ATLDataController.h"
#import "ABORoutesWindowController.h"
#import "ABOOrganizationWindowController.h"
#import "ATLDataController.h"
#import "FFEAccount.h"

#import "ATLJunction.h"
#import "ATLStation.h"

#import "NSManagedObjectContext+FFEUtilities.h"

@implementation ABOLocationWindowController

#pragma mark - Connecting to the environment

- (ABOAppDelegate *)appDelegate
{
    return (ABOAppDelegate*)[[NSApplication sharedApplication] delegate];
}

- (NSManagedObjectContext *)managedObjectContext
{
    return self.dataController.managedObjectContext;
}

- (IBAction)searchRouteForItem:(id)sender {
    [self.appDelegate.dataController searchAndAddRoutesForItem:self.selectedItem];
}

- (NSArray *)selectedItems
{
    return [self.itemsArrayController selectedObjects];
}

- (ATLLocation *)selectedItem
{
    NSArray *theItems = self.selectedItems;
    if ([theItems count] == 1) {
        return theItems[0];
    }
    return nil;
}

- (void)connectRouteWithRouteItems:(id)sender
{
    [self.appDelegate.routesWindowController connectRouteWithRouteItems:sender];
}

- (void)connectStationWithOperators:(id)sender
{
    NSSet *operators = [NSSet setWithArray: self.appDelegate.organisationWindowController.selectedOrganizations];
    for (NSManagedObject *subroute in self.selectedItems) {
        [subroute setValue:operators forKey:@"operators"];
    }
}

- (void)parseSelection:(id)sender
{
    /*
    for (ATLLocation *item in self.selectedItems) {
        NSURL *wikiURL = item.wikiURL;
        if (wikiURL && !item.parseObject && [item.className isEqualToString:@"ATLStation"]) {
            NSLog(@"parse station: %@", item.name);
            item.parseObject = [PARResult stationFromURL:wikiURL];
            if (item.parseObject) {
                item.code = [[(PARResult*)item.parseObject properties] objectForKey:@"code"];
                item.opened = [[(PARResult*)item.parseObject properties] objectForKey:@"opened"];
                item.closed = [[(PARResult*)item.parseObject properties] objectForKey:@"closed"];
            }
            
        }
    }*/
}

- (IBAction)toggleStatus:(id)sender {
    if ([self.selectedItem isKindOfClass:[ATLJunction class]]) {
        [(ATLJunction*)self.selectedItem toggleDirection];
    }
}

- (IBAction)addItemCodes:(id)sender
{
    int counter = 1;
    for (ATLLocation *item in self.itemsArrayController.arrangedObjects) {
        int value = item.code.intValue;
        if (value >= counter) {
            counter = value + 1;
        }
    }
    for (ATLLocation *item in self.itemsArrayController.arrangedObjects) {
        if (!item.code || [item.code length] == 0) {
            item.code = [NSString stringWithFormat:@"j_%03d", counter++];
        }
    }
}

#pragma mark - Export RouteItems XML

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
    [output appendString:@"<locations version=\"1.0\">\n"];
    for (ATLJunction *junction in [self.managedObjectContext allObjectsOfClass:[ATLJunction class]]) {
        [output appendString:junction.xmlString];
    }
    for (ATLStation *station in [self.managedObjectContext allObjectsOfClass:[ATLStation class]]) {
        [output appendString:station.xmlString];
    }
    [output appendString:@"</locations>\n"];
    return output;
}

#pragma mark - Tools menu

- (void)synchronize:(id)sender
{
    [self.dataController saveContext];
    [self.dataController synchronizeClass:[ATLStation class]];
}

- (void)pushStationsToServer:(id)sender
{
    NSTimeInterval waitingTime = 0.0;
    for (ATLStation *station in [self.managedObjectContext allObjectsOfClass:[ATLStation class]]) {
        waitingTime += 3.0;
        [self performSelector:@selector(pushStation:) withObject:station afterDelay:waitingTime];
    }
}

- (void)pushStation:(ATLStation*)station
{
    NSLog(@"Push station %@", station);
    [self.dataController updateRemoteObjectWith:station];
}

- (void)resetLastModified:(id)sender
{
    for (ATLStation *station in [self.managedObjectContext allObjectsOfClass:[ATLStation class]]) {
        station.lastServerModification = nil;
    }
    [self.dataController saveContext];
}

@end
