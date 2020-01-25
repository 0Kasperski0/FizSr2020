clc;
clear;
tic
addpath('Images');  
addpath('Results/'); 
projectdir = 'Images';
files = dir(fullfile(projectdir));
files([files.isdir]) = [];
Dark=imread('PA160425DARK.jpg'); 
DarkF=imread('DARKfilmowy.jpg'); 
fileID2 = fopen(['Results\ksiezrozklady.txt'],'w');
debugmode=0; %1 - zdjêcia+ploty 0 - normalnie

fprintf(fileID2,['Nazwa:' '\t' '\t' 'mu:'  '\t\t' 'sigma:' '\n']);


for file = files'
IMG = imread(file.name);
[rows, columns, numberOfColorChannels] = size(IMG);

if (debugmode==1)
    figure;
    imshow(IMG);                                                               
end

if(columns==3216)
   IMG=IMG-Dark;
else
   IMG=IMG-DarkF;
end

IMG_GRAY= rgb2gray(IMG);
IMGMean=mean(IMG_GRAY(:));
THR=IMGMean*1.3;                       
BW = imcomplement(IMG_GRAY < 50);

BW = imclose(BW,strel('disk',2));
BW = imfill(BW,'holes');
BW=bwareafilt(BW,1); 
[B,L] = bwboundaries(BW,4,'noholes');
hold on
for k = 1:length(B)
    Boundary = B{k};
    if (debugmode==1)
        plot(Boundary(:,2),Boundary(:,1),'r','LineWidth',2);                                                             
    end
 
end
FName=extractBefore(file.name,'.');
PList = regionprops(L,'PixelList');
IMGpixs=PList.PixelList;  
PVal = regionprops(L,IMG_GRAY,'PixelValues','PixelList');

IMGPix=(PVal.PixelValues);
IMGPix=double(IMGPix);


if (debugmode==1)
    F=figure('Name',FName);
    H=histogram(IMGPix,'Normalization','probability');  
    
end

HF = fitdist(IMGPix,'Normal');

if (debugmode==1)
    histfit(IMGPix,20,'Normal');
    saveas(figure(F),[pwd '/Results/histograms/' FName '.fig']);
    saveas(figure(F),[pwd '/Results/pictures/' FName '.png']);
end

fprintf(fileID2,[FName '\t' num2str(HF.mu) '\t\t' num2str(HF.sigma) '\n']);

if (debugmode==1)
    fileID = fopen(['Results\data\' FName '.txt'],'w');           
    fprintf(fileID,'%6.2f \r\n',IMGPix);
    fclose(fileID);
end
               
end
toc
fclose(fileID2);
