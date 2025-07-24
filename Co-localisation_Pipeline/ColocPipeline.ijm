// TODO:
// Have Weka segmentation run before this to segment neurons to get roi for comdet

//Supported filetypes: .tif, .stk, .tiff; if other filetypes wanted, adjust line 223

// Get multiple Folders from where to load images
LoadDirs = newArray();
AddFolder = true;
while (AddFolder==true) {
	if (LoadDirs.length>0) {
			File.setDefaultDir(LoadDirs[LoadDirs.length-1]);
		}
	Dir = getDir("Choose Folder from where to load images");
	LoadDirs = Array.concat(LoadDirs,Dir);
	AddFolder = getBoolean("Do you wish to add more folders?");	
}
if(LoadDirs.length==1){File.setDefaultDir(LoadDirs[0]);}
// Get Saving Dir where to save the csv's
SaveDir = getDir("Folder where to save results table(s)");

// Window to get parameters from user to pass on to the DetCom plugin
Dialog.create("Pipeline for colocalization analysis");
Dialog.addString("Directory where results will be saved. Can be over-ruled by option below.", SaveDir, 80); //Str1
Dialog.addCheckbox("Save results in an individual folder inside original folder", false);//Tick1
Dialog.addString("Name of folder results will be saved in (only when above is enabled)", "", 20); //Str2
Dialog.addMessage("Those parameters are passed further to ComDet/Detect Particles (Help)");
Dialog.addCheckbox("Calculate colocalization?", true); //Tick2
Dialog.addNumber("Maximum distance between colocalized particles", 4, 2, 5, "px"); //Int1
Dialog.addCheckbox("Join ROIs for intensity of colocalized particles", false); //Tick3
Dialog.addCheckbox("Plot detected particles in all channels?", false); //Tick4
Dialog.addChoice("ROIs shape", newArray("Ovals", "Rectangles"), "Ovals"); //Choice1
Dialog.addChoice("Add to ROI Manager", newArray("Nothing", "All detections", "Only colocalized particles", "Only non-colocalized particles"), "Nothing");//Choice2
Dialog.addChoice("Summary Table", newArray("Reset", "Append"), "Reset");//Choice3
Dialog.addChoice("What combination of Channels to analyze?", newArray("1","2","3","4","12","13","14","23","24","34","123","124","134","234","1234"), "12"); //Choice4
Dialog.addCheckbox("Save generated images", false); //Tick5
Dialog.addCheckbox("ROIs are provided for the analysis", false);//Tick6

Dialog.addHelp("https://imagej.net/plugins/spots-colocalization-comdet");
Dialog.show();

// Fetch all the parameters from the first dialog box
SaveDir = Dialog.getString();//Str1
inside = Dialog.getCheckbox();//Tick1
SaveFolder = Dialog.getString();//Str2
calc = Dialog.getCheckbox();//Tick2
if (calc==true){ calc = "calculate";}
else {calc = "";}
Max = Dialog.getNumber();//Int1
join = Dialog.getCheckbox();//Tick3
if (join == true){join = "join";}
else {join = "";}
plot = Dialog.getCheckbox();//Tick4
if (plot==true){plot = "plot";}
else {plot = "";}
shape = Dialog.getChoice();//Choice1
add = Dialog.getChoice();//Choice2
if (add!="Nothing"){
	add = "["+add+"]";
}
table = Dialog.getChoice();//Choice3
channels = Dialog.getChoice();//Choice4
saving = Dialog.getCheckbox();//Tick5
rois = Dialog.getCheckbox();//Tick6

// make 2nd dialog box to get parameters for the channels that need to be analyzed
default = false;
Dialog.create("Parameters for the channels");
if (channels == "1" || channels == "2" || channels == "3" || channels == "4") {
	//Channel 1
	Dialog.addMessage("Options for channel "+channels);
	Dialog.addCheckbox("Include larger particles", default); //check1ch1
	Dialog.addCheckbox("Segment larger particles (slow)", default); //check2ch1
	Dialog.addNumber("Approximate particle size", 2, 2, 5, "pxs"); //no1ch1
	Dialog.addNumber("Intensity threshold (in SD)", 3, 2, 5, "around (3-20)"); //no2ch1
}

if (channels == "12" || channels=="13" || channels=="14" || channels=="23" || channels=="24" || channels=="34") {
	ch1 = substring(channels, 0,1);
	ch2 = substring(channels, 1,2);
	//Channel 1
	Dialog.addMessage("Options for channel "+ch1);
	Dialog.addCheckbox("Include larger particles", default); //check1ch1
	Dialog.addCheckbox("Segment larger particles (slow)", default); //check2ch1
	Dialog.addNumber("Approximate particle size", 2, 2, 5, "pxs"); //no1ch1
	Dialog.addNumber("Intensity threshold (in SD)", 3, 2, 5, "around (3-20)"); //no2ch1
	
	//Channel 2
	Dialog.addMessage("Options for channel "+ch2);
	Dialog.addCheckbox("Include larger particles", default); //check1ch2
	Dialog.addCheckbox("Segment larger particles (slow)", default); //check2ch2
	Dialog.addNumber("Approximate particle size", 2, 2, 5, "pxs"); //no1ch2
	Dialog.addNumber("Intensity threshold (in SD)", 3, 2, 5, "around (3-20)"); //no2ch2
}

