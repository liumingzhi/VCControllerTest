//
//  UIImage+Utility.m
//  QunariPhone
//
//  Created by 姜琢 on 13-6-8.
//  Copyright (c) 2013年 Qunar.com. All rights reserved.
//

#import "UIImage+Utility.h"
@import Accelerate;
#import <float.h>

@implementation UIImage (Utility)

+ (UIImage *)imageWithBundlePath:(NSString *)path
{
    UIImage *image = [UIImage imageNamed:path];
    if (image == nil)
    {
        image = [UIImage imageWithContentsOfFile:path];
    }
    
    return image;
}

+ (UIImage *)imageFromColor:(UIColor *)color
{
    CGRect rect = CGRectMake(0, 0, 1, 1);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context,[color CGColor]);
    CGContextFillRect(context, rect);
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}


// 截取部分图像
- (UIImage *)getSubImage:(CGRect)rect
{
    CGImageRef subImageRef = CGImageCreateWithImageInRect(self.CGImage, rect);
    CGRect smallBounds = CGRectMake(0, 0, CGImageGetWidth(subImageRef), CGImageGetHeight(subImageRef));
    
    UIGraphicsBeginImageContext(smallBounds.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextDrawImage(context, smallBounds, subImageRef);
    
    UIImage *smallImage = [UIImage imageWithCGImage:subImageRef];
    CFRelease(subImageRef);
    UIGraphicsEndImageContext();
    
    return smallImage;
}



// 等比例缩放
- (UIImage *)scaleToSize:(CGSize)size
{
    CGFloat width  = CGImageGetWidth(self.CGImage);
    CGFloat height = CGImageGetHeight(self.CGImage);
    
    float scale = [[UIScreen mainScreen] scale];
    
    float verticalRadio   = size.height*scale/height;
    float horizontalRadio = size.width*scale/width;
    
    float radio = 1;
    
    if (verticalRadio > 1 && horizontalRadio > 1)
    {
        radio = 1;
    }
    else
    {
        radio = verticalRadio < horizontalRadio ? verticalRadio : horizontalRadio;
    }
    
    width  = width * radio;
    height = height * radio;
    
    int xPos = (size.width - width/scale)/2;
    int yPos = (size.height - height/scale)/2;
    
    UIGraphicsBeginImageContextWithOptions(size, NO,scale);
    [self drawInRect:CGRectMake(xPos, yPos, width/scale, height/scale)];
    
    UIImage *scaledImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return scaledImage;
}

+ (UIImage *)TransformtoSize:(CGSize)size image:(UIImage *)image
{
    UIGraphicsBeginImageContext(size);
    [image drawInRect:CGRectMake(0, 0, size.width, size.height)];
    UIImage *transformedImg=UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return transformedImg;
}

- (UIImage *)imageWithMaxLength:(CGFloat)sideLenght
{
    CGSize size = [self fitSize:sideLenght];
    
    UIGraphicsBeginImageContext(size);
    
    CGContextSetInterpolationQuality(UIGraphicsGetCurrentContext(), kCGInterpolationDefault);
    CGRect rect = CGRectMake(0, 0, size.width, size.height);
    [self drawInRect:rect];
    
    UIImage *newimg = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return newimg;
}

- (CGSize)fitSize:(CGFloat)sideLenght
{
    CGFloat scale;
    CGSize newsize;
    
    if(self.size.width <= sideLenght && self.size.height <= sideLenght)
    {
        newsize = self.size;
    }
    else
    {
        if(self.size.width >= self.size.height)
        {
            scale = sideLenght/self.size.width;
            newsize.width = sideLenght;
            newsize.height = ceilf(self.size.height*scale);
        }
        else
        {
            scale = sideLenght/self.size.height;
            newsize.height = sideLenght;
            newsize.width = ceilf(self.size.width*scale);
        }
    }
    
    return newsize;
}


- (UIImage *) boxBlurWithRadius:(CGFloat) radius {
    radius *= [UIScreen mainScreen].scale;
    radius = (NSUInteger)floor(radius * 3.f * sqrt(2.f * M_PI) / 4.f + .5f);
    radius *= .5f;
    if (!((NSUInteger)radius % 2)) {
        radius++;
    }
    
    CGImageRef inImageRef = self.CGImage;
    
    size_t width = CGImageGetWidth(inImageRef) * .5f;
    size_t height = CGImageGetHeight(inImageRef) * .5f;
    size_t rowBytes = CGImageGetBytesPerRow(inImageRef) * .5f;
    
    uint32_t *bitmapData = malloc(rowBytes * height);
    CGContextRef inContext = CGBitmapContextCreate(bitmapData,
                                                   width,
                                                   height,
                                                   8,
                                                   rowBytes,
                                                   CGImageGetColorSpace(inImageRef),
                                                   (CGBitmapInfo)kCGImageAlphaPremultipliedLast);
    CGContextDrawImage(inContext, CGRectMake(0, 0, width, height), inImageRef);
    
    vImage_Buffer inBuffer;
    inBuffer.width = CGBitmapContextGetWidth(inContext);
    inBuffer.height = CGBitmapContextGetHeight(inContext);
    inBuffer.rowBytes = CGBitmapContextGetBytesPerRow(inContext);
    inBuffer.data = CGBitmapContextGetData(inContext);
    
    void *pixelBuffer = malloc(rowBytes * height);
    vImage_Buffer outBuffer;
    outBuffer.width = width;
    outBuffer.height = height;
    outBuffer.rowBytes = rowBytes;
    outBuffer.data = pixelBuffer;
    
    vImageBoxConvolve_ARGB8888(&inBuffer, &outBuffer, NULL, 0, 0, radius, radius, NULL, kvImageEdgeExtend);
    vImageBoxConvolve_ARGB8888(&outBuffer, &inBuffer, NULL, 0, 0, radius, radius, NULL, kvImageEdgeExtend);
    vImageBoxConvolve_ARGB8888(&inBuffer, &outBuffer, NULL, 0, 0, radius, radius, NULL, kvImageEdgeExtend);
    
    CGContextRef outContext = CGBitmapContextCreate(outBuffer.data,
                                                    outBuffer.width,
                                                    outBuffer.height,
                                                    8,
                                                    outBuffer.rowBytes,
                                                    CGImageGetColorSpace(inImageRef),
                                                    (CGBitmapInfo)kCGImageAlphaNoneSkipLast);
    CGImageRef outImageRef = CGBitmapContextCreateImage(outContext);
    UIImage *outImage = [UIImage imageWithCGImage:outImageRef];
    
    CFRelease(outImageRef);
    CGContextRelease(outContext);
    free(pixelBuffer);
    free(bitmapData);
    CGContextRelease(inContext);
    
    return outImage;
}

- (UIImage *)applyBlurWithRadius:(CGFloat)blurRadius tintColor:(UIColor *)tintColor saturationDeltaFactor:(CGFloat)saturationDeltaFactor maskImage:(UIImage *)maskImage
{
    // Check pre-conditions.
    if (self.size.width < 1 || self.size.height < 1) {
        NSLog (@"*** error: invalid size: (%.2f x %.2f). Both dimensions must be >= 1: %@", self.size.width, self.size.height, self);
        return nil;
    }
    if (!self.CGImage) {
        NSLog (@"*** error: image must be backed by a CGImage: %@", self);
        return nil;
    }
    if (maskImage && !maskImage.CGImage) {
        NSLog (@"*** error: maskImage must be backed by a CGImage: %@", maskImage);
        return nil;
    }
    
    CGRect imageRect = { CGPointZero, self.size };
    UIImage *effectImage = self;
    
    BOOL hasBlur = blurRadius > __FLT_EPSILON__;
    BOOL hasSaturationChange = fabs(saturationDeltaFactor - 1.) > __FLT_EPSILON__;
    if (hasBlur || hasSaturationChange) {
        UIGraphicsBeginImageContextWithOptions(self.size, NO, 2.0);
        CGContextRef effectInContext = UIGraphicsGetCurrentContext();
        CGContextScaleCTM(effectInContext, 1.0, -1.0);
        CGContextTranslateCTM(effectInContext, 0, -self.size.height);
        CGContextDrawImage(effectInContext, imageRect, self.CGImage);
        
        vImage_Buffer effectInBuffer;
        effectInBuffer.data     = CGBitmapContextGetData(effectInContext);
        effectInBuffer.width    = CGBitmapContextGetWidth(effectInContext);
        effectInBuffer.height   = CGBitmapContextGetHeight(effectInContext);
        effectInBuffer.rowBytes = CGBitmapContextGetBytesPerRow(effectInContext);
        
        UIGraphicsBeginImageContextWithOptions(self.size, NO, 2.0);
        CGContextRef effectOutContext = UIGraphicsGetCurrentContext();
        vImage_Buffer effectOutBuffer;
        effectOutBuffer.data     = CGBitmapContextGetData(effectOutContext);
        effectOutBuffer.width    = CGBitmapContextGetWidth(effectOutContext);
        effectOutBuffer.height   = CGBitmapContextGetHeight(effectOutContext);
        effectOutBuffer.rowBytes = CGBitmapContextGetBytesPerRow(effectOutContext);
        
        if (hasBlur) {
            // A description of how to compute the box kernel width from the Gaussian
            // radius (aka standard deviation) appears in the SVG spec:
            // http://www.w3.org/TR/SVG/filters.html#feGaussianBlurElement
            //
            // For larger values of 's' (s >= 2.0), an approximation can be used: Three
            // successive box-blurs build a piece-wise quadratic convolution kernel, which
            // approximates the Gaussian kernel to within roughly 3%.
            //
            // let d = floor(s * 3*sqrt(2*pi)/4 + 0.5)
            //
            // ... if d is odd, use three box-blurs of size 'd', centered on the output pixel.
            //
            CGFloat inputRadius = blurRadius * 2.0;
            int radius = floor(inputRadius * 3. * sqrt(2 * M_PI) / 4 + 0.5);
            if (radius % 2 != 1) {
                radius += 1; // force radius to be odd so that the three box-blur methodology works.
            }
            vImageBoxConvolve_ARGB8888(&effectInBuffer, &effectOutBuffer, NULL, 0, 0, radius, radius, 0, kvImageEdgeExtend);
            vImageBoxConvolve_ARGB8888(&effectOutBuffer, &effectInBuffer, NULL, 0, 0, radius, radius, 0, kvImageEdgeExtend);
            vImageBoxConvolve_ARGB8888(&effectInBuffer, &effectOutBuffer, NULL, 0, 0, radius, radius, 0, kvImageEdgeExtend);
        }
        BOOL effectImageBuffersAreSwapped = NO;
        if (hasSaturationChange) {
            CGFloat s = saturationDeltaFactor;
            CGFloat floatingPointSaturationMatrix[] = {
                0.0722 + 0.9278 * s,  0.0722 - 0.0722 * s,  0.0722 - 0.0722 * s,  0,
                0.7152 - 0.7152 * s,  0.7152 + 0.2848 * s,  0.7152 - 0.7152 * s,  0,
                0.2126 - 0.2126 * s,  0.2126 - 0.2126 * s,  0.2126 + 0.7873 * s,  0,
                0,                    0,                    0,  1,
            };
            const int32_t divisor = 256;
            NSUInteger matrixSize = sizeof(floatingPointSaturationMatrix)/sizeof(floatingPointSaturationMatrix[0]);
            int16_t saturationMatrix[matrixSize];
            for (NSUInteger i = 0; i < matrixSize; ++i) {
                saturationMatrix[i] = (int16_t)roundf(floatingPointSaturationMatrix[i] * divisor);
            }
            if (hasBlur) {
                vImageMatrixMultiply_ARGB8888(&effectOutBuffer, &effectInBuffer, saturationMatrix, divisor, NULL, NULL, kvImageNoFlags);
                effectImageBuffersAreSwapped = YES;
            }
            else {
                vImageMatrixMultiply_ARGB8888(&effectInBuffer, &effectOutBuffer, saturationMatrix, divisor, NULL, NULL, kvImageNoFlags);
            }
        }
        if (!effectImageBuffersAreSwapped)
            effectImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        if (effectImageBuffersAreSwapped)
            effectImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
    }
    
    // Set up output context.
    UIGraphicsBeginImageContextWithOptions(self.size, NO, 2.0);
    CGContextRef outputContext = UIGraphicsGetCurrentContext();
    CGContextScaleCTM(outputContext, 1.0, -1.0);
    CGContextTranslateCTM(outputContext, 0, -self.size.height);
    
    // Draw base image.
    CGContextDrawImage(outputContext, imageRect, self.CGImage);
    
    // Draw effect image.
    if (hasBlur) {
        CGContextSaveGState(outputContext);
        if (maskImage) {
            CGContextClipToMask(outputContext, imageRect, maskImage.CGImage);
        }
        CGContextDrawImage(outputContext, imageRect, effectImage.CGImage);
        CGContextRestoreGState(outputContext);
    }
    
    // Add in color tint.
    if (tintColor) {
        CGContextSaveGState(outputContext);
        CGContextSetFillColorWithColor(outputContext, tintColor.CGColor);
        CGContextFillRect(outputContext, imageRect);
        CGContextRestoreGState(outputContext);
    }
    
    // Output image is ready.
    UIImage *outputImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return outputImage;
}

- (UIImage *)applyTintEffectWithColor:(UIColor *)tintColor
{
    const CGFloat EffectColorAlpha = 0.6;
    UIColor *effectColor = tintColor;
    NSInteger componentCount = CGColorGetNumberOfComponents(tintColor.CGColor);
    if (componentCount == 2) {
        CGFloat b;
        if ([tintColor getWhite:&b alpha:NULL]) {
            effectColor = [UIColor colorWithWhite:b alpha:EffectColorAlpha];
        }
    }
    else {
        CGFloat r, g, b;
        if ([tintColor getRed:&r green:&g blue:&b alpha:NULL]) {
            effectColor = [UIColor colorWithRed:r green:g blue:b alpha:EffectColorAlpha];
        }
    }
    
    return [self applyBlurWithRadius:60 tintColor:tintColor saturationDeltaFactor:1.0 maskImage:nil];
}

@end
