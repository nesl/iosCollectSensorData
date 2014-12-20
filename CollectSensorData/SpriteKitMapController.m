//
//  SpriteKitMapController.m
//  CollectSensorData
//
//  Created by Bo Jhang Ho on 3/8/14.
//  Copyright (c) 2014 Bo Jhang Ho. All rights reserved.
//

#import "SpriteKitMapController.h"

@interface SpriteKitMapController() {
    
    UIImageView *imageView;
    UIImageView *imageViewPoint;
    UIImage *imagePoint;
    UIImageView *imageViewRange;
    UIImage *imageRange;
    BOOL firstAnimation;
    double boundWidth;
    double boundHeight;
    double pointPOffsetX, pointPOffsetY;
    double mapWidth, mapHeight;
    double latRatio, lonRatio;
    double errorMeter;
}

@end

@implementation SpriteKitMapController

const double latt = 34.069320;
const double latb = 34.068517;
const double lonl = -118.443380;
const double lonr = -118.442545;
const double latd = latt - latb;
const double lond = lonr - lonl;
const double pixel2meter = 8.45;

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
 
    firstAnimation = YES;
    boundWidth = 1255.0;
    boundHeight = 1351.0;
    
    locationManager = [[CLLocationManager alloc] init];
    locationManager.delegate = self;
    locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    locationManager.distanceFilter = 1;
    
    if([CLLocationManager locationServicesEnabled]){
        [locationManager startUpdatingLocation];
    }
    else {
        NSLog(@"can't use location service");
    }

    UIImage* image = [UIImage imageNamed:@"map"];
    mapWidth = image.size.width;
    mapHeight = image.size.height;
    imageView = [[UIImageView alloc] initWithImage:image];
    imageView.frame = (CGRect){.origin=CGPointMake(139.0f, 117.0f), .size=image.size};
    [scrollView addSubview:imageView];
    imageView.backgroundColor = [UIColor blackColor];
    imageView.clipsToBounds = YES;
    imageView.image = image;
    
    
    
    
    
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(2000.f, 2000.f), NO, 0.0f);
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGContextSaveGState(ctx);
    
    CGRect rect = CGRectMake(0, 0, 2000, 2000);
    UIColor *color = [[UIColor alloc] initWithRed:1.0 green:0.0 blue:0.0 alpha:0.4];
    CGContextSetFillColorWithColor(ctx, color.CGColor);
    CGContextFillEllipseInRect(ctx, rect);
    
    CGContextRestoreGState(ctx);
    imageRange = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    imageViewRange = [[UIImageView alloc] initWithImage:imageRange];
    //imageViewRange.frame = CGRectMake(0, 0, 500, 500);
    //imageViewRange.center = imageView.superview.center;
    imageViewPoint.frame = (CGRect){.origin=CGPointMake(-10000.0, -10000.0), .size=imageRange.size};
    //imageViewRange.transform = CGAffineTransformMakeScale(0.1, 0.1);
    [scrollView addSubview:imageViewRange];
    
    
    imagePoint = [UIImage imageNamed:@"point"];
    pointPOffsetX = -imagePoint.size.width / 2;
    pointPOffsetY = -imagePoint.size.height / 2;
    imageViewPoint = [[UIImageView alloc] initWithImage:imagePoint];
    imageViewPoint.frame = (CGRect){.origin=CGPointMake(-1000.0, -1000.0), .size=imagePoint.size};
    [scrollView addSubview:imageViewPoint];
    

    scrollView.pagingEnabled = NO;
    scrollView.contentSize = CGSizeMake(boundWidth, boundHeight);
    NSLog(@"%f %f", imageView.frame.size.width, imageView.frame.size.height);

    // focus on the center of scrollView
    //CGSize tSize = scrollView.bounds.size;
    //CGRect tFrame = scrollView.frame;
    //tFrame.origin.x = (tSize.width - tFrame.size.width) / 2.0f;
    //tFrame.origin.y = (tSize.height - tFrame.size.height) / 2.0f;
    //scrollView.frame = tFrame;
    
    //CGRect tFrame = scrollView.frame;
    //tFrame.origin.x = (1255.0 - 640.0) / 2.0;
    //tFrame.origin.y = (1351.0 - 1136.0) / 2.0;
    //scrollView.frame = tFrame;
    
    UITapGestureRecognizer *twoFingerTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(scrollViewTwoFingerTapped:)];
    twoFingerTapRecognizer.numberOfTapsRequired = 1;
    twoFingerTapRecognizer.numberOfTouchesRequired = 2;
    [scrollView addGestureRecognizer:twoFingerTapRecognizer];
    
    
    CGPoint pt;
    pt.x = (1255.0 - 640.0) / 2.0;
    pt.y = (1351.0 - 1136.0) / 2.0;
    [scrollView setContentOffset:pt animated:NO];
    scrollView.minimumZoomScale = 0.5f;
    scrollView.maximumZoomScale = 2.0f;
    scrollView.delegate = self;
    
    //scrollView.zoomScale = 1.5f;
    //scrollView.contentSize = imageForZooming.bounds.size;
    
    //NSLog(@"zoom scale: %f -", scrollView.zoomScale);
    
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if (firstAnimation) {
        [scrollView setZoomScale:0.5 animated:NO];
        [scrollView zoomToRect:CGRectMake((boundWidth - 640.0) / 4.0, (boundHeight - 1136.0) / 4.0, 320, 568) animated:YES];
        firstAnimation = NO;
    }
    NSLog(@"map view will appear");
    //NSLog(@"zoom scale: %f", scrollView.zoomScale);
    
}

