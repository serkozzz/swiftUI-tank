//
//  test.m
//  TankEngineXCFramework
//
//  Created by Sergey Kozlov on 26.11.2025.
//

#import <Foundation/Foundation.h>
#import "test.h"

int testBridgeFunction(int a, int b) {
    return a + b;
}

const NSString * _Nonnull testBridgeString(void) {
    return @"Hello from Objective-C";
}
