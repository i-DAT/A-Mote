/**
 * =============================================================================
 * NonGraphicalFaceDetectorLite
 * - org.i500.projects.faceDetection.NonGraphicalFaceDetectorLite
 * -----------------------------------------------------------------------------
 * @author 	Justin Roberts
 * @date	00:14 25/01/10
 * -----------------------------------------------------------------------------
 * ChangeLog:
 * 1. removing all graphical aspects of the detector process
 * 2. removed the idle timer as it stops very low capture rates
 * =============================================================================
 */
package org.i500.projects.faceDetection 
{
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.net.LocalConnection;
	import flash.media.Video;	
	import flash.media.Camera;	
	import flash.utils.Timer;		
	import flash.events.TimerEvent;	
	import flash.display.Graphics;	
	import flash.display.BitmapData;	
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.display.MovieClip;
	
	import org.i500.projects.faceDetection.events.FaceDetectorLiteEvent;
	
	import gs.easing.Cubic;	
	import gs.TweenLite;	
	
	import jp.maaash.ObjectDetection.ObjectDetector;	
	import jp.maaash.ObjectDetection.ObjectDetectorEvent;	
	import jp.maaash.ObjectDetection.ObjectDetectorOptions;	
	
	/**
	 * NonGraphicalFaceDetectorLite
	 * - org.i500.projects.faceDetection.NonGraphicalFaceDetectorLite
	 */
	public class NonGraphicalFaceDetectorLite extends EventDispatcher
	{
		//-----------------------------------------------------------
		// Consts
		//
		
		// Detector data
		//
		private 	const 	DETECTOR_DATA 			:String 	= "assets/zip/face.zip";
		
		// Camera settings
		//
		private 	const 	CAMERA_WIDTH 			:int 		= 160;
		private 	const 	CAMERA_HEIGHT 			:int 		= 120;
		private 	const 	CAMERA_FPS	 			:int 		= 1;
		
		//How often to analyze the webcam image
		// - use 1000/x so we know how many times per second (1000/30 = 33.3 = 30 fps)
		// - idle removed as it causes problems when running very low capture rates
		//
		private 	const 	DELAY_FACE_DETECT		:int 		= Math.ceil(1000 / CAMERA_FPS);
		
		//-----------------------------------------------------------
		// vars
		//
		
		private 	var 	__detectedCount			:uint;
		private 	var 	__detector    			:ObjectDetector;
		private 	var 	__rects					:Array;
		private 	var 	__bitmap   				:Bitmap;
		private 	var 	__video 				:Video;
		
		// Timers
		//
		private 	var 	__detectionTimer 		:Timer;
		
		/**
		 * NonGraphicalFaceDetectorLite
		 * - org.i500.projects.faceDetection.NonGraphicalFaceDetectorLite
		 */		
		public function NonGraphicalFaceDetectorLite() 
		{
			super();
			
			init();
		}
		
		/**
		 * Initialise
		 */
		private function init():void 
		{
			//initialise bitmap
			initBitmap();
			
			//initalize detector			
			initDetector();
			
			//set up camera
			initCamera();
			
			//initalise the timers
			initTimers();
		}
		
		/**
		 * Initialise the bitmap once, dont need to recreate a new bitmap each time
		 */
		private function initBitmap():void
		{
			__bitmap 							= new Bitmap( new BitmapData( CAMERA_WIDTH, CAMERA_HEIGHT, false ) );
		}
		
		/**
		 * Initializes the detector
		 */
		private function initDetector ():void
		{
			//Array of reusable rectangles
			__rects 							= new Array( );
			
			//Keep track of how many have been detected so we know when it changes
			__detectedCount						= 0;
			
			//Detector
			__detector 							= new ObjectDetector();
			__detector.options 					= getDetectorOptions( );
			__detector.loadHaarCascades( 		DETECTOR_DATA );
			
			//hook up detection complete
			__detector.addEventListener( 		ObjectDetectorEvent.DETECTION_COMPLETE, handleDetectionComplete );
		}
		
		/**
		 * Detector options factory
		 */
		private function getDetectorOptions():ObjectDetectorOptions
		{
			var _options:ObjectDetectorOptions 	= new ObjectDetectorOptions();
			_options.min_size 					= 25;
			_options.startx 					= ObjectDetectorOptions.INVALID_POS;
			_options.starty 					= ObjectDetectorOptions.INVALID_POS;
			_options.endx 						= ObjectDetectorOptions.INVALID_POS;
			_options.endy 						= ObjectDetectorOptions.INVALID_POS;
			
			return _options;
		}
		
		/**
		 * Initialises the timers
		 */
		private function initTimers():void
		{
			//timer for how often to detect
			__detectionTimer 					= new Timer( DELAY_FACE_DETECT );
			__detectionTimer.addEventListener( 	TimerEvent.TIMER , handleDetectionTimer );
			__detectionTimer.start();
		}
		
		/**
		 * 
		 */
		private function initCamera():void
		{
			var _camera:Camera 					= Camera.getCamera();
			_camera.setMode( 					CAMERA_WIDTH, CAMERA_HEIGHT, CAMERA_FPS);
            
			if ( _camera != null )
			{
				__video 						= new Video( _camera.width , _camera.height ); // take width/height from the camera incase its different
				__video.attachCamera( 			_camera );
			}
			else
			{
				trace( "You need a camera." );
			}
		}
		
		/**
		 * Called when No faces are found after DELAY_IDLE time
		 * - logically this just seems to be if the detector times out, unless it just doesnt bother saying its completed if it cant find any faces?
		 */
		private function handleIdleTimer(e:TimerEvent):void 
		{
			// Assume this means we have to set to 0 manually?
			__detectedCount = 0;
			
			dispatchEvent( new FaceDetectorLiteEvent( FaceDetectorLiteEvent.IDLE, __detectedCount ) );
		}
		
		/**
		 * Evalutates the webcam video for faces on a timer
		 */	
		private function handleDetectionTimer(e:TimerEvent):void 
		{
			__bitmap.bitmapData.draw( 			__video );
			__detector.detect( 					__bitmap );
		}
		
		/**
		 * Fired when a detection is complete
		 */
		private function handleDetectionComplete( e:ObjectDetectorEvent ):void 
		{
			if ( e.rects.length != __detectedCount )
			{
				__detectedCount = e.rects.length;
				
				dispatchEvent( new FaceDetectorLiteEvent( FaceDetectorLiteEvent.DETECTED, __detectedCount ) );
			}
		}
		
		// END OF CLASS
	}
	
}

/*
//==============================================================================
// EOF
//==============================================================================
*/