using Toybox.WatchUi as Ui;
using Toybox.System as Sys;
class NotifyAppDelegate extends Ui.BehaviorDelegate {

    function initialize() {
        BehaviorDelegate.initialize();
    }
	
	function onNextPage()
    {
    	var size = MyNotifyData.NotifyNum;
    	var index = MyNotifyData.Index;
        var view = new ImageNotifyView(false);
        var delegate = new ImageNotifyDelegate(false);
        Ui.switchToView(view, delegate, Ui.SLIDE_UP);
		Sys.println("Analog:onNextPage");
        return true;
    }

    function onPreviousPage() {
        var size = MyNotifyData.NotifyNum;
    	var index = MyNotifyData.Index;
        var view = new ImageNotifyView(false);
        var delegate = new ImageNotifyDelegate(false);
        Ui.switchToView(view, delegate, Ui.SLIDE_DOWN);
  		Sys.println("Analog:onPreviousPage"); 
        return true;
    }


}