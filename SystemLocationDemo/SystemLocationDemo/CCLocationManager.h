//
//  CCLocationManager.h
//  CCLocationDemo
//
//  Created by leicunjie on 16/4/26.
//  Copyright © 2016年 leicunjie. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^ LocationSuccessBlock) (id data);
typedef void (^ LocationFailBlock) (id data);

@interface CCLocationManager : NSObject

- (void)startUpdateLocationWithSuccessBlock:(LocationSuccessBlock)successBlock
                               addFailBlock:(LocationFailBlock)failBlock;

@end
