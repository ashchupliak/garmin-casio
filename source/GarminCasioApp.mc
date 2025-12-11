import Toybox.Application;
import Toybox.Graphics;
import Toybox.Lang;
import Toybox.System;
import Toybox.WatchUi;
import Toybox.Time;
import Toybox.Time.Gregorian;
import Toybox.ActivityMonitor;
import Toybox.Activity;

class GarminCasioApp extends Application.AppBase {
    function initialize() {
        AppBase.initialize();
    }

    function getInitialView() as [Views] or [Views, InputDelegates] {
        return [new GarminCasioView()];
    }
}

class GarminCasioView extends WatchUi.WatchFace {
    // LCD font colors
    private const FONT_COLOR = 0x000000;      // Black - main text for LCD display
    private const FONT_GLOW = 0x444444;       // Dark gray shadow for LCD effect

    private var _background as BitmapResource?;
    private var _isLowPower as Boolean = false;

    // Digit bitmaps for time display
    private var _digits as Array<BitmapResource?> = new Array<BitmapResource?>[10];
    private var _colon as BitmapResource?;

    // Letter and digit bitmaps for date display
    private var _letters as Dictionary = {};
    private var _dateDigits as Array<BitmapResource?> = new Array<BitmapResource?>[10];

    // Metric icons
    private var _caloriesIcon as BitmapResource?;
    private var _stepsIcon as BitmapResource?;
    private var _batteryIcon as BitmapResource?;
    private var _heartIcon as BitmapResource?;

    function initialize() {
        WatchFace.initialize();
    }

    function onLayout(dc as Dc) as Void {
        _background = WatchUi.loadResource(Rez.Drawables.Background) as BitmapResource;

        // Load digit bitmaps
        _digits[0] = WatchUi.loadResource(Rez.Drawables.Digit0) as BitmapResource;
        _digits[1] = WatchUi.loadResource(Rez.Drawables.Digit1) as BitmapResource;
        _digits[2] = WatchUi.loadResource(Rez.Drawables.Digit2) as BitmapResource;
        _digits[3] = WatchUi.loadResource(Rez.Drawables.Digit3) as BitmapResource;
        _digits[4] = WatchUi.loadResource(Rez.Drawables.Digit4) as BitmapResource;
        _digits[5] = WatchUi.loadResource(Rez.Drawables.Digit5) as BitmapResource;
        _digits[6] = WatchUi.loadResource(Rez.Drawables.Digit6) as BitmapResource;
        _digits[7] = WatchUi.loadResource(Rez.Drawables.Digit7) as BitmapResource;
        _digits[8] = WatchUi.loadResource(Rez.Drawables.Digit8) as BitmapResource;
        _digits[9] = WatchUi.loadResource(Rez.Drawables.Digit9) as BitmapResource;
        _colon = WatchUi.loadResource(Rez.Drawables.Colon) as BitmapResource;

        // Load letter bitmaps for date display
        _letters["A"] = WatchUi.loadResource(Rez.Drawables.LetterA) as BitmapResource;
        _letters["B"] = WatchUi.loadResource(Rez.Drawables.LetterB) as BitmapResource;
        _letters["C"] = WatchUi.loadResource(Rez.Drawables.LetterC) as BitmapResource;
        _letters["D"] = WatchUi.loadResource(Rez.Drawables.LetterD) as BitmapResource;
        _letters["E"] = WatchUi.loadResource(Rez.Drawables.LetterE) as BitmapResource;
        _letters["F"] = WatchUi.loadResource(Rez.Drawables.LetterF) as BitmapResource;
        _letters["G"] = WatchUi.loadResource(Rez.Drawables.LetterG) as BitmapResource;
        _letters["H"] = WatchUi.loadResource(Rez.Drawables.LetterH) as BitmapResource;
        _letters["I"] = WatchUi.loadResource(Rez.Drawables.LetterI) as BitmapResource;
        _letters["J"] = WatchUi.loadResource(Rez.Drawables.LetterJ) as BitmapResource;
        _letters["L"] = WatchUi.loadResource(Rez.Drawables.LetterL) as BitmapResource;
        _letters["M"] = WatchUi.loadResource(Rez.Drawables.LetterM) as BitmapResource;
        _letters["N"] = WatchUi.loadResource(Rez.Drawables.LetterN) as BitmapResource;
        _letters["O"] = WatchUi.loadResource(Rez.Drawables.LetterO) as BitmapResource;
        _letters["P"] = WatchUi.loadResource(Rez.Drawables.LetterP) as BitmapResource;
        _letters["R"] = WatchUi.loadResource(Rez.Drawables.LetterR) as BitmapResource;
        _letters["S"] = WatchUi.loadResource(Rez.Drawables.LetterS) as BitmapResource;
        _letters["T"] = WatchUi.loadResource(Rez.Drawables.LetterT) as BitmapResource;
        _letters["U"] = WatchUi.loadResource(Rez.Drawables.LetterU) as BitmapResource;
        _letters["V"] = WatchUi.loadResource(Rez.Drawables.LetterV) as BitmapResource;
        _letters["W"] = WatchUi.loadResource(Rez.Drawables.LetterW) as BitmapResource;
        _letters["Y"] = WatchUi.loadResource(Rez.Drawables.LetterY) as BitmapResource;

        // Load date digit bitmaps (smaller than time digits)
        _dateDigits[0] = WatchUi.loadResource(Rez.Drawables.DateDigit0) as BitmapResource;
        _dateDigits[1] = WatchUi.loadResource(Rez.Drawables.DateDigit1) as BitmapResource;
        _dateDigits[2] = WatchUi.loadResource(Rez.Drawables.DateDigit2) as BitmapResource;
        _dateDigits[3] = WatchUi.loadResource(Rez.Drawables.DateDigit3) as BitmapResource;
        _dateDigits[4] = WatchUi.loadResource(Rez.Drawables.DateDigit4) as BitmapResource;
        _dateDigits[5] = WatchUi.loadResource(Rez.Drawables.DateDigit5) as BitmapResource;
        _dateDigits[6] = WatchUi.loadResource(Rez.Drawables.DateDigit6) as BitmapResource;
        _dateDigits[7] = WatchUi.loadResource(Rez.Drawables.DateDigit7) as BitmapResource;
        _dateDigits[8] = WatchUi.loadResource(Rez.Drawables.DateDigit8) as BitmapResource;
        _dateDigits[9] = WatchUi.loadResource(Rez.Drawables.DateDigit9) as BitmapResource;

        // Load metric icons
        _caloriesIcon = WatchUi.loadResource(Rez.Drawables.IconCalories) as BitmapResource;
        _stepsIcon = WatchUi.loadResource(Rez.Drawables.IconSteps) as BitmapResource;
        _batteryIcon = WatchUi.loadResource(Rez.Drawables.IconBattery) as BitmapResource;
        _heartIcon = WatchUi.loadResource(Rez.Drawables.IconHeart) as BitmapResource;
    }

