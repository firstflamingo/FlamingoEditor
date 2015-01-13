//  Copyright (c) 2014-2015 First Flamingo Enterprise B.V.
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
//  ABOSeriesWindowController.m
//  FlamingoEditor
//
//  Created by Berend Schotanus on 27-06-14.
//

#import "ABOSeriesWindowController.h"

#import "ATLDataController.h"
#import "ATLScheduleImporter.h"
#import "ATLSeries.h"
#import "ATLSeriesRef.h"
#import "ATLService.h"
#import "ATLMissionRule.h"
#import "ATLTimePath.h"

#import "NSManagedObjectContext+FFEUtilities.h"

@interface ABOSeriesWindowController ()

@end

@implementation ABOSeriesWindowController

- (IBAction)correctUpOffset:(id)sender {
    ATLMissionRule *missionRule = self.upMissionRulesController.selectedObjects[0];
    ATLTimePath *timePath = missionRule.timePath;
    int correction = [self.upOffsetCorrectionField.stringValue intValue];
    [timePath correctOffsetWith:correction];
    NSLog(@"Correct offset of time path %u with %d", timePath.hash_, correction);
    [self.upRulesTableView reloadData];
    [self.upPathTableView reloadData];
}

- (IBAction)correctDownOffset:(id)sender {
    ATLMissionRule *missionRule = self.downMissionRulesController.selectedObjects[0];
    ATLTimePath *timePath = missionRule.timePath;
    int correction = [self.downOffsetCorrectionField.stringValue intValue];
    [timePath correctOffsetWith:correction];
    NSLog(@"Correct offset of time path %u with %d", timePath.hash_, correction);
    [self.downRulesTableView reloadData];
    [self.downPathTableView reloadData];
}

- (void)importGTFS:(id)sender
{
    NSOpenPanel *panel = [NSOpenPanel openPanel];
	[panel setAllowsMultipleSelection:NO];
    [panel setCanChooseDirectories:YES];
    [panel setCanChooseFiles:NO];
    [panel beginWithCompletionHandler:^(NSInteger result){
        if (result == NSFileHandlingPanelOKButton) {
            ATLScheduleImporter *importer = [ATLScheduleImporter new];
            NSLog(@"import %@...", panel.URL);
            [importer importContentsOfDirectory:panel.URL
                       intoManagedObjectContext:self.dataController.managedObjectContext
                                    withOptions:noImportOptions];
        }
    }];
}

- (IBAction)syncOffsets:(id)sender {
    for (ATLSeries *series in [self.seriesArrayController selectedObjects]) {
        [series syncOffsets];
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
    [output appendString:@"<timetable version=\"1.0\" year=\"2014\">\n"];
    for (ATLSeries *series in self.seriesArrayController.arrangedObjects) {
        [output appendString:series.xmlString];
    }
    [output appendString:@"</timetable>\n"];
    return output;
}

@end
