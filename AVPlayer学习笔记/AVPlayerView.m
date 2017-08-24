//
//  AVPlayerView.m
//  AVPlayer学习笔记
//
//  Created by 周建波 on 16/12/5.
//  Copyright © 2016年 周建波. All rights reserved.
//

#import "AVPlayerView.h"
#import <MediaPlayer/MediaPlayer.h>
#import "SongModel.h"

@implementation AVPlayerView

-(void)creatPlayer{
    AVQueuePlayer
    [self initSongsData];
    SongModel*model = self.songsArray.firstObject;
    self.avplayer = [[AVPlayer alloc]initWithPlayerItem:model.item];
    self.index = 0;
}

-(void)initSongsData{

    SongModel*firstModel = [[SongModel alloc]init];
    firstModel.songName = @"那些花儿";
    firstModel.singer = @"朴树";
    firstModel.picture = [UIImage imageNamed:@"pushu.jpg"];
    firstModel.item = [AVPlayerItem playerItemWithURL:[NSURL fileURLWithPath: [[NSBundle mainBundle] pathForResource:@"那些花儿" ofType:@"mp3"]]];
    [firstModel.item  addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:nil];
    [firstModel.item addObserver:self forKeyPath:@"loadedTimeRanges" options:NSKeyValueObservingOptionNew context:nil];
    
    SongModel*secondModel = [[SongModel alloc]init];
    secondModel.songName = @"演员";
    secondModel.singer = @"薛之谦";
    secondModel.picture = [UIImage imageNamed:@"xue.png"];
    secondModel.item = [AVPlayerItem playerItemWithURL:[NSURL URLWithString:@"http://sc1.111ttt.com/2015/1/06/06/99060941326.mp3"]];
    [secondModel.item  addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:nil];
    [secondModel.item addObserver:self forKeyPath:@"loadedTimeRanges" options:NSKeyValueObservingOptionNew context:nil];
    
    self.songsArray = @[secondModel,firstModel];
}

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context{
    
    AVPlayerItem*item = (AVPlayerItem*)object;
    
    if ([keyPath isEqualToString:@"status"]) {
        
        switch (item.status) {
            case AVPlayerItemStatusReadyToPlay:
            {
                NSLog(@"开始播放");
                [self.avplayer play];
                _isPlaying = YES;
                [self setLockScreenNowPlayingInfo];
            }
                break;
                
            default:
                break;
        }
        
    }
    if ([keyPath isEqualToString:@"loadedTimeRanges"]) {
        
        NSLog(@"缓冲进来了");
    }
}


- (void)setLockScreenNowPlayingInfo
{
    SongModel*model = self.songsArray[_index];
    //更新锁屏时的歌曲信息
    MPMediaItemArtwork *artWork = [[MPMediaItemArtwork alloc] initWithImage:model.picture];
    
    NSDictionary *dic = @{MPMediaItemPropertyTitle:model.songName,
                          MPMediaItemPropertyArtist:model.singer,
//                          MPMediaItemPropertyLyrics:@"hello lyrics break ",
//                          MPMediaItemPropertyReleaseDate:@"2017-08-23",//唱片发布日期
                          MPMediaItemPropertyPlaybackDuration:@200.0,//设置锁屏界面歌曲时间
                          MPMediaItemPropertyArtwork:artWork//锁屏界面图片
                          };
    [[MPNowPlayingInfoCenter defaultCenter] setNowPlayingInfo:dic];
}

-(void)next{
    
    if (_index==1) {
        _index=0;
    }else{
        _index++;
    }
    
    SongModel*model = _songsArray[_index];
    
    [self.avplayer replaceCurrentItemWithPlayerItem:model.item];
    
}

-(void)last{
    
    if (_index==0) {
        _index=1;
    }else{
        _index--;
    }
    
    SongModel*model = _songsArray[_index];
    
    [self.avplayer replaceCurrentItemWithPlayerItem:model.item];
    
}
@end
