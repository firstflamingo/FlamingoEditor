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
//  ABOTableCellView.m
//  FlamingoEditor
//
//  Created by Berend Schotanus on 09-08-12.
//

#import "ABOTableCellView.h"

@implementation ABOTableCellView

- (void)updateTime:(id)sender
{
    NSLog(@"timeField: %@", self.timeField.stringValue);
    int16_t arrival = 0, departure = 0;
    NSArray *components = [self.timeField.stringValue componentsSeparatedByString:@"-"];
    if ([components count] > 0) {
        arrival = [components[0] intValue];
    }
    if ([components count] > 1) {
        departure = [components[1] intValue];
    } else {
        departure = arrival;
    }
    if (self.upDirection) {
        [self.delegate updateUpArrival:arrival departure:departure forPointIndex:self.pointIndex];
    } else {
        [self.delegate updateDownArrival:arrival departure:departure forPointIndex:self.pointIndex];
    }
    [self updateArrival:arrival departure:departure];
}

- (void)updateArrival:(int16_t)arrival departure:(int16_t)departure
{
    if (departure == arrival) {
        self.timeField.stringValue = [NSString stringWithFormat:@"%02d", departure];
    } else {
        self.timeField.stringValue = [NSString stringWithFormat:@"%02d-%02d", arrival, departure];
    }
}

@end
