/**
 * =============================================================================
 * FaceDetectorLiteEvent
 * - org.i500.projects.faceDetection.events.FaceDetectorLiteEvent
 * -----------------------------------------------------------------------------
 * @author 	Justin Roberts
 * @date	12:16 25/01/10
 * -----------------------------------------------------------------------------
 * ChangeLog:
 * ...
 * =============================================================================
 */
package org.i500.projects.faceDetection.events 
{
	import flash.events.Event;
	
	/**
	 * FaceDetectorLiteEvent
	 * - org.i500.projects.faceDetection.events.FaceDetectorLiteEvent
	 * ...
	 */
	public class FaceDetectorLiteEvent extends Event 
	{
		//-----------------------------------------------------------
		// Consts
		//
		
		public static const DETECTED	:String 	= 'DETECTED';
		public static const IDLE		:String 	= 'IDLE';
		
		//-----------------------------------------------------------
		// vars
		//
		
		public var detectedCount		:uint 		= 0;
		
		/**
		 * FaceDetectorLiteEvent
		 * - org.i500.projects.faceDetection.events.FaceDetectorLiteEvent
		 * ...
		 */
		public function FaceDetectorLiteEvent(type:String, hasDetected:uint, bubbles:Boolean=false, cancelable:Boolean=false) 
		{ 
			detectedCount = hasDetected;
			
			super(type, bubbles, cancelable);
		} 
		
		/**
		 * clone
		 */
		public override function clone():Event 
		{ 
			return new FaceDetectorLiteEvent(type, detectedCount, bubbles, cancelable);
		} 
		
		/**
		 * enum this bad boy
		 */
		public override function toString():String 
		{ 
			return formatToString("FaceDetectorLiteEvent", "type", "bubbles", "cancelable", "eventPhase"); 
		}
		
	}
	
}

/*
//==============================================================================
// EOF
//==============================================================================
*/