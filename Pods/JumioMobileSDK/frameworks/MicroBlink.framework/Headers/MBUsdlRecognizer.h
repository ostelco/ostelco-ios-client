//
//  MBUsdlRecognizer.h
//  MicroBlinkDev
//
//  Created by Jura Skrlec on 03/01/2018.
//

#import "PPMicroBlinkDefines.h"
#import "MBRecognizer.h"
#import "MBUsdlRecognizerResult.h"
#import "MBMicroBlinkInitialization.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * A recognizer that can scan USDL.
 */
PP_CLASS_DEPRECATED_IOS(1.0, 7.0, "MBUsdlRecognizer is deprecated in PDF417 SDK 7.0.0")
@interface MBUsdlRecognizer : MBRecognizer<NSCopying>

MB_INIT

/**
 * USDL recognizer results
 */
@property (nonatomic, strong, readonly) MBUsdlRecognizerResult *result;

/**
 * Set this to YES to scan even barcode not compliant with standards
 * For example, malformed USDL barcodes which were incorrectly encoded
 *
 * Use only if necessary because it slows down the recognition process
 *
 * Default: YES
 */
@property (nonatomic, assign) BOOL scanUncertain;

/**
 * Set this to YES to scan barcodes which don't have quiet zone (white area) around it
 *
 * Use only if necessary because it slows down the recognition process
 *
 * Default: YES
 */
@property (nonatomic, assign) BOOL allowNullQuietZone;

@end

NS_ASSUME_NONNULL_END
