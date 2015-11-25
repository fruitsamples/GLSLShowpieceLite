//-------------------------------------------------------------------------
//
//	File: Eroded.m
//
//  Abstract: Eroded GLSL Exhibit
// 			 
//  Disclaimer: IMPORTANT:  This Apple software is supplied to you by
//  Apple Inc. ("Apple") in consideration of your agreement to the
//  following terms, and your use, installation, modification or
//  redistribution of this Apple software constitutes acceptance of these
//  terms.  If you do not agree with these terms, please do not use,
//  install, modify or redistribute this Apple software.
//  
//  In consideration of your agreement to abide by the following terms, and
//  subject to these terms, Apple grants you a personal, non-exclusive
//  license, under Apple's copyrights in this original Apple software (the
//  "Apple Software"), to use, reproduce, modify and redistribute the Apple
//  Software, with or without modifications, in source and/or binary forms;
//  provided that if you redistribute the Apple Software in its entirety and
//  without modifications, you must retain this notice and the following
//  text and disclaimers in all such redistributions of the Apple Software. 
//  Neither the name, trademarks, service marks or logos of Apple Inc.
//  may be used to endorse or promote products derived from the Apple
//  Software without specific prior written permission from Apple.  Except
//  as expressly stated in this notice, no other rights or licenses, express
//  or implied, are granted by Apple herein, including but not limited to
//  any patent rights that may be infringed by your derivative works or by
//  other works in which the Apple Software may be incorporated.
//  
//  The Apple Software is provided by Apple on an "AS IS" basis.  APPLE
//  MAKES NO WARRANTIES, EXPRESS OR IMPLIED, INCLUDING WITHOUT LIMITATION
//  THE IMPLIED WARRANTIES OF NON-INFRINGEMENT, MERCHANTABILITY AND FITNESS
//  FOR A PARTICULAR PURPOSE, REGARDING THE APPLE SOFTWARE OR ITS USE AND
//  OPERATION ALONE OR IN COMBINATION WITH YOUR PRODUCTS.
//  
//  IN NO EVENT SHALL APPLE BE LIABLE FOR ANY SPECIAL, INDIRECT, INCIDENTAL
//  OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
//  SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
//  INTERRUPTION) ARISING IN ANY WAY OUT OF THE USE, REPRODUCTION,
//  MODIFICATION AND/OR DISTRIBUTION OF THE APPLE SOFTWARE, HOWEVER CAUSED
//  AND WHETHER UNDER THEORY OF CONTRACT, TORT (INCLUDING NEGLIGENCE),
//  STRICT LIABILITY OR OTHERWISE, EVEN IF APPLE HAS BEEN ADVISED OF THE
//  POSSIBILITY OF SUCH DAMAGE.
// 
//  Copyright (c) 2004-2007 Apple Inc., All rights reserved.
//
//-------------------------------------------------------------------------

#import "Eroded.h"

@implementation Eroded

- (void) initOffset
{
	offset = [[UniformData alloc] init];
	
	[offset initCurrent:0 atIndex:0];
	[offset initMax:0 atIndex:0];
	[offset initMin:0 atIndex:0];
	[offset initDelta:0 atIndex:0];

	[offset initCurrent:0 atIndex:1];
	[offset initMax:0.25 atIndex:1];
	[offset initMin:-0.45 atIndex:1];
	[offset initDelta:0.01 atIndex:1];
} // initScale

- (void) setupUniforms
{
	[self initOffset];
	
	glUseProgramObjectARB(programObject);
	
	glUniform3fARB([self getUniformLocation:programObject uniformName:"LightPosition"], 0.0, 0.0, 4.0);
	glUniform1fARB([self getUniformLocation:programObject uniformName:"Scale"], 0.6);
	glUniform3fvARB([self getUniformLocation:programObject uniformName:"Offset"], 1, [offset current]);
	glUniform1iARB([self getUniformLocation:programObject uniformName:"sampler3d"], 0);		
} // setupUniforms

- (void) initLazy
{
	[super initLazy];
	
	// Setup GLSL

	// Here we get a new model
	
	model = [[Models alloc] init];
	
	// noise texture
	
	noiseTexture = [self loadNoiseTexture];

	// Load vertex and fragment shaders
	
	[self loadShadersFromResource:@"Eroded" ];
		
	// Setup uniforms
	
	[self setupUniforms];
} // initLazy

- (void) dealloc
{
	glDeleteTextures(1, &noiseTexture);

	[offset dealloc];
	
	[model dealloc];
	
	[super dealloc];
} // dealloc

- (NSString *) name
{
	return @"Eroded";
}

- (NSString *) descriptionFilename
{
	return [appBundle pathForResource: @"Eroded" ofType: @"rtf"];
} // descriptionFilename

- (void) renderFrame
{
	[super renderFrame];
	
	glUseProgramObjectARB(programObject);
	
	[offset animate];
	
	glUniform3fvARB([self getUniformLocation:programObject uniformName:"Offset"], 1, [offset current]);

	glBindTexture(GL_TEXTURE_3D, noiseTexture);
	
	[model drawModel:kModelSolidTeapot];
	
	glUseProgramObjectARB(NULL);
} // renderFrame

@end
