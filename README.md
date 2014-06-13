Appcelerator Titanium :: Barcode View
=============

An Appcelerator Titanium module that creates a view that allows you to scan UPC's using the ZBar Barcode Reader (http://zbar.sourceforge.net/).

I had been playing around with the Acktie Barcode reader and really wanted something that would let me place the view inside of my own page (and not use a modal window). This module allows you to create the barcode view just as you would create a standard Titanium.UI.view and listen for a 'success' callback.

This module will continue to grow and new options will be added in the near future.

<h2>Setup</h2>

Include the module in your tiapp.xml:

<pre><code>
<module platform="iphone">com.mfogg.barcode</module>

</code></pre>

<h2>Usage</h2>

Currently the options you have are limited to what type of barcodes you would like to 'listen' for and the miniumum scan quality, but that makes the module pretty simple :)

The types of barcodes available are:

* EAN2
* EAN5
* EAN8
* UPCE
* ISBN10
* UPCA
* EAN13
* ISBN13
* COMPOSITE
* I25
* DATABAR
* DATABAR_EXP
* CODE39
* PDF417
* CODE93
* CODE128

And they can be used like...

<pre><code>
var Barcode = require('com.mfogg.barcode'); // Initialize the Barcode module

// open a single window
var win = Ti.UI.createWindow({backgroundColor:"#eee"});

var allowed_upcs = [ // See list of available barcode types above
  "UPCE",
  "ISBN10",
  "UPCA",
  "EAN13",
  "CODE93",
  "CODE128"
];

var barcodeView = Barcode.createView({
  top: 0,
  height: 320,
  width: 320,
  barcodes: allowed_upcs, // Required
  minQuality: 10 // Optional (defaults to 0)
});

win.add(barcodeView);
win.open();

</code></pre>
* Note here that the created view (ex. 'barcodeView' above) can have other views added on top of it to act as a camera overlay (exactly how you would a standard Ti.UI.view)


<h3>Listeners</h3>

Currently, the only event listener enabled is "success" which will fire __every__ time a barcode that fits the types above comes into the view.

<pre><code>
barcodeView.addEventListener("success", function(event){
	// event.data == number returned from the scan
	// event.type == type of scan
  // event.quality == quality of scan (http://zbar.sourceforge.net/iphone/sdkdoc/ZBarSymbol.html#quality__i)
  
	Ti.API.info("[NEW SCAN] Data: "+event.data);
	Ti.API.info("[NEW SCAN] Type: "+event.type);
  Ti.API.info("[NEW SCAN] Quality: "+event.quality);
});

</code></pre>

<h2>Known Issues and Future Improvements</h2>

1. Ability to manage the light on/off (on initialize and via function call).
2. Android support

... anything else :)

<h2>Please let me know if you'd like any additions or something isn't working!</h2>

<h3>License</h3>
Do whatever you want, however you want, whenever you want. And if you find a problem on your way, let me know so I can fix it for my own apps too :)

<h3>Attributions</h3>

* https://github.com/acktie/Acktie-Mobile-iOS-Barcode-Reader - Got a lot of inspiration from what these guys did.
* http://zbar.sourceforge.net/ - ZBar Barcode Reader