    function onUpdate(dc as Dc) as Void {
        var clockTime = System.getClockTime();
        var width = dc.getWidth();
        var height = dc.getHeight();
        var centerX = width / 2;
        var centerY = height / 2;

        // Draw background image scaled to screen size
        if (_background != null) {
            dc.drawScaledBitmap(0, 0, width, height, _background);
        }

        // Check if metrics should be on top (swapped layout)
        var metricsOnTop = Application.Properties.getValue("MetricsOnTop");
        if (metricsOnTop == null) { metricsOnTop = false; }

        if (metricsOnTop) {
            // Swapped layout: metrics on top, date on bottom
            drawMetrics(dc, centerX, 40);
            drawFrostCrystalTime(dc, centerX, centerY, clockTime);
            drawDate(dc, centerX, height - 45);
        } else {
            // Default layout: date on top, metrics on bottom
            drawDate(dc, centerX, 40);
            drawFrostCrystalTime(dc, centerX, centerY, clockTime);
            drawMetrics(dc, centerX, height - 45);
        }
    }

    // Draw date in top area using Crystal font bitmaps (format: TUE 9 DEC 25)
    function drawDate(dc as Dc, centerX as Number, y as Number) as Void {
        var now = Time.now();
        var info = Gregorian.info(now, Time.FORMAT_MEDIUM);

        // Format: "TUE 9 DEC 25" (uppercase day, day number, uppercase month, 2-digit year)
        var year2digit = info.year % 100;
        var dayOfWeek = info.day_of_week.toUpper();
        var monthName = info.month.toUpper();
        var dateString = dayOfWeek + " " + info.day + " " + monthName + " " + year2digit;

        // Draw the date using Crystal font bitmaps
        drawCrystalText(dc, dateString, centerX, y);
    }

