
//	MIT License

//	Copyright (c) 2019 Nicholas Condon n.condon@uq.edu.au

//	Permission is hereby granted, free of charge, to any person obtaining a copy
//	of this software and associated documentation files (the "Software"), to deal
//	in the Software without restriction, including without limitation the rights
//	to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//	copies of the Software, and to permit persons to whom the Software is
//	furnished to do so, subject to the following conditions:

//	The above copyright notice and this permission notice shall be included in all
//	copies or substantial portions of the Software.

//	THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//	IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//	FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//	AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//	LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//	OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//	SOFTWARE.

print("\\Clear")
run("Clear Results");


scripttitle="Ruffle Quantification";
version="1.0";
date="26/08/2019";
description="This automated script measures dorsal ruffle area and intensity from Z-stack (3D) images and is written in the ImageJ macro language. "
+"Regions of dorsal ruffling are determined as being from the 'top half of the cell' which is largest cross-sectional midpoint of the nucleus. <br><br>"
+"This script requires 2-channel images as the file input and should be within a single directory, with Actin labelling in Channel 1 and nuclei labelling in Channel 2. The script will request the file extension for filtering (eg. .tif). <br><br>"
+"Images are processed automatically in a loop and stored in a newly created output folder with the script runtime appended. Output files include a log, excel spreadsheet and two image files. "
+"The first image file is the summed (Z-projected) ruffle region merged ontop of the cell area threshold image, while the second is the thresholded area of the ruffles merged with the cell area. <br><br>"
+"Tip: To turn off the Bio-Formats importer window follow instructions "+"<a href=https://github.com/NickCondon/BioFormatsInstructions>here.</a>"
   
showMessage("Institute for Molecular Biosciences ImageJ Script", "<html>" 
    +"<h1><font size=6 color=Teal>ACRF: Cancer Biology Imaging Facility</h1>
    +"<h1><font size=5 color=Purple><i>The University of Queensland</i></h1>
    +"<h4><a href=http://imb.uq.edu.au/Microscopy/>ACRF: Cancer Biology Imaging Facility</a></h4>"
    +"<h1><font color=black>ImageJ Script Macro: "+scripttitle+"</h1> "
    +"<p1>Version: "+version+" ("+date+")</p1>"
    +"<H2><font size=3>Created by Dr Nicholas Condon</H2>"	
    +"<p1><font size=2> contact n.condon@uq.edu.au \n </p1>" 
    +"<P4><font size=2> Available for use/modification/sharing under the "+"<p4><a href=https://opensource.org/licenses/MIT/>MIT License</a><\h4> </P4>"
//    +"<h3>   <\h3>"    
    +"<p1><font size=3 \b i>"+description+"</p1>"
   	+"<h1><font size=2> </h1>"  
	+"<h0><font size=5> </h0>"
    +"");


print("");
print("FIJI Macro: "+scripttitle);																	//Writes to log window script title 
print("Version: "+version+" Version Date: "+date);													//Writes to log window script version number and Date
print("ACRF: Cancer Biology Imaging Facility");														//Writes to log window acknowledgement
print("By Nicholas Condon (2019) n.condon@uq.edu.au")												//Writes to log window acknowledgement
print("");
getDateAndTime(year, month, week, day, hour, min, sec, msec);										//Gets date and time for script run date
print("Script Run Date: "+day+"/"+(month+1)+"/"+year+"  Time: " +hour+":"+min+":"+sec);				//Writes to log window script run date
print("");


path = getDirectory("Choose a Directory containing tiffs of macropinocytosis");						//Gets the file path
list = getFileList(path);																			//Gets the list of files within that directory
resultsDir = path+"Analysis_Results_"+year+"-"+month+"-"+day+"_at_"+hour+"."+min+"/";				//Creates a path and name for output directory
File.makeDirectory(resultsDir);																		//Creates output directory
print("**** Parameters ****");																		//Creates header for log window
print("Working Directory Location: "+path);															//Writes to log window working directory location

