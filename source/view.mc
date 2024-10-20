import Toybox.Graphics;
import Toybox.Lang;
import Toybox.System;
import Toybox.SensorHistory;
import Toybox.WatchUi;
import Toybox.Math;
import Toybox.Time;
import Toybox.Time.Gregorian;

function calcPoint(radius as Number, a as Number) as [Float, Float] {
    if (a > 0 && a < 90) {
        return [
            Math.round(radius * Math.cos(Math.toRadians(a))),
            Math.round(- radius * Math.sin(Math.toRadians(a)))
        ];
    } else if (a > 90 && a < 180) {
        return [
            Math.round(- radius * Math.sin(Math.toRadians(a-90))),
            Math.round(- radius * Math.cos(Math.toRadians(a-90)))
        ];
    } else if (a > 180 && a < 270) {
        return [
            Math.round(-radius * Math.cos(Math.toRadians(a-180))),
            Math.round(radius * Math.sin(Math.toRadians(a-180)))
        ];
    } else if (a > 270 && a < 360) {
        return [
            Math.round(radius * Math.sin(Math.toRadians(a-270))),
            Math.round(radius * Math.cos(Math.toRadians(a-270)))
        ];
    }
    return [0.0, 0.0];
}

function min(a as Float, b as Float) as Float {
    return a < b ? a : b;
}

function max(a as Number, b as Number) as Number {
    return a > b ? a : b;
}

function getBodyBattery() {
    var bodybatt = null;
    if (
      Toybox has :SensorHistory &&
      Toybox.SensorHistory has :getBodyBatteryHistory
    ) {
      bodybatt = Toybox.SensorHistory.getBodyBatteryHistory({ :period => 1 });
    } else {
      return "N";
    }
    if (bodybatt != null) {
      bodybatt = bodybatt.next();
    }
    if (bodybatt != null) {
      bodybatt = bodybatt.data;
    }

    if (bodybatt != null && bodybatt >= 0 && bodybatt <= 100) {
      return bodybatt.format("%d");
    } else {
      return "-";
    }
  }

function drawBattery(dc as Dc, screenWidth as Number, battery as Float) as Void {
    var center = screenWidth / 2;
    var y = screenWidth * 0.85;
    dc.setPenWidth(6);
    var startAngle = 90 - 50;
    var endAngle = 90 + 50;
    var radius = 40;
    dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
    var redZoneAngle = endAngle + (270-endAngle)/4;
    dc.drawArc(center, y, radius, Graphics.ARC_CLOCKWISE, startAngle, redZoneAngle);
    dc.setColor(0xa13e37, Graphics.COLOR_TRANSPARENT);
    dc.drawArc(center, y, radius, Graphics.ARC_CLOCKWISE, redZoneAngle, endAngle);
    dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);

    dc.fillCircle(center, y, 5);
    var angle = endAngle + (360-(endAngle - startAngle))*battery/100;
    if (angle > 360) {
        angle = angle - 360;
    }

    var diff = calcPoint(radius - 14, Math.round(angle));
    dc.setPenWidth(2);
    dc.drawLine(center, y, center + diff[0], y + diff[1]);

    angle = endAngle + (270-endAngle) / 2;
    var diff1 = calcPoint(radius - 8, Math.round(angle));
    var diff2 = calcPoint(radius, Math.round(angle));
    dc.drawLine(center + diff1[0], y + diff1[1], center + diff2[0], y + diff2[1]);

    angle = 360 - ((270-endAngle) / 2 - startAngle);
    diff1 = calcPoint(radius - 8, Math.round(angle));
    diff2 = calcPoint(radius, Math.round(angle));
    dc.drawLine(center + diff1[0], y + diff1[1], center + diff2[0], y + diff2[1]);

    dc.drawLine(center, y + radius - 8, center, y + radius);

    dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_TRANSPARENT);
    dc.fillCircle(center, y, 3);

    
}

function drawRoundedArc(dc as Dc, screenWidth as Number, startAngle as Number, sweepAngle as Number) as Void {
    var arcWidth = 24;
    var center = screenWidth / 2;
    var radius = screenWidth / 2 - arcWidth / 2;

    dc.setPenWidth(arcWidth);
    dc.drawArc(center, center, radius, Graphics.ARC_CLOCKWISE, startAngle, sweepAngle);
    var start = calcPoint(radius, startAngle);
    dc.fillCircle(center + start[0], center + start[1], arcWidth / 2);

    var end = calcPoint(radius, sweepAngle);
    dc.fillCircle(center + end[0], center + end[1], arcWidth / 2);
}

class lyncisView extends WatchUi.WatchFace {

    const TIME_FORMAT = "$1$:$2$";
    const COLOR_DIM_GRAY = 0xE8E9FF;
    const COLOR_ARC_STEPS = 0x5399e6;
    const COLOR_ARC_STEPS_BG = 0x264669;
    const COLOR_ARC_BB = 0x4ddb60;
    const COLOR_ARC_BB_BG = 0x19451f;

    function initialize() {
        WatchFace.initialize();
    }

    // Load your resources here
    function onLayout(dc as Dc) as Void {
        setLayout(Rez.Layouts.WatchFace(dc));
    }

