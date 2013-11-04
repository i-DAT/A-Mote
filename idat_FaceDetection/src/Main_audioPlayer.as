/**
 * =============================================================================
 * Main_audioPlayer
 * - .Main_audioPlayer
 * -----------------------------------------------------------------------------
 * @author 	Justin Roberts
 * @date	01:34 26/01/10
 * -----------------------------------------------------------------------------
 * ChangeLog:
 * ...
 * =============================================================================
 */
package  
{
	import flash.display.Sprite;
	import org.i500.projects.audioPlayer.AudioPlayer;
	
	
	/**
	 * Main_audioPlayer
	 * - .Main_audioPlayer
	 */
	public class Main_audioPlayer extends Sprite
	{
		//-----------------------------------------------------------
		// vars
		//
		
		private var __audio:AudioPlayer;
		
		/**
		 * Main_audioPlayer
		 * - .Main_audioPlayer
		 */		
		public function Main_audioPlayer() 
		{
			trace( 'Main_audioPlayer' );
			
			__audio = new AudioPlayer();
			__audio.volume = 0;
			__audio.load( 'assets/mp3/a mote mix down_loop.mp3' );
			__audio.fadeTo( 1, 25 );
			
			//__audio.load( 'assets/mp3/test4.mp3' );
			//__audio.load( 'assets/mp3/44.mp3' );
		}
		
	}

}

/*
//==============================================================================
// EOF
//==============================================================================
*/