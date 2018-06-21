//
//  MapViewController.h
//
//  Created by Karim Naaji on 10/12/16.
//  Copyright © 2016 Karim Naaji. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <TangramMap/TangramMap.h>
#import <CoreLocation/CoreLocation.h>

typedef struct SimulatedLocationData {
    double lat;
    double lng;
    double altitude;
    double horizontalAccuracy;
    double verticalAccuracy;
    double course;
    double speed;
    double timestamp;
    
    // about rotationMatrix from motion
    double m11;
    double m12;
    double m13;
    double m21;
    double m22;
    double m23;
    double m31;
    double m32;
    double m33;
    
    //about gravity from motion
    double x;
    double y;
    double z;
    
    //about quaternion from motion
    double quaternion_x;
    double quaternion_y;
    double quaternion_z;
    double quaternion_w;
    
}SimulatedLocationData;


@interface MapViewControllerDelegate : NSObject <TGMapViewDelegate>
- (void)mapView:(nonnull TGMapViewController *)mapView didLoadScene:(int)sceneID withError:(nullable NSError *)sceneError;
- (void)mapViewDidCompleteLoading:(nonnull TGMapViewController *)mapView;
- (void)mapView:(nonnull TGMapViewController *)mapView didSelectFeature:(nullable NSDictionary *)feature atScreenPosition:(CGPoint)position;
- (void)mapView:(nonnull TGMapViewController *)mapView didSelectLabel:(nullable TGLabelPickResult *)labelPickResult atScreenPosition:(CGPoint)position;
- (void)mapView:(nonnull TGMapViewController *)mapView didSelectMarker:(nullable TGMarkerPickResult *)markerPickResult atScreenPosition:(TGGeoPoint)position;
- (void)mapView:(nonnull TGMapViewController *)view didCaptureScreenshot:(nonnull UIImage *)screenshot;
@end

@interface MapViewControllerRecognizerDelegate : NSObject <TGRecognizerDelegate>

- (void)mapView:(nonnull TGMapViewController *)view recognizer:(nonnull UIGestureRecognizer *)recognizer didRecognizeSingleTapGesture:(CGPoint)location;
- (void)mapView:(nonnull TGMapViewController *)view recognizer:(nonnull UIGestureRecognizer *)recognizer didRecognizeLongPressGesture:(CGPoint)location;

@end

@interface MapViewController : TGMapViewController
@property (strong, nonatomic) TGMapData* mapData;
+ (MapViewController *) shared;
- (void) goLocation: (CLLocationCoordinate2D) location;

- (void) makeMarker_points: (int)size color:(NSString*)color simulatedLocationDatas:(SimulatedLocationData *)coordinates;
- (void) makeMarker_points: (int)size color:(NSString*)color cLLocationCoordinate2Ds:(CLLocationCoordinate2D *)coordinates;

- (void) makeMarker_polyline: (int)size color:(NSString*)color simulatedLocationDatas:(SimulatedLocationData *)coordinates;
- (void) makeMarker_polyline: (int)size color:(NSString*)color cLLocationCoordinate2Ds:(CLLocationCoordinate2D *)coordinates;

// not recomended
- (void) showPath: (int)size color:(NSString*)color simulatedLocationDatas:(SimulatedLocationData *)coordinates;
- (void) showPath: (int)size color:(NSString*)color cLLocationCoordinate2Ds:(CLLocationCoordinate2D *)coordinates;

@end