    // Helper function to draw text using Crystal font bitmaps
    function drawCrystalText(dc as Dc, text as String, centerX as Number, y as Number) as Void {
        var letterWidth = 11;   // Crystal letters (15x18px)
        var digitWidth = 9;     // Width for date digits (12x18px)
        var spacing = 3;
        var totalWidth = 0;

        // Calculate total width
        for (var i = 0; i < text.length(); i++) {
            var c = text.substring(i, i + 1);
            if (c.equals(" ")) {
                totalWidth += 4;  // Space width
            } else if (_letters.hasKey(c)) {
                totalWidth += letterWidth + spacing;
            } else if (c.toNumber() != null) {
                totalWidth += digitWidth + spacing;
            }
        }

        var startX = centerX - totalWidth / 2;

        // Draw each character
        for (var i = 0; i < text.length(); i++) {
            var c = text.substring(i, i + 1);

            if (c.equals(" ")) {
                startX += 4;
            } else if (_letters.hasKey(c)) {
                var letter = _letters[c];
                if (letter != null) {
                    dc.drawBitmap(startX, y, letter);
                }
                startX += letterWidth + spacing;
            } else {
                // Try to draw as digit using date-specific digit bitmaps
                var digitVal = c.toNumber();
                if (digitVal != null && digitVal >= 0 && digitVal <= 9) {
                    if (_dateDigits[digitVal] != null) {
                        dc.drawBitmap(startX, y, _dateDigits[digitVal]);
                    }
                    startX += digitWidth + spacing;
                }
            }
        }
    }

    // Draw 2 configurable metrics in bottom dotted area, centered
    // Metric types: 0=Heart, 1=Steps, 2=Calories, 3=Battery
    function drawMetrics(dc as Dc, centerX as Number, y as Number) as Void {
        // Get activity data
        var actInfo = ActivityMonitor.getInfo();
        var steps = 0;
        var calories = 0;
        if (actInfo != null) {
            if (actInfo.steps != null) { steps = actInfo.steps; }
            if (actInfo.calories != null) { calories = actInfo.calories; }
        }

        // Get battery level
        var sysStats = System.getSystemStats();
        var battery = sysStats.battery.toNumber();

        // Get heart rate (use 0 if not available)
        var heartRate = 0;
        var hrInfo = Activity.getActivityInfo();
        if (hrInfo != null && hrInfo.currentHeartRate != null) {
            heartRate = hrInfo.currentHeartRate;
        }

        // Read settings for which metrics to display
        var leftMetric = Application.Properties.getValue("LeftMetric");
        var rightMetric = Application.Properties.getValue("RightMetric");
        if (leftMetric == null) { leftMetric = 1; }  // Default: Steps
        if (rightMetric == null) { rightMetric = 3; }  // Default: Battery

        // Layout: 2 metrics centered with spacing between them
        var metricSpacing = 70;  // Space between the two metrics
        var leftX = centerX - metricSpacing / 2 - 15;
        var rightX = centerX + metricSpacing / 2 + 15;

        // Draw left metric
        drawMetricByType(dc, leftMetric, leftX, y, heartRate, steps, calories, battery);

        // Draw right metric
        drawMetricByType(dc, rightMetric, rightX, y, heartRate, steps, calories, battery);
    }

    // Draw a metric based on type (0=Heart, 1=Steps, 2=Calories, 3=Battery)
    function drawMetricByType(dc as Dc, metricType as Number, x as Number, y as Number,
                              heartRate as Number, steps as Number, calories as Number, battery as Number) as Void {
        var icon = null;
        var value = "";
        var iconW = 0;
        var iconH = 0;

        if (metricType == 0) {
            // Heart rate
            icon = _heartIcon;
            value = heartRate.toString();
            iconW = 15;
            iconH = 12;
        } else if (metricType == 1) {
            // Steps
            icon = _stepsIcon;
            value = steps.toString();
            iconW = 17;
            iconH = 20;
        } else if (metricType == 2) {
            // Calories
            icon = _caloriesIcon;
            value = calories.toString();
            iconW = 20;
            iconH = 22;
        } else if (metricType == 3) {
            // Battery
            icon = _batteryIcon;
            value = battery.toString() + "%";
            iconW = 22;
            iconH = 10;
        }

        drawSingleMetric(dc, icon, value, x, y, iconW, iconH);
    }

