// Begin of User input
root = "Path/to/Python_script"; // Path where the Python script MeshBuilder.exe is located. Macro needs the "/" seperator for paths
// End of User input

function randomInt(n) {
	return n * random();
}
run("8-bit");
n = Math.round(randomInt(10000));
Names = getList("image.titles");
Name = Names[0];
selectWindow(Name);
run("Z Project...", "projection=[Max Intensity]");
selectWindow("MAX_"+Name);
run("Brightness/Contrast...");
run("Enhance Contrast", "saturated=0.35");
close("B&C");
//setTool("polygon"); // old version to draw a roi around cell or whatever
setTool("wand");
run("Wand Tool...");
waitForUser("Set, ready, draw!", "Set Parameters of the wand tool and produce ROI around Cell (if needed). Confirm with OK");
size = Roi.size();
if (size!=0){
	roiManager("add");
	DIR = getDir("Path to Save ROI");
	print("ROI is saved as Cell"+n+".zip");
	roiManager("save", DIR + "/Cell"+n+".zip");}
close("MAX_"+Name);
selectWindow(Name);
run("Stack to Images");
DIR1 = getDir("Path to save individual Imgs");
if (File.exists(DIR1)!=1) {
	File.makeDirectory(DIR1);
}
content = getFileList(DIR1);
if (content.length != 0) {
	print("Folder name: Imgs"+n);
	waitForUser("Folder is not empty. Creating new folder.");
	close("Log");
	File.makeDirectory(DIR1+"/Imgs"+n);
	DIR1 = DIR1+"/Imgs"+n;
}
Names = getList("image.titles");
for (i = 1; i < Names.length; i++) {
	SubName = Names[i];
	selectWindow(SubName);
	if (size!=0){
		roiManager("select", 0);
		setBackgroundColor(0, 0, 0);
		run("Clear Outside");}
	waitForUser("Adjust contrast", "Last chance to adjust contrast for this image.");
	run("Apply LUT");
	saveAs("tiff", DIR1+"/0"+i+".tif");
	close("0"+i+".tif");
}
close("*");
close("B&C");
close("ROI Manager");
close("Log");
exec(root+"/"+"MeshBuilder.exe");