    // Called when this View is brought to the foreground. Restore
    // the state of this View and prepare it to be shown. This includes
    // loading resources into memory.
    function onShow() as Void {
    }

      // Update the view
    function onUpdate(dc as Dc) as Void {
        // Get the current time and format it correctly

        var act = Toybox.ActivityMonitor.getInfo();
        var sys = Toybox.System.getSystemStats();
        
        var steps = act.steps;
        if (steps == null) {
            steps = 0;
        }
        var stepsGoal = act.stepGoal;
        if (stepsGoal == null) {
            stepsGoal = 6000;
        }

        var clockTime = System.getClockTime();
        var hours = clockTime.hour;
        if (!System.getDeviceSettings().is24Hour) {
            if (hours > 12) {
                hours = hours - 12;
            }
        }
        var timeString = Lang.format(self.TIME_FORMAT, [hours.format("%02d"), clockTime.min.format("%02d")]);
        var stepsString = Lang.format("$1$ / $2$", [steps, stepsGoal]);

        // Update the view
        
        var dateView = View.findDrawableById("DateLabel") as Text;
        var secondsView = View.findDrawableById("SecondsLabel") as Text;

        

        secondsView.setText(clockTime.sec.format("%02d"));

        dateView.setText(self.getDate());

        var WIDTH= dc.getWidth();

        // view.setColor(Application.Properties.getValue("ForegroundColor") as Number);
        var view = View.findDrawableById("TimeLabel") as Text;
        view.setText(timeString);
        

        // Call the parent onUpdate function to redraw the layout
        View.onUpdate(dc);

        // var wp = Application.loadResource(Rez.Drawables.BackgroundImage);
        // dc.drawBitmap(0, 0, wp);

        var cinfo = System.getDeviceSettings().connectionInfo[:bluetooth];
        System.println(cinfo.state);

        dc.setColor(self.COLOR_ARC_BB_BG, Graphics.COLOR_TRANSPARENT);
        drawRoundedArc(dc, WIDTH, 60, 320);
        dc.setColor(self.COLOR_ARC_BB, Graphics.COLOR_TRANSPARENT);
        var bbArcValue = 320 + self.getBodyBattery();
        bbArcValue = bbArcValue >= 360 ? 360 - bbArcValue : bbArcValue;
        bbArcValue = bbArcValue == 320 ? 321 : bbArcValue;
        drawRoundedArc(dc, WIDTH, bbArcValue, 320);

        dc.setColor(self.COLOR_ARC_STEPS_BG, Graphics.COLOR_TRANSPARENT);
        drawRoundedArc(dc, WIDTH, 220, 120);
        dc.setColor(self.COLOR_ARC_STEPS, Graphics.COLOR_TRANSPARENT);
        
        var stepsArcSize = Math.round(min(1.0, 1.0 * steps / stepsGoal) * 100);
        stepsArcSize = stepsArcSize == 0 ? 1: stepsArcSize;
        drawRoundedArc(dc, WIDTH, 220, 220 - stepsArcSize);
        
        var center = WIDTH/2;

        var smallFontHeight = dc.getFontHeight(Graphics.FONT_XTINY) - 12;
        var font = Graphics.getVectorFont({:face=>["RobotoCondensedBold","RobotoRegular"], :size=>smallFontHeight});
        dc.setColor(self.COLOR_DIM_GRAY, Graphics.COLOR_TRANSPARENT);
        dc.drawRadialText(
            center, center, font, stepsString, Graphics.TEXT_JUSTIFY_CENTER, 170, WIDTH/2-34-smallFontHeight/2,
            Graphics.RADIAL_TEXT_DIRECTION_CLOCKWISE
        );
        var energyText = Lang.format("energy $1$ %", [self.getBodyBattery().format("%d")]);
        dc.drawRadialText(
            center, center, font, energyText, Graphics.TEXT_JUSTIFY_CENTER, 10, WIDTH/2-34-smallFontHeight/2,
            Graphics.RADIAL_TEXT_DIRECTION_CLOCKWISE
        );

        drawBattery(dc, WIDTH, sys.battery);
    }

    // Called when this View is removed from the screen. Save the
    // state of this View here. This includes freeing resources from
    // memory.
    function onHide() as Void {
    }

    // The user has just looked at their watch. Timers and animations may be started here.
    function onExitSleep() as Void {
    }

    // Terminate any active timers and prepare for slow updates.
    function onEnterSleep() as Void {
    }

    private function getBodyBatteryIterator() {
    if ((Toybox has :SensorHistory) && (Toybox.SensorHistory has :getBodyBatteryHistory)) {
        return Toybox.SensorHistory.getBodyBatteryHistory({:period=>5});
    }
    return null;
}

private function getBodyBattery() as Lang.Number {
    var bbIterator = getBodyBatteryIterator();
    var sample = bbIterator.next();

    while (sample != null) {
        if(sample.data != null) {
            return sample.data;
        }
        sample = bbIterator.next();
    }

    return 1;
}

private function getDate() as String {
   var today = Gregorian.info(Time.now(), Time.FORMAT_MEDIUM);
   var dateString = Lang.format("$1$ $2$ $3$",         [
            today.day_of_week,
            today.day,
            today.month,
        ]
    );
    return dateString;
}

}
