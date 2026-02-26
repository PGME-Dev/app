//
//  MobileRTCInMeetingDeviceInfo.h
//  MobileRTC
//
//  Created by Zoom on 2022/11/17.
//  Copyright © Zoom Communications, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
/*!
 @brief information of meeting device info.
 Here are more detailed structural descriptions..
*/
@interface MobileRTCInMeetingDeviceInfo : NSObject
/*!
 @brief index
 */
@property(nonatomic, assign, readonly) NSInteger index DEPRECATED_MSG_ATTRIBUTE("Please use meetingId instead");
/*!
 @brief device name
 */
@property(nonatomic, copy, readonly) NSString * _Nullable deviceName;
/*!
 @brief meeting topic
 */
@property(nonatomic, copy, readonly) NSString * _Nullable meetingTopic;
/*!
 @brief meeting number
 */
@property(nonatomic, assign, readonly) NSUInteger meetingNumber;
/*!
 @brief meeting id
 */
@property(nonatomic, copy, readonly) NSString * _Nullable meetingId;
/*!
 @brief this meeting support joining in companion mode
 */
@property(nonatomic, assign) BOOL isSupportCompanionMode;

@end