    // Helper to draw a single metric (icon + value below)
    function drawSingleMetric(dc as Dc, icon as BitmapResource?, value as String, x as Number, y as Number, iconW as Number, iconH as Number) as Void {
        var digitWidth = 9;
        var digitSpacing = 2;

        // Set color to match icon (black for LCD style)
        dc.setColor(FONT_COLOR, Graphics.COLOR_TRANSPARENT);

        // Draw icon centered (positioned lower, below the line)
        if (icon != null) {
            dc.drawBitmap(x - iconW / 2, y - iconH + 5, icon);
        }

        // Calculate value width for centering
        var valueWidth = 0;
        for (var i = 0; i < value.length(); i++) {
            var c = value.substring(i, i + 1);
            if (c.equals("%")) {
                valueWidth += 8;  // % sign width
            } else {
                valueWidth += digitWidth + digitSpacing;
            }
        }

        // Draw value centered below icon
        var valueX = x - valueWidth / 2;
        var valueY = y + 8;

        for (var i = 0; i < value.length(); i++) {
            var c = value.substring(i, i + 1);
            if (c.equals("%")) {
                // Draw % sign using small text (color already set above)
                dc.drawText(valueX, valueY - 2, Graphics.FONT_XTINY, "%", Graphics.TEXT_JUSTIFY_LEFT);
                valueX += 8;
            } else {
                var digitVal = c.toNumber();
                if (digitVal != null && digitVal >= 0 && digitVal <= 9) {
                    if (_dateDigits[digitVal] != null) {
                        dc.drawBitmap(valueX, valueY, _dateDigits[digitVal]);
                    }
                    valueX += digitWidth + digitSpacing;
                }
            }
        }
    }

    // ═══════════════════════════════════════════════════════════════════
    // 7-SEGMENT LCD FONT - Classic Casio digital watch style
    // Each digit composed of 7 segments (a-g) that can be on/off
    //      aaa
    //     f   b
    //      ggg
    //     e   c
    //      ddd
    // ═══════════════════════════════════════════════════════════════════

    // Draw a single 7-segment digit
    function draw7SegmentDigit(dc as Dc, digit as Number, x as Number, y as Number, segWidth as Number, segHeight as Number) as Void {
        // Define which segments are on for each digit (a,b,c,d,e,f,g)
        var segments = [
            [1,1,1,1,1,1,0], // 0
            [0,1,1,0,0,0,0], // 1
            [1,1,0,1,1,0,1], // 2
            [1,1,1,1,0,0,1], // 3
            [0,1,1,0,0,1,1], // 4
            [1,0,1,1,0,1,1], // 5
            [1,0,1,1,1,1,1], // 6
            [1,1,1,0,0,0,0], // 7
            [1,1,1,1,1,1,1], // 8
            [1,1,1,1,0,1,1]  // 9
        ];

        var seg = segments[digit];
        var w = segWidth;
        var h = segHeight;
        var t = 6;  // Thickness of segments
        var g = 2;  // Gap between segments

        // Segment a (top horizontal) - clean hexagon
        if (seg[0] == 1) {
            dc.fillPolygon([[x + t, y],
                           [x + w - t, y],
                           [x + w, y + t],
                           [x + w - t, y + t*2],
                           [x + t, y + t*2],
                           [x, y + t]]);
        }

        // Segment b (top right vertical)
        if (seg[1] == 1) {
            dc.fillPolygon([[x + w - t, y + t*2 + g],
                           [x + w, y + t*2 + g + t],
                           [x + w, y + h - g],
                           [x + w - t*2, y + h - g]]);
        }

        // Segment c (bottom right vertical)
        if (seg[2] == 1) {
            dc.fillPolygon([[x + w - t*2, y + h + g],
                           [x + w, y + h + g],
                           [x + w, y + h*2 - t*2 - g],
                           [x + w - t, y + h*2 - t*2 - g + t]]);
        }

        // Segment d (bottom horizontal) - clean hexagon
        if (seg[3] == 1) {
            dc.fillPolygon([[x + t, y + h*2 - t*2],
                           [x + w - t, y + h*2 - t*2],
                           [x + w, y + h*2 - t],
                           [x + w - t, y + h*2],
                           [x + t, y + h*2],
                           [x, y + h*2 - t]]);
        }

        // Segment e (bottom left vertical)
        if (seg[4] == 1) {
            dc.fillPolygon([[x, y + h + g],
                           [x + t*2, y + h + g],
                           [x + t*2, y + h*2 - t*2 - g],
                           [x + t, y + h*2 - t*2 - g + t],
                           [x, y + h*2 - t*2 - g]]);
        }

        // Segment f (top left vertical)
        if (seg[5] == 1) {
            dc.fillPolygon([[x, y + t*2 + g + t],
                           [x + t*2, y + t*2 + g],
                           [x + t*2, y + h - g],
                           [x, y + h - g]]);
        }

        // Segment g (middle horizontal) - diamond hexagon
        if (seg[6] == 1) {
            dc.fillPolygon([[x + t*2, y + h - t],
                           [x + w - t*2, y + h - t],
                           [x + w, y + h],
                           [x + w - t*2, y + h + t],
                           [x + t*2, y + h + t],
                           [x, y + h]]);
        }
    }

