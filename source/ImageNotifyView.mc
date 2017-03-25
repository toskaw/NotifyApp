using Toybox.WatchUi as Ui;
using Toybox.Graphics as Gfx;
using Toybox.Communications as Comm;
using Toybox.System as Sys;
using Toybox.Attention as Attention;

class ImageNotifyView extends Ui.View {
	   
    function initialize(f) {
    	View.initialize();
    }
    //! Load your resources here
    function onLayout(dc) {
        MyNotifyData.width = dc.getWidth();
        MyNotifyData.height = dc.getHeight();
    }

    //! Called when this View is brought to the foreground. Restore
    //! the state of this View and prepare it to be shown. This includes
    //! loading resources into memory.
    function onShow() {
    }

    //! Update the view
    function onUpdate(dc) {
    	var x = 0;
		var y = 0;	
    	var bitmap = MyNotifyData.bitmap;
    	var status = MyNotifyData.status;
    	var index = MyNotifyData.Index;
    	var size = MyNotifyData.NotifyNum;
        if (status == 0) {
        	dc.setColor(Gfx.COLOR_BLACK, Gfx.COLOR_WHITE);
        	dc.clear();
        	if (bitmap != null) {
        		x = (dc.getWidth() - bitmap.getWidth()) / 2;
        		y = (dc.getHeight() - bitmap.getHeight()) / 2;
        	    dc.drawBitmap(x, y,bitmap);
        	}
        	dc.drawText(50, dc.getHeight() - 50, Gfx.FONT_MEDIUM, "Loading", Gfx.TEXT_JUSTIFY_LEFT);
        	drawIndicator(dc);
        }
        else if (status == 1) {
        	dc.setColor( Gfx.COLOR_BLACK, Gfx.COLOR_WHITE );
        	dc.clear();
        	if (bitmap != null) {
         		x = (dc.getWidth() - bitmap.getWidth()) / 2;
        		y = (dc.getHeight() - bitmap.getHeight()) / 2;
        	    dc.drawBitmap(x, y,bitmap);
        	}
        	drawIndicator(dc);
        }
        else if (status == -1) {
         	dc.setColor(Gfx.COLOR_BLACK, Gfx.COLOR_WHITE);
        	dc.clear();
        	dc.drawText(dc.getWidth()/2, dc.getHeight()/2 - 15, Gfx.FONT_MEDIUM, "No Data", Gfx.TEXT_JUSTIFY_CENTER | Gfx.TEXT_JUSTIFY_VCENTER);
        	dc.drawText(dc.getWidth()/2, dc.getHeight()/2 + 15, Gfx.FONT_MEDIUM, "Press Enter", Gfx.TEXT_JUSTIFY_CENTER | Gfx.TEXT_JUSTIFY_VCENTER);
         	drawIndicator(dc);
        }
        
    }
    
    function drawIndicator(dc) {
     	var index = MyNotifyData.Index;
    	var size = MyNotifyData.NotifyNum;   
        dc.drawText(dc.getWidth() - 50, dc.getHeight() - 50, Gfx.FONT_MEDIUM, (index + 1)+"/"+size, Gfx.TEXT_JUSTIFY_RIGHT);
    }

    //! Called when this View is removed from the screen. Save the
    //! state of this View here. This includes freeing resources from
    //! memory.
    function onHide() {
    }
}
