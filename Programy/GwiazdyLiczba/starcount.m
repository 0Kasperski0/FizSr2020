clc;
clear;
tic
addpath('Images');  
addpath('Results/'); 
projectdir = 'Images';
files = dir(fullfile(projectdir));
files([files.isdir]) = [];
dark=imread('PA160425DARK.jpg'); 
debugmode=0; %1 - zdjêcia+wykresy 0 - normalnie

fileID = fopen(['Results\data\lgwiazd.txt'],'w');
fprintf(fileID,['Nazwa:' '\t' '\t' 'Liczba gwiazd:'  '\t' 'Ratio:'  '\t\t' 'Data wykonania:' '\n']);
for file = files'
IMG = imread(file.name);
IMGinfo=imfinfo(file.name);

if (debugmode==1)
    figure;                                 
    imshow(IMG);                                                                      
end

IMG=IMG-dark;
IMG_GRAY= rgb2gray(IMG);
IMGmean=mean(IMG_GRAY(:));
THR=IMGmean*1.3;                                                       
BW = imcomplement(IMG_GRAY < THR);                              
BW = imclose(BW,strel('disk',2));
BW = imfill(BW,'holes');

StarCount=regionprops(BW,'EulerNumber');
StarArea=regionprops(BW,'Area');                    
StarArea=struct2array(StarArea);
Sum=sum(StarArea);
Ratio = Sum/(IMGinfo.Width*IMGinfo.Height); 
[B,L] = bwboundaries(BW,4,'noholes');
                                                       
if (debugmode==1)  
    hold on                                                                      
end

for k = 1:length(B) 
    boundary = B{k};
    if (debugmode==1)  
         plot(boundary(:,2),boundary(:,1),'r','LineWidth',2);                                                                         
    end
  
end

Stats = regionprops(L,'PixelList');
IMGpixs=Stats.PixelList; 
Stats = regionprops(L,IMG_GRAY,'PixelValues','PixelList');
ch=extractBefore(file.name,'.');

if (debugmode==1)
    F=figure('Name',ch);
    H=histogram(StarArea); 
    saveas(figure(F),[pwd '/Results/histograms/' ch '.fig']);
    saveas(figure(F),[pwd '/Results/pictures/' ch '.png']);
end

fprintf(fileID,[ch '\t' num2str(numel(StarCount)) '\t\t' num2str(Ratio) '\t' num2str(IMGinfo.DateTime)  '\n']);   

end
fclose(fileID);
toc