    // Old function kept for compatibility but now calls 7-segment version
    function drawFrostDigit(dc as Dc, digit as Number, x as Number, y as Number, pixelSize as Number) as Void {
        // Frost Crystal digit patterns (7 wide x 9 tall)
        // Design features: angular cuts, ice-crystal aesthetic, bold strokes
        var patterns = [
            // 0 - Oval with angular cuts at corners
            [[0,1,1,1,1,1,0],
             [1,1,0,0,0,1,1],
             [1,0,0,0,0,0,1],
             [1,0,0,0,0,0,1],
             [1,0,0,0,0,0,1],
             [1,0,0,0,0,0,1],
             [1,0,0,0,0,0,1],
             [1,1,0,0,0,1,1],
             [0,1,1,1,1,1,0]],
            // 1 - Crystal pillar with angular base
            [[0,0,0,1,0,0,0],
             [0,0,1,1,0,0,0],
             [0,1,0,1,0,0,0],
             [0,0,0,1,0,0,0],
             [0,0,0,1,0,0,0],
             [0,0,0,1,0,0,0],
             [0,0,0,1,0,0,0],
             [0,0,0,1,0,0,0],
             [0,1,1,1,1,1,0]],
            // 2 - Sharp angular turns
            [[0,1,1,1,1,1,0],
             [1,1,0,0,0,1,1],
             [0,0,0,0,0,0,1],
             [0,0,0,0,0,1,1],
             [0,0,1,1,1,0,0],
             [0,1,1,0,0,0,0],
             [1,0,0,0,0,0,0],
             [1,1,0,0,0,1,1],
             [0,1,1,1,1,1,0]],
            // 3 - Double crystal curves
            [[0,1,1,1,1,1,0],
             [1,1,0,0,0,1,1],
             [0,0,0,0,0,0,1],
             [0,0,0,0,0,1,1],
             [0,0,1,1,1,0,0],
             [0,0,0,0,0,1,1],
             [0,0,0,0,0,0,1],
             [1,1,0,0,0,1,1],
             [0,1,1,1,1,1,0]],
            // 4 - Angular ice shard
            [[0,0,0,0,1,0,0],
             [0,0,0,1,1,0,0],
             [0,0,1,0,1,0,0],
             [0,1,0,0,1,0,0],
             [1,0,0,0,1,0,0],
             [1,1,1,1,1,1,1],
             [0,0,0,0,1,0,0],
             [0,0,0,0,1,0,0],
             [0,0,0,0,1,0,0]],
            // 5 - Bold crystal block
            [[1,1,1,1,1,1,1],
             [1,0,0,0,0,0,0],
             [1,0,0,0,0,0,0],
             [1,1,1,1,1,0,0],
             [0,0,0,0,1,1,0],
             [0,0,0,0,0,1,1],
             [0,0,0,0,0,0,1],
             [1,1,0,0,0,1,1],
             [0,1,1,1,1,1,0]],
            // 6 - Flowing crystal
            [[0,0,1,1,1,1,0],
             [0,1,1,0,0,0,0],
             [1,0,0,0,0,0,0],
             [1,0,1,1,1,0,0],
             [1,1,0,0,0,1,0],
             [1,0,0,0,0,1,1],
             [1,0,0,0,0,0,1],
             [1,1,0,0,0,1,1],
             [0,1,1,1,1,1,0]],
            // 7 - Sharp ice angle
            [[1,1,1,1,1,1,1],
             [1,1,0,0,0,1,1],
             [0,0,0,0,0,1,0],
             [0,0,0,0,1,0,0],
             [0,0,0,1,0,0,0],
             [0,0,1,0,0,0,0],
             [0,0,1,0,0,0,0],
             [0,0,1,0,0,0,0],
             [0,0,1,0,0,0,0]],
            // 8 - Double crystal rings
            [[0,1,1,1,1,1,0],
             [1,1,0,0,0,1,1],
             [1,0,0,0,0,0,1],
             [1,1,0,0,0,1,1],
             [0,1,1,1,1,1,0],
             [1,1,0,0,0,1,1],
             [1,0,0,0,0,0,1],
             [1,1,0,0,0,1,1],
             [0,1,1,1,1,1,0]],
            // 9 - Inverted crystal 6
            [[0,1,1,1,1,1,0],
             [1,1,0,0,0,1,1],
             [1,0,0,0,0,0,1],
             [1,1,0,0,0,0,1],
             [0,1,1,1,1,0,1],
             [0,0,0,0,0,0,1],
             [0,0,0,0,0,1,1],
             [0,0,0,0,1,1,0],
             [0,1,1,1,1,0,0]]
        ];

        var pattern = patterns[digit];

        // Draw blue glow/shadow first (offset by 2 pixels)
        dc.setColor(FONT_GLOW, Graphics.COLOR_TRANSPARENT);
        for (var row = 0; row < 9; row++) {
            for (var col = 0; col < 7; col++) {
                if (pattern[row][col] == 1) {
                    dc.fillRectangle(x + col * pixelSize + 2, y + row * pixelSize + 2, pixelSize, pixelSize);
                }
            }
        }

        // Draw main white digit on top
        dc.setColor(FONT_COLOR, Graphics.COLOR_TRANSPARENT);
        for (var row = 0; row < 9; row++) {
            for (var col = 0; col < 7; col++) {
                if (pattern[row][col] == 1) {
                    dc.fillRectangle(x + col * pixelSize, y + row * pixelSize, pixelSize, pixelSize);
                }
            }
        }
    }

