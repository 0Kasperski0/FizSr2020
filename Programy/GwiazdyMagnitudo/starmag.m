clc;
clear;
tic
addpath('Images');  
addpath('Results/'); 
projectdir = 'Images';
files = dir(fullfile(projectdir));
files([files.isdir]) = [];
dark=imread('PA160425DARK.jpg'); 


for file = files'
IMG = imread(file.name);
fname=extractBefore(file.name,'.');

Image=figure;
imshow(IMG);

IMG=IMG-dark;
IMG_GRAY= rgb2gray(IMG);


THR=mean(IMG_GRAY(:))*1.3;             
BW = imcomplement(IMG_GRAY < THR);   
BWall=BW;



BW = imclose(BW,strel('disk',2));
BW = imfill(BW,'holes');
% pocz¹tkowy histogram dla porównania wartoœci
BWhist=BW;
[B,L] = bwboundaries(BWhist,4,'noholes');
statsh = regionprops(L,IMG_GRAY,'Area');
SurfHS=struct2array(statsh);
SurfHS = SurfHS(SurfHS~=1); 
SurfHS=sort(SurfHS');
HS=figure;
histogram(SurfHS);



THRbw=input('Podaj wartoœæ progu dla powierzchni:\n'); 
                                 
BW=bwareafilt(BW,[1 THRbw]);
BW=bwareafilt(BW,1);
close(HS);
figure(Image);

[B,L] = bwboundaries(BW,4,'noholes');
hold on
for k = 1:length(B)
  boundary = B{k};
  plot(boundary(:,2),boundary(:,1),'g','LineWidth',2);
end

MAG=input('Podaj wartoœæ mag zaznaczonej gwiazdy: \n');

StarArea = regionprops(L,IMG_GRAY,'Area');
StarInt=regionprops(L,IMG_GRAY,'MeanIntensity');
StarIntArr=struct2array(StarInt);
MainStar=struct2array(StarArea);
MainStar = MainStar(MainStar~=1);   
MainStar=MainStar*StarIntArr;


BW = imclose(BWall,strel('disk',2));
BW = imfill(BW,'holes'); 
                                        
BW=bwareafilt(BW,[1 THRbw]);
[B,L] = bwboundaries(BW,4,'noholes');
hold on
for k = 1:length(B)
  boundary = B{k};
  %plot(boundary(:,2),boundary(:,1),'r','LineWidth',2);         %rysowanie wszystkich gwiazd
end

StarArea = regionprops(L,IMG_GRAY,'Area');
Itensity=regionprops(L,IMG_GRAY,'MeanIntensity');
Itensity=struct2array(Itensity);
Surface=struct2array(StarArea);
Surface=Surface';
Itensity=Itensity';
Surface=Surface.*Itensity;

MagArr=2.5*log10(MainStar./Surface);
MagArr=MagArr+MAG;

close(Image);
F=figure('Name',fname);
H=histogram(MagArr,40);

saveas(figure(F),[pwd '/Results/histograms/' fname '.fig']);
saveas(figure(F),[pwd '/Results/pictures/' fname '.png']);

fileID = fopen(['Results\data\' fname '.txt'],'w');
fprintf(fileID,'%6.2f \r\n',MagArr); %zapis magnitudo do pliku txt
fclose(fileID);


end
toc