summaryFile = File.open(resultsDir+"Quantification_Outputs_"+year+"-"+month+"-"+day+"_at_"+hour+"."+min+".xls");	//Creates Excel output file with headers below
print(summaryFile,"ImageId \t Number of Cells \t Number of Nuclei \t Middle Slice#  \t Total Slice# \t Total Cell Area  \t Sum Intensity (F-Actin) \t Total Area Ruffles (Top F-Actin) \t Ratio Top:Bottom (Area) \t Ratio Sum Intensity: Cell Area \t Normalised Ratio Top:Bottom \t Normalise Sum Intensity:Area \n" );


ext = ".tif";																						//Variable for file name extension
  Dialog.create("Select Filename filter");															//File name filter dialog
  	Dialog.addString("File Extension:", ext);														//Dialog for user input of file extension
 	Dialog.addMessage("(For example .czi  .lsm  .nd2  .lif  .ims)");								//Example file extensions to remind user
  	Dialog.addMessage(" ");																			//Spacing
 	Dialog.show();																					//Shows dialog
	ext = Dialog.getString();																		//Updates extension variable with users input
	print("File extension: "+ext);																	//Writes to log window chosen file extension


start = getTime();																					//Creates an internal timer



print("");
print("**** Event Logger ****");																	//Writes to log window header for Event Logger section

