/**
 * =============================================================================
 * AudioPlayer
 * - org.i500.projects.audioPlayer.AudioPlayer
 * -----------------------------------------------------------------------------
 * @author 	Justin Roberts
 * @date	01:09 26/01/10
 * -----------------------------------------------------------------------------
 * ChangeLog:
 * ...
 * =============================================================================
 */
package org.i500.projects.audioPlayer 
{
	import flash.events.Event;
	import flash.events.SampleDataEvent;
	import flash.media.Sound;
	import flash.net.URLRequest;
	import flash.utils.ByteArray;
	import gs.TweenLite;
	
	/**
	 * AudioPlayer
	 * - org.i500.projects.audioPlayer.AudioPlayer
	 */
	public class AudioPlayer
	{
		//-----------------------------------------------------------
		// Consts
		//
		
		private 	const 	SAMPLE_RATE 		:int 			= 44100;
		private 	const 	OUTPUT_BUFFER 		:int 			= 2048;
		
		//-----------------------------------------------------------
		// vars
		//
		
		private		var		__volume			:Number			= 1;
		
		private 	var 	__file				:String;
		private 	var 	__stream			:URLRequest;
		private 	var 	__input				:Sound;
		private 	var 	__output			:Sound;
		private		var		__audioData			:ByteArray;
		
		/**
		 * AudioPlayer
		 * - org.i500.projects.audioPlayer.AudioPlayer
		 */		
		public function AudioPlayer() 
		{
			//
		}
		
		public function fadeTo( targetVolume:Number, duration:Number ):void
		{
			TweenLite.to( this, duration, { volume: targetVolume } );
		}
		
		public function get volume():Number { return __volume; }
		
		public function set volume(value:Number):void 
		{
			__volume = value;
		}
		
		public function load( url:String ):void
		{
			__file 							= url;
			__stream						= new URLRequest( __file );
			__input							= new Sound();
			__input.addEventListener(		Event.COMPLETE, handleInputComplete );
			__input.load( 					__stream );
		}
		
		private function handleInputComplete(e:Event):void 
		{
			__input.removeEventListener(	Event.COMPLETE, handleInputComplete );
			
			__audioData						= new ByteArray();
			
			var _samplesLoaded:Number		= (__input.length / 1000) * SAMPLE_RATE;
			__input.extract(				__audioData, _samplesLoaded );
			__audioData.position			= 0;
			
			//
			__output						= new Sound();
			__output.addEventListener(		SampleDataEvent.SAMPLE_DATA, handleSampleData );
			__output.play();
		}
		
		private function handleSampleData(e:SampleDataEvent):void 
		{
			var _bytes:ByteArray			= new ByteArray();
			
			for ( var c:int = 0; c < OUTPUT_BUFFER; c++ )
			{
				// loop and hack ... mp3 adds junk data to the ends, so this needs to be trimmed to make it loop properly.
				if ( __audioData.bytesAvailable < 1024*10 )
				{
					__audioData.position	= 1024*10;
				}
				
				e.data.writeFloat( __audioData.readFloat() * __volume );
				e.data.writeFloat( __audioData.readFloat() * __volume );
			}
		}
		
	}

}

/*
//==============================================================================
// EOF
//==============================================================================
*/