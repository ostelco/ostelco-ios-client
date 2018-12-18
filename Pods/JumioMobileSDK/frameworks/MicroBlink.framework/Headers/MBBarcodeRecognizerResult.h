//
//  MBBarcodeRecognizerResult.h
//  MicroBlinkDev
//
//  Created by Jura Skrlec on 28/11/2017.
//

#import <Foundation/Foundation.h>

#import "PPMicroBlinkDefines.h"
#import "MBRecognizerResult.h"
#import "MBBarcodeResult.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * Result of MBBarcodeRecognizer; is used for scanning most of 1D barcode formats, and 2D format
 * such as Aztec, DataMatrix and QR code
 */
PP_CLASS_AVAILABLE_IOS(6.0)
@interface MBBarcodeRecognizerResult : MBRecognizerResult<NSCopying>

- (instancetype)init NS_UNAVAILABLE;

/**
 * Byte array with result of the scan
 */
- (NSData *_Nullable)data;

/**
 * Retrieves string content of scanned data
 */
- (NSString *)stringData;

/**
 * Flag indicating uncertain scanning data
 * E.g obtained from damaged barcode.
 */
- (BOOL)isUncertain;

/**
 * Method which gives string representation for a given PPBarcodeType enum value.
 *
 *  @param type PPBarcodeType enum value
 *
 *  @return String representation of a given PPBarcodeType enum value.
 */
+ (NSString *_Nonnull)toTypeName:(MBBarcodeType)type;

/**
 * Type of the barcode scanned
 *
 *  @return Type of the barcode
 */
@property(nonatomic, assign, readonly) MBBarcodeType barcodeType;


@end

NS_ASSUME_NONNULL_END