    // Draw Frost Crystal colon (vertical ice crystals)
    function drawFrostColon(dc as Dc, x as Number, y as Number, pixelSize as Number) as Void {
        // Glow
        dc.setColor(FONT_GLOW, Graphics.COLOR_TRANSPARENT);
        dc.fillRectangle(x + 2, y + pixelSize * 2 + 2, pixelSize * 2, pixelSize * 2);
        dc.fillRectangle(x + 2, y + pixelSize * 5 + 2, pixelSize * 2, pixelSize * 2);

        // Main dots
        dc.setColor(FONT_COLOR, Graphics.COLOR_TRANSPARENT);
        dc.fillRectangle(x, y + pixelSize * 2, pixelSize * 2, pixelSize * 2);
        dc.fillRectangle(x, y + pixelSize * 5, pixelSize * 2, pixelSize * 2);
    }

    // Main time drawing function using bitmap digits
    function drawFrostCrystalTime(dc as Dc, centerX as Number, centerY as Number, clockTime as System.ClockTime) as Void {
        var hour = clockTime.hour;
        var min = clockTime.min;
        var sec = clockTime.sec;

        // Always use 24-hour format

        var h1 = hour / 10;
        var h2 = hour % 10;
        var m1 = min / 10;
        var m2 = min % 10;

        // Actual bitmap dimensions
        var digitWidth = 40;
        var digitHeight = 58;
        var spacing = 4;  // Consistent spacing between all elements
        var colonWidth = 13;  // Actual colon width
        var totalWidth = digitWidth * 4 + colonWidth + spacing * 5;  // 5 gaps total

        var startX = centerX - totalWidth / 2;
        var startY = centerY - digitHeight / 2;

        // Draw time using bitmap digits from Crystal font with consistent spacing
        if (_digits[h1] != null) { dc.drawBitmap(startX, startY, _digits[h1]); }
        startX += digitWidth + spacing;
        if (_digits[h2] != null) { dc.drawBitmap(startX, startY, _digits[h2]); }
        startX += digitWidth + spacing;
        // Blink colon every second (show on even seconds, hide on odd)
        if (_colon != null && sec % 2 == 0) { dc.drawBitmap(startX, startY + 10, _colon); }
        startX += colonWidth + spacing;
        if (_digits[m1] != null) { dc.drawBitmap(startX, startY, _digits[m1]); }
        startX += digitWidth + spacing;
        if (_digits[m2] != null) { dc.drawBitmap(startX, startY, _digits[m2]); }
    }