- (void)setPoint {
    double x = latRatio * mapWidth * scrollView.zoomScale;
    double y = lonRatio * mapHeight * scrollView.zoomScale;
    imageViewPoint.frame = (CGRect){.origin=CGPointMake(x + pointPOffsetX, y + pointPOffsetY), .size=imagePoint.size};
    
    double radius = errorMeter * pixel2meter * scrollView.zoomScale;
    imageViewRange.frame = (CGRect){.origin=CGPointMake(x-radius, y-radius), .size=CGSizeMake(2*radius, 2*radius)};

}

- (void)scrollViewTwoFingerTapped:(UITapGestureRecognizer*)recognizer {
    // Zoom out slightly, capping at the minimum zoom scale specified by the scroll view
    //CGFloat newZoomScale = self.scrollView.zoomScale / 1.5f;
    //newZoomScale = MAX(newZoomScale, self.scrollView.minimumZoomScale);
    //[self.scrollView setZoomScale:newZoomScale animated:YES];
    //NSLog(@"two finger tap");
}

- (UIView*)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    // Return the view that you want to zoom
    return imageView;
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView {
    // The scroll view has zoomed, so you need to re-center the contents
    [self centerScrollViewContents];
    
    //NSLog(@"zoom scale = %lf", scrollView.zoomScale);
    //[self setPointX:200.0 Y:200.0];
    //NSLog(@"xx %f %f", imageView.frame.size.width, imageView.frame.size.height);
    [self setPoint];
}

- (void)centerScrollViewContents {
    CGSize boundsSize = scrollView.bounds.size;
    CGRect contentsFrame = imageView.frame;
    
    if (contentsFrame.size.width < boundsSize.width) {
        contentsFrame.origin.x = (boundsSize.width - contentsFrame.size.width) / 2.0f;
    } else {
        contentsFrame.origin.x = 0.0f;
    }
    
    if (contentsFrame.size.height < boundsSize.height) {
        contentsFrame.origin.y = (boundsSize.height - contentsFrame.size.height) / 2.0f;
    } else {
        contentsFrame.origin.y = 0.0f;
    }
    
    imageView.frame = contentsFrame;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation {
    //NSLog(@"latitude %+.6f, longitude %+.6f\n",
    //      newLocation.coordinate.latitude,
    //      newLocation.coordinate.longitude);
    //NSLog(@"Horizontal Accuracy:%f", newLocation.horizontalAccuracy);
    
    
    latRatio = (newLocation.coordinate.latitude - latb) / latd;
    lonRatio = 1.0 - (newLocation.coordinate.longitude - lonl) / lond;
    errorMeter = newLocation.horizontalAccuracy;
    [self setPoint];
    //[self setPointX:400 Y:400];
    
    //NSLog(@"third view: %f %f", newLocation.coordinate.latitude, newLocation.coordinate.longitude);
    //NSLog(@"third view2: %f %f", latRatio, lonRatio);
    //NSLog(@"third view3: %f %f", px, py);
    //NSLog(@"third view4: %f", scrollView.zoomScale);
}

/*- (IBAction)buttonTest {
    NSLog(@"click");
}*/

//http://defol.io/kalmerrautam/splyzr-icons

@end
