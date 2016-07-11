using Toybox.Application as App;
using Toybox.WatchUi as Ui;
using Toybox.Communications as Comm;
using Toybox.Timer as Timer;
using Toybox.System as Sys;
using Toybox.Attention as Attention;

class NotifyAppApp extends App.AppBase {
	var connected = false;
	var timer;
	var popup;
	var comm;
	var vibrateData = [
    	new Attention.VibeProfile(  25, 50 ),
        new Attention.VibeProfile(  50, 50 ),
        new Attention.VibeProfile(  75, 50 ),
        new Attention.VibeProfile( 100, 50 ),
        new Attention.VibeProfile(  75, 50 ),
        new Attention.VibeProfile(  50, 50 ),
        new Attention.VibeProfile(  25, 50 )
    ];
	
    function initialize() {
        AppBase.initialize();
        Comm.setMailboxListener( method(:onMail) );
        timer = new Timer.Timer();
        checkConnect();
        popup = false;
        comm = null;
        var set = Sys.getDeviceSettings();
        MyNotifyData.width = set.screenWidth;
        MyNotifyData.height = set.screenHeight;
	}

	function onCheckConnect(responseCode, data) {
		if( responseCode == 200 ) {
			connected = true;
			timer.stop();
 		}
	}
	
	function checkConnect() {
		if (connected) {
			return;
		}
		
	    if (Sys.getDeviceSettings().phoneConnected) {
    		Comm.makeJsonRequest(
				"http://127.0.0.1:8080/",
				{"regist" => "19A65F9191F0471E8AF86C0E1B93D68A"},
				{
            		"Content-Type" => Comm.REQUEST_CONTENT_TYPE_URL_ENCODED
            	},
            	method(:onCheckConnect)
        	);	
        }
        else {
         	timer.start( method(:checkConnect), 10000, false );
        } 
	}
	
    //! onStart() is called on application start up
    function onStart() {
    }

    //! onStop() is called when your application is exiting
    function onStop() {
    }

    //! Return the initial view of your application here
    function getInitialView() {
        return [ new Analog(), new NotifyAppDelegate() ];
    }
    
    function onMail(mailIter)
    {
    	var mail;
    	if (comm) {
    		Sys.println("busy");
    		mail = mailIter.next();
    		while(mail != null) {
    			mail = mailIter.next();
    		}
    		Comm.emptyMailbox();
    		return;
    	}
     	Sys.println("onMail");
    	comm = MyNotifyData.CommNotify(method(:onReceive));
    	mail = mailIter.next();
    	while (mail != null) {
        	mail = mailIter.next();
        }
        Comm.emptyMailbox();
    }
    
    function onReceive(size) {
       if (size > 0 && !popup) {
        	var view = new ImageNotifyView(true);
        	var delegate = new ImageNotifyDelegate(true);
        	Sys.println("PopUP");
        	popup = true;
        	delegate.popback(method(:onPopout));
        	Ui.pushView(view, delegate, Ui.SLIDE_IMMEDIATE);
 		}
        comm = null;                
        if (popup) {
        	if (size > 0) {
        		comm = MyNotifyData.CommImage(0, method(:onImage));
        	}
        	Ui.requestUpdate();
        }
        
    }
    
    function onImage(data) {
       	if (popup) {
       	    Sys.println("vibrate");       	
    		Attention.vibrate( vibrateData );
    		Ui.requestUpdate();    		
    	}    
    	comm = null;
    }
    
    function onPopout() {
    	Sys.println("popout");
    	popup = false;
    }
}

module MyNotifyData {
	var bitmap = null;
	var NotifyNum = 0;
	var Index = -1;
	var status = -1;
	var width;
	var height;
	
    hidden var paletteTEST=[
    	0x000000, 
     	0x555555,
    	0xAAAAAA,
	   	0xFFFFFF
    ];	

	function CommNotify(callback) {
		var com = new myCom();
		com.RequestNotify(callback);
		return com;
	}
	
	function CommImage(index, callback) {
		var com = new myCom();
		com.RequestImage(index, callback);
		return com;
	}
	
	class myCom {
		var callback;
		var id;
		
		function cancel() {
			callback = null;
		}
		
		function onNotifyNum(responseCode, data) {
        	if( responseCode == 200 ) {
        		if (NotifyNum != data["count"].toNumber()) {
        			NotifyNum = data["count"].toNumber();
        			Index = -1;
        			if (NotifyNum == 0) {
        				bitmap = null;
        				status = -1;
        			}
        		}
        		if (callback != null) {
        			callback.invoke(NotifyNum);
        		}
        	}
        	else {
        		NotifyNum = 0;
        		status = -1;
        		bitmap = null;
        		Index = -1;
        		if (callback != null) {
        			callback.invoke(NotifyNum);
        		}
        	}
		}
		function onImageRecive(responseCode, data) {
        	if( responseCode == 200 ) {
        		status = 1;
        		bitmap = data;
        		Index = id;
        	}
        	else {
        		NotifyNum = 0;
        		bitmap = null;
        		status = -1;
        		Index = -1;
          	}
          	Sys.println("onImage");
          	if (callback != null) {
           		Sys.println("callback-1");
          		callback.invoke(bitmap);
            	Sys.println("callback-2");
          	}
		} 
		function initialize() {
		}
		function RequestNotify(cb) {
			callback = cb;
    		Comm.makeJsonRequest(
				"http://127.0.0.1:8080/",
				{},
				{
            		"Content-Type" => Comm.REQUEST_CONTENT_TYPE_URL_ENCODED
            	},
            	method(:onNotifyNum)
        	);
		}
		function RequestImage(index, cb) {
          	Sys.println("ReqImage 1");
			callback = cb;
			id = index;
			Index = id;
			status = 0;
           	Sys.println("ReqImage 2");
        	Comm.makeImageRequest(
            	"http://127.0.0.1:8080/",
				{"id" => index},
				{
                	:palette=>paletteTEST,
                	:maxWidth=>width,
                	:maxHeight=>height
            	},
            	method(:onImageRecive)
        	);
		}
	}	
}
