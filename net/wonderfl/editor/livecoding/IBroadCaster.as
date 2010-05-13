package net.wonderfl.editor.livecoding 
{
    import flash.events.IEventDispatcher;
    public interface IBroadCaster extends IEventDispatcher
    {
        function join( room :String, ticket :String ) :void;

        function send( command :String, ... args ) :void;

        // to notify the end of live coding
        function close():void;

        // to connect
        function connect( host :String = null, port :int = 0 ) :void;
    }
}
