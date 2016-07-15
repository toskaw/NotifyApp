//!
//! Copyright 2015 by Garmin Ltd. or its subsidiaries.
//! Subject to Garmin SDK License Agreement and Wearables
//! Application Developer Agreement.
//!

using Toybox.Graphics as Gfx;
using Toybox.System as Sys;
using Toybox.Lang as Lang;
using Toybox.Math as Math;
using Toybox.Time as Time;
using Toybox.Time.Gregorian as Calendar;
using Toybox.WatchUi as Ui;
using Toybox.Application as App;
using Toybox.Timer as Timer;

//! This implements an analog watch face
//! Original design by Austen Harbour
class Analog extends Ui.View
{
    var timer;
    var outerHourHand = [ [-3,-6], [-5,-12], [-5,-60], [0,-70], [5,-60], [5,-12], [3,-6] ];
    var innerHourHand = [ [-2,-15], [-2,-58], [0,-68], [2,-58], [2,-15] ];
    var outerMinuteHand = [ [-3,-6], [-5,-12], [-5,-88], [0,-98], [5,-88], [5,-12], [3,-6] ];
    var innerMinuteHand = [ [-2,-15], [-2,-78], [0,-88], [2,-78], [2,-15] ];
	var secondHand = [ [-1,-6], [-1,-90], [0,-100], [1,-90], [1,-6] ];
    //! Constructor
    function initialize()
    {
    }

	function onShow()
    {
    	timer.start( method(:onTimer), 1000, true );
    }
	function onTimer()
	{
		Ui.requestUpdate();
	}
    //! Nothing to do when going away
    function onHide()
    {
    	timer.stop();
    }
	function onLayout(dc)
	{
		timer = new Timer.Timer();
	   	//timer.start( method(:onTimer), 1000, true );
	}

    function drawHand(dc, angle, centerX, centerY, coords, color) {
        var result = new [coords.size()];
        var cos = Math.cos(angle);
        var sin = Math.sin(angle);
		
        // Transform the coordinates
        for (var i = 0; i < coords.size(); i += 1) {
            var x = (coords[i][0] * cos) - (coords[i][1] * sin) + centerX;
            var y = (coords[i][0] * sin) + (coords[i][1] * cos) + centerY;
            result[i] = [x, y];
        }
        dc.setColor(color, Gfx.COLOR_TRANSPARENT, color);
        dc.fillPolygon(result);
    }
 
    //! Handle the update event
    function onUpdate(dc)
    {
        var width, height;
        var screenWidth = dc.getWidth();
        var clockTime = Sys.getClockTime();
        var hour;
        var min;
		var sec;
		var data = Sys.getDeviceSettings();
		var connect = data.phoneConnected;
		var num = MyNotifyData.NotifyNum;
		
        width = dc.getWidth();
        height = dc.getHeight();

        var now = Time.now();
        var info = Calendar.info(now, Time.FORMAT_LONG);

        var dateStr = Lang.format("$1$ $2$ $3$", [info.day_of_week, info.month, info.day]);

        // Clear the screen
        dc.setColor(Gfx.COLOR_BLACK, Gfx.COLOR_WHITE);
        dc.fillRectangle(0,0,dc.getWidth(), dc.getHeight());
        // Draw the gray rectangle
        //dc.setColor(Gfx.COLOR_DK_GRAY, Gfx.COLOR_DK_GRAY);
        //dc.fillPolygon([[0,0],[dc.getWidth(), 0],[dc.getWidth(), dc.getHeight()],[0,0]]);
        // Draw the numbers
        dc.setColor(Gfx.COLOR_WHITE, Gfx.COLOR_TRANSPARENT);
        dc.drawText((width/2),0,Gfx.FONT_NUMBER_MEDIUM,"12",Gfx.TEXT_JUSTIFY_CENTER);
        dc.drawText(width,height/2,Gfx.FONT_NUMBER_MEDIUM,"3", Gfx.TEXT_JUSTIFY_RIGHT|Gfx.TEXT_JUSTIFY_VCENTER);
        dc.drawText(width/2,height-30,Gfx.FONT_NUMBER_MEDIUM,"6", Gfx.TEXT_JUSTIFY_CENTER|Gfx.TEXT_JUSTIFY_VCENTER);
        dc.drawText(0,height/2,Gfx.FONT_NUMBER_MEDIUM,"9",Gfx.TEXT_JUSTIFY_LEFT|Gfx.TEXT_JUSTIFY_VCENTER);

        dc.drawText(width/2,(height/4),Gfx.FONT_MEDIUM, dateStr, Gfx.TEXT_JUSTIFY_CENTER);
        if (connect) {
	    	dc.drawText(50,(height/2),Gfx.FONT_TINY, "N:" + num.toString(), Gfx.TEXT_JUSTIFY_CENTER|Gfx.TEXT_JUSTIFY_VCENTER);
	    }
	    else {
	    	dc.drawText(50,(height/2),Gfx.FONT_TINY, "N:off", Gfx.TEXT_JUSTIFY_CENTER|Gfx.TEXT_JUSTIFY_VCENTER);
	    }
        // Draw the hash marks
        //drawHashMarks(dc);
        // Draw the hour. Convert it to minutes and
        // compute the angle.
        hour = ( ( ( clockTime.hour % 12 ) * 60 ) + clockTime.min );
        hour = hour / (12 * 60.0);
        hour = hour * Math.PI * 2;
        drawHand(dc, hour, width/2, height/2, outerHourHand, Gfx.COLOR_DK_GRAY);
        drawHand(dc, hour, width/2, height/2, innerHourHand, Gfx.COLOR_WHITE);
        // Draw the minute
        min = ( clockTime.min / 60.0) * Math.PI * 2;
        drawHand(dc, min, width/2, height/2, outerMinuteHand, Gfx.COLOR_DK_GRAY);
        drawHand(dc, min, width/2, height/2, innerMinuteHand, Gfx.COLOR_WHITE);
        // Draw the second
        sec = ( clockTime.sec / 60.0) * Math.PI * 2;
        drawHand(dc, sec, width/2, height/2, secondHand, Gfx.COLOR_WHITE);
        
        // Draw the inner circle
        dc.setColor(Gfx.COLOR_LT_GRAY, Gfx.COLOR_BLACK);
        dc.fillCircle(width/2, height/2, 7);
        dc.setColor(Gfx.COLOR_BLACK,Gfx.COLOR_BLACK);
        dc.drawCircle(width/2, height/2, 7);

    }
}


