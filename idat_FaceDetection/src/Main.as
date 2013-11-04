/**
 * =============================================================================
 * Main
 * - .Main
 * -----------------------------------------------------------------------------
 * @author 	Justin Roberts
 * @date	12:02 25/01/10
 * -----------------------------------------------------------------------------
 * ChangeLog:
 * ...
 * =============================================================================
 */
package  
{
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.TimerEvent;
	import flash.filters.BlurFilter;
	import flash.filters.ColorMatrixFilter;
	import flash.utils.Timer;
	import org.i500.projects.faceDetection.events.FaceDetectorLiteEvent;
	import org.i500.projects.faceDetection.GraphicalFaceDetectorLite;
	import org.i500.projects.faceDetection.NonGraphicalFaceDetectorLite;
	import org.i500.projects.numberGrid.NumberGrid;
	import org.i500.projects.particleField.MaskOverlay;
	import org.i500.projects.particleField.ParticleField;
	
	/**
	 * Main
	 * - .Main
	 */
	public class Main extends MovieClip
	{
		//-----------------------------------------------------------
		// Consts
		//
		
		private const BLUR_INCREMENT		:Number 							= .1;
		private const BLUR_DELAY			:Number 							= 1000 / 30;
		private const BLUR_MAX				:uint 								= 20;
		private const BLUR_MIN				:uint 								= 1; // make it always blur a little or theres a noticable jump
		
		private const DISTANCE_INCREMENT	:Number 							= .05;
		private const DISTANCE_MAX			:Number 							= 1;
		private const DISTANCE_MIN			:Number 							= .1;
		
		private const DARKEN_INCREMENT		:Number 							= .01;
		private const DARKEN_MAX			:Number 							= 1;
		private const DARKEN_MIN			:Number 							= 0;
		
		//-----------------------------------------------------------
		// vars
		//
		
		private var __distance				:Number								= DISTANCE_MIN;
		private var __distanceTarget		:Number								= DISTANCE_MIN;
		
		private var __darken				:Number								= DARKEN_MIN;
		private var __darkenTarget			:Number								= DARKEN_MIN;
		
		private var __blurNumbers			:Number								= BLUR_MIN;
		private var __blurNumbersTarget		:Number								= BLUR_MIN;
		
		private var __blurParicles			:Number								= BLUR_MIN;
		private var __blurPariclesTarget	:Number								= BLUR_MIN;
		
		private var __blurTimer				:Timer;
		
		private var __faceDetector			:GraphicalFaceDetectorLite;
		private var __particleField			:ParticleField;
		private var __maskOverlay			:MaskOverlay;
		private var __numberGrid			:NumberGrid;
		
		/**
		 * Main
		 * - .Main
		 */		
		public function Main() 
		{
			init();
		}
		
		private function init():void
		{
			// Particle field
			//
			__particleField						= new ParticleField();
			addChild( 							__particleField );
			
			// Number grid
			//
			__numberGrid						= new NumberGrid();
			__numberGrid.blendMode				= 'screen';
			addChild( 							__numberGrid );
			
			// Mask overlay
			//
			__maskOverlay						= new MaskOverlay();
			addChild( 							__maskOverlay );
			
			// Face detector
			//
			__faceDetector 						= new GraphicalFaceDetectorLite();
			__faceDetector.addEventListener( 	FaceDetectorLiteEvent.DETECTED, 	handleDetected );
			__faceDetector.addEventListener( 	FaceDetectorLiteEvent.IDLE, 		handleDetected );
			addChild( 							__faceDetector );
			
			// Blur
			//
			__blurTimer							= new Timer( BLUR_DELAY );
			__blurTimer.addEventListener(		TimerEvent.TIMER, handleBlurTimer );
			__blurTimer.start();
		}
		
		private function handleBlurTimer(e:TimerEvent):void 
		{
			var _blurFilter:BlurFilter;
			
			__blurNumbers						+= ( __blurNumbersTarget - __blurNumbers ) 		* BLUR_INCREMENT;
			__blurParicles						+= ( __blurPariclesTarget - __blurParicles ) 	* BLUR_INCREMENT;
			__distance							+= ( __distanceTarget - __distance ) 			* DISTANCE_INCREMENT;
			__darken							+= ( __darkenTarget - __darken ) 				* DARKEN_INCREMENT;
			
			__particleField.distance			= __distance;
			__particleField.darkening			= __darken;
			
			if ( __blurNumbers > 0 )
			{
				_blurFilter 					= new BlurFilter( __blurNumbers, __blurNumbers, 3 );
				__numberGrid.filters 			= [ _blurFilter ];
			}
			else
			{
				__numberGrid.filters 			= [];
			}
			
			if ( __blurParicles > 0 )
			{
				_blurFilter 					= new BlurFilter( __blurParicles, __blurParicles, 3 );
				__particleField.filters 		= [ _blurFilter ];
			}
			else
			{
				__particleField.filters 			= [];
			}
		}
		
		private function handleDetected(e:FaceDetectorLiteEvent):void 
		{
			trace( 'handleDetected', e.detectedCount );
			
			if ( e.detectedCount > 0 )
			{
				__blurPariclesTarget			= BLUR_MAX;
				__blurNumbersTarget				= BLUR_MIN;
				__distanceTarget				= DISTANCE_MAX;
				__darkenTarget					= DARKEN_MAX;
			}
			else
			{
				__blurPariclesTarget			= BLUR_MIN;
				__blurNumbersTarget				= BLUR_MAX;
				__distanceTarget				= DISTANCE_MIN;
				__darkenTarget					= DARKEN_MIN;
			}
		}
		
	}

}

/*
//==============================================================================
// EOF
//==============================================================================
*/