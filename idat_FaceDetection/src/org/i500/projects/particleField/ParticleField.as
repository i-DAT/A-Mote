/**
 * =============================================================================
 * ParticleField
 * - org.i500.projects.particleField.ParticleField
 * -----------------------------------------------------------------------------
 * @author 	Justin Roberts
 * @date	01:57 25/01/10
 * -----------------------------------------------------------------------------
 * ChangeLog:
 * ...
 * =============================================================================
 */
package org.i500.projects.particleField 
{
	import com.dangries.bitmapUtilities.*;
	import com.dangries.objects.Particle3D;
	import com.dangries.geom3D.*;
	import com.dangries.display.*;
	//import fl.events.SliderEvent;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.filters.BlurFilter;
	import flash.geom.ColorTransform;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	/**
	 * ParticleField
	 * - org.i500.projects.particleField.ParticleField
	 */
	public class ParticleField extends Sprite
	{
		//-----------------------------------------------------------
		// Consts
		//
		
		private const AMOUNT_BLUR:uint = 2;				// [0..10] : anything higher than 10 doesnt really work
		private const AMOUNT_DARKEN:Number = 0.001;		// [0..1] : lower values means the particles leave longer trails (depending on the blur)
		private const AMOUNT_PARTICLES:uint = 6000;	// [1..10000] : use lower numbers if using low blur & darken
		private const COLOUR:uint = 0xff0000;			// instead of 1 colour try selecting from a pool of nice colours ;p
		
		//-----------------------------------------------------------
		// vars
		//
		
		private var noiseMaker:NoiseParticleMaker;
		private var particles:Array;
		
		private var blur:BlurFilter;
		private var darken:ColorTransform;
		
		private var board:RotatingParticleBoard;
		private var boardRect:Rectangle;
		private var filterPoint:Point;
		
		private var p:Particle3D;
		private var slider1Param:Number;
		private var slider2Param:Number;
		private var slider3Param:Number;
		private var slider4Param:Number;
		
		private var numDestinations:Number;
		
		private var numParticles:Number;
		private var minRecess:Number;
		private var maxRecess:Number;
		
		private var sliderEasing:Number;
		
		private var ax:Number;
		private var ay:Number;
		private var az:Number;
		private var dSquared:Number;
		private var scaledAccelFactor:Number;
		
		/**
		 * ParticleField
		 * - org.i500.projects.particleField.ParticleField
		 */		
		public function ParticleField() 
		{
			super();
			
			addEventListener( Event.ADDED_TO_STAGE, init );
		}
		
		/**
		 * Setter for slider2Param (distance)
		 */
		public function set distance( value:Number ):void
		{
			slider2Param = value;
		}
		
		/**
		 * Setter for slider3Param (darkening)
		 */
		public function set darkening( value:Number ):void
		{
			slider3Param = value;
		}
		
		private function getRandomColour():uint
		{
			var _colours:Array = [0xfefdde, 0xfefec7, 0xfdfeb1, 0xfefa9d, 0xfdef89, 0xfde373, 0xfdd85c, 0xfdcc48, 0xfdc133, 0xfeb41f, 0xfea90a, 0xfb9e00, 0xf29201, 0xe88601, 0xde7b01, 0xd46f01, 0xca6401, 0xc05701, 0xb74c01, 0xad4001, 0xa33401, 0x992801, 0x8f1d01, 0x8f1d01, 0x851102, 0x851814];
			
			return _colours[ Math.floor( Math.random() * _colours.length ) ];
		}
		
		/**
		 * Initialise
		 * @param	e
		 */
		private function init(e:Event):void 
		{
			removeEventListener( Event.ADDED_TO_STAGE, init );
			
			board = new RotatingParticleBoard(stage.stageWidth,stage.stageHeight,true, 0x00000000, 200);
			board.setDepthDarken(0,-50, 2);
			//board.makeFrame(2,0xB83903,1); //JR removed this to remove the outline
			board.holder.x = 0;
			board.holder.y = stage.stageHeight/2 - board.height/2;
			//set the initial rotation:
			board.currentQ = new Quaternion(Math.cos(Math.PI/12), Math.sin(Math.PI/12)/Math.sqrt(2),0,-Math.sin(Math.PI/12)/Math.sqrt(2));
			//set the automatic rotation to use while mouse is not dragging:
			board.autoQuaternion = new Quaternion(Math.cos(Math.PI/300),0,Math.sin(Math.PI/300),0);
			//board.autoQuaternion = new Quaternion(1,0,0,0);
			
			board.arcballRad = Math.sqrt(board.width*board.width + board.height*board.height)/2;
			
			//the following causes the depth darkening settings to be moved
			//along with the "recess" parameter of the RotatingParticleBoard.
			//A positive "recess" parameter moves the origin away from the observer.
			board.moveLightWithRecess = true;
			
			blur = new BlurFilter( AMOUNT_BLUR, AMOUNT_BLUR );
			darken = new ColorTransform(1,1,1, 1 - AMOUNT_DARKEN );
			boardRect = new Rectangle(0,0,board.width,board.height);
			filterPoint = new Point(0,0);
			
			slider1Param = 0.1;
			slider2Param = 0.1;
			slider3Param = 0;
			
			/*
			slider1.value = slider1Param*100;
			slider2.value = slider2Param*100;
			slider3.value = slider3Param*100;
			
			slider3.liveDragging = true;
			*/
			
			//the "easing" value below causes slider values to be updated smoothly.
			sliderEasing = 0.5;
			
			//set the initial light darkening settings
			lightDistanceUpdate();
			
			minRecess = -200;
			maxRecess = 1000;
			
			//add following code to see arcball silhouette:
			/*
			var ballOutline:Shape = new Shape();
			ballOutline.graphics.lineStyle(1,0x888888);
			ballOutline.graphics.drawCircle(0,0,board.arcballRad);
			ballOutline.x = board.width/2;
			ballOutline.y = board.height/2;
			board.holder.addChild(ballOutline);
			*/
			
			createParticles();
		}
		
		/**
		 * The NoiseParticleMaker generates randomly colored
		 * particles of any desired number.  Although the colors are
		 * changed later in the code, this was a convenient way to create
		 * the particles.
		 */
		private function createParticles():void
		{
			noiseMaker = new NoiseParticleMaker( AMOUNT_PARTICLES );
			noiseMaker.addEventListener(NoiseParticleMaker.PARTICLES_CREATED, go);
			noiseMaker.createParticles();
		}
		
		private function go(evt:Event):void
		{
			particles = noiseMaker.particleArray;
			
			//"Destinations" are simply recorded points for each particle
			//that can be used to define movements.
			numDestinations = 1;
			//create destination arrays for each particle
			noiseMaker.buildDestinationArrays(numDestinations);
			
			//set destinations
			setDestinations();
			
			//Here we change the color of the particles, place particles in
			//position 0 and initialize velocity vectors.
			var cParam:Number;
			var r:Number;
			var g:Number;
			var b:Number;
			for (var i:Number = 0; i<= particles.length - 1; i++) {
				p = particles[i];
				p.x = p.dest[0].x;
				p.y = p.dest[0].y;
				p.z = p.dest[0].z;
				
				//The particles are all given the same color.
				//Other options would be to color them randomly, or color them
				//differently according to position, etc.
				
				//p.setColor( COLOUR );
				p.setColor( getRandomColour() );
				
				var vx:Number = p.y*0.02;
				var vy:Number = -p.x*0.02;
				var vz:Number = 0;
				p.vel = new Point3D(vx,vy,vz);
			}
			
			addChild(board.holder);
			
			addEventListener(Event.ENTER_FRAME, onEnter);
			//slider3.addEventListener(SliderEvent.CHANGE, slider3Handler);
		}
		
		private function slider3Handler(evt:Event):void
		{
			lightDistanceUpdate();
		}
		
		private function lightDistanceUpdate():void
		{
			// this needs updating to remove slider3.value
			/*
			var d:Number = Math.pow(0.01*slider3.value,0.2);
			var d2:Number = 0.5*Math.pow(Math.cos(d*Math.PI),3)+0.5
			board.setDepthDarken(70, 64-d2*200, 1);
			*/
		}
		
		private function onEnter(evt:Event):void
		{
			/*
			if (messageTextField.text == "0"
			{
				slider2Param = 1;
				slider3Param = 1;
			}
			
			if (messageTextField.text == "1")
			{
				slider2Param = 0.1;
				slider3Param = 0;
			}
			*/
			
			// this needs updating to remove references to slider1 & silder2
			/*
			slider1Param += sliderEasing*(slider1.value/100 - slider1Param);
			slider2Param += sliderEasing*(slider2.value/100 - slider2Param);
			*/
			
			scaledAccelFactor = (1.33+1.33*slider1Param);
			
			board.recess = minRecess + (slider2Param)*(maxRecess - minRecess);
			
			//update fixed coordinates:
			for (var i:Number = 0; i <= particles.length - 1; i++)
			{
				p = particles[i];
				
				dSquared = p.x*p.x + p.y*p.y + p.z*p.z;
				
				ax = -p.x/(0.000001+dSquared);//*(3*p.lum/255+1);
				ay = -p.y/(0.000001+dSquared);//*(3*p.lum/255+1);
				az = -p.z/(0.000001+dSquared);//*(3*p.lum/255+1);
				
				p.vel.x = (p.vel.x + scaledAccelFactor*ax);
				p.vel.y = (p.vel.y + scaledAccelFactor*ay);
				p.vel.z = (p.vel.z + scaledAccelFactor*az);
				
				p.x += p.vel.x;
				p.y += p.vel.y;
				p.z += p.vel.z;
			}
			
			board.bitmapData.lock();
			
			//apply Filters to effect fade-out of old pixels
			if ( AMOUNT_BLUR > 1 )
			{
				board.bitmapData.applyFilter(board.bitmapData, boardRect, filterPoint, blur);
			}
			
			if ( AMOUNT_DARKEN < 1 )
			{
				board.bitmapData.colorTransform(boardRect, darken);
			}
			
			//draw particles
			board.drawParticles(particles);
			board.bitmapData.unlock()
		}
		
		/**
		 * there are other functions defined below which also can be used to set the initial positions of the particles.
		 */
		private function setDestinations( destination:uint = 2 ):void
		{
			switch( destination )
			{
				case 0:
					setPositionsRandomCube(0);
					break;
				
				case 1:
					setPositionsRandomCylinderZ(0);
					break;
				
				case 2:
				default:
					setPositionsRandomSphere(0);
					break;
				
			}
		}
		
		/**
		 * setPositionsRandomCube
		 * @param	n
		 */
		private function setPositionsRandomCube(n:Number):void
		{
			var s1:Number;
			var s2:Number;
			var s3:Number;
			var shift:int;
			var sArray:Array = [];
			var r = 75;
			for (var t:Number = 0; t <= particles.length - 1; t++)
			{
				p = particles[t];
				s1 = 2*Math.floor(Math.random()*2)-1;
				s2 = 2*Math.random() - 1;
				s3 = 2*Math.random() - 1;
				sArray = [s1, s2, s3];
				shift = Math.floor(Math.random()*3);
				p.dest[n].x = r*sArray[shift];
				p.dest[n].y = r*sArray[(shift + 1) %3];
				p.dest[n].z = r*sArray[(shift + 2) %3];
			}
		}
		
		/**
		 * setPositionsRandomSphere
		 * @param	n
		 */
		private function setPositionsRandomSphere(n:Number):void
		{
			var splitLum:Number = 0;
			var r:Number;
			var theta:Number;
			var phi:Number;
			var sinPhi:Number;
			var cosPhi:Number;
			for (var t:Number = 0; t <= particles.length - 1; t++)
			{
				p = particles[t];
				//r = Math.sqrt(2)*Math.pow(Math.random(),0.0125)*cubeSide/2;
				r = 90;
				//TESTING:
				//r = cubeSide/2;
				theta = Math.random()*Math.PI*2;
				phi = Math.acos(2*Math.random()-1);
				p.dest[n].x = r*Math.sin(phi)*Math.cos(theta);
				p.dest[n].y = r*Math.sin(phi)*Math.sin(theta);
				p.dest[n].z = r*Math.cos(phi);
			}
		}
		
		/**
		 * setPositionsRandomCylinderZ
		 * @param	n
		 */
		private function setPositionsRandomCylinderZ(n:Number):void
		{
			var rad:Number = 70;
			var len:Number = 100;
			var theta:Number;
			for (var t:Number = 0; t <= particles.length - 1; t++)
			{
				p = particles[t];
				theta = Math.random()*2*Math.PI;
				p.dest[n].x = rad*Math.cos(theta);
				p.dest[n].y = rad*Math.sin(theta);
				p.dest[n].z = len*(2*Math.random()-1);
			}
		}
		
		// End of class
	}

}

/*
//==============================================================================
// EOF
//==============================================================================
*/