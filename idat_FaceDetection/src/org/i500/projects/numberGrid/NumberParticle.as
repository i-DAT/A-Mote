/**
 * =============================================================================
 * NumberParticle
 * - org.i500.projects.numberGrid.NumberParticle
 * -----------------------------------------------------------------------------
 * @author 	Justin Roberts
 * @date	03:25 25/01/10
 * -----------------------------------------------------------------------------
 * ChangeLog:
 * ...
 * =============================================================================
 */
package org.i500.projects.numberGrid 
{
	import flash.display.MovieClip;
	import flash.text.TextField;
	
	/**
	 * NumberParticle
	 * - org.i500.projects.numberGrid.NumberParticle
	 */
	public class NumberParticle extends MovieClip
	{
		//-----------------------------------------------------------
		// vars
		//
		
		/**
		 * NumberParticle
		 * - org.i500.projects.numberGrid.NumberParticle
		 */
		public function NumberParticle() 
		{
			super();
		}
		
		/**
		 * Finds the label textfield and sets its text
		 */
		public function set label( value:String ):void
		{
			var _label:TextField = this.getChildAt(0) as TextField;
			
			_label.text = String( value );
		}
		
	}

}

/*
//==============================================================================
// EOF
//==============================================================================
*/