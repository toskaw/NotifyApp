using Toybox.Application as App;
using Toybox.WatchUi as Ui;
using Toybox.Communications as Com;
using Toybox.Timer as Timer;
using Toybox.System as Sys;
using Toybox.Attention as Attention;

class NotifyAppApp extends App.AppBase {
	var connected = false;
	var timer;
	var popup;
	var comm;
	var mailMethod;
	var phoneMethod;
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
        mailMethod = method(:onMail);
        phoneMethod = method(:onPhone);
        if(Com has :registerForPhoneAppMessages) {
            Com.registerForPhoneAppMessages(phoneMethod);
        } else {
            Com.setMailboxListener(mailMethod);
        }
        
        Com.setMailboxListener( method(:onMail) );
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
    		Com.makeWebRequest(
				"http://127.0.0.1:8080/",
				{"regist" => "19A65F9191F0471E8AF86C0E1B93D68A"},
				{
					:headers =>{
            			"Content-Type" => Com.REQUEST_CONTENT_TYPE_URL_ENCODED
            		},
            		:responseType => Communications.HTTP_RESPONSE_CONTENT_TYPE_JSON
            	},
            	method(:onCheckConnect)
        	);	
        }
        else {
         	timer.start( method(:checkConnect), 10000, false );
        } 
	}
	
    //! onStart() is called on application start up
    function onStart(state) {
    }

    //! onStop() is called when your application is exiting
    function onStop(state) {
    }

    //! Return the initial view of your application here
    function getInitialView() {
        return [ new Analog(), new NotifyAppDelegate() ];
    }
    
    function onMail(mailIter)
    {
    	var mail;
    	Sys.println("onMail");
      	mail = mailIter.next();
    	while (mail != null) {
        	mail = mailIter.next();
        }
        if(Com has :emptyMailbox) {
       		//Com.emptyMailbox();
       	}
    	if (comm != null) {
    		Sys.println("busy");
     		return;
    	}
    	comm = MyNotifyData.CommNotify(method(:onReceive));
    }
    function onPhone(msg) {
        var i;
		Sys.println("onPhone");
     	if (comm != null) {
    		Sys.println("busy");
     		return;
    	}
    	comm = MyNotifyData.CommNotify(method(:onReceive));
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
	var save_mode = false;
    var count;
	
    var paletteTEST=[
    	0xFF000000, 
     	0xFF555555,
    	0xFFAAAAAA,
	   	0xFFFFFFFF
    ];	

	function SaveMode() {
		if (!App.getApp().getProperty("save_mode")) {
			return false;
		}
		return save_mode; 
	}
	
	function CountUp() {
		if (!App.getApp().getProperty("save_mode")) {
			return;
		}
		count += 1;
		if (count > 600) {
			save_mode = true;
			count = 600;
		}
	}
	
	function ResetCount() {
		count = 0;
		save_mode = false;
	}
	function CommNotify(callback) {
		var com = new myCom();
     	Sys.println("com create");
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
     		Sys.println("request");
			callback = cb;
    		Com.makeWebRequest(
				"http://127.0.0.1:8080/",
				{},
				{
            		:headers => { "Content-Type" => Com.REQUEST_CONTENT_TYPE_URL_ENCODED }
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
        	Com.makeImageRequest(
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