    // ═══════════════════════════════════════════════════════════════════
    // FROST CRYSTAL LETTERS - For date display (4x6 grid)
    // ═══════════════════════════════════════════════════════════════════

    function drawFrostLetter(dc as Dc, letter as String, x as Number, y as Number, pixelSize as Number) as Number {
        var pattern = null;
        var width = 4;

        // Frost Crystal letter patterns (4 wide x 6 tall)
        if (letter.equals("S")) {
            pattern = [[0,1,1,1], [1,0,0,0], [0,1,1,0], [0,0,0,1], [0,0,0,1], [1,1,1,0]];
        } else if (letter.equals("u")) {
            pattern = [[0,0,0,0], [1,0,0,1], [1,0,0,1], [1,0,0,1], [1,0,0,1], [0,1,1,0]];
        } else if (letter.equals("n")) {
            pattern = [[0,0,0,0], [1,1,1,0], [1,0,0,1], [1,0,0,1], [1,0,0,1], [1,0,0,1]];
        } else if (letter.equals("M")) {
            pattern = [[1,0,0,1], [1,1,1,1], [1,0,0,1], [1,0,0,1], [1,0,0,1], [1,0,0,1]];
        } else if (letter.equals("o")) {
            pattern = [[0,0,0,0], [0,1,1,0], [1,0,0,1], [1,0,0,1], [1,0,0,1], [0,1,1,0]];
        } else if (letter.equals("T")) {
            pattern = [[1,1,1,1], [0,1,1,0], [0,1,1,0], [0,1,1,0], [0,1,1,0], [0,1,1,0]];
        } else if (letter.equals("e")) {
            pattern = [[0,0,0,0], [0,1,1,0], [1,0,0,1], [1,1,1,1], [1,0,0,0], [0,1,1,1]];
        } else if (letter.equals("W")) {
            pattern = [[1,0,0,1], [1,0,0,1], [1,0,0,1], [1,0,0,1], [1,1,1,1], [1,0,0,1]];
        } else if (letter.equals("d")) {
            pattern = [[0,0,0,1], [0,0,0,1], [0,1,1,1], [1,0,0,1], [1,0,0,1], [0,1,1,1]];
        } else if (letter.equals("h")) {
            pattern = [[1,0,0,0], [1,0,0,0], [1,1,1,0], [1,0,0,1], [1,0,0,1], [1,0,0,1]];
        } else if (letter.equals("F")) {
            pattern = [[1,1,1,1], [1,0,0,0], [1,1,1,0], [1,0,0,0], [1,0,0,0], [1,0,0,0]];
        } else if (letter.equals("r")) {
            pattern = [[0,0,0,0], [1,0,1,1], [1,1,0,0], [1,0,0,0], [1,0,0,0], [1,0,0,0]];
        } else if (letter.equals("i")) {
            pattern = [[0,1,0,0], [0,0,0,0], [0,1,0,0], [0,1,0,0], [0,1,0,0], [0,1,0,0]];
            width = 2;
        } else if (letter.equals("a")) {
            pattern = [[0,0,0,0], [0,1,1,1], [0,0,0,1], [0,1,1,1], [1,0,0,1], [0,1,1,1]];
        } else if (letter.equals("t")) {
            pattern = [[0,1,0,0], [1,1,1,0], [0,1,0,0], [0,1,0,0], [0,1,0,0], [0,0,1,1]];
            width = 3;
        } else if (letter.equals(" ")) {
            return x + pixelSize * 2;
        } else {
            return x + pixelSize * 4;
        }

        if (pattern != null) {
            // Glow
            dc.setColor(FONT_GLOW, Graphics.COLOR_TRANSPARENT);
            for (var row = 0; row < 6; row++) {
                for (var col = 0; col < width; col++) {
                    if (pattern[row][col] == 1) {
                        dc.fillRectangle(x + col * pixelSize + 1, y + row * pixelSize + 1, pixelSize, pixelSize);
                    }
                }
            }
            // Main
            dc.setColor(FONT_COLOR, Graphics.COLOR_TRANSPARENT);
            for (var row = 0; row < 6; row++) {
                for (var col = 0; col < width; col++) {
                    if (pattern[row][col] == 1) {
                        dc.fillRectangle(x + col * pixelSize, y + row * pixelSize, pixelSize, pixelSize);
                    }
                }
            }
        }

        return x + (width + 1) * pixelSize;
    }

