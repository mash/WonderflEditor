package net.wonderfl.editor.livecoding {
    import flash.events.*;
    import flash.net.Socket;
    import flash.utils.Timer;
    import flash.system.Security;
    import com.adobe.serialization.json.JSON;
    import com.adobe.serialization.json.JSONDecoder;
    import com.adobe.serialization.json.JSONEncoder;

	[Event(name = 'LiveCodingEvent_JOINED', type = 'net.wonderfl.editor.livecoding.LiveCodingEvent')]
	[Event(name = 'LiveCodingEvent_RELAYED', type = 'net.wonderfl.editor.livecoding.LiveCodingEvent')]
	[Event(name = 'LiveCodingEvent_MEMBERS_UPDATED', type = 'net.wonderfl.editor.livecoding.LiveCodingEvent')]
	[Event(name = 'LiveCodingEvent_CHAT_RECEIVED', type = 'net.wonderfl.editor.livecoding.LiveCodingEvent')]
	[Event(name = 'LiveCodingEvent_ERROR', type = 'net.wonderfl.editor.livecoding.LiveCodingEvent')]
	[Event(name = 'close', type = 'flash.events.Event')]
	[Event(name = 'connect', type = 'flash.events.Event')]
	[Event(name = 'ioError', type = 'flash.events.IOErrorEvent')]
	[Event(name = 'securityError', type = 'flash.events.SecurityErrorEvent')]
    public class SocketBroadCaster extends EventDispatcher implements IBroadCaster {
        private var debug  :Boolean = false;
        private var socket :Socket;
        private var host   :String;
        private var port   :int;
        private var remainingString :String = "";
        

        Security.allowDomain('*');

        public function SocketBroadCaster( _host :String = null, _port :int = 0 ){
            host = _host;
            port = _port;

            socket = new Socket;
            socket.addEventListener( Event.CLOSE,                       dispatchEvent );
            socket.addEventListener( Event.CONNECT,                     dispatchEvent );
            socket.addEventListener( IOErrorEvent.IO_ERROR,             dispatchEvent );
            socket.addEventListener( SecurityErrorEvent.SECURITY_ERROR, dispatchEvent );
            socket.addEventListener( ProgressEvent.SOCKET_DATA,         onSocketData );

            var timer :Timer = new Timer( 30 * 1000 ); // forever
            timer.addEventListener( TimerEvent.TIMER, function( e :Event ) :void {
                if ( socket && socket.connected ) {
                    call( 'ping', null );
                }
            });
            timer.start();
        }

        public function connect( _host :String = null, _port :int = 0 ) :void {
            if ( _host ) { host = _host; }
            if ( _port ) { port = _port; }
            if ( ! host || ! port ) {
                throw('specify host and port');
            }

            socket.connect( host, port );
        }

        public function join(ticket :String ) :void {
            call( 'join', { ticket : ticket } );
        }

        private function call( method :String, args :Object ) :void {
            logger("[call]method: "+method+" args: ",args);

            var obj  :Object = { method : method, args : args };
            var json :String = JSON.encode( obj );
            socket.writeUTFBytes( json+"\n" );
            socket.flush();
        }

        private function onSocketData( e :ProgressEvent ) :void {
            var str :String = socket.readUTFBytes(socket.bytesAvailable);
            logger("[onSocketData]raw: ", e, str);

            var messages :Array = str.split(/\r?\n/);
            for (var i :int = 0, len :int = messages.length;i < len; i++) {
                var obj :Object = parse(messages[i]);
                route( obj );
            }
        }

        // TODO: parseできなかったら、長いjsonの途中かもしれないから、parseできなかった分とっといてあとに回す？
        private function parse( str :String ) :Object {
            if ( !str || str.match(/^\r?\n?$/)) {
                return null;
            }

            remainingString += str;

            var obj :Object;
            try {
                obj = ( new JSONDecoder(remainingString, false) ).getValue();
            } catch(err :Error) {
                logger("failed to parse: " + remainingString + " error: " + err);
                return null;
            }
            remainingString = '';
            return obj;
        }

        private function route( obj :Object ) :void {
            if ( ! obj ) { return; }

            if ( obj.method && (obj.method == 'joined') ) {
                dispatchEvent( new LiveCodingEvent( LiveCodingEvent.JOINED, obj.args ) );
            }
            else if ( ! obj.method && obj.error ) {
                dispatchEvent( new LiveCodingEvent( LiveCodingEvent.ERROR, obj.error ) );
            }
            else if ( obj.method && obj.method == 'members_updated' ) {
                dispatchEvent( new LiveCodingEvent( LiveCodingEvent.MEMBERS_UPDATED, obj.args ) );
            }
            else if ( obj.method && obj.method == 'relay' ) {
                dispatchEvent( new LiveCodingEvent( LiveCodingEvent.RELAYED, obj.args ) );
            }
            else if ( obj.method && obj.method == 'chat' ) {
                dispatchEvent( new LiveCodingEvent( LiveCodingEvent.CHAT_RECEIVED, obj.args ) );
            }
        }

        public function send( command :String, ... args ) :void {
            if ( ! socket || ! socket.connected ) { return; }

            call( 'relay', { command: command, args: args } );
        }

        public function chat( text :String ) :void {
            if ( ! socket || ! socket.connected ) { return; }

            call( 'chat', { text : text } );
        }

        // to notify the end of live coding
        public function close():void {
			if (socket.connected) socket.close();
        }

        private function logger(... args):void {
            //CONFIG::debug { log.apply(null, (new Array("[SocketBroadCaster]")).concat(args)); }
        }
    }
}
