/**
 * =============================================================================
 * GraphicalFaceDetector
 * - org.i500.projects.faceDetection.GraphicalFaceDetector
 * -----------------------------------------------------------------------------
 * @author 	Justin Roberts
 * @date	11:05 24/01/10
 * -----------------------------------------------------------------------------
 * ChangeLog:
 * ...
 * =============================================================================
 */
package org.i500.projects.faceDetection 
{
	import flash.events.Event;
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
	 * GraphicalFaceDetector
	 * - org.i500.projects.faceDetection.GraphicalFaceDetector
	 */
	public class GraphicalFaceDetector extends Sprite
	{
		//-----------------------------------------------------------
		// Consts
		//
		
		// Detector data
		//
		private 	const 	DETECTOR_DATA 			:String 	= "assets/zip/face.zip";
		
		// Camera settings
		//
		private 	const 	CAMERA_WIDTH 			:int 		= 80;
		private 	const 	CAMERA_HEIGHT 			:int 		= 60;
		private 	const 	CAMERA_FPS	 			:int 		= 30;
		
		//How often to analyze the webcam image & how long a rectangle will remain visible after no faces are found
		// - use 1000/x so we know how many times per second (1000/30 = 33.3 = 30 fps)
		//
		private 	const 	DELAY_FACE_DETECT		:int 		= Math.ceil(1000 / CAMERA_FPS);
		private 	const 	DELAY_IDLE 				:int 		= Math.ceil(1000 / 2);
		
		//-----------------------------------------------------------
		// vars
		//
		
		private 	var 	__detecting				:Boolean	= false;
		private 	var 	__detectedCount			:uint;
		private 	var 	__detector    			:ObjectDetector;
		private 	var 	__rects					:Array;
		private 	var 	__bitmap   				:Bitmap;
		private 	var 	__video 				:Video;
		
		// Timers
		//
		private 	var 	__detectionTimer 		:Timer;
		private 	var 	__idleTimer 			:Timer;
		
		/**
		 * GraphicalFaceDetector
		 * - org.i500.projects.faceDetection.GraphicalFaceDetector
		 */		
		public function GraphicalFaceDetector() 
		{
			super();
			
			addEventListener( Event.ADDED_TO_STAGE, init );
		}
		
		/**
		 * Initialise
		 * @param	e
		 */
		private function init(e:Event):void 
		{
			removeEventListener( Event.ADDED_TO_STAGE, init );
			
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
			_options.min_size 					= 5;
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
			//Timer for rectangles not being found
			__idleTimer 						= new Timer( DELAY_IDLE );
			__idleTimer.addEventListener( 		TimerEvent.TIMER , handleIdleTimer);
			
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
				addChild( 						__video );
			}
			else 
			{
				trace( "You need a camera." );
			}
		}
		
		/**
		 * Called when No faces are found after __noFaceTimeout time
		 */
		private function handleIdleTimer(e:TimerEvent):void 
		{
			__idleTimer.stop();
			
			for (var i : int = 0; i < __rects.length; i++)
			{
				TweenLite.to( __rects[i] , .5, { alpha:0, x:__rects[i].x + __video.x, y:__rects[i].y, ease:Cubic.easeOut } );					
			}
			
			// Assume this means we have to set to 0 manually?
			__detectedCount = 0;
			
			dispatchEvent( new FaceDetectorLiteEvent( FaceDetectorLiteEvent.IDLE, __detectedCount ) );
		}
		
		/**
		 * Evalutates the webcam video for faces on a timer
		 */	
		private function handleDetectionTimer(e:TimerEvent):void 
		{
			if ( __detecting == false )
			{
				__detecting						= true;
				__bitmap.bitmapData.draw( 		__video );
				__detector.detect( 				__bitmap );
			}
			else
			{
				trace( 'Not finished yet' );
			}
		}
		
		/**
		 * Creates a rectangle
		 */
		private function createRect():Sprite
		{
			var rectContainer : Sprite = new Sprite();
			rectContainer.graphics.lineStyle( 2, 0xff0000, 1 );
			rectContainer.graphics.beginFill(0x000000,0);
			rectContainer.graphics.drawRect(0, 0, 100, 100);
			
			return rectContainer;
		}
		
		/**
		 * Fired when a detection is complete
		 */
		private function handleDetectionComplete(event:ObjectDetectorEvent):void 
		{
			// Clear detecting flag
			__detecting						= false;
			
			//no faces found
			if(event.rects.length == 0) return;
			
			//stop the no-face timer and start back up again
			__idleTimer.stop();
			__idleTimer.start();
			
			//Track the change in detection
			if ( event.rects.length != __detectedCount )
			{
				__detectedCount = event.rects.length;
				
				dispatchEvent( new FaceDetectorLiteEvent( FaceDetectorLiteEvent.DETECTED, __detectedCount ) );
			}
			
			//loop through faces found			
			for (var i : int = 0; i < event.rects.length ; i++)
			{
				//create rectangles if needed
				if (__rects[i] == null)
				{
					__rects[i] = createRect();
					addChild(__rects[i]);
				}
				
				//Animate to new size
				TweenLite.to( __rects[i] , .5, { alpha:1, x:event.rects[i].x*__video.scaleX + __video.x, y:event.rects[i].y*__video.scaleY, width:event.rects[i].width*__video.scaleX, height:event.rects[i].height*__video.scaleY, ease:Cubic.easeOut } );
			}
			
			//hide the rest of the rectangles
			if (event.rects.length < __rects.length)
			{
				for (var j : int = event.rects.length; j < __rects.length; j++)
				{
					TweenLite.to( __rects[j] , .5, { alpha:0, x:__rects[j].x, y:__rects[j].y, ease:Cubic.easeOut } );					
				}
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