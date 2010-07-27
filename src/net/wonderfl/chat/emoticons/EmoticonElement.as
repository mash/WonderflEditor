package net.wonderfl.chat.emoticons 
{
	import flash.display.Sprite;
	import flash.events.IOErrorEvent;
	import flash.net.URLRequest;
	import flash.text.engine.ElementFormat;
	import flash.text.engine.GraphicElement;
	import flash.text.engine.TextBaseline;
	import net.wonderfl.font.FontSetting;
	import net.wonderfl.utils.bind;
	import org.bytearray.gif.player.GIFPlayer;
	/**
	 * ...
	 * @author kobayashi-taro
	 */
	public class EmoticonElement extends Sprite
	{
		private static const EMOTICON_LIST:Object = { "yes":"emoticon-0148-yes.gif", "drunk":"emoticon-0175-drunk.gif", "puke":"emoticon-0119-puke.gif", "bigsmile":"emoticon-0102-bigsmile.gif", "handshake":"emoticon-0150-handshake.gif", "crying":"emoticon-0106-crying.gif", "mmm":"emoticon-0125-mmm.gif", "wink":"emoticon-0105-wink.gif", "coffee":"emoticon-0162-coffee.gif", "wondering":"emoticon-0112-wondering.gif", "talking":"emoticon-0117-talking.gif", "middlefinger":"emoticon-0173-middlefinger.gif", "dance":"emoticon-0169-dance.gif", "muscle":"emoticon-0165-muscle.gif", "sun":"emoticon-0157-sun.gif", "skype":"emoticon-0151-skype.gif", "blush":"emoticon-0111-blush.gif", "myspace":"emoticon-0186-myspace.gif", "dull":"emoticon-0114-dull.gif", "shake":"emoticon-0145-shake.gif", "toivo":"emoticon-0177-toivo.gif", "time":"emoticon-0158-time.gif", "ninja":"emoticon-0170-ninja.gif", "inlove":"emoticon-0115-inlove.gif", "fubar":"emoticon-0181-fubar.gif", "clapping":"emoticon-0137-clapping.gif", "emo":"emoticon-0147-emo.gif", "makeup":"emoticon-0135-makeup.gif", "smoke":"emoticon-0176-smoke.gif", "mooning":"emoticon-0172-mooning.gif", "sweating":"emoticon-0107-sweating.gif", "worried":"emoticon-0124-worried.gif", "sleepy":"emoticon-0113-sleepy.gif", "party":"emoticon-0123-party.gif", "itwasntme":"emoticon-0122-itwasntme.gif", "wait":"emoticon-0133-wait.gif", "heidy":"emoticon-0185-heidy.gif", "hi":"emoticon-0128-hi.gif", "rain":"emoticon-0156-rain.gif", "devil":"emoticon-0130-devil.gif", "giggle":"emoticon-0136-giggle.gif", "tongueout":"emoticon-0110-tongueout.gif", "no":"emoticon-0149-no.gif", "bear":"emoticon-0134-bear.gif", "swear":"emoticon-0183-swear.gif", "kiss":"emoticon-0109-kiss.gif", "movie":"emoticon-0160-movie.gif", "headbang":"emoticon-0179-headbang.gif", "rock":"emoticon-0178-rock.gif", "punch":"emoticon-0146-punch.gif", "music":"emoticon-0159-music.gif", "flower":"emoticon-0155-flower.gif", "drink":"emoticon-0168-drink.gif", "nod":"emoticon-0144-nod.gif", "star":"emoticon-0171-star.gif", "envy":"emoticon-0132-envy.gif", "whew":"emoticon-0141-whew.gif", "sadsmile":"emoticon-0101-sadsmile.gif", "angel":"emoticon-0131-angel.gif", "speechless":"emoticon-0108-speechless.gif", "bow":"emoticon-0139-bow.gif", "brokenheart":"emoticon-0153-brokenheart.gif", "smile":"emoticon-0100-smile.gif", "pizza":"emoticon-0163-pizza.gif", "angry":"emoticon-0121-angry.gif", "cool":"emoticon-0103-cool.gif", "beer":"emoticon-0167-beer.gif", "bug":"emoticon-0180-bug.gif", "nerd":"emoticon-0126-nerd.gif", "thinking":"emoticon-0138-thinking.gif", "cake":"emoticon-0166-cake.gif", "mail":"emoticon-0154-mail.gif", "yawn":"emoticon-0118-yawn.gif", "call":"emoticon-0129-call.gif", "rofl":"emoticon-0140-rofl.gif", "heart":"emoticon-0152-heart.gif", "smirk":"emoticon-0143-smirk.gif", "doh":"emoticon-0120-doh.gif", "lipssealed":"emoticon-0127-lipssealed.gif", "tmi":"emoticon-0184-tmi.gif", "phone":"emoticon-0161-phone.gif", "poolparty":"emoticon-0182-poolparty.gif", "evilgrin":"emoticon-0116-evilgrin.gif", "happy":"emoticon-0142-happy.gif", "cash":"emoticon-0164-cash.gif", "bandit":"emoticon-0174-bandit.gif" };
		private var _graphic:GraphicElement;
		
		public function EmoticonElement($iconName:String, $elementFormat:ElementFormat) 
		{
			var player:GIFPlayer = new GIFPlayer;
			mouseChildren = mouseEnabled = false;
			player.load(new URLRequest("net/wonderfl/emoticons/" + EMOTICON_LIST[$iconName]));
			player.addEventListener(IOErrorEvent.IO_ERROR, bind(trace, [$iconName]));
			//player.scaleX = player.scaleY = FontSetting.LINE_HEIGHT / 19;
			player.x = 3;
			addChild(player);
			
			var elf:ElementFormat = $elementFormat.clone();
			elf.dominantBaseline = TextBaseline.IDEOGRAPHIC_CENTER;
			
			_graphic = new GraphicElement(player, player.x * 2 + FontSetting.LINE_HEIGHT, FontSetting.LINE_HEIGHT, elf);
		}
		
		public function get graphic():GraphicElement { return _graphic; }
		public static function isValidEmoticon($iconName:String):Boolean {
			//return false;
			return Boolean(EMOTICON_LIST[$iconName]);
		}
	}
}