    // Frost Crystal small digit (4x6 grid)
    function drawFrostSmallDigit(dc as Dc, digit as Number, x as Number, y as Number, pixelSize as Number) as Void {
        var patterns = [
            [[0,1,1,0], [1,0,0,1], [1,0,0,1], [1,0,0,1], [1,0,0,1], [0,1,1,0]],  // 0
            [[0,0,1,0], [0,1,1,0], [0,0,1,0], [0,0,1,0], [0,0,1,0], [0,1,1,1]],  // 1
            [[0,1,1,0], [1,0,0,1], [0,0,1,0], [0,1,0,0], [1,0,0,0], [1,1,1,1]],  // 2
            [[1,1,1,0], [0,0,0,1], [0,1,1,0], [0,0,0,1], [0,0,0,1], [1,1,1,0]],  // 3
            [[0,0,1,0], [0,1,1,0], [1,0,1,0], [1,1,1,1], [0,0,1,0], [0,0,1,0]],  // 4
            [[1,1,1,1], [1,0,0,0], [1,1,1,0], [0,0,0,1], [0,0,0,1], [1,1,1,0]],  // 5
            [[0,1,1,0], [1,0,0,0], [1,1,1,0], [1,0,0,1], [1,0,0,1], [0,1,1,0]],  // 6
            [[1,1,1,1], [0,0,0,1], [0,0,1,0], [0,1,0,0], [0,1,0,0], [0,1,0,0]],  // 7
            [[0,1,1,0], [1,0,0,1], [0,1,1,0], [1,0,0,1], [1,0,0,1], [0,1,1,0]],  // 8
            [[0,1,1,0], [1,0,0,1], [0,1,1,1], [0,0,0,1], [0,0,1,0], [0,1,0,0]]   // 9
        ];

        var pattern = patterns[digit];

        // Glow
        dc.setColor(FONT_GLOW, Graphics.COLOR_TRANSPARENT);
        for (var row = 0; row < 6; row++) {
            for (var col = 0; col < 4; col++) {
                if (pattern[row][col] == 1) {
                    dc.fillRectangle(x + col * pixelSize + 1, y + row * pixelSize + 1, pixelSize, pixelSize);
                }
            }
        }

        // Main
        dc.setColor(FONT_COLOR, Graphics.COLOR_TRANSPARENT);
        for (var row = 0; row < 6; row++) {
            for (var col = 0; col < 4; col++) {
                if (pattern[row][col] == 1) {
                    dc.fillRectangle(x + col * pixelSize, y + row * pixelSize, pixelSize, pixelSize);
                }
            }
        }
    }

    // Date drawing function
    function drawFrostCrystalDate(dc as Dc, centerX as Number, centerY as Number) as Void {
        var now = Time.now();
        var info = Gregorian.info(now, Time.FORMAT_SHORT);

        var dow = info.day_of_week;
        var dayStr = "";
        if (dow == 1) { dayStr = "Sun"; }
        else if (dow == 2) { dayStr = "Mon"; }
        else if (dow == 3) { dayStr = "Tue"; }
        else if (dow == 4) { dayStr = "Wed"; }
        else if (dow == 5) { dayStr = "Thu"; }
        else if (dow == 6) { dayStr = "Fri"; }
        else if (dow == 7) { dayStr = "Sat"; }

        var day = info.day;
        var pixelSize = 3;

        // Calculate width
        var totalWidth = 3 * 5 * pixelSize + 3 * pixelSize + 2 * 5 * pixelSize;
        var startX = centerX - totalWidth / 2;

        // Draw day name
        for (var i = 0; i < dayStr.length(); i++) {
            startX = drawFrostLetter(dc, dayStr.substring(i, i + 1), startX, centerY, pixelSize);
        }

        startX += pixelSize * 2;

        // Draw day number
        var d1 = day / 10;
        var d2 = day % 10;

        if (d1 > 0) {
            drawFrostSmallDigit(dc, d1, startX, centerY, pixelSize);
            startX += 5 * pixelSize;
        }
        drawFrostSmallDigit(dc, d2, startX, centerY, pixelSize);
    }

    function onEnterSleep() as Void {
        _isLowPower = true;
        WatchUi.requestUpdate();
    }

    function onExitSleep() as Void {
        _isLowPower = false;
        WatchUi.requestUpdate();
    }

    function onPartialUpdate(dc as Dc) as Void {
    }
}
