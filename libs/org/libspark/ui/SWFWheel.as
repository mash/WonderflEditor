/**
 * SWFWheel - remove dependencies of mouse wheel on each browser.
 *
 * Copyright (c) 2008 - 2010 Spark project (www.libspark.org)
 *
 * Dual licensed under the MIT (MIT-LICENSE.txt)
 * and GPL (GPL-LICENSE.txt) licenses.
 */
package org.libspark.ui
{
    import flash.display.DisplayObject;
    import flash.display.InteractiveObject;
    import flash.display.Stage;
    import flash.events.MouseEvent;
    import flash.external.ExternalInterface;
    import flash.geom.Point;
    import flash.system.Capabilities;

    /**
     *
     */
    public class SWFWheel
    {
        public static const VERSION:String = '1.5 RC2';
        public static const STATE_NATIVE:int = 0;
        public static const STATE_IF_NEEDED:int = 1;
        public static const STATE_HACKED:int = 2;

        public static const EXECUTE_LIBRARY_FUNCTION:String = "SWFWheel.join";
        public static const GET_STATE_FUNCTION:String = "SWFWheel.getState";
        public static const DEFINE_LIBRARY_FUNCTION:String = "function(){if(window.SWFWheel)return;var win=window,doc=document,nav=navigator;var SWFWheel=window.SWFWheel=function(id){this.setUp(id);if(SWFWheel.browser.msie)this.bind4msie();else this.bind()};SWFWheel.prototype={setUp:function(id){var el=SWFWheel.retrieveObject(id);if(el.nodeName.toLowerCase()=='embed'||SWFWheel.browser.safari)el=el.parentNode;this.target=el;this.eventType=SWFWheel.browser.mozilla?'DOMMouseScroll':'mousewheel'},bind:function(){this.target.addEventListener(this.eventType,function(evt){var target,name,delta=0;if(/XPCNativeWrapper/.test(evt.toString())){var k=evt.target.getAttribute('id')||evt.target.getAttribute('name');if(!k)return;target=SWFWheel.retrieveObject(k)}else{target=evt.target}name=target.nodeName.toLowerCase();if(name!='object'&&name!='embed')return;if(!target.checkBrowserScroll()){evt.preventDefault();evt.returnValue=false}if(!target.triggerMouseEvent)return;switch(true){case SWFWheel.browser.mozilla:delta=-evt.detail;break;case SWFWheel.browser.opera:delta=evt.wheelDelta/40;break;default:delta=evt.wheelDelta/80;break}target.triggerMouseEvent(delta,evt.ctrlKey,evt.altKey,evt.shiftKey)},false)},bind4msie:function(){var _wheel,_unload,target=this.target;_wheel=function(){var evt=win.event,delta=0,name=evt.srcElement.nodeName.toLowerCase();if(name!='object'&&name!='embed')return;if(!target.checkBrowserScroll())evt.returnValue=false;if(!target.triggerMouseEvent)return;delta=evt.wheelDelta/40;target.triggerMouseEvent(delta,evt.ctrlKey,evt.altKey,evt.shiftKey)};_unload=function(){target.detachEvent('onmousewheel',_wheel);win.detachEvent('onunload',_unload)};target.attachEvent('onmousewheel',_wheel);win.attachEvent('onunload',_unload)}};SWFWheel.browser=(function(){var ua=nav.userAgent.toLowerCase(),pl=nav.platform.toLowerCase(),version,pv=[0,0,0];if(nav.plugins&&nav.plugins['Shockwave Flash']){version=nav.plugins['Shockwave Flash'].description.replace(/^.*\\s+(\\S+\\s+\\S+$)/,'$1');pv[0]=parseInt(version.replace(/^(.*)\\..*$/,'$1'),10);pv[1]=parseInt(version.replace(/^.*\\.(.*)\\s.*$/,'$1'),10);pv[2]=/[a-z-A-Z]/.test(version)?parseInt(version.replace(/^.*[a-zA-Z]+(.*)$/,'$1'),10):0}else if(win.ActiveXObject){try{var axo=new ActiveXObject('ShockwaveFlash.ShockwaveFlash');if(axo){version=axo.GetVariable('$version');if(version){version=version.split(' ')[1].split(',');pv[0]=parseInt(version[0],10);pv[1]=parseInt(version[1],10);pv[2]=parseInt(version[2],10)}}}catch(e){}}return{win:pl?/win/.test(pl):/win/.test(ua),mac:pl?/mac/.test(pl):/mac/.test(ua),playerVersion:pv,version:(ua.match(/.+(?:rv|it|ra|ie)[\/:\\s]([\\d.]+)/)||[0,'0'])[1],chrome:/chrome/.test(ua),stainless:/stainless/.test(ua),safari:/webkit/.test(ua)&&!/(chrome|stainless)/.test(ua),opera:/opera/.test(ua),msie:/msie/.test(ua)&&!/opera/.test(ua),mozilla:/mozilla/.test(ua)&&!/(compatible|webkit)/.test(ua)}})();SWFWheel.join=function(id){var t=setInterval(function(){if(SWFWheel.retrieveObject(id)){clearInterval(t);new SWFWheel(id)}},0)};SWFWheel.getState=function(id){var STATE_HACKED=2,STATE_IF_NEEDED=1,STATE_NATIVE=0,br=SWFWheel.browser,fp=br.playerVersion;if(br.mac){if(fp[0]>=10&&fp[1]>=1){if(br.safari||br.stainless)return STATE_NATIVE;else if(br.chrome)return STATE_IF_NEEDED;else return STATE_HACKED}else{return STATE_HACKED}}if(!(fp[0]>=10&&fp[1]>=1)&&SWFWheel.browser.safari)return STATE_HACKED;var el=SWFWheel.retrieveObject(id),name=el.nodeName.toLowerCase(),wmode='';if(name=='object'){var k,param,params=el.getElementsByTagName('param'),len=params.length;for(var i=0;i<len;i++){param=params[i];if(param.parentNode!=el)continue;k=param.getAttribute('name');wmode=param.getAttribute('value')||'';if(/wmode/i.test(k))break}}else if(name=='embed'){var wmode=el.getAttribute('wmode')||''}if(br.msie){if(/transparent/i.test(wmode))return STATE_HACKED;else if(/opaque/i.test(wmode))return STATE_IF_NEEDED;else return STATE_NATIVE}else{if(/opaque|transparent/i.test(wmode))return STATE_HACKED;else return STATE_NATIVE}};SWFWheel.retrieveObject=function(id){var el=doc.getElementById(id);if(!el){var nodes=doc.getElementsByTagName('embed'),len=nodes.length;for(var i=0;i<len;i++){if(nodes[i].getAttribute('name')==id){el=nodes[i];break}}}return el}}";

        private static var _stage:Stage;
        private static var _state:int;
        private static var _browserScroll:Boolean = true;

        /**
         *  initialize the SWFWheel hack.
         *
         *  @param stage                Stage object.
         */
        public static function initialize(stage:Stage):void
        {
            if (!available || isReady) return;

            _stage = stage;

            // define javascript library.
            ExternalInterface.call(DEFINE_LIBRARY_FUNCTION);
            // start light hack.
            ExternalInterface.call(EXECUTE_LIBRARY_FUNCTION, ExternalInterface.objectID);
            ExternalInterface.addCallback('checkBrowserScroll', checkBrowserScroll);
            // get runtime state.
            _state = ExternalInterface.call(GET_STATE_FUNCTION, ExternalInterface.objectID);
            // prevent process if no need hack.
            if(_state == STATE_NATIVE) return;
            //  start deep hack.
            ExternalInterface.addCallback('triggerMouseEvent', triggerMouseEvent);
        }

        /**
         *
         *  @return bool        if already initialized, this property is true. otherwize it is false.
         */
        public static function get isReady():Boolean
        {
            return _stage != null;
        }

        /**
         *
         *  @return bool        if SWFWheel is available, this property is true. otherwite it is false.
         */
        public static function get available():Boolean
        {
            var f:Boolean = false;

            if (!ExternalInterface.available) return f;

            try
            {
                f = Boolean(ExternalInterface.call("function(){return true;}"));
            }
            catch (e:Error)
            {
                //  FIXME: should show full stack trace?
                //trace(e.getStackTrace());
                trace("Warning: turn off SWFWheel because can't access external interface.");
            }
            return f;
        }

        /**
         *  @return bool        ckeck current runtime state.
         */
        public static function get state():int
        {
            return _state;
        }

        /**
         *
         *  @return bool        if be allowed browser scrolling, this property is true, otherwise it is false.
         */
        public static function get browserScroll():Boolean
        {
            return _browserScroll;
        }

        /**
         *
         *  @param value            specified broswer scrolling.
         */
        public static function set browserScroll(value:Boolean):void
        {
            _browserScroll = value;
        }

        /**
         *  will execute when dispatch `mouse wheel` event on swf content layer.
         *
         *  @param  delta           mouse wheel delta.
         *  @param  ctrlKey         if ctrl key pressed return true, otherwise false.
         *  @param  altKey          if alt key pressed return true, otherwise false.
         *  @param  shiftKey        if shift key pressed return true, otherwise false.
         */
        private static function triggerMouseEvent(delta:Number, ctrlKey:Boolean, altKey:Boolean, shiftKey:Boolean):void
        {
            // prevent process if ignore case.
            if (_state == STATE_NATIVE) return;
            if (_state == STATE_IF_NEEDED && _browserScroll) return;
            //  retrieve target object.
            var targets:Array = _stage.getObjectsUnderPoint(new Point(_stage.mouseX,
                                                                      _stage.mouseY));
            var tmp:DisplayObject = targets.pop() as DisplayObject;
            //  search deepest target.
            var target:InteractiveObject;
            while (tmp != null) {
                target = tmp as InteractiveObject;
                if (target) break;
                tmp = tmp.parent;
            }
            //  prevent process if can't find target.
            if (!target) return;
            //  create event.
            var event:MouseEvent = new MouseEvent(
                    MouseEvent.MOUSE_WHEEL,
                    true,
                    false,
                    target.mouseX,
                    target.mouseY,
                    null,                   // related object is only over and out.
                    ctrlKey,
                    altKey,
                    shiftKey,
                    false,                  // dirty...
                    int(delta)
                );
            //  trigger event.
            target.dispatchEvent(event);
        }

        /**
         *  will execute when dispatch `mouse wheel` event on swf content layer.
         *
         *  @return bool
         */
        private static function checkBrowserScroll():Boolean
        {
            return _browserScroll;
        }
    }
}