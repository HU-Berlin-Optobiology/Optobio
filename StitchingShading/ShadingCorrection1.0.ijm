function inside(value, array) {
	for (i=0; i<array.length; i++) {
		if (value == array[i]) return true;
	}
	return false;
}
LoadDir = getDir("Path from where to load images");
Save = getString("Where to save images", "Def");
SaveDir = LoadDir + "/" + Save
if (File.exists(SaveDir)!= true){
	File.makeDirectory(SaveDir);
}
Imgs = getFileList(LoadDir);
WLs = newArray();
FileNamesUnique = newArray();
//Getting information about data
for (i=0; i<Imgs.length; i++){
	file = Imgs[i];
	if (endsWith(file, ".nd") |endsWith(file, ".ome")) { //If there is an ND- or OME-File it gets moved away into a ND folder
		ndPath = LoadDir+"/ND";
		if (File.isDirectory(ndPath)==0) {
			File.makeDirectory(ndPath);
		}
		File.rename(LoadDir+"/"+file, ndPath+"/"+file);
	}
	if (endsWith(file, "_s1.stk")) {
		FileNamesUnique = Array.concat(FileNamesUnique, file);
		filetype = ".stk";
		begin = 14;
		end = 10;
		base = 16;
		channelBegin = 10;
		channelEnd = 7;
		wl = substring(file, lengthOf(file)-channelBegin, lengthOf(file)-channelEnd);
		if (inside(wl, WLs)==false) {
			WLs = Array.concat(WLs,wl);
		}
	}
	else if (endsWith(file, "_s1.ome.tif")) {
		FileNamesUnique = Array.concat(FileNamesUnique, file);
		filetype = ".ome.tif";
		begin = 17;
		end = 14;
		base = 19;
		channelBegin = 14;
		channelEnd = 11;
		wl = substring(file, lengthOf(file)-channelBegin, lengthOf(file)-channelEnd);
		if (inside(wl, WLs)==false) {
			WLs = Array.concat(WLs,wl);
		}
		//New as of 3.4.3
		if (substring(FileNamesUnique[0], lengthOf(FileNamesUnique[0])-begin, lengthOf(FileNamesUnique[0])-end) != "sdc") {
			begin = 18;
			base = 20;
		}
	}
}
// Figuring out method used to get images, either sdc or Confocal
if (substring(FileNamesUnique[0], lengthOf(FileNamesUnique[0])-begin, lengthOf(FileNamesUnique[0])-end) == "sdc") {
	Method = "sdc";
}
else if (substring(FileNamesUnique[0], lengthOf(FileNamesUnique[0])-begin, lengthOf(FileNamesUnique[0])-end) == "Conf") {
	Method = "Conf";
}
// If only one channel used, file names won't have w1 and so on
if (lengthOf(FileNamesUnique) == 1) n = 2;
else n = 0;
//Getting Base Name of Images based on used Method (everything before w1... if available)
if (Method == "sdc") {
	FileNameBase = substring(FileNamesUnique[0], 0, lengthOf(FileNamesUnique[0])-base+n);
}
else if (Method == "Conf") {
	FileNameBase = substring(FileNamesUnique[0], 0, lengthOf(FileNamesUnique[0])-base+n);
}

//Open images in ascending order -> max-proj 'em -> stack 'em -> save stack
for (a=0;a<WLs.length;a++){
	wl = WLs[a];
	for (s=1;s<Imgs.length+1;s++) {
		for (i=0; i<Imgs.length;i++){
			file = Imgs[i];
			name = wl+"_s"+s+".ome.tif";
			if (endsWith(file, name)==true) {
				run("Bio-Formats Windowless Importer", "open="+LoadDir+"/"+file);
				rename(wl+"_s0"+s+"ome.tif");
			}
		}
	}
	Wins = getList("image.titles");
	for (i=0; i<Wins.length; i++){
		selectImage(Wins[i]);
		run("Z Project...", "projection=[Max Intensity]");
		rename("0"+i);
	}
	run("Convert Images to Stack");
	rename(wl+".tif");
	run("BaSiC ", "processing_stack="+wl+".tif flat-field=None dark-field=None shading_estimation=[Estimate shading profiles] shading_model=[Estimate flat-field only (ignore dark-field)] setting_regularisationparametes=Automatic temporal_drift=Ignore correction_options=[Compute shading and correct images] lambda_flat=0.50 lambda_dark=0.50");
	close("Log");
	selectImage("Corrected:"+wl+".tif");
	close("\\Others");
	run("Stack to Images");
	Wins2 = getList("image.titles");
	for (i=0; i<Wins2.length;i++){
		selectImage(Wins2[i]);
		saveAs("Tiff", SaveDir+"/"+FileNameBase+"w"+(a+1)+Method+wl+"_s"+(i+1)+".ome.tif");
	}
	close("*");
}

