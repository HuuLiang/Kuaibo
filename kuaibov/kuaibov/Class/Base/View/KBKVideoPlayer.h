//
//  KBKVideoPlayer.h
//  KBKuaibo
//
//  KBeated by Sean Yue on 16/1/27.
//  Copyright © 2016年 iqu8. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface KBKVideoPlayer : UIView

@property (nonatomic,readonly) NSURL *videoURL;
@property (nonatomic,copy) KBKAction endPlayAction;

- (instancetype)initWithVideoURL:(NSURL *)videoURL;
- (void)startToPlay;
- (void)pause;

@end
