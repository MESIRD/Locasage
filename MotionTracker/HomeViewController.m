//
//  HomeViewController.m
//  MotionTracker
//
//  Created by mesird on 08/10/2016.
//  Copyright © 2016 mesird. All rights reserved.
//

#import "HomeViewController.h"

#import "BarragePostViewController.h"
#import "TextTrackerViewController.h"

@interface HomeViewController () <UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@property (weak, nonatomic) IBOutlet UIView *profileSetView;
@property (weak, nonatomic) IBOutlet UIImageView *avatarView;
@property (weak, nonatomic) IBOutlet UITextField *nickField;

@property (nonatomic, strong) UIImagePickerController *imagePicker;


@end

@implementation HomeViewController

- (UIImagePickerController *)imagePicker {
    
    if (!_imagePicker) {
        _imagePicker = [[UIImagePickerController alloc] init];
        _imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        _imagePicker.delegate   = self;
        _imagePicker.allowsEditing = YES;
    }
    return _imagePicker;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    _profileSetView.hidden = YES;
    [self _firstTimeLaunch];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    self.navigationController.navigationBar.hidden = YES;
}

- (void)_firstTimeLaunch {
    
//    id firstLaunch = [[NSUserDefaults standardUserDefaults] objectForKey:@"firstLaunch"];
//    if (!firstLaunch) {
        [[NSUserDefaults standardUserDefaults] setObject:@"1" forKey:@"firstLaunch"];
        
        _profileSetView.hidden = NO;
        _avatarView.userInteractionEnabled = YES;
        UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapOnAvatarView:)];
        [_avatarView addGestureRecognizer:tapRecognizer];
//    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)realTimeChattingButtonPressed:(id)sender {
    
    BarragePostViewController *vc = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:NSStringFromClass(BarragePostViewController.class)];
    [self.navigationController pushViewController:vc animated:YES];
}

- (IBAction)historicalMessageButtonPressed:(id)sender {
    
    TextTrackerViewController *vc = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:NSStringFromClass(TextTrackerViewController.class)];
    [self.navigationController pushViewController:vc animated:YES];
}

- (IBAction)submitProfileButtonPressed:(id)sender {
    
    _profileSetView.hidden = YES;
}

- (void)tapOnAvatarView:(UITapGestureRecognizer *)recognizer {
    [self presentViewController:self.imagePicker animated:YES completion:nil];
}

#pragma mark - UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {
    
    [self dismissViewControllerAnimated:YES completion:nil];
    
    UIImage *image = info[UIImagePickerControllerEditedImage];
    if (!image) {
        NSLog(@"No image is selected");
        return;
    }
    
    
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