if (channels == "123" || channels=="124" || channels=="134" || channels=="234") {
	ch1 = substring(channels, 0,1);
	ch2 = substring(channels, 1,2);
	ch3 = substring(channels, 2,3);
	//Channel 1
	Dialog.addMessage("Options for channel "+ch1);
	Dialog.addCheckbox("Include larger particles", default); //check1ch1
	Dialog.addCheckbox("Segment larger particles (slow)", default); //check2ch1
	Dialog.addNumber("Approximate particle size", 2, 2, 5, "pxs"); //no1ch1
	Dialog.addNumber("Intensity threshold (in SD)", 3, 2, 5, "around (3-20)"); //no2ch1
	
	//Channel 2
	Dialog.addMessage("Options for channel "+ch2);
	Dialog.addCheckbox("Include larger particles", default); //check1ch2
	Dialog.addCheckbox("Segment larger particles (slow)", default); //check2ch2
	Dialog.addNumber("Approximate particle size", 2, 2, 5, "pxs"); //no1ch2
	Dialog.addNumber("Intensity threshold (in SD)", 3, 2, 5, "around (3-20)"); //no2ch2
	
	//Channel 3
	Dialog.addMessage("Options for channel "+ch3);
	Dialog.addCheckbox("Include larger particles", default); //check1ch3
	Dialog.addCheckbox("Segment larger particles (slow)", default); //check2ch3
	Dialog.addNumber("Approximate particle size", 2, 2, 5, "pxs"); //no1ch3
	Dialog.addNumber("Intensity threshold (in SD)", 3, 2, 5, "around (3-20)"); //no2ch3
}

if (channels == "1234") {
	ch1 = substring(channels, 0,1);
	ch2 = substring(channels, 1,2);
	ch3 = substring(channels, 2,3);
	ch4 = substring(channels, 3,4);
	//Channel 1
	Dialog.addMessage("Options for channel "+ch1);
	Dialog.addCheckbox("Include larger particles", default); //check1ch1
	Dialog.addCheckbox("Segment larger particles (slow)", default); //check2ch1
	Dialog.addNumber("Approximate particle size", 2, 2, 5, "pxs"); //no1ch1
	Dialog.addNumber("Intensity threshold (in SD)", 3, 2, 5, "around (3-20)"); //no2ch1
	
	//Channel 2
	Dialog.addMessage("Options for channel "+ch2);
	Dialog.addCheckbox("Include larger particles", default); //check1ch2
	Dialog.addCheckbox("Segment larger particles (slow)", default); //check2ch2
	Dialog.addNumber("Approximate particle size", 2, 2, 5, "pxs"); //no1ch2
	Dialog.addNumber("Intensity threshold (in SD)", 3, 2, 5, "around (3-20)"); //no2ch2
	
	//Channel 3
	Dialog.addMessage("Options for channel "+ch3);
	Dialog.addCheckbox("Include larger particles", default); //check1ch3
	Dialog.addCheckbox("Segment larger particles (slow)", default); //check2ch3
	Dialog.addNumber("Approximate particle size", 2, 2, 5, "pxs"); //no1ch3
	Dialog.addNumber("Intensity threshold (in SD)", 3, 2, 5, "around (3-20)"); //no2ch3
	
	//Channel 4
	Dialog.addMessage("Options for channel "+ch4);
	Dialog.addCheckbox("Include larger particles", default); //check1ch4
	Dialog.addCheckbox("Segment larger particles (slow)", default); //check2ch4
	Dialog.addNumber("Approximate particle size", 2, 2, 5, "pxs"); //no1ch4
	Dialog.addNumber("Intensity threshold (in SD)", 3, 2, 5, "around (3-20)"); //no2ch4
}
Dialog.addHelp("https://imagej.net/plugins/spots-colocalization-comdet");
Dialog.show();

