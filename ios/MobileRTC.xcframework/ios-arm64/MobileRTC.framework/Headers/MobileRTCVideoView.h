//
//  MobileRTCVideoView.h
//  MobileRTC
//
//  Created by Zoom on 2017/11/15.
//  Copyright © Zoom Communications, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

/*!
 @brief MobileRTCVideoAspect An Enum which provide video aspect.
 */
typedef enum {
    ///Original
    MobileRTCVideoAspect_Original       = 0,
    ///Full Filled
    MobileRTCVideoAspect_Full_Filled    = 1,
    ///Letter Box
    MobileRTCVideoAspect_LetterBox  = 2,
    ///Pan And Scan
    MobileRTCVideoAspect_PanAndScan = 3,
}MobileRTCVideoAspect;

/*!
 MobileRTCVideoView
 @brief MobileRTCVideoView is designed for Render Attendee Video.
 */
@interface MobileRTCVideoView : UIView

/*!
 @brief Designated for get rendering user's ID.
 @return userid that rendering.
 */
- (NSInteger)getUserID;

/*!
 @brief Designated for Render Attendee Video.
 @param userID user's video will be shown up.
 */
- (BOOL)showAttendeeVideoWithUserID:(NSUInteger)userID;

/*!
 @brief Designated for Stop Render.
 */
- (void)stopAttendeeVideo;

/*!
 @brief Designated for changing video aspect according to customer's requirement.
 */
- (void)setVideoAspect:(MobileRTCVideoAspect)aspect;

@end

/*!
 MobileRTCPreviewVideoView
 @brief MobileRTCPreviewVideoView is designed for Preview Self Video.
 @warning App need reponse to onSinkMeetingPreviewStopped, SDK handle start & stop Preview.
 */
@interface MobileRTCPreviewVideoView : MobileRTCVideoView

@end

/*!
 MobileRTCActiveVideoView
 @brief MobileRTCActiveVideoView is designed for Render Active Video.
 */
@interface MobileRTCActiveVideoView : MobileRTCVideoView

@end

/*!
 MobileRTCActiveShareView
 @brief MobileRTCActiveShareView is designed for Render Share Content.
 */
@interface MobileRTCActiveShareView : MobileRTCVideoView

/*!
 @brief Designated for Render Share Content.
 @param shareSourceID user's shared content will be shown up.
 */
- (BOOL)showActiveShareWithShareSourceID:(NSUInteger)shareSourceID;

/*!
 @brief Designated for Stop Render Share Content.
 */
- (void)stopActiveShare;

/*!
 @brief Designated for Render Share Content Scale Change.
 @param shareSourceID user's shared content scale change.
 */
- (void)changeShareScaleWithShareSourceID:(NSUInteger)shareSourceID;

/*!
 @brief Get MobileRTC Active Share View use share souce ID
 */
- (NSUInteger)getShareSourceID;

@end