for (z=0; z<list.length; z++) {																		//Loop for selecting files to open
	if (endsWith(list[z],ext)){																		//Confirms file extension has the selected file name filter [ext]
		open(path+list[z]);																			//Opens the file
 		windowtitle = getTitle();																	//Gets the name of the file and defines variable
		windowtitlenoext = replace(windowtitle, ext, "");											//Defines a new variable with the file name with no extension

																	
print("");

print("Opening File: "+(z+1)+" of "+list.length);													//Writes to log which file is being opened (number)
print("Filename = "+ windowtitle);																	//Writes to log which file is being opened (name)

getDimensions(width, height, channels, slices, frames);												//Gets dimensions of the currently open file
totSlices = slices;
setBatchMode(1);																					//Turns on background mode


run("Duplicate...", "title=nuc duplicate channels=2");												//Duplicates the nuclei channel (channel 2)
run("Median...", "radius=2 stack");																	//Runs a median filter
setAutoThreshold("Otsu dark");
run("Convert to Mask", "method=Default background=Dark black");										//Converts the threshold selection to a mask
run("Close-", "stack");																				//Closes any open areas of the resultant threshold
run("Fill Holes", "stack");																			//Fills any holes within the resultant threshold
run("Clear Results");																				//Clears any results in the results window
AreaA = newArray(nSlices);																			//Creates an array to place measurements of each slices nuclei area into
for (i=0;i<nSlices;i++){																			//Loop for each slide
	setSlice(i+1);																					//Sets the slice as the loop number plus 1 (base0)
	run("Measure");																					//Measures the mean intensity of nuclei for the given slice
	Apix = (getResult("Mean",0)*getResult("Area",0)/255);											//Calculates the number of pixels based off of the average intensity by the area
	AreaA[i] = Apix;																				//Prints the number of 'positive' nuclei pixels into the array 
	run("Clear Results");																			//Clears any results in the results window
}
Array.getStatistics(AreaA, min, max, mean, stdDev);													//Queries the array for its maximum number
print("Maxium Value of nuclei found = "+max);														//Writes to the log window the maximum number of pixels found within the array
run("Clear Results");																				//Clears any results in the results window


Apix=0;k=0;																							//Defines variables for finding midpoint slice number
for (k=0; k<nSlices && max!=Apix; k++){																//Loop to query each nuclei area until it matches the maximum found above
	setSlice(k+1);																					//Sets the slice as the loop number plus 1 (base0)
	run("Measure");																					//Measures the mean intensity of nuclei for the given slice
	Apix = (getResult("Mean",0)*getResult("Area",0)/255);											//Calculates the number of pixels based off of the average intensity by the area
	run("Clear Results");																			//Clears any results in the results window
}

if (k==slices){k= (nSlices/2);}
print("Maxium nuclei area = Slice: "+k+" (of "+totSlices+" slices)");								//Writes to log window the Slice number with the largest nuclei area (midpoint)
midPoint = k;																						//Defines mid-point variable
setBatchMode(0);																					//Turns off background mode


selectWindow("nuc");																				//Selects nuclei image stack
run("Z Project...", "projection=[Sum Slices]");														//Runs a SUM Z-projection
setAutoThreshold("Moments dark");																	//Detects nuclei using the "Moments" threshold algorithm
run("Convert to Mask");																				//Converts the threshold into a mask
run("Analyze Particles...", "size=10-Infinity show=Masks summarize");								//Finds the number of nuclei using Analyse particles tool
selectWindow("Summary");																			//Selects the Summary window
IJ.renameResults("Results");																		//Converts the summary window to a Results window
numNuc = getResult("Count", 0);																		//Collects the count of nuclei and adds to variable numNuc
print("The number of Nuclei Found = "+ numNuc);														//Writes to log window the number of nuclei found
run("Clear Results");																				//Clears any results in the results window
saveAs("tiff", resultsDir+windowtitlenoext+"_Merged-Threshed-Nuc.tif");  							//Saves the resultant merged image into results directory with appended description

selectWindow(windowtitle);																			//Selects original file window
run("Duplicate...", "title=actin duplicate channels=1");											//Duplicates Channel 1 calling it actin
run("Z Project...", "stop="+midPoint+" projection=[Max Intensity]");								//Runs a Maximum Z-Projection from slice 1 to midpoint variable
rename("Bottom");																					//Renames image "Bottom"
run("Duplicate...", "title=ThreshBottom");															//Creates a duplicate of "Bottom"
run("Median...", "radius=2");																		//Runs a median filter
setAutoThreshold("Triangle dark");																	//Detects base of cell using Triangle threshold algorithm
//setThreshold(8, 255);
run("Convert to Mask");																				//Converts threshold into a mask


run("Red");																							//Runs red LUT
run("Measure");																						//Runs the measure command
CellAPix = (getResult("Mean",0)*getResult("Area",0)/255);											//Defines variable and calcultes number of pixels that make up the cell area (base measurement)
print("Cell Area = "+CellAPix);																		//Writes to the log window the cell area


run("Duplicate...", "title=CellCounter");															//Duplicates the thresholded bottom of cells image calling it "CellCounter"
run("Distance Map");																				//Runs the binary command Distance Map to split touching cells
setAutoThreshold("IJ_IsoData dark");																//Converts resultant distance map into binary
setOption("BlackBackground", true);																	//Defines foreground/background
run("Convert to Mask");																				//Converts the threshold into a mask
run("Analyze Particles...", "size=30-Infinity show=Masks summarize");								//Counts the number of cells using analyse particles
selectWindow("Summary");																			//Selects the Summary window
IJ.renameResults("Results");																		//Converts the sumary window to a Results window
numCells = getResult("Count", 0);																	//Collects the count of cells and adds to variable numCells
print("The number of Cells Found = "+ numCells);													//Writes to log window the number of cells found
run("Clear Results");																				//Clears any results in the results window


selectWindow("actin");																				//Selects the channel 1 stack image called actin
run("Z Project...", "start="+midPoint+" projection=[Sum Slices]");									//Runs a Maximum Z-Projection from midpoint slice variable to nSlices
rename("Top");																						//Renames image "Top"
run("Clear Results");																				//Clears any results in the results window
run("Measure");																						//Runs the measure command
Sumpix = getResult("Mean",0)*getResult("Area",0);													//Defines variable and calculates number of pixels that make up the ruffle intensity (top measurement)
print("Sum intensity of pixels = "+Sumpix);															//Writes to the log window the sum pixel intensity of ruffles


run("Duplicate...", "title=ThreshTop");																//Duplicates the dorsal image and calls it "ThreshTop"
run("Subtract Background...", "rolling=20");														//Removes out of focus light for threshold
setAutoThreshold("Moments dark");																	//Detects ruffle regions based on Moments threshold algorithm
run("Convert to Mask");																				//Converts threshold into a mask
saveAs("tiff", resultsDir+windowtitlenoext+"_Merged-Threshed-ruffles.tif");  						//Saves the resultant merged image into results directory with appended description
rename("ThreshTop");
run("Clear Results");																				//Clears any results in the results window
run("Measure");																						//Runs the measure command
TopArea = (getResult("Mean",0)*getResult("Area",0)/255);											//Defines variable and calcultes number of pixels that make up the ruffle area (top measurement)
print("The Top Area = "+TopArea);																	//Writes to the log window the sum pixel intensity of ruffles


RatioArea = TopArea/CellAPix;																		//Calculates the ratio of top area to bottom area (ruffles to cell area)
print("The Ratio of Top:Bottom areas = "+RatioArea);												//Writes to log window the ratio of top area to bottom area
RatioInt = Sumpix/CellAPix;																			//Calculates the ratio of top intensity to bottom area (Summed ruffle intensity to cell area)
print("The Ratio of Sum Intensity Top:Bottom area = "+RatioInt);									//Writes to log window the ratio of top summed intensity to bottom area

normRatioArea = (TopArea/CellAPix)/numCells;														//Normalises the ratio area by the number of cells
print("The Normalised Ratio of Top:Bottom areas = "+normRatioArea);									//Writes to log window the normalised ruffle area
normRatioInt = (Sumpix/CellAPix)/numCells;															//Normalises the ratio intensity by the number of cells
print("The Normalised Ratio of Sum Intensity Top:Bottom area = "+normRatioInt);						//Writes to log window the normalise ruffle intensity (sum)

																									//Following line prints calculated variables and key results to csv output file
print(summaryFile,windowtitle+ "\t"+numCells+"\t"+numNuc+"\t"+midPoint+"\t"+totSlices+"\t"+CellAPix+"\t"+Sumpix+"\t"+TopArea+"\t"+RatioArea+"\t"+RatioInt+"\t"+normRatioArea+"\t"+normRatioInt+"\n");

selectWindow("Bottom");																				//Selects image called bottom (thresholded cell area)											
run("32-bit");																						//Converts image to 32-bit
run("Red");																							//Runs red LUT

selectWindow("Top");																				//Selects image called Top (Sum projection of ruffles)
run("Green");																						//Runs green LUT
run("Merge Channels...", "c1=Bottom c2=Top create keep");											//Merges these to images into a single image
rename("Merge_Orig");																				//Renames the image
run("RGB Color");																					//Flattens output image as RGB
run("Enhance Contrast", "saturated=0.2");															//Enhances displayed brightness & contrast
saveAs("tiff", resultsDir+windowtitlenoext+"_Merged-Summed-Ruffles.tif");  							//Saves the resultant merged image into resutls directory with appended description

selectWindow("ThreshTop");																			//Selects image called ThreshTop (Thresholded iamge of ruffles)
run("Green");																						//Runs the green LUT
run("Merge Channels...", "c1=ThreshBottom c2=ThreshTop create keep");								//Merges these to images into a single image
rename("Merge_Thresh");																				//Renames the image
saveAs("tiff", resultsDir+windowtitlenoext+"_Merged-Threshed-Area.tif");  							//Saves the resultant merged image into results directory with appended description

while (nImages>0){close();}																			//Loop for closing all other image windows
}																									//Ends file list opening loop
}																									//Ends filtering list loop


print("");																							
print("Batch Completed");																			//Writes to log window that the script is finished
print("Total Runtime was: "+((getTime()-start)/1000));												//Writes to log window script runtime


selectWindow("Log");																				//Selects the log window
saveAs("Text", resultsDir+"Log.txt");																//Saves the log window into results directory


title = "Batch Completed";																			//Creates title for a pop-up window
msg = "Put down that coffee! Your analysis is finished";											//Creates message contents for pop-up window
waitForUser(title, msg); 																			//Waits for user to acknowledge end of script



