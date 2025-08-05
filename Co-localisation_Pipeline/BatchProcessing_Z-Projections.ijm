//TODO: Saving name needs to be adjusted to the name of the used raw data

// Macro to generate images with some sort of Z-Projection out of all available raw data
// Get multiple Folders from where to load images
LoadDirs = newArray();
AddFolder = true;
while (AddFolder==true) {
	if (LoadDirs.length>0) {
			File.setDefaultDir(LoadDirs[LoadDirs.length-1]);
		}
	Dir = getDir("Choose Folder from where to load images");
	LoadDirs = Array.concat(LoadDirs,Dir);
	if (LoadDirs.length==1){print("These are your chosen folders:");}
	print(Dir);
	AddFolder = getBoolean("Do you wish to add more folders?");
}
if(LoadDirs.length==1){File.setDefaultDir(LoadDirs[0]);}
close("Log");

//Window to get parameters from user about how to process
Dialog.create("Options on how to handle data");
Dialog.addMessage("All generated images will be saved inside a generated folder inside original folder");
Dialog.addMessage("The Z-Projection will always be applied on the whole stack from slice 1 to the end");
Dialog.addString("Name of folder where generated images will be saved:", "Default"); //Str1
Dialog.addChoice("What Z-projection should be applied? ", newArray("none","Average Intensity","Max Intensity", 
"Min Intensity","Sum Slices", "Standard Deviation", "Median")); //Choice1
Dialog.addChoice("What colour-code should be applied?", newArray("RGB","YMC"), "RGB"); //Choice2
Dialog.show();

//Fetch parameters from window
SaveFolder = Dialog.getString();//Str1
projection = Dialog.getChoice();//Choice1
//präfix for saved images
if (projection=="Median"){prefix = "MED_";}
else if (projection=="none"){prefix = "none_";}
else if (projection=="Average Intensity"){prefix = "AVG_";}
else if (projection=="Max Intensity"){prefix = "MAX_";}
else if (projection=="Min Intensity"){prefix = "MIN_";}
else if (projection=="Sum Slices"){prefix = "SUM_";}
else if (projection=="Standard Deviation"){prefix = "STD_";}
colour = Dialog.getChoice();//Choice2

//Window to get number of channels for every loaded folder
Dialog.create("Number of channels in every folder");
for (i=0;i<LoadDirs.length;i++){
	Dialog.addNumber("# channels inside "+LoadDirs[i]+":", 3);
}
Dialog.show();

//Fetch # Channels per folder from window
Channels = newArray();
for (j=0;j<LoadDirs.length;j++){
	channel = Dialog.getNumber();//channel
	Channels = Array.concat(Channels,channel);
}

//Processing Folders and therefore images
//be carefull with new ome.tif files. opening one of the channels is already opening the whole stack including all channels --> open companion.ome instead
for (folder=0;folder<LoadDirs.length;folder++){
	Option2 = false;
	LoadDir = LoadDirs[folder];
	SaveDir = LoadDir+"/"+SaveFolder;
	Files = getFileList(LoadDir);
	File.makeDirectory(SaveDir);
	ImgFiles = newArray();
	Channel = Channels[folder];
	for (f=0;f<Files.length;f++){
		file = Files[f];
		if (endsWith(file, ".tif")==true || endsWith(file, ".stk")==true || endsWith(file, ".tiff")==true){
			ImgFiles = Array.concat(ImgFiles,file);
		}
	}
	Amount = ImgFiles.length/Channel;
	for (img=0;img<Amount;img++){
		for (k=0;k<Channel;k++){
			Img = ImgFiles[img*Channel+k];
			if (endsWith(Img, ".ome.tif")==true && k==0){//encountered .ome.tif file --> opne only one of the images --> when k==0
				run("Bio-Formats Windowless Importer", "open=["+LoadDir+"/"+Img+"]");
				TempName = getTitle();
				NameArray = split(TempName, "_");
				name = prefix;
				for (i=0;i<NameArray.length-1;i++){
					name = name+"_"+NameArray[i];
				}
				getDimensions(width, height, channels, slices, frames);
				if (slices>1){run("Z Project...", "projection=[" + projection + "]");}//prevents unwanted results with z-projection when only one slice per channel
				saveAs("Tiff", SaveDir+"/"+name+".tif");
				close("*");
			}
			else if (endsWith(Img,".tif")==true || endsWith(Img,".stk")==true || endsWith(Img,".tiff")==true){// no .ome.tif file --> open every single channel and handle them accordingly
				open(LoadDir+"/"+Img);
				Option2=true;
			}
		}
		TempName = getTitle();
		NameArray = split(TempName, "_");
		name = prefix;
		for (i=0;i<NameArray.length-1;i++){
			name = name+"_"+NameArray[i];
		}
		if (Option2==true){
			Imgs = getList("image.titles");
			if (Channel==1){
				getDimensions(width, height, channels, slices, frames);
				if (slices>1){run("Z Project...", "projection=[" + projection + "]");}
				saveAs("Tiff", SaveDir+"/"+name+".tif");
				close("*");
			}
			else if (Channel==2){
				if (colour=="YMC") {run("Merge Channels...", "c5="+Imgs[1]+" c6="+Imgs[0]+" create");}//YMC
				else if (colour=="RGB") {run("Merge Channels...", "c1="+Imgs[1]+" c2="+Imgs[0]+" create");}//RGB
				getDimensions(width, height, channels, slices, frames);
				if (slices>1){run("Z Project...", "projection=[" + projection + "]");}
				saveAs("Tiff", SaveDir+"/"+name+".tif");
				close("*");
			}
			else if (Channel==3){
				if (colour=="YMC") {run("Merge Channels...", "c5="+Imgs[1]+" c6="+Imgs[0]+" c7="+Imgs[2]+" create");}//YMC
				else if (colour=="RGB") {run("Merge Channels...", "c1="+Imgs[1]+" c2="+Imgs[0]+" c3="+Imgs[2]+" create");}//RGB
				getDimensions(width, height, channels, slices, frames);
				if (slices>1){run("Z Project...", "projection=[" + projection + "]");}
				saveAs("Tiff", SaveDir+"/"+name+".tif");
				close("*");
			}
			else if (Channel==4){
				if(colour=="YMC") {run("Merge Channels...", "c4="+Imgs[3]+" c5="+Imgs[1]+" c6="+Imgs[0]+" c7="+Imgs[2]+" create");} //YMC
				else if (colour=="RGB") {run("Merge Channels...", "c1="+Imgs[1]+" c2="+Imgs[0]+" c3="+Imgs[2]+" c4="+Imgs[3]+" create");}//RGB
				getDimensions(width, height, channels, slices, frames);
				if (slices>1){run("Z Project...", "projection=[" + projection + "]");}
				saveAs("Tiff", SaveDir+"/"+name+".tif");
				close("*");
			}
		}
	}
}
