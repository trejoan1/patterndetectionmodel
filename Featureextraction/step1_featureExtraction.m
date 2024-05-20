clc;
close all;
clear all;

global CAMERA_TEST
CAMERA_TEST       = 'C';
global VIDEO
VIDEO             = 'HDV_0056';

% Especifica un radio de 10px para rellenar el espacio más grande del obj estructurante.
global RADIUS
RADIUS      = 3; %2; %4  %10

% Constant for Pixel connectivity
global PxConnect
PxConnect   = 8; % 8 (default) | 4

global CAMERA

if(CAMERA_TEST == 'A')
% CAM A
    CAMERA      = [720.0 340.0 128 72]; %[700.0 300.0 200 100]; %[600.0 350.0 203.2 114.3];    % [380.0 450.0 150 150];
end

if(CAMERA_TEST == 'B')
% CAM B
    CAMERA      = [420.0 490.0 128 72]; % [390.0 495.0 128 72];
end

if(CAMERA_TEST == 'C')
% CAM B
    CAMERA      = [260.0 580.0 128 72]; %[210.0 590.0 128 72]; % [350.0 490.0 203.2 114.3];    % [380.0 450.0 150 150];
end

counter     = 0;        % Contador de frames
Tabla       = [];       % Table general
DBG         = [];       % Data Base Global
DBL         = [];       % Data Base of feature extraction
uid         = 1;        % contador de objs
fName       = 0;        % Folder Name counter

% ID,FRAME,PrevOBJ,CurrOBJ,Area,Perimeter,CentroideX,CentroideY,STDX,STDY,CIR,EULER,HARRIS,MHU1,MHU2,MHU3
DBL (uid, 1) = 0; % "ID";
DBL (uid, 2) = 0; % "FRAME";
DBL (uid, 3) = 0; % "#OBJ";
DBL (uid, 4) = 0; % "OBJ";
DBL (uid, 5) = 0; % "Area";
DBL (uid, 6) = 0; % "Perimeter";
DBL (uid, 7) = 0; % "CentroideX";
DBL (uid, 8) = 0; % "CentroideY";
DBL (uid, 9) = 0; % "STDX";
DBL (uid, 10) = 0; % "STDY";
DBL (uid, 11) = 0; % "CIR";
DBL (uid, 12) = 0; % "EULER";
DBL (uid, 13) = 0; % "HARRIS";
DBL (uid, 14) = 0; % "MHU1";
DBL (uid, 15) = 0; % "MHU2";
DBL (uid, 16) = 0; % "MHU3";
DBL (uid, 17) = 0; % "MHU3";

% Determine if video frame is available to read    0.016689 0.016678
path_file = strcat('/Volumes/ATM1T/groundtruth/',VIDEO,'/1/gt',sprintf('%09d',1),'-*.jpg');

names = dir(path_file);
file = names.name;
folder = names.folder;
% Read frame
frame = imread(strcat(folder,'/',file));

prevF = zeros(size(frame));

