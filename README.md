# MeMRI PTB
<p align="justify">
The Metabolic MRI Processing Toolbox (MeMRI-PTB) allows converting, processing, quantifying (TBD) and visualizing (TBD) raw-export metabolic imaging data i.e. multi-dimensional spectroscopy data from both Siemens and Philips MR platforms in MATLAB. Additionally, the processing application and scripts are MR-system independent and the full MeMRI-PTB package includes custom code support for data conversions and processing methods.
</p>

# **Installation**
<p align="justify">
MeMRI-PTB can be downloaded here, or retrieved via the MATLAB environment allowing seamless updating via pull-requests. See below for the latter assuming git is installed on your PC (see https://gitforwindows.org/ ). In both cases, do run memri_install() before first use. </p>

## **Github in MATLAB**
<p align="justify">
Create an empty folder for MeMRI-PTB named Metabolic-MRI-Processing-Toolbox in MATLAB using the “Current Folder” pane via right-click > New > Folder. For a custom root directory name, see the paragraph below. Open the directory Metabolic-MRI-Processing-Toolbox, right-click inside the “Current Folder” pane and select “Source Control”. The window below will appear: </p>

<img width="936" height="466" alt="image" src="https://github.com/user-attachments/assets/05df92b2-88d5-42fa-8147-6a7e8bc0fcc0" />

<p align="justify">
Select Git as “Source Control Integration” and enter the github path “https://github.com/Illuminate-MeMRI/Metabolic-MRI-Processing-Toolbox” in the “Repository path” editfield. Click “retrieve” at the bottom right and continue after MATLAB has downloaded all files. </p>

> [!IMPORTANT]
After all files have been downloaded, **run the memri_install() script** from the root-directory of the MeMRI-PTB to add the required folders to MATLAB's search path.

<p align="justify"> This ensures all directories and files can be found by the applications and scripts. Do update memri_findRoot() if a different root-directory name is used, see below. </p>

## **Custom root directory**
A custom directory name for the GitHub repository requires an update to the function memri_findRoot() in ... > functions > framework. The root-directory name is stored as variable “stroi”, the first code-line in the file, and must be changed to the root directory name of MEMRI-PTB.

## **Example data**
The MRS example data is too large for default use with github and therefore stored at a different (onedrive-cloud) location.

[Philips data](https://1drv.ms/u/c/5f8322958f5befbc/IQCn-ZvLp0yRRLIvRbqVTIp5ARbksLR0-qfTeTrS_jfFPR8?e=l88Ppz)  [384MB] ---- SHA256: 296359abc7478f3b43e1ec928850e3672f61b8b5c402885088c0f0ae86654242

[Siemens data](https://1drv.ms/u/c/5f8322958f5befbc/IQCaO6PB-vIjTaQR_RnXiYOKAUDYf_VcKTHEz_y_kiUxZOI?e=do6mDd)  [307MB] ---- SHA256: 88eac8a950a874b6a12d114cbc23663ce837c0c14d67f3068b881c5ef5dcfaa1

# Framework
<p align="justify">
The MeMRI-PTB framework is split into three hierarchical layers. The first layer comprises the core methodology, which is complemented by a second data management layer responsible for coordinating and overseeing its functionality. The final layer consists of application-level components for graphical interfacing, which provide access to and interaction with the underlying framework. Every processing method is a module in the MeMRI-PTB framework and allows custom processing methods (i.e. modules) to be added to the application or scripted processing pipelines easily with the provided guides.

# Dependencies
Solely the MeMRI-PTB data conversion application and scripts are MR-system dependent and read and convert Siemens and Philips data: dat-files and list/data-files, to a generalized MATLAB structure-format. Custom-code is supported and in combination with provided guides allows user to implement read and conversion scripts for unsupported MR-system data. 
</p>

# **Background**
<p align="justify">
Large x-nuclei spectroscopy data sets from high-field MR systems are becoming more prevalent in the recent decades due to technological advances in both hardware and computing power. Increases in RF coil density i.e. phased arrays, allow acquisition over large field of views (FOV) paving the way for upper and lower body MRS applications.
However, MR systems cannot handle these data sets using the conventional reconstruction pipelines and are often poorly documented. New processing methods have been introduced to increase sensitivity through new coil-combination and denoising methods. Therefor raw spectroscopy data is often exported for offline reconstruction. 
Multi-centre studies with different MR-system vendors are a crucial part of translating academic research into clinical practice. Unfortunately, there is no consensus on processing methods nor their implementation. Therefore, we collaborated between 4 sites in 3 European countries to streamline data handling and visualization methodology. This resulted in this metabolic MR imaging processing toolbox available for the entire MR spectroscopy community.
</p>

For more information about the Illuminate project, please visit: https://www.ihi-illuminate.org/
