package sound {
	
	import flash.events.Event;
	import flash.media.Sound;
import flash.media.SoundChannel;
import flash.media.SoundChannel;
	import flash.media.SoundTransform;
	import flash.utils.Dictionary;
	
	public class SoundsManager {
		
		public static var on:Boolean = true;
		
		private static const soundChannels:Dictionary = new Dictionary();
		private static const instances:Dictionary = new Dictionary();
		
		private static function playSound(snd:Sound):SoundChannel {
			var sc:SoundChannel = soundChannels[snd];
			if (!sc) {
				sc = snd.play();
				soundChannels[snd] = sc;
				const soundComplete:Function = function(event:Event):void {
					sc.removeEventListener(Event.SOUND_COMPLETE, soundComplete);
					delete soundChannels[snd];
				};
				sc.addEventListener(Event.SOUND_COMPLETE, soundComplete);
			}
			return sc;
		}
		
		private static function playStratifySound(snd:Sound, infinityLoop:Boolean):SoundChannel {
			var sc:SoundChannel = soundChannels[snd];
			if (sc) {
				sc.stop();
			}

			sc = snd.play();
			if (infinityLoop) {
				const soundComplete:Function = function(event:Event):void {
					if (soundChannels[snd]) {
						delete soundChannels[snd];
					}
					soundChannels[snd] = snd.play();
					soundChannels[snd].addEventListener(Event.SOUND_COMPLETE, soundComplete);
				};
				sc.addEventListener(Event.SOUND_COMPLETE, soundComplete);
			}
			soundChannels[snd] = sc;
			return sc;
		}
		
		private static function getSoundInstance(soundClass:Class):Sound {
			var snd:Sound = instances[soundClass];
			if (!snd) {
				snd = new soundClass();
				instances[soundClass] = snd;
			}
			return snd;
		}
		
		//--------------------------------------------------------------------------
		//
		//  Public Functions
		//
		//--------------------------------------------------------------------------
		
		public static function playSoundByName(soundClass:Class, stratify:Boolean = true, infinityLoop:Boolean = false):void {
			if (!on) return;
			const snd:Sound = getSoundInstance(soundClass);
			if (!snd) return;
			if (stratify) {
				playStratifySound(snd, infinityLoop);
			} else {
				playSound(snd);
			}
		}
		
		public static function stopSoundByName(soundClass:Class):void {
			if (!soundClass) return;
			const soundInstance:Sound = getSoundInstance(soundClass);
			const sc:SoundChannel = soundChannels[soundInstance];
			if (sc) sc.stop();
		}
		
		public static function stopAllSounds():void {
			for each (var soundChannel:SoundChannel in soundChannels) {
				soundChannel.stop();
			}
		}
		
		public static function muteAllSounds():void {
			on = false;
			var st:SoundTransform = new SoundTransform(0);
			for each (var sc:SoundChannel in soundChannels) {
				if (!sc) continue;
				sc.soundTransform = st;
			}
		}
		
		public static function unmuteAllSounds():void {
			on = true;
			var st:SoundTransform = new SoundTransform(1);
			for each (var sc:SoundChannel in soundChannels) {
				sc.soundTransform = st;
			}
		}
	}
}
