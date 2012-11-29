//
//  GKImageCropViewController.m
//  GKImagePicker
//
//  Created by Georg Kitz on 6/1/12.
//  Copyright (c) 2012 Aurora Apps. All rights reserved.
//

#import "GKImageCropViewController.h"
#import "GKImageCropView.h"

const int kToolbarHeight = 53;

@interface GKImageCropViewController ()

@property (nonatomic, strong) GKImageCropView *imageCropView;
@property (nonatomic, strong) UIToolbar *toolbar;
@property (nonatomic, strong) UIButton *cancelButton;
@property (nonatomic, strong) UIButton *useButton;

- (void)_actionCancel;
- (void)_actionUse;
- (void)_setupNavigationBar;
- (void)_setupCropView;

@end

@implementation GKImageCropViewController

@synthesize currentFilterType;

#pragma mark -
#pragma mark Getter/Setter

@synthesize sourceImage, cropSize, delegate;
@synthesize imageCropView;
@synthesize toolbar;
@synthesize cancelButton, useButton;

#pragma mark -
#pragma Private Methods


- (void)_actionCancel
{
   if (!self.navigationController)
   {
      UIView *shadowView = [[UIView alloc] initWithFrame:self.view.bounds];
      shadowView.backgroundColor = [UIColor blackColor];

      [self.view.window addSubview:shadowView];
      
      UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0f, 53.0f, 320.0f, 320.0f)];
      imageView.contentMode = UIViewContentModeScaleAspectFit;
      imageView.image = sourceImage;
      
      [self.view.window addSubview:imageView];
      
      [UIView animateWithDuration:0.4f animations:^{
         
         shadowView.alpha = 0.0f;
         imageView.frame = _zoomOutFrame;
         [self dismissModalViewControllerAnimated:NO];
         
      } completion:^(BOOL finished) {
         
         [shadowView removeFromSuperview];
         [imageView removeFromSuperview];
         
      }];
   }
   else
   {
      [self.navigationController popViewControllerAnimated:YES];
   }
}


- (void)_actionUse
{
    // Remove filter from cropped image, so that user
    // is able to change it on the image processing screen
    if (self.currentFilterType != FOFilterTypeBasic)
    {
       [self applyFilter:FOFilterTypeBasic];
    }
   
    _croppedImage = [self.imageCropView croppedImage];
    [self.delegate imageCropController:self didFinishWithCroppedImage:_croppedImage];
}


- (void)_setupNavigationBar{
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel 
                                                                                          target:self 
                                                                                          action:@selector(_actionCancel)];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"fo.choose", nil)
                                                                              style:UIBarButtonItemStyleBordered 
                                                                             target:self 
                                                                             action:@selector(_actionUse)];
}


- (void)_setupCropView
{
    self.imageCropView = [[GKImageCropView alloc] initWithFrame:self.view.bounds];
    [self.imageCropView setImageToCrop:sourceImage];
    [self.imageCropView setCropSize:cropSize];
    
    [self.view addSubview:self.imageCropView];
}

- (void)_setupCancelButton{
    
    self.cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
    
    [self.cancelButton setBackgroundImage:[[UIImage imageNamed:@"PLCameraSheetButton.png"] stretchableImageWithLeftCapWidth:5 topCapHeight:0] forState:UIControlStateNormal];
    [self.cancelButton setBackgroundImage:[[UIImage imageNamed:@"PLCameraSheetButtonPressed.png"] stretchableImageWithLeftCapWidth:5 topCapHeight:0] forState:UIControlStateHighlighted];
    
    [self.cancelButton setTitle:NSLocalizedString(@"fo.cancel", nil) forState:UIControlStateNormal];
    [[self.cancelButton titleLabel] setFont:[UIFont boldSystemFontOfSize:12]];
    [self.cancelButton setTitleColor:[UIColor colorWithRed:0.173 green:0.176 blue:0.176 alpha:1] forState:UIControlStateNormal];
    [self.cancelButton setTitleShadowColor:[UIColor colorWithRed:0.827 green:0.831 blue:0.839 alpha:1] forState:UIControlStateNormal];
    [self.cancelButton  addTarget:self action:@selector(_actionCancel) forControlEvents:UIControlEventTouchUpInside];
    [[self.cancelButton titleLabel] setShadowOffset:CGSizeMake(0, 1)];
    [self.cancelButton sizeToFit];
    self.cancelButton.frame = (CGRect){CGPointZero, self.cancelButton.frame.size.width + 14.0f, self.cancelButton.frame.size.height};
}