while fName < 39 %11
    fName = fName + 1;
    counter = 0;
    
    path_folder = strcat('/Volumes/ATM1T/groundtruth/',VIDEO,'/',sprintf('%d',fName));
    % Change to whatever pattern you need.
    filePattern = fullfile(path_folder, '*.jpg'); 
    theFiles    = dir(filePattern);
    nFiles      = length(theFiles);
    
    while counter < nFiles %2000
    % Increase counter of frame's
        counter = counter + 1;
        % path_file = strcat('/Users/a80118/Documents/groundtruth/HDV_0056/1/gt',sprintf('%09d',counter),'-*.jpg');
        path_file = strcat('/Volumes/ATM1T/groundtruth/',VIDEO,'/',sprintf('%d',fName),'/gt',sprintf('%09d',counter+(2000*(fName-1))),'-*.jpg');
        
        names = dir(path_file);
        file = names.name;
        folder = names.folder;

    % Read next frame
        frame = imread(strcat(folder,'/',file));
        currentF = frame;

    % Convert RGB image or colormap to grayscale
        ib = double(frame);
        ib = ib > 128;

    % Se procede a aplicar un proceso morphological
        ib = morphological_filter(ib);

    % Creates an interactive Crop Image to simulate a virtual camera
        J  = imcrop(ib, CAMERA);
        ib = J;

    %{
     *****************************************************************************************
     * Propósito            : Obtener los objetos en movimientos mediante la obtención de las 
     *                        componentes conexas "conectadas" en la imagen binaria.
     *
     * Parámetros In    	: BW -> Imagen binaria; conn —> Conectividad 
     * Parámetros Out 		: L —> Matriz de etiquetas; n -> Número de objetos conectados
     *
     * Fecha de Creación   	: Miercoles, 03 de Junio de 2020.
     * Responsable        	: Trejo Morales Antonio.
     * 
     ************** Copyright (C) 2020 UAQ - https://www.uaq.mx/informatica/ *****************
    %}

        [L,n] = bwlabel(prevF, PxConnect);                  % n número de componentes conexas (objetos encontrados)
                                                            % L es la matriz de etiquetas de regiones contiguas
        %showGraphics(ib,J,n);
        
        Ap      = 0;                                        % Ap -> area promedio
        stdx    = 0;                                        % stdx -> desviacion estandar en x
        stdy    = 0;                                        % stdy -> desviacion estandar en y
        xc      = 0;
        yc      = 0;

        for i = 1 : n
            [y,x] = find(L == i);                           % Obtener las posiciones de cada componente conexa - Use the find command to get the row and column coordinates of the object labeled "i".
            stdx  = stdx + std(x);                          % Standard deviation for component x
            stdy  = stdy + std(y);                          % Standard deviation for component y
            Ap    = Ap + length(x);                         % Length of largest array dimension (area promedio)

            lienzo  = zeros(size(ib));

            for j=1:length(x)
                lienzo(y(j),x(j))=1;
            end

            lnz         = lienzo;
            ancho       = max(x)-min(x)+1;
            alto        = max(y)-min(y)+1;
            imchiquita  = zeros(alto,ancho);
            mx          = min(x);
            my          = min(y);

            for k=1 : length(x)
                imchiquita(y(k)-my+1, x(k)-mx+1)=1;
            end

            % Measure properties of image regions
            props = regionprops(lienzo, 'Centroid', 'Perimeter');
            %allAreas = sort([props.Area])
            centroids = vertcat(props.Centroid);

            % Place crosshairs on the centroids.
            xc = xc + centroids(:, 1);
            yc = yc + centroids(:, 2);

            % Encontrar el perímetro de los objetos en la imagen binaria
            %per = bwperim(lienzo, PxConnect);
            per = props.Perimeter;

            eul = bweuler(lienzo, PxConnect);

            addpath(genpath('Hu_Moments'));
            %addpath('Hu_Moments','-end');
            eta = SI_Moment(lienzo);
            inv_moments = Hu_Moments(eta);

            addpath('Harris_Corner','-end');
            corners = detectHarrisFeatures(lienzo);
            harris = corners.Count; 

            addpath('Circularidad','-end');
            [msi,nobj]=bwlabel(lienzo);
            [Height,Width,z1] = size(lienzo);  
            [CIR, c, MR, RR] = Circularidad(nobj,msi, Width);

            if counter == 392
                s=0;
            end 
            % Fix bug - Matrix dimensions must agree.
            [H,W,z] = size(lnz);
            if W == 202
                lnz(:,W) = []; % 101x202 ~ 101x201
            end
            if H == 102
                lnz(H,:) = []; % 102x201 ~ 101x201
            end

            [ibL,nconnec2]=bwlabel(ib);

            trz = lnz.*ibL;
            obj = max(trz(:));

            uid = uid + 1;
            DBL (uid, 1) = uid-1;            % ID
            DBL (uid, 2) = counter;          % FRAME
            DBL (uid, 3) = i;                % Previous OBJ
            DBL (uid, 4) = obj;              % Current OBJ
            DBL (uid, 5) = length(x);        % Area
            DBL (uid, 6) = per;              % Perimeter
            DBL (uid, 7) = centroids(:, 1);  % Centroide x
            DBL (uid, 8) = centroids(:, 2);  % Centroide y
            DBL (uid, 9) = std(x);           % STDX
            DBL (uid, 10) = std(y);          % STDY
            DBL (uid, 11) = CIR;             % CIR
            DBL (uid, 12) = eul;             % EULER
            DBL (uid, 13) = harris;          % HARRIS
            DBL (uid, 14) = inv_moments(1);  % MHU1
            DBL (uid, 15) = inv_moments(2);  % MHU2
            DBL (uid, 16) = inv_moments(3);  % MHU3
            DBL (uid, 17) = inv_moments(4);  % MHU4
        end

        Ap   = Ap/n;    % Area promedio
        stdx = stdx/n;  % Desviación estándar x
        stdy = stdy/n;  % Desviación estándar y
        xc   = xc/n;    % Centroide en x
        yc   = yc/n;    % Centroide en y

        % Acquire the current time                          sprintf('Current Time = %.3f sec', vidObj.CurrentTime)
        time = file; % videoObject.CurrentTime;

         %             frame   time #obj area stdx, stdy,
        %Tabla=[Tabla; counter, time, n, Ap, stdx, stdy];
        %Tabla=[Tabla; counter, n, Ap, xc, yc, stdx, stdy];

        DBG (counter, 1) = counter;         % FRAME
        DBG (counter, 2) = n;               % OBJ TOTAL
        DBG (counter, 3) = Ap;              % Area AVG
        DBG (counter, 4) = xc;              % Centroide x AVG
        DBG (counter, 5) = yc;              % Centroide y AVG
        DBG (counter, 6) = stdx;            % STDX AVG
        DBG (counter, 7) = stdy;            % STDY AVG

        % Display images
        %showGraphics(ib, J, n);

        X = sprintf('%d -> %d',fName, counter);
        disp(X);

        prevF = ib;
    end
