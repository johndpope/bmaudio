//
//  BMViewController.m
//  BMAudioIOS
//
//  Created by Peter Marks on 10/19/13.
//  Copyright (c) 2013 BeatMatch LLC. All rights reserved.
//

#import "BMViewController.h"
#import "BMAudio.h"
#import "BMAudioTrack.h"
#import "BMSamplerUnit.h"
#import "BMMusicPlayer.h"

@interface BMViewController ()
{
    BMSamplerUnit *tromboneSampler;
    BMMusicPlayer *musicPlayer;
    NSTimer *updateTimer;
}
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UILabel *beatLabel;
@property (weak, nonatomic) IBOutlet UILabel *tempoLabel;
@end

@implementation BMViewController

#pragma mark - view lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    tromboneSampler = [BMSamplerUnit unit];
    BMAudioTrack *tromboneTrack = [BMAudioTrack trackWithUnits:@[tromboneSampler]];
    [[BMAudio sharedInstance] loadAudioTrack:tromboneTrack];
    
    [[BMAudio sharedInstance] setUpIOSAudioSession];
    [[BMAudio sharedInstance] setUpAudioGraph];
    
    [tromboneSampler loadPreset:@"Trombone"];
    
    musicPlayer = [[BMMusicPlayer alloc] init];
    [musicPlayer loadSequenceFromMidiFile:@"CarntSleepBassline"];
    musicPlayer.currentTempo = 70.0;
    [musicPlayer noteEventsOnOrAfterBeat:0 beforeBeat:32];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    updateTimer = [NSTimer scheduledTimerWithTimeInterval:0.03 target:self selector:@selector(updateUI:) userInfo:nil repeats:YES];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [updateTimer invalidate];
    updateTimer = nil;
}

#pragma mark - utility

- (void)updateUI:(NSTimer *)argTimer
{
    MusicTimeStamp timeStamp = [musicPlayer currentTime];
    self.timeLabel.text = [NSString stringWithFormat:@"%f", timeStamp];
    self.beatLabel.text = [NSString stringWithFormat:@"%u.%u.%u", (int)[musicPlayer currentBeat].bar, [musicPlayer currentBeat].beat, [musicPlayer currentBeat].subbeat];
    self.tempoLabel.text = [NSString stringWithFormat:@"%f", musicPlayer.currentTempo];
}

#pragma mark - actions

- (IBAction)noteOnAction:(id)sender
{
    [tromboneSampler noteOnWithNote:49 velocity:83];
}

- (IBAction)noteOffAction:(id)sender
{
    [tromboneSampler noteOffWithNote:49];
}

- (IBAction)playAction:(id)sender
{
    [musicPlayer play];
}

- (IBAction)pauseAction:(id)sender
{
    [musicPlayer pause];
}

- (IBAction)resetAction:(id)sender
{
    [musicPlayer reset];
}

@end