- (void)_setupUseButton{
    
    self.useButton = [UIButton buttonWithType:UIButtonTypeCustom];
    
    [self.useButton setBackgroundImage:[[UIImage imageNamed:@"PLCameraSheetDoneButton.png"] stretchableImageWithLeftCapWidth:5 topCapHeight:0] forState:UIControlStateNormal];
    [self.useButton setBackgroundImage:[[UIImage imageNamed:@"PLCameraSheetDoneButtonPressed.png"] stretchableImageWithLeftCapWidth:5 topCapHeight:0] forState:UIControlStateHighlighted];
    
    [self.useButton setTitle:NSLocalizedString(@"fo.choose", nil) forState:UIControlStateNormal];
    [self.useButton sizeToFit];
    [[self.useButton titleLabel] setFont:[UIFont boldSystemFontOfSize:12]];
    [self.useButton setTitleShadowColor:[UIColor colorWithRed:0.118 green:0.247 blue:0.455 alpha:1] forState:UIControlStateNormal];
    [self.useButton  addTarget:self action:@selector(_actionUse) forControlEvents:UIControlEventTouchUpInside];
   
    [[self.useButton titleLabel] setShadowOffset:CGSizeMake(0, -1)];   
}

- (UIImage *)_toolbarBackgroundImage{
    
    CGFloat components[] = {
        1., 1., 1., 1.,
        123./255., 125/255., 132./255., 1.
    };
    
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(320, kToolbarHeight), YES, 0.0);
    
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGGradientRef gradient = CGGradientCreateWithColorComponents(colorSpace, components, NULL, 2);
    
    CGContextDrawLinearGradient(ctx, gradient, CGPointMake(0, 0), CGPointMake(0, kToolbarHeight), kCGImageAlphaNoneSkipFirst);
    
    UIImage *viewImage = UIGraphicsGetImageFromCurrentImageContext();   
    UIGraphicsEndImageContext();
    
    return viewImage;
}

- (void)_setupToolbar
{
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
    {
       self.toolbar = [[UIToolbar alloc] initWithFrame:CGRectZero];
       [self.toolbar setBackgroundImage:[self _toolbarBackgroundImage] forToolbarPosition:UIToolbarPositionAny barMetrics:UIBarMetricsDefault];
       [self.view addSubview:self.toolbar];
      
       [self _setupCancelButton];
       [self _setupUseButton];
      
       UILabel *info = [[UILabel alloc] initWithFrame:CGRectZero];
       info.text = NSLocalizedString(@"fo.croptitle", nil);
       info.numberOfLines = 0;
       info.textColor = [UIColor colorWithRed:0.173 green:0.173 blue:0.173 alpha:1];
       info.backgroundColor = [UIColor clearColor];
       info.shadowColor = [UIColor colorWithRed:0.827 green:0.831 blue:0.839 alpha:1];
       info.shadowOffset = CGSizeMake(0, 1);
       info.font = [UIFont boldSystemFontOfSize:18];
       info.textAlignment = UITextAlignmentCenter;
       info.lineBreakMode = UILineBreakModeWordWrap;
       info.frame = CGRectMake(0.0f, 0.0f, self.view.frame.size.width - self.cancelButton.frame.size.width - self.useButton.frame.size.width - 24.0f, kToolbarHeight);
      
       UIBarButtonItem *cancel = [[UIBarButtonItem alloc] initWithCustomView:self.cancelButton];
       UIBarButtonItem *flex = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
       UIBarButtonItem *lbl = [[UIBarButtonItem alloc] initWithCustomView:info];
       UIBarButtonItem *use = [[UIBarButtonItem alloc] initWithCustomView:self.useButton];
      
       [self.toolbar setItems:[NSArray arrayWithObjects:cancel, flex, lbl, flex, use, nil]];
   }
}

#pragma mark -
#pragma Super Class Methods

- (id)init{
    self = [super init];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
   [super viewDidLoad];
   // Do any additional setup after loading the view.
   
   [self _setupNavigationBar];
   [self _setupCropView];
   [self _setupToolbar];
   
   // Apply filter if user selected one on camera screen
   [self applyFilter:self.currentFilterType];
   
   if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
   {
      [self.navigationController setNavigationBarHidden:YES];
   }
}

- (void)viewDidUnload{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
   
    CGRect imageCropRect = self.view.bounds;
    imageCropRect.size.height -= kToolbarHeight;
   
    self.imageCropView.frame = imageCropRect;
    self.toolbar.frame = CGRectMake(0, CGRectGetHeight(self.view.frame) - kToolbarHeight, 320, kToolbarHeight);
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Filters
- (void)applyFilter:(FOFilterType)type
{
	GPUImagePicture *stillImageSource = [[GPUImagePicture alloc] initWithImage:self.sourceImage];
	GPUImageFilter *stillImageFilter = [[FOFilterManager sharedManager] imageFilterForFilterType:type];
   
	[stillImageSource addTarget:stillImageFilter];
	[stillImageSource processImage];
   
	UIImage *filteredImage = [stillImageFilter imageFromCurrentlyProcessedOutput];
   
   [self.imageCropView setImageToCrop:filteredImage];
   //   [self.imageCropView setNeedsDisplay];
}

@end
