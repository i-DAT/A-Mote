/**
 * =============================================================================
 * Main_detector
 * - .Main_detector
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
	import flash.display.StageDisplayState;
	import flash.events.NetStatusEvent;
	import flash.events.SyncEvent;
	import flash.net.NetConnection;
	import flash.net.ObjectEncoding;
	import flash.net.SharedObject;
	import org.i500.projects.faceDetection.events.FaceDetectorLiteEvent;
	import org.i500.projects.faceDetection.GraphicalFaceDetector;
	
	/**
	 * Main_detector
	 * - .Main_detector
	 */
	public class Main_detector extends MovieClip
	{
		//-----------------------------------------------------------
		// Consts
		//
		
		private const SHARED_OBJECT_PATH	:String								= 'rtmp:/faceDetect';// ; //'rtmp://i-dat-fusion.plymouth.ac.uk/jr'
		private const SHARED_OBJECT_NAME	:String								= 'faceDetection';
		
		//-----------------------------------------------------------
		// vars
		//
		
		private var __netConnection			:NetConnection;
		private var __sharedObject			:SharedObject;
		private var __faceDetector			:GraphicalFaceDetector;
		
		/**
		 * Main_detector
		 * - .Main_detector
		 */		
		public function Main_detector() 
		{
			this.stage.displayState 			= StageDisplayState.FULL_SCREEN;
			init();
		}
		
		private function init():void
		{
			// Face detector
			//
			__faceDetector 						= new GraphicalFaceDetector();
			
			__faceDetector.addEventListener( 	FaceDetectorLiteEvent.DETECTED, 	handleDetected );
			__faceDetector.addEventListener( 	FaceDetectorLiteEvent.IDLE, 		handleDetected );
			addChild( 							__faceDetector );
			
			__faceDetector.scaleX				= this.stage.stageWidth / __faceDetector.width;
			__faceDetector.scaleY				= this.stage.stageHeight / __faceDetector.height;
			
			// Shared object
			//
			__netConnection						= new NetConnection();
			__netConnection.objectEncoding		= ObjectEncoding.AMF0;
			__netConnection.addEventListener(	NetStatusEvent.NET_STATUS, handleNetStatus );
			__netConnection.connect( 			SHARED_OBJECT_PATH );
			//
			__sharedObject						= SharedObject.getRemote( SHARED_OBJECT_NAME, __netConnection.uri );
			__sharedObject.connect(				__netConnection );
		}
		
		private function handleNetStatus(e:NetStatusEvent):void 
		{
			trace( 'handleNetStatus', e.info, e.toString() );
		}
		
		private function handleDetected(e:FaceDetectorLiteEvent):void 
		{
			trace( 'handleDetected', e.detectedCount );
			
			// Update shared object
			//
			__sharedObject.data.detectedCount = e.detectedCount;
			__sharedObject.setDirty( 'detectedCount' );
		}
		
	}

}

/*
//==============================================================================
// EOF
//==============================================================================
*/