//
//  ViewController.m
//  AVPlayer学习笔记
//
//  Created by 周建波 on 16/11/17.
//  Copyright © 2016年 周建波. All rights reserved.
//

#import "ViewController.h"
#import <AVFoundation/AVFoundation.h>
#import <MediaPlayer/MediaPlayer.h>
#import "SongModel.h"


@interface ViewController ()

@property(nonatomic,strong)AVQueuePlayer*player;

@property(nonatomic,assign)BOOL isPlaying;

@property(nonatomic,strong)NSArray*songInfoArray;
///当前播放index
@property(nonatomic,assign)NSInteger index;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    //这里SourceType为MP3时可以后台播放，source为MP4类型时不能退到后台播放、却可以锁屏播放
   
    [self becomeFirstResponder];
    [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
    
    [self initPlayer];
}

-(void)initPlayer{
    
    AVPlayerItem*firstItem = [AVPlayerItem playerItemWithURL:[NSURL fileURLWithPath: [[NSBundle mainBundle] pathForResource:@"那些花儿" ofType:@"mp3"]]];
    AVPlayerItem*secondItem = [AVPlayerItem playerItemWithURL:[NSURL URLWithString:@"http://sc1.111ttt.com/2015/1/06/06/99060941326.mp3"]];
    
    SongModel*firstModel = [[SongModel alloc]init];
    firstModel.songName = @"那些花儿";
    firstModel.singer = @"朴树";
    firstModel.picture = [UIImage imageNamed:@"pushu.jpg"];
    firstModel.duration = 294;
    firstModel.item = firstItem;
    
    SongModel*secondModel = [[SongModel alloc]init];
    secondModel.songName = @"演员";
    secondModel.singer = @"薛之谦";
    secondModel.picture = [UIImage imageNamed:@"xue.png"];
    secondModel.duration = 262;
    secondModel.item = secondItem;
    _songInfoArray = @[firstModel,secondModel];
    
    self.player = [[AVQueuePlayer alloc]initWithItems:@[firstItem]];
    
    _index = 0;
// item和player都有status 属性 通常我们观察item的status 是因为可以检测资源是否可以播放，当然这里直接调用play方法也是可以直接播放的
    [firstItem addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playeyEnd:) name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
    

    
}

///播放结束
-(void)playeyEnd:(NSNotification*)notify{
    NSLog(@"end");
    [self nextSong];
    
}

///AVPlayerItem observer
-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context{
    AVPlayerItem*item = (AVPlayerItem*)object;
    if ([keyPath isEqualToString:@"status"]) {
        if (item.status==AVPlayerItemStatusReadyToPlay) {
            NSLog(@"play");
            
            [self setLockScreenNowPlayingInfo];
            
            [item removeObserver:self forKeyPath:@"status"];
            
            [self.player play];

        }
        
        if (item.status==AVPlayerItemStatusFailed) {
            
            NSLog(@"filad");
            
            [self setLockScreenNowPlayingInfo];
            
            [item removeObserver:self forKeyPath:@"status"];
            
            [self nextSong];
        }
    }
}
#pragma mark - 远程控制接收方法的设置
- (void)remoteControlReceivedWithEvent:(UIEvent *)event {
    if (event.type == UIEventTypeRemoteControl) {  //判断是否为远程控制
        switch (event.subtype) {
            case  UIEventSubtypeRemoteControlPlay:
            {
                if (!_isPlaying) {
                    [self.player play];
                }
                _isPlaying=!_isPlaying;
            }
                break;
            case UIEventSubtypeRemoteControlPause:
            {
                if (_isPlaying) {
                    [self.player pause];
                }
                _isPlaying = !_isPlaying;
            }
                break;
            case UIEventSubtypeRemoteControlNextTrack:
            {
                [self nextSong];
            }
                break;
            case UIEventSubtypeRemoteControlPreviousTrack:
            {
                [self lastSong];
            }
                break;
            default:
                break;
        }
    }
}

-(void)nextSong{
    
    //下一首
    if (_index==_songInfoArray.count-1) {
        _index =0;
    }else{
        _index++;
    }
    
    SongModel*model = _songInfoArray[_index];
    
     [model.item addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:nil];
    [self.player removeAllItems];
    [self.player insertItem:model.item afterItem:nil];
    [self.player seekToTime:kCMTimeZero];
    
    [self setLockScreenNowPlayingInfo];
    
}

-(void)lastSong{
    //上一首
    if (_index==0) {
        _index =_songInfoArray.count-1;
        
    }else{
        _index--;
        
    }
#warning 在同一时间内一个item只能占用一个位置、所以这里是先删除，再添加
    SongModel*model = _songInfoArray[_index];
    [model.item addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:nil];
    [self.player removeAllItems];
    [self.player insertItem:model.item afterItem:nil];
    [self.player seekToTime:kCMTimeZero];
    [self setLockScreenNowPlayingInfo];
}

///设置锁屏信息
- (void)setLockScreenNowPlayingInfo
{
    SongModel*model = self.songInfoArray[_index];
    //更新锁屏时的歌曲信息
    MPMediaItemArtwork *artWork = [[MPMediaItemArtwork alloc] initWithImage:model.picture];
    
    NSDictionary *dic = @{MPMediaItemPropertyTitle:model.songName,
                          MPMediaItemPropertyArtist:model.singer,
                          //                          MPMediaItemPropertyLyrics:@"hello lyrics break ",
                          //                          MPMediaItemPropertyReleaseDate:@"2017-08-23",//唱片发布日期
                          MPMediaItemPropertyPlaybackDuration:@(model.duration),//设置锁屏界面歌曲时间
                          MPMediaItemPropertyArtwork:artWork//锁屏界面图片
                          };
    [[MPNowPlayingInfoCenter defaultCenter] setNowPlayingInfo:dic];
}


@end
