/**
 * =============================================================================
 * Main_visualiser
 * - .Main_visualiser
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
	import flash.display.StageDisplayState;
	import flash.events.Event;
	import flash.events.NetStatusEvent;
	import flash.events.SyncEvent;
	import flash.events.TimerEvent;
	import flash.filters.BlurFilter;
	import flash.filters.ColorMatrixFilter;
	import flash.net.NetConnection;
	import flash.net.ObjectEncoding;
	import flash.net.SharedObject;
	import flash.ui.Mouse;
	import flash.utils.Timer;
	import org.i500.projects.audioPlayer.AudioPlayer;
	import org.i500.projects.numberGrid.NumberGrid;
	import org.i500.projects.particleField.MaskOverlay;
	import org.i500.projects.particleField.ParticleField;
	
	/**
	 * Main_visualiser
	 * - .Main_visualiser
	 */
	public class Main_visualiser extends MovieClip
	{
		//-----------------------------------------------------------
		// Consts
		//
		
		private const SHARED_OBJECT_PATH	:String								= 'rtmp:/faceDetect';// ; //'rtmp://i-dat-fusion.plymouth.ac.uk/jr'
		private const SHARED_OBJECT_NAME	:String								= 'faceDetection';
		
		private const AUDIO_FILE			:String 							= 'assets/mp3/a mote mix down_loop.mp3';
		private const VOLUME_MAX			:Number 							= 1;
		private const VOLUME_MIN			:Number 							= .1;
		private const VOLUME_DELAY			:Number 							= 5; // seconds to fade in/out
		
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
		
		// Flash comms
		private var __netConnection			:NetConnection;
		private var __sharedObject			:SharedObject;
		
		//UI
		private var __particleField			:ParticleField;
		private var __maskOverlay			:MaskOverlay;
		private var __numberGrid			:NumberGrid;
		
		private var __audio					:AudioPlayer;
		
		/**
		 * Main_visualiser
		 * - .Main_visualiser
		 */		
		public function Main_visualiser() 
		{
			this.stage.displayState 			= StageDisplayState.FULL_SCREEN;
			Mouse.hide();
			
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
			
			// Audio player
			//
			__audio 							= new AudioPlayer();
			__audio.volume 						= 0;
			__audio.load( 						AUDIO_FILE );
			__audio.fadeTo( 					1, 30 ); // Make it fade in over 30 seconds
			
			// Shared object
			//
			__netConnection						= new NetConnection();
			__netConnection.objectEncoding		= ObjectEncoding.AMF0;
			__netConnection.addEventListener(	NetStatusEvent.NET_STATUS, handleNetStatus );
			__netConnection.connect( 			SHARED_OBJECT_PATH );
			//
			__sharedObject						= SharedObject.getRemote( SHARED_OBJECT_NAME, __netConnection.uri );
			__sharedObject.addEventListener(	SyncEvent.SYNC, handleSharedObjectSync );
			__sharedObject.connect(				__netConnection );
			
			// Blur
			//
			__blurTimer							= new Timer( BLUR_DELAY );
			__blurTimer.addEventListener(		TimerEvent.TIMER, handleBlurTimer );
			__blurTimer.start();
		}
		
		private function handleNetStatus(e:NetStatusEvent):void 
		{
			trace( 'handleNetStatus', e.info, e.toString() );
		}
		
		private function handleSharedObjectSync(e:* = null):void 
		{
			if ( __sharedObject.data.detectedCount > 0 )
			{
				__blurPariclesTarget			= BLUR_MAX;
				__blurNumbersTarget				= BLUR_MIN;
				__distanceTarget				= DISTANCE_MAX;
				__darkenTarget					= DARKEN_MAX;
				//
				__audio.fadeTo( 				VOLUME_MIN, VOLUME_DELAY );
			}
			else
			{
				__blurPariclesTarget			= BLUR_MIN;
				__blurNumbersTarget				= BLUR_MAX;
				__distanceTarget				= DISTANCE_MIN;
				__darkenTarget					= DARKEN_MIN;
				//
				__audio.fadeTo( 				VOLUME_MAX, VOLUME_DELAY );
			}
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
		
	}

}

/*
//==============================================================================
// EOF
//==============================================================================
*/