// Fetching Parameters from 2nd Window
if (channels == "1" || channels == "2" || channels == "3" || channels == "4") {
	ch1i = Dialog.getCheckbox(); //check1ch1
	ch1l = Dialog.getCheckbox(); //check2ch1
	ch1a = Dialog.getNumber(); //no1ch1
	ch1s = Dialog.getNumber(); //no2ch1
}
if (channels == "12" || channels=="13" || channels=="14" || channels=="23" || channels=="24" || channels=="34") {
	ch1i = Dialog.getCheckbox(); //check1ch1
	ch1l = Dialog.getCheckbox(); //check2ch1
	ch1a = Dialog.getNumber(); //no1ch1
	ch1s = Dialog.getNumber(); //no2ch1
	
	ch2i = Dialog.getCheckbox(); //check1ch2
	ch2l = Dialog.getCheckbox(); //check2ch2
	ch2a = Dialog.getNumber(); //no1ch2
	ch2s = Dialog.getNumber(); //no2ch2
}
if (channels == "123" || channels=="124" || channels=="134" || channels=="234") {
	ch1i = Dialog.getCheckbox(); //check1ch1
	ch1l = Dialog.getCheckbox(); //check2ch1
	ch1a = Dialog.getNumber(); //no1ch1
	ch1s = Dialog.getNumber(); //no2ch1
	
	ch2i = Dialog.getCheckbox(); //check1ch2
	ch2l = Dialog.getCheckbox(); //check2ch2
	ch2a = Dialog.getNumber(); //no1ch2
	ch2s = Dialog.getNumber(); //no2ch2
	
	ch3i = Dialog.getCheckbox(); //check1ch3
	ch3l = Dialog.getCheckbox(); //check2ch3
	ch3a = Dialog.getNumber(); //no1ch3
	ch3s = Dialog.getNumber(); //no2ch3
}
if (channels == "1234") {
	ch1i = Dialog.getCheckbox(); //check1ch1
	ch1l = Dialog.getCheckbox(); //check2ch1
	ch1a = Dialog.getNumber(); //no1ch1
	ch1s = Dialog.getNumber(); //no2ch1
	
	ch2i = Dialog.getCheckbox(); //check1ch2
	ch2l = Dialog.getCheckbox(); //check2ch2
	ch2a = Dialog.getNumber(); //no1ch2
	ch2s = Dialog.getNumber(); //no2ch2
	
	ch3i = Dialog.getCheckbox(); //check1ch3
	ch3l = Dialog.getCheckbox(); //check2ch3
	ch3a = Dialog.getNumber(); //no1ch3
	ch3s = Dialog.getNumber(); //no2ch3
	
	ch4i = Dialog.getCheckbox(); //check1ch4
	ch4l = Dialog.getCheckbox(); //check2ch4
	ch4a = Dialog.getNumber(); //no1ch4
	ch4s = Dialog.getNumber(); //no2ch4
}
// Loading images from folder --> splitting into individual channels --> merging wanted channels
for (folder=0; folder<LoadDirs.length; folder++){
	Dir = LoadDirs[folder];
	TempPrefix=split(Dir, "\\");
	prefix=TempPrefix[TempPrefix.length-1];
	SaveDir1 = SaveDir + prefix;
	Files = getFileList(Dir);
	Imgs = newArray();
	if (rois==true){ROIs = newArray();}
	// Preparing arrays containing paths to images and rois; these arrays should have same length (one roi per image and only a single roi, not a collection of them)
	for (file=0; file<Files.length; file++) {
		if (endsWith(Files[file], ".tif")==true || endsWith(Files[file], ".tiff")==true || endsWith(Files[file], ".stk")==true){
			img = Files[file];
			Imgs = Array.concat(Imgs,img);
		}
		if (endsWith(Files[file], ".roi")==true && rois==true){
			roi = Files[file];
			ROIs = Array.concat(ROIs,roi);
		}
	}
	if (rois==true){
		diff1 = Imgs.length-ROIs.length;
		diff2 = ROIs.length-Imgs.length;
		// failsafe for when there are less ROIs than images
		if (Imgs.length!=ROIs.length && ROIs.length<Imgs.length){
			for (i=0; i<diff1; i++){
				ROIs = Array.concat(ROIs,"");
			}
		}
		// failsafe when there are more ROIs than images
		if (Imgs.length!=ROIs.length && ROIs.length>Imgs.length){
			for (i=0; i<diff2; i++){
				Imgs = Array.concat(Imgs,"");
			}
		}
	}
	for (img=0; img<Imgs.length; img++){
		if (endsWith(Imgs[img], ".tif")==true || endsWith(Imgs[img], ".tiff")==true || endsWith(Imgs[img], ".stk")==true){
			run("Bio-Formats Windowless Importer", "open=["+Dir+"/"+Imgs[img]+"]");
			getDimensions(width, height, chs, slices, frames);
			if (channels != chs) {
				run("Split Channels"); //split channels
				if (lengthOf(channels)==2) {run("Merge Channels...", "c1=C"+ch1+"-/"+Imgs[img]+" c2=C"+ch2+"-/"+Imgs[img]+" create");} //merge WANTED channels
				if (lengthOf(channels)==3) {run("Merge Channels...", "c1=C"+ch1+"-/"+Imgs[img]+" c2=C"+ch2+"-/"+Imgs[img]+" c3=C"+ch3+"-/"+Imgs[img]+" create");} //merge WANTED channels
				if (lengthOf(channels)==4) {run("Merge Channels...", "c1=C"+ch1+"-/"+Imgs[img]+" c2=C"+ch2+"-/"+Imgs[img]+" c3=C"+ch3+"-/"+Imgs[img]+" c4=C"+ch4+"-/"+Imgs[img]+" create");} //merge WANTED channels
				rename(Imgs[img]);
				close("\\Others");
				if (saving==true){
					if (inside==true){
						SaveDir1 = Dir+"/"+SaveFolder;
						if (File.isDirectory(SaveDir1)==false){
							File.makeDirectory(SaveDir1);
						}
					}
					if (inside==false){
						if (File.isDirectory(SaveDir)==false){File.makeDirectory(SaveDir);}
						if (File.isDirectory(SaveDir1)==false){File.makeDirectory(SaveDir1);}
					}
					saveAs("Tiff", SaveDir1+"/Co-loc_"+Imgs[img]);}
			}
		if (endsWith(ROIs[img], ".roi")==true && rois==true){
			open(Dir+"/"+ROIs[img]);
		}
		// Launching plugin on newly created x-channel image depending on amount of channels
		SaveDir1 = SaveDir+"/"+prefix;
		if (inside==true){
			SaveDir1=Dir+"/"+SaveFolder;
			if (File.isDirectory(SaveDir1)==false){
				File.makeDirectory(SaveDir1);
			}
		}
		if (inside==false){
			if (File.isDirectory(SaveDir)==false){File.makeDirectory(SaveDir);}
			if (File.isDirectory(SaveDir1)==false){File.makeDirectory(SaveDir1);}
		}
		if (channels == "1" || channels == "2" || channels == "3" || channels == "4") {
			run("Detect Particles",  calc+" max="+Max+" "+join+" "+plot+" rois="+shape+" add="+add+" summary="+table+" "+ch1i+" "+ch1l+" ch1a="+ch1a+" ch1s="+ch1s);
		}
		if (channels == "12" || channels=="13" || channels=="14" || channels=="23" || channels=="24" || channels=="34") {
			run("Detect Particles",  calc+" max="+Max+" "+join+" "+plot+" rois="+shape+" add="+add+" summary="+table+" "+ch1i+" "+ch1l+" ch1a="+ch1a+" ch1s="+ch1s+" "+ch2i+" "+ch2l+" ch2a="+ch2a+" ch2s="+ch2s);
		}
		if (channels == "123" || channels=="124" || channels=="134" || channels=="234") {
			run("Detect Particles",  calc+" max="+Max+" "+join+" "+plot+" rois="+shape+" add="+add+" summary="+table+" "+ch1i+" "+ch1l+" ch1a="+ch1a+" ch1s="+ch1s+" "+ch2i+" "+ch2l+" ch2a="+ch2a+" ch2s="+ch2s+" "+ch3i+" "+ch3l+" ch3a="+ch3a+" ch3s="+ch3s);
		}
		if (channels == "1234") {
			run("Detect Particles",  calc+" max="+Max+" "+join+" "+plot+" rois="+shape+" add="+add+" summary="+table+" "+ch1i+" "+ch1l+" ch1a="+ch1a+" ch1s="+ch1s+" "+ch2i+" "+ch2l+" ch2a="+ch2a+" ch2s="+ch2s+" "+ch3i+" "+ch3l+" ch3a="+ch3a+" ch3s="+ch3s+" "+ch4i+" "+ch4l+" ch4a="+ch4a+" ch4s="+ch4s);
		}
		// Saving all results from plugin according to decisions
		saveAs("Tiff", SaveDir1+"/Marked_Co-loc_"+Imgs[img]);
		Table.rename("Results", Imgs[img]+"_Results.csv");
		saveAs("Results", SaveDir1+"/"+Imgs[img]+"_Results.csv");
		close(Imgs[img]+"_Results.csv");
		if (table=="Reset"){
			Table.rename("Summary", Imgs[img]+"_Summary.csv");
			saveAs("Results", SaveDir1+"/"+Imgs[img]+"_Summary.csv");
			close(Imgs[img]+"_Summary.csv");
		}
		if (add!="[All detections]" && add!="Nothing"){
			print(add);
			roiManager("Save", SaveDir1+"/"+Imgs[img]+"_Rois.zip");
			close("ROI Manager");
		}
		close("Log");
		close("*");
		}
	}
	if (table=="Append") {
		Table.rename("Summary", prefix+"_Summary.csv");
		saveAs("Results", SaveDir1+"/"+prefix+"_Summary.csv");
		close(prefix+"_Summary.csv");
	}

}




