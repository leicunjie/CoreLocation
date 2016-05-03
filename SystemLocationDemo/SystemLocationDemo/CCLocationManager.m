//
//  CCLocationManager.m
//  CCLocationDemo
//
//  Created by leicunjie on 16/4/26.
//  Copyright © 2016年 leicunjie. All rights reserved.
//

#import "CCLocationManager.h"
#import <CoreLocation/CoreLocation.h>
#import <UIKit/UIKit.h>

typedef  NS_ENUM(NSInteger ,CCLocationNotAllowedType) {
    CCLocationNotAllowedSystemType,//系统设置
    CCLocationNotAllowedApplicationType,//应用设置
};

@interface CCLocationManager()<CLLocationManagerDelegate,UIAlertViewDelegate>

/** 位置管理*/
@property(nonatomic ,strong) CLLocationManager *locationM;
@property(nonatomic,copy) LocationSuccessBlock successBlock;
@property(nonatomic,copy) LocationFailBlock failBlock;
@property(nonatomic)CCLocationNotAllowedType locationNotAllowedType;

@end

@implementation CCLocationManager

- (void)startUpdateLocationWithSuccessBlock:(LocationSuccessBlock)successBlock
                               addFailBlock:(LocationFailBlock)failBlock {
    if(successBlock)
        self.successBlock = successBlock;
    if(failBlock)
        self.failBlock = failBlock;
   [self setLocationM];
}

- (void)setLocationM
{
    if(!_locationM){
        _locationM = [[CLLocationManager alloc]init];
        _locationM.delegate = self;
        _locationM.desiredAccuracy = kCLLocationAccuracyBest;
        _locationM.distanceFilter = 10;
        float systemVersion = [[[UIDevice currentDevice]systemVersion] floatValue];
        if(systemVersion >= 8.0)
            [_locationM requestWhenInUseAuthorization];
    }
    [_locationM startUpdatingLocation];
}

#pragma mark - CLLocationManagerDelegate
- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    if(!locations.count)
        return;
    
    CLLocation * loc = locations[0];
    double lat = loc.coordinate.latitude;
    double lon = loc.coordinate.longitude;
    
    CLGeocoder * geo = [[CLGeocoder alloc] init];
    [geo reverseGeocodeLocation:[[CLLocation alloc] initWithLatitude:lat longitude:lon] completionHandler:^(NSArray<CLPlacemark *> * __nullable placemarks, NSError * __nullable error) {
         if(error)
             return ;
         
         // 包含区，街道等信息的地标对象
         CLPlacemark *placemark = [placemarks firstObject];
         NSDictionary *addressDictionary = placemark.addressDictionary;
        NSLog(@"%@",addressDictionary);
         if(self.successBlock){
             self.successBlock(addressDictionary);
             
             //系统会定位多次，传值成功一次后置空
             self.successBlock = nil;
         }
         
         //停止定位
         [_locationM stopUpdatingLocation];
     }];
}

- (void)locationManager:(CLLocationManager *)manager
       didFailWithError:(NSError *)error {
    switch (error.code) {
        case kCLErrorLocationUnknown:
            NSLog(@"The location manager was unable to obtain a location value right now.");
            break;
        case kCLErrorDenied:{
            if ([CLLocationManager locationServicesEnabled]){
                self.locationNotAllowedType = CCLocationNotAllowedApplicationType;
                UIAlertView * alertView = [[UIAlertView alloc]initWithTitle:@"提示" message:@"定位服务未开启，请在系统设置中开启定位服务" delegate:self cancelButtonTitle:@"暂不" otherButtonTitles:@"去设置", nil];
                [alertView show];
            }
           else //系统关闭定位服务会有两次提示
               self.locationNotAllowedType = CCLocationNotAllowedSystemType;
            NSLog(@"Access to the location service was denied by the user.");
            break;
        }
        case kCLErrorNetwork:
            NSLog(@"The network was unavailable or a network error occurred.");
            break;
        default:
            NSLog(@"未定义错误");
            break;
    }
}

/**
 *  当前的授权状态发生改变时调用
 *
 *  @param manager 位置管理者
 *  @param status  授权状态
 */

/*
- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
    switch (status) {
        case kCLAuthorizationStatusNotDetermined: {
            NSLog(@"用户没有决定");
            break;
        }
            // 系统预留字段, 暂时没有用
        case kCLAuthorizationStatusRestricted: {
            NSLog(@"受限制");
            break;
        }
        case kCLAuthorizationStatusDenied: {
            // 判断是否支持定位, 或者定位服务是否开启
            if ([CLLocationManager locationServicesEnabled]){
                NSLog(@"真正被拒绝");
            }else{
                NSLog(@"定位服务关闭");
            }
            break;
        }
        case kCLAuthorizationStatusAuthorizedAlways: {
            NSLog(@"前后台定位授权");
            break;
        }
        case kCLAuthorizationStatusAuthorizedWhenInUse: {
            NSLog(@"前台定位授权");
            break;
        }
        default:
            break;
    }
}
*/

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if(buttonIndex == 1) {
        NSURL *url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
//       if(self.locationNotAllowedType == CCLocationNotAllowedSystemType)
//           url = [NSURL URLWithString:@"prefs:root=LOCATION_SERVICES"];
        if ([[UIApplication sharedApplication] canOpenURL:url]) {
            [[UIApplication sharedApplication] openURL:url];
        }
    }
}

@end
