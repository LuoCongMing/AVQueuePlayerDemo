//
//  SongModel.h
//  AVPlayer学习笔记
//
//  Created by JMiMac01 on 2017/8/23.
//  Copyright © 2017年 周建波. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

@interface SongModel : NSObject
///歌曲名称
@property(nonatomic,copy)NSString*songName;
///歌手
@property(nonatomic,copy)NSString*singer;
///专辑封面
@property(nonatomic,strong)UIImage*picture;
///歌曲时间
@property(nonatomic,assign)double duration;
///包含歌曲信息的item
@property(nonatomic,strong)AVPlayerItem*item;
@end
