/**
 * =============================================================================
 * Main_agent
 * - .Main_agent
 * -----------------------------------------------------------------------------
 * @author 	Justin Roberts
 * @date	03:48 02/02/10
 * -----------------------------------------------------------------------------
 * ChangeLog:
 * ...
 * =============================================================================
 */
package  
{
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	import mdm.*;
	
	/**
	 * Main_agent
	 * - .Main_agent
	 */
	public class Main_agent extends Sprite
	{
		//-----------------------------------------------------------
		// Consts
		//
		
		public static const MAINTENANCE_DELAY	:Number			= 1000 * 10;
		public static const APP_DETECTOR		:String			= 'Main_detector.exe';
		public static const APP_VISUALISER		:String			= 'Main_visualiser.exe';
		
		public static const RES_WIDTH			:uint			= 640;
		public static const RES_HEIGHT			:uint			= 480;
		public static const RES_RATE			:uint			= 60;
		
		//-----------------------------------------------------------
		// vars
		//
		
		private var __resolution				:Array;
		private var __processDetector			:Object;
		private var __processVisualiser			:Object;
		private var __maintenanceTimer			:Timer;
		
		/**
		 * Main_agent
		 * - .Main_agent
		 */		
		public function Main_agent() 
		{
			// Modified init sequence to cope with Shell stuff
			//
			if (Application.path == '')
			{
				mdm.Application.init(		this, 					addedHandler );
			}
			else
			{
				addEventListener(			Event.ADDED_TO_STAGE, 	addedHandler );
			}
		}
		
		private function addedHandler(e:Event = null):void 
		{
			removeEventListener(Event.ADDED_TO_STAGE, addedHandler);
			
			// Get resolution
			//
			__resolution = String( mdm.System.getResolution() ).split(',');
			
			// Enable exit hook
			//
			mdm.Application.enableExitHandler()
			mdm.Application.onAppExit = exitHook;
			
			// Set resolution
			//
			mdm.System.setResolution( RES_WIDTH, RES_HEIGHT, RES_RATE );
			
			// Maintenance timer
			//
			__maintenanceTimer = new Timer( MAINTENANCE_DELAY );
			__maintenanceTimer.addEventListener(TimerEvent.TIMER, handleMaintenanceTimer );
			__maintenanceTimer.start();
		}
		
		private function exitHook():void
		{
			// Stop the app trying to re-launch
			//
			__maintenanceTimer.reset();
			__maintenanceTimer.removeEventListener(TimerEvent.TIMER, handleMaintenanceTimer);
			
			// Set resolution
			//
			mdm.System.setResolution( Number(__resolution[0]), Number(__resolution[1]), Number(__resolution[2]) );
			
			//Exits the application
			//
			mdm.Application.exit();
		}
		
		private function handleMaintenanceTimer(e:TimerEvent):void 
		{
			var _isOpen:Boolean;
			
			// Detector
			//
			__processDetector = checkProcess( __processDetector, APP_DETECTOR, 2 );
			
			// Visualiser
			//
			__processVisualiser = checkProcess( __processVisualiser, APP_VISUALISER, 4 );
		}
		
		private function checkProcess( _processId:Object, exe:String, _windowStatus:Number ):Object
		{
			var _isOpen:Boolean;
			
			if ( _processId != null )
			{
				_isOpen = mdm.Process.isOpen( Number( _processId ) );
			}
			
			if ( _processId == null || _isOpen != true )
			{
				_processId = spawnProcess( exe, _windowStatus );
			}
			
			return _processId;
		}
		
		private function spawnProcess( exe:String, _windowStatus:Number ):Object
		{
			trace( "creating process.....", mdm.Application.path 	+ 	exe );
			
			// setup process
			//
			var _name					:String 			= '';											// I'm not sure what this is
			var _xPos					:Number 			= 0;											//
			var _yPos					:Number 			= 0;											//
			var _width					:Number 			= 0;											//
			var _height					:Number 			= 0;											//
			var _appName				:String 			= ''; 											// MUST BE ''
			var _app					:String 			= mdm.Application.path 	+ 	exe;	// 
			var _startInFolder			:String 			= mdm.Application.path;							// Look in same folder
			var _priority				:Number				= 2;											// Normal = 2
			//var _windowStatus			:Number				= 4;											// Maximised = 3
			var _processId				:Object				= mdm.Process.create( 		_name, 
																						_xPos, 
																						_yPos, 
																						_width, 
																						_height, 
																						_appName, 
																						_app, 
																						_startInFolder, 
																						_priority, 
																						_windowStatus );
			//
			
			trace( 'spawnProcess :: _processId =' + _processId );
			
			return _processId;
		}
		
	}

}

/*
//==============================================================================
// EOF
//==============================================================================
*/