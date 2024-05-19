clc;
close all;
clear all;

global CAMERA_TEST
CAMERA_TEST       = 'C';
global VIDEO
VIDEO             = 'HDV_0056';

load(strcat(VIDEO,'_cam',lower(CAMERA_TEST),'_trajectories.mat')); % T.mat
j = 0;
k = 0;
arr = zeros(size(T)); % T.mat variable of trajectories

TT          = [];
DBTemp      = [];
features    = [];
DBFeatures  = [];
trajectory  = [];
centroides  = [];


for i = 1 : length(T) 
    elements = size(T(i).trajectory,1);
    arr(i) = elements; 
    if(elements > 10)
        j = j + 1;
        trajectory(j) = elements;
        TT = [TT ; T(i)];
        
        centroides(j).X = T(i).trajectory(:,7); % "CentroidX";
        centroides(j).Y = T(i).trajectory(:,8); % "CentroidY";
        
%       features(j).id          = T(i).trajectory(:,1);  % "ID";
%       features(j).frame       = T(i).trajectory(:,2);  % "FRAME";
%       features(j).prevobj     = T(i).trajectory(:,3);  % "PrevOBJ";
%       features(j).currobj     = T(i).trajectory(:,4);  % "CurrOBJ";
        features(j).area        = T(i).trajectory(:,5);  % "Area";
        features(j).perimeter   = T(i).trajectory(:,6);  % "Perimeter";
        features(j).centroidx   = T(i).trajectory(:,7);  % "CentroidX";
        features(j).centroidy   = T(i).trajectory(:,8);  % "CentroidY";
        features(j).stdx        = T(i).trajectory(:,9);  % "STDX";
        features(j).stdy        = T(i).trajectory(:,10); % "STDY";
        features(j).cir         = T(i).trajectory(:,11); % "CIR";
        features(j).euler       = T(i).trajectory(:,12); % "EULER";
        features(j).harris      = T(i).trajectory(:,13); % "HARRIS";
        features(j).mhu1        = T(i).trajectory(:,14); % "MHU1";
        features(j).mhu2        = T(i).trajectory(:,15); % "MHU2";
        features(j).mhu3        = T(i).trajectory(:,16); % "MHU3";
        features(j).mhu4        = T(i).trajectory(:,17); % "MHU4";
        
        for x = 1 : length (centroides(j).X)
            k = k +1;
            DBTemp (k, 1) = i;                  % "ID";
            DBTemp (k, 2) = centroides(j).X(x); % "X";
            DBTemp (k, 3) = centroides(j).Y(x); % "Y";
            
            DBFeatures (k, 1)  = i;                         % "ID new label";
            DBFeatures (k, 2)  = features(j).area(x);       % "Area";
            DBFeatures (k, 3)  = features(j).perimeter(x);  % "Perimeter";
            DBFeatures (k, 4)  = features(j).centroidx(x);  % "CentroideX";
            DBFeatures (k, 5)  = features(j).centroidy(x);  % "CentroideY";
            DBFeatures (k, 6)  = features(j).stdx(x);       % "STDX";
            DBFeatures (k, 7) = features(j).stdy(x);        % "STDY";
            DBFeatures (k, 8) = features(j).cir(x);         % "CIR";
            DBFeatures (k, 9) = features(j).euler(x);       % "EULER";
            DBFeatures (k, 10) = features(j).harris(x);     % "HARRIS";
            DBFeatures (k, 11) = features(j).mhu1(x);       % "MHU1";
            DBFeatures (k, 12) = features(j).mhu2(x);       % "MHU2";
            DBFeatures (k, 13) = features(j).mhu3(x);       % "MHU3";
            DBFeatures (k, 14) = features(j).mhu4(x);       % "MHU3";
        end
        
    end
    
end

csvwrite(strcat(VIDEO,'_cam',lower(CAMERA_TEST),'_centroides.csv'), DBTemp);
csvwrite(strcat(VIDEO,'_cam',lower(CAMERA_TEST),'_features.csv'), DBFeatures);
save(strcat(VIDEO,'_cam',lower(CAMERA_TEST),'_centroides.mat'),'centroides')   % save variable in the output.mat file
save(strcat(VIDEO,'_cam',lower(CAMERA_TEST),'_features.mat'),'features')   % save variable in the output.mat file

%histogram(arr);
%nbins = 150;
%histfit(arr,nbins, 'exponential');
%xlabel('sampled points of trajectories ( x )');
%ylabel('Frequency of trajectories ( n )');


figure;
histogram(trajectory);
nbins = 300;
histfit(trajectory,nbins, 'exponential');
xlabel('Sampled points of trajectories ( x )');
ylabel('Frequency of trajectories ( n )');
ylim([0 210])
xlim([0 200])

figure;
histogram(trajectory);
nbins = 300;
histfit(trajectory,nbins, 'exponential');
xlabel('Sampled points of trajectories ( x )');
ylabel('Frequency of trajectories ( n )');
ylim([0 160])
xlim([0 150])


% funcion parametrica
% minimos cuadrados