end 

%save('medidas_generales.txt','Tabla','-ascii', '-double');
csvwrite(strcat(VIDEO,'_cam',lower(CAMERA_TEST),'_medidas_generales.csv'), DBG);
csvwrite(strcat(VIDEO,'_cam',lower(CAMERA_TEST),'_medidas_geometricas.csv'), DBL);
save(strcat(VIDEO,'_cam',lower(CAMERA_TEST),'_DBG.mat'), 'DBG');   % save variable in the output.mat file
save(strcat(VIDEO,'_cam',lower(CAMERA_TEST),'_DBL.mat'), 'DBL');   % save variable in the output.mat file
hold off;

% varNames = {'ID','FRAME','#OBJ','OBJ','Area','Perimeter','CentroideX','CentroideY','STDX','STDY','CIR','EULER','HARRIS','MHU1','MHU2','MHU3'};
% string(varNames)

%{
 *****************************************************************************************
 *             Universidad Autónoma de Querétaro
 *
 * Nombre del Aplicativo: morphological_filter.
 * Archivo              : morphological_filter.m
 * Lenguaje             : lenguaje M
 * Propósito            : Filtro morfologico de apertura y cierre aplicado a una imágen
 *                        binaria.
 *
 * Historia...
 * Fecha de Creación    : Martes, 01 de Junio de 2021.
 * Responsable          : Antonio Trejo Morales
 *
 ************** Copyright (C) 2019 UAQ - https://www.uaq.mx/informatica/ *****************
%}

function img = morphological_filter(ib)
global RADIUS;

% Se procede a aplicar un proceso morphological

