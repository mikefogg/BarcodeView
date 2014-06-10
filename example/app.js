/*
* Barcode Titanium Module. 
* 
* Original Author : Mike Fogg : github.com/mikefogg : June 2014
* 
*/ 


var Barcode = require('com.mfogg.barcode');
Ti.API.info("module is => " + Barcode);

// open a single window
var win = Ti.UI.createWindow({backgroundColor:"#eee"});

var allowed_upcs = [
  // "EAN2",
  // "EAN5",
  // "EAN8",
  "UPCE",
  // "ISBN10",
  "UPCA",
  "EAN13",
  // "ISBN13",
  // "COMPOSITE",
  // "I25",
  // "DATABAR",
  // "DATABAR_EXP",
  // "CODE39",
  // "PDF417",
  // "CODE93",
  // "CODE128"
];

var cameraView = Barcode.createView({
  top: 0,
  height: 200,
  width: 320,
  backgroundColor: "#fff",
  barcodes: allowed_upcs
});

cameraView.addEventListener("success", function(event){
	// event.data == number
	// event.type == type of scan
	
	Ti.API.info("Scanned "+event.data);
	alert("Scanned "+event.data);
});

win.add(cameraView);
win.open();