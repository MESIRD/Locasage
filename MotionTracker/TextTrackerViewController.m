//
//  TextTrackerViewController.m
//  MotionTracker
//
//  Created by mesird on 08/10/2016.
//  Copyright © 2016 mesird. All rights reserved.
//

#import "TextTrackerViewController.h"

#import <CoreLocation/CoreLocation.h>
#import <CoreMotion/CoreMotion.h>
#import <AVFoundation/AVFoundation.h>

@interface TextTrackerViewController () <CLLocationManagerDelegate> {
    
@private
    double _xAngle;
    double _yAngle;
    double _zAngle;
}

@property (nonatomic, strong) CLLocationManager  *locationManager;
@property (nonatomic, strong) CMMotionManager    *motionManager;
@property (nonatomic, strong) AVCaptureSession   *captureSession;

@property (weak, nonatomic) IBOutlet UIView *previewView;
@property (weak, nonatomic) IBOutlet UILabel *verticalLabel;
@property (weak, nonatomic) IBOutlet UILabel *horizontalLabel;
@property (weak, nonatomic) IBOutlet UILabel *coordinateLabel;

@property (nonatomic, strong) AVCaptureDevice *currentDevice;

@end

@implementation TextTrackerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self.view layoutIfNeeded];
    
    // Start Motion Tracker
    [self _initMotion];
    
    // Start Location
    [self _initLocation];
    
    // Open Camera
    [self _initCamera];
    
    // Init Text
    [self _initText];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    self.navigationController.navigationBar.hidden = NO;
}

- (void)_initMotion {
    
    _motionManager = [[CMMotionManager alloc] init];
    _motionManager.accelerometerUpdateInterval = 1;
    [_motionManager startAccelerometerUpdatesToQueue:[NSOperationQueue currentQueue] withHandler:^(CMAccelerometerData * _Nullable accelerometerData, NSError * _Nullable error) {
        
        double accelerX = accelerometerData.acceleration.x;
        double accelerY = accelerometerData.acceleration.y;
        double accelerZ = accelerometerData.acceleration.z;
        
        // Calculate the angle of device orientation and x axis
        double zAngle = atan2(accelerZ, sqrtf(accelerX * accelerX + accelerY * accelerY)) / M_PI * 180.0;
        _verticalLabel.text = [NSString stringWithFormat:@"z angle : %.2f", zAngle];
    }];
}

- (void)_initLocation {
    
    _locationManager = [[CLLocationManager alloc] init];
    _locationManager.delegate = self;
    
    // Start heading updates.
    if ([CLLocationManager headingAvailable]) {
        _locationManager.headingFilter = 1;
        [_locationManager startUpdatingHeading];
    }
    
    // Start location services to get the true heading.
    if ([CLLocationManager locationServicesEnabled]) {
        _locationManager.distanceFilter = kCLDistanceFilterNone;
        _locationManager.desiredAccuracy = kCLLocationAccuracyBest;
        [_locationManager startUpdatingLocation];
    }
}

- (void)_initCamera {
    
    NSArray *devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    for (AVCaptureDevice *device in devices) {
        if (device.position == AVCaptureDevicePositionBack) {
            _currentDevice = device;
            break;
        }
    }
    
    _captureSession = [AVCaptureSession new];
    _captureSession.sessionPreset = AVCaptureSessionPresetPhoto;
    
    AVCaptureDeviceInput *cameraDeviceInput = [[AVCaptureDeviceInput alloc] initWithDevice:_currentDevice error:nil];
    if ([_captureSession canAddInput:cameraDeviceInput]) {
        [_captureSession addInput:cameraDeviceInput];
    }
    
    AVCaptureVideoPreviewLayer *previewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:_captureSession];
    previewLayer.frame = _previewView.bounds;
    previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    previewLayer.backgroundColor = [UIColor blackColor].CGColor;
    [_previewView.layer addSublayer:previewLayer];
    
    if ([previewLayer.connection isVideoOrientationSupported]) {
        [previewLayer.connection setVideoOrientation:AVCaptureVideoOrientationLandscapeRight];
    }
    
    [_captureSession startRunning];
}

- (void)_initText {
    
    NSString *text = @"123123"
}

#pragma mark - Core Location Delegate

- (void)locationManager:(CLLocationManager *)manager didUpdateHeading:(CLHeading *)newHeading {
    if (newHeading.headingAccuracy < 0) {
        return;
    }
    
    _horizontalLabel.text = [NSString stringWithFormat:@"x Angle : %.2f", newHeading.magneticHeading];
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations {
    if (locations.count == 0) {
        return;
    }
    
    CLLocationCoordinate2D coordinate = locations[0].coordinate;
    CLLocationDistance altitude = locations[0].altitude;
    _coordinateLabel.text = [NSString stringWithFormat:@"longitude : %.6f, latitude : %.6f, altitude : %.6f", coordinate.longitude, coordinate.latitude, altitude];
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    
    NSLog(@"Error : %@", error.localizedDescription);
}

#pragma mark - Others

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    
    [_motionManager stopAccelerometerUpdates];
    [_locationManager stopUpdatingLocation];
    [_locationManager stopUpdatingHeading];
    [_captureSession stopRunning];
}

@end
