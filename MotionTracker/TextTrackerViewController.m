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

#import "MTPost.h"

#define SCREEN_WIDTH  [UIScreen mainScreen].bounds.size.width
#define SCREEN_HEIGHT [UIScreen mainScreen].bounds.size.height

@interface TextTrackerViewController () <CLLocationManagerDelegate> {
    
@private
    double _xAngle;
    double _yAngle;
    double _zAngle;
    
    double _longitude;
    double _latitude;
    double _angle;
}

@property (nonatomic, strong) CLLocationManager  *locationManager;
@property (nonatomic, strong) CMMotionManager    *motionManager;
@property (nonatomic, strong) AVCaptureSession   *captureSession;

@property (weak, nonatomic) IBOutlet UIView *previewView;
@property (weak, nonatomic) IBOutlet UILabel *verticalLabel;
@property (weak, nonatomic) IBOutlet UILabel *horizontalLabel;
@property (weak, nonatomic) IBOutlet UILabel *coordinateLabel;

@property (nonatomic, strong) AVCaptureDevice *currentDevice;

@property (nonatomic, strong) NSArray *posts;
@property (nonatomic, strong) NSMutableArray *postLabels;

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
    _motionManager.accelerometerUpdateInterval = 0.1f;
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
        _locationManager.headingFilter = kCLHeadingFilterNone;
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
    
    // current 30.2980000000,120.0642270000
    MTPost *post1 = [[MTPost alloc] initWithText:@"徐杰到此一游" longitude:120.07f andLatitude:30.30f];
    MTPost *post2 = [[MTPost alloc] initWithText:@"孙雪松到此一游" longitude:120.05f andLatitude:30.30f];
    MTPost *post3 = [[MTPost alloc] initWithText:@"刘楠到此一游" longitude:120.06f andLatitude:30.30f];
    MTPost *post4 = [[MTPost alloc] initWithText:@"袁俊力到此一游" longitude:120.07f andLatitude:30.27f];
    MTPost *post5 = [[MTPost alloc] initWithText:@"夏尔特到此一游" longitude:120.07f andLatitude:30.32f];
    MTPost *post6 = [[MTPost alloc] initWithText:@"曾宁忠到此一游" longitude:120.04f andLatitude:30.27f];
    MTPost *post7 = [[MTPost alloc] initWithText:@"虐虐到此一游" longitude:120.09f andLatitude:30.33f];
    MTPost *post8 = [[MTPost alloc] initWithText:@"王安石到此一游" longitude:120.01f andLatitude:30.37f];
    
    _posts = @[post1,
               post2, post3, post4, post5, post6, post7, post8
               ];
    
    _postLabels = [NSMutableArray array];
    for (MTPost *post in _posts) {
        UILabel *label = [self _createLabelWithPost:post];
        [self.view addSubview:label];
        [_postLabels addObject:label];
    }
}

- (UILabel *)_createLabelWithPost:(MTPost *)post {
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, arc4random() % (int)SCREEN_HEIGHT, 100, 21)];
    label.text = post.text;
    label.backgroundColor = [UIColor whiteColor];
    label.font = [UIFont systemFontOfSize:14.0f];
    label.textColor = [UIColor blackColor];
    label.textAlignment = NSTextAlignmentCenter;
    [label sizeToFit];
    CGRect frame = label.frame;
    frame.origin.x = [self _percentageOfWidthWithPost:post] * SCREEN_WIDTH;
    label.frame = frame;
    return label;
}

- (double)_percentageOfWidthWithPost:(MTPost *)post {
    
    double x1,y1,x2,y2;
    
    x1 = _longitude;
    y1 = _latitude;
    x2 = post.longitude;
    y2 = post.latitude;
    
    double alpha;
    double beta = _angle / 180.0f * M_PI;
    
    // calculate alpha
    if (x2 >= x1) {
        if (y2 >= y1) {
            alpha = atan2((x2 - x1), (y2 - y1));
        } else {
            alpha = M_PI - atan2((x2 - x1), (y1 - y2));
        }
    } else {
        if (y2 >= y1) {
            alpha = -atan2((x1 - x2), (y1 - y2));
        } else {
            alpha = -(M_PI - atan2((x1 - x2), (y2 - y1)));
        }
    }
    
    // calculate angle
    if (beta > M_PI) {
        beta = beta - 2 * M_PI;
    }
    
    double gamma;
    if (beta < 0) {
        if (alpha < 0) {
            if (fabs(alpha) > fabs(beta)) {
                gamma = -fabs(alpha - beta);
            } else {
                gamma = fabs(alpha - beta);
            }
        } else {
            gamma = alpha - beta;
        }
    } else {
        if (alpha < 0) {
            gamma = alpha - beta;
        } else {
            if (alpha > beta) {
                gamma = fabs(alpha - beta);
            } else {
                gamma = -fabs(alpha - beta);
            }
        }
    }
    
    NSLog(@"gamma / M_PI_4 = %.2f, gamma = %.2f, angle = %.2f", gamma / M_PI_4, gamma, gamma / M_PI * 180.0f);
    return 0.5f + gamma / M_PI_4;
}

- (void)_refreshScreenLabels {
    
    for (int i = 0; i < _posts.count; i ++) {
        MTPost *post   = _posts[i];
        UILabel *label = _postLabels[i];
        CGRect frame   = label.frame;
        double perc    = [self _percentageOfWidthWithPost:post];
        frame.origin.x = perc * SCREEN_WIDTH;
        label.frame    = frame;
    }
}

#pragma mark - Core Location Delegate

- (void)locationManager:(CLLocationManager *)manager didUpdateHeading:(CLHeading *)newHeading {
    if (newHeading.headingAccuracy < 0) {
        return;
    }
    
    _angle = newHeading.magneticHeading;
    _horizontalLabel.text = [NSString stringWithFormat:@"x Angle : %.2f", newHeading.magneticHeading];
    [self _refreshScreenLabels];
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations {
    if (locations.count == 0) {
        return;
    }
    
    CLLocationCoordinate2D coordinate = locations[0].coordinate;
    CLLocationDistance altitude = locations[0].altitude;
    _longitude = coordinate.longitude;
    _latitude = coordinate.latitude;
    _coordinateLabel.text = [NSString stringWithFormat:@"longitude : %.6f, latitude : %.6f, altitude : %.6f", coordinate.longitude, coordinate.latitude, altitude];
    [self _refreshScreenLabels];
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