% Nota: una imagen morfológica es una erosión seguida de una dilatación, utilizando el
%   mismo elemento de estructuración para ambas operaciones. Apertura Puede combinar la
%   dilatación y la erosión para eliminar objetos pequeños de una imagen y suavizar el
%   borde de objetos grandes.

    
% strel: Create a disk-shaped structuring element with a radius of 4 pixels.
%   Cree un elemento de estructuración en forma de disco. Utilice un elemento de
%   estructuración de disco para conservar la naturaleza circular del objeto. Especifique
%   un radio de 10 píxeles para que se llene el espacio más grande.
%-----------------------------------------------------------------------------------------
%   Create a disk-shaped structuring element. Use a disk structuring element to preserve
%   the circular nature of the object. Specify a radius of 10 pixels so that the largest
%   gap gets filled.
    
    se = strel('square', RADIUS); % square  disk
    
% imopen: Remove snowflakes having a radius less than 4 pixels by opening it with the
%   disk-shaped structuring element.
%   Realizar apertura morfológica. La operación de apertura erosiona una imagen y luego
%   dilata la imagen erosionada, utilizando el mismo elemento de estructuración para
%   ambas operaciones. La apertura morfológica es útil para eliminar objetos pequeños de
%   una imagen conservando la forma y el tamaño de los objetos más grandes de la imagen.
%   Para obtener un ejemplo, consulte .Utilice apertura morfológica para extraer grandes
%   características de imagen.
    
    ib = imopen(ib, se);
    
% imclose: Perform a morphological close operation on the image. 
%   Realizar cierre morfológico. La operación de cierre dilata una imagen y a continuación
%   erosiona la imagen dilatada, utilizando el mismo elemento de estructuración para ambas
%   operaciones. El cierre morfológico es útil para rellenar pequeños agujeros de una
%   imagen conservando la forma y el tamaño de los objetos de la imagen.

    ib = imclose(ib, se);
    
    % bwperim                 % Encontrar el perímetro de los objetos en la imagen binaria
    % imhist                  % Histograma de datos de imagen
    
    img = ib;
end


function showGraphics_(index, im1, im2, im3, im4, im5, im6)
global PIXELL;
global CAMERA;

    %figure('Position', [1000, 500, 1600, 1000]);
    % Current image or frame
    subplot(2, 3, 1);
    imagesc(im1);                                     
    title(sprintf('Frame actual No. %d', index));
    drawnow;
    h = drawrectangle('Position', CAMERA,'StripeColor','r', 'LineWidth', 1.0);
    
    subplot(2, 3, 2);
    imagesc(im3);                                     
    title('Fondo');
    drawnow;
    
    subplot(2, 3, 3);
    imagesc(im4);
    title('Matriz de movimiento');
    drawnow;
    
    subplot(2, 3, 4);
    imagesc(im5);
    title(sprintf('Mat. Bin. mayor a %d %s', PIXELL, 'px'));
    drawnow;
    
    subplot(2, 3, 5);
    imagesc(im6);
    title("Objetos en movimiento");
    drawnow;
    
    subplot(2, 3, 6);
    imagesc(im2);                                     
    title('Cámara virtual');
    drawnow;
end

function showGraphics(ib, J, n)
global CAMERA;
    %  Sets the colormap for the current figure to scale gray.
    colormap(gray(256));
        
    img=imread('mask.jpg');
    %img=imread('MaskRGB.png');
    subplot(3, 1, 1);
    imagesc(img);                                     
    title(sprintf('Mask'));
    drawnow;
    h = drawrectangle('Position', CAMERA,'StripeColor','r', 'LineWidth', 1.0);
    
    subplot(3, 1, 2);
    imagesc(ib);                                     
    title(sprintf('Tracking'));
    drawnow;
    h = drawrectangle('Position', CAMERA,'StripeColor','r', 'LineWidth', 1.0);
    
    subplot(3, 1, 3);
    imagesc(J);                                     
    title(sprintf('Camera [obj = %d]', n));
    drawnow;
end









