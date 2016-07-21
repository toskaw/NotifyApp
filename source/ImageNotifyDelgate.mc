using Toybox.WatchUi as Ui;
using Toybox.Communications as Comm;
using Toybox.System as Sys;
using Toybox.Timer as Timer;

class ImageNotifyDelegate extends Ui.BehaviorDelegate
{
	hidden var popup;
	hidden var timer;
	hidden var popNotify;
	hidden var comm;
	
	function initialize(flag) {
        Ui.BehaviorDelegate.initialize();
        popup = flag;
        comm = null;
        timer = new Timer.Timer();
        if (popup) {
        	timer.start( method(:onTimer), 30000, false );
        }
        popNotify = null;
    }
    function popback(handler) {
    	popNotify = handler;
    }
    
	function onTimer() {
		Sys.println("Notify:onTimer");
		if (popNotify != null) {
			popNotify.invoke();
			popNotify = null;
		}
		if (comm) {
			comm.cancel();
			comm = null;
		}
    	Ui.popView(Ui.SLIDE_IMMEDIATE); 
	}
	
    function onKey(evt) {
        var key = evt.getKey();
        if (comm) {
       		return Ui.BehaviorDelegate.onKey(evt); 
        }
 		if ( key == KEY_ENTER ) {
 			if (popup) {
 				timer.stop();
 				Sys.println("Notify:onKey popout");
				if (popNotify != null) {
					popNotify.invoke();
					popNotify = null;
				}
 			}
 			comm = MyNotifyData.CommNotify(method(:onReceive));
 			return true;
 		}
 	
        return Ui.BehaviorDelegate.onKey(evt); 
    }
    
    function onReceive(size) {
        comm = null;
        if (size > 0) {
        	var index = (MyNotifyData.Index + 1) % size;
        	comm = MyNotifyData.CommImage(index, method(:onReceiveImage));
        }
        Ui.requestUpdate();
    }
    function onReceiveImage(data) {
    	Ui.requestUpdate();
    	comm = null;
	}
	function onNextPage() {
		Sys.println("Notify:onNextPage");
		if (comm != null) {
			comm.cancel();
			comm = null;
		}
		if (popup) {
        	Ui.popView(Ui.SLIDE_IMMEDIATE);
        	timer.stop();
 			if (popNotify != null) {
				popNotify.invoke();
				popNotify = null;
			}
        	return true;
		}
        var view = new Analog();
        var delegate = new NotifyAppDelegate();
        Ui.switchToView(view, delegate, Ui.SLIDE_UP);
        return true;
    }

    function onPreviousPage() {
 		Sys.println("Notify:onPreviousPage");
 		if (comm) {
			comm.cancel();
			comm = null;
		}
    	if (popup) {
        	Ui.popView(Ui.SLIDE_IMMEDIATE);
        	timer.stop();
 			if (popNotify != null) {
				popNotify.invoke();
				popNotify = null;
			}
        	return true;
		}
        var view = new Analog();
        var delegate = new NotifyAppDelegate();
        Ui.switchToView(view, delegate, Ui.SLIDE_DOWN);
  
        return true;
    }
    function onBack() {
 		Sys.println("Notify:onBack");
		if (comm) {
			comm.cancel();
			comm = null;
		}
    	if (popup) {
    	    Ui.popView(Ui.SLIDE_IMMEDIATE);
        	timer.stop();
			if (popNotify != null) {
				popNotify.invoke();
				popNotify = null;
			}
        	return true;
    	}
    	return false;
    }

}
