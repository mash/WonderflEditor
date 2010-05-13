package {
    import flash.display.Sprite;
    import flash.utils.setTimeout;
    
    public class FlashTest extends Sprite {
        public function FlashTest() {
            // write as3 code here..
            setTimeout(function(): void{trace(new Error().getStackTrace())}, 1000);
            
        }
    }
}