%{
 *****************************************************************************************
 *             Universidad Autónoma de Querétaro
 *
 * Nombre del Aplicativo: step3 of trajectories of objects
 * Archivo              : step3_trajectories.m
 * Lenguaje             : lenguaje M
 * Propósito            : Extracción de trayactorias de los objetos en movimiento.
 *
 * Historia...
 * Fecha de Creación    : Martes, 01 de Junio de 2021.
 * Responsable          : Antonio Trejo Morales
 *
 ************************** UAQ - https://www.uaq.mx/informatica/ ************************
%}

clc;
close all;
clear all;

e   = [];
DBL = [];
temp = [];

i   = 1;
j   = 1;
z   = 1;

global CAMERA_TEST
CAMERA_TEST       = 'C';
global VIDEO
VIDEO             = 'HDV_0056';

DBL = csvread(strcat(VIDEO,'_cam',lower(CAMERA_TEST),'_medidas_geometricas.csv'));
[rows, cols] = size(DBL);

% ID,FRAME,PrevOBJ,CurrOBJ,Area,Perimeter,CentroideX,CentroideY,STDX,STDY,CIR,EULER,HARRIS,MHU1,MHU2,MHU3

% DBL (uid, 1) = 0; % "ID";
% DBL (uid, 2) = 0; % "FRAME";
% DBL (uid, 3) = 0; % "PrevOBJ";
% DBL (uid, 4) = 0; % "CurrOBJ";
% DBL (uid, 5) = 0; % "Area";
% DBL (uid, 6) = 0; % "Perimeter";
% DBL (uid, 7) = 0; % "CentroideX";
% DBL (uid, 8) = 0; % "CentroideY";
% DBL (uid, 9) = 0; % "STDX";
% DBL (uid, 10) = 0; % "STDY";
% DBL (uid, 11) = 0; % "CIR";
% DBL (uid, 12) = 0; % "EULER";
% DBL (uid, 13) = 0; % "HARRIS";
% DBL (uid, 14) = 0; % "MHU1";
% DBL (uid, 15) = 0; % "MHU2";
% DBL (uid, 16) = 0; % "MHU3";
% DBL (uid, 17) = 0; % "MHU3";

while rows
    
    find1 = DBL ( 1, 4);
    
    if(find1 == 0)
        % Set current row
        e (j, :) = DBL ( 1, :);
        T(i).trajectory = e;
        DBL( 1, :) = [];  
        [rows, cols] = size(DBL);
        
        e   = [];
        j   = 1;
        i   = i + 1;
        disp(rows);
    else
        t=size(DBL);
        if(t(1)> 1)
            exist = true;
            item = DBL (2, 3);
        else
            exist = false;
            item = DBL (1, 3);
        end
        
        if(find1 == item && exist) %if(find1 == DBL (2, 3))
            if(DBL (2, 4) > 0) % if CurrOBJ != 0
                e (j, :) = DBL (1, :);
                DBL(1, :) = [];  
                [rows, cols] = size(DBL);
                j = j + 1;
            else
                % trajectory finish because find cero
                
                % Set current and next rows
                e (j, :) = DBL (1, :);
                e (j+1, :) = DBL (2, :);
                
                % Set to trajectory T
                T(i).trajectory = e;
                i   = i + 1;
                
                e   = [];
                % remove current and next rows
                DBL(1, :) = [];  
                DBL(1, :) = [];  
                
                j = 1;
                z = 1;
                % Join two matrix
                DBL = [temp; DBL];
                [rows, cols] = size(DBL);
                temp = [];
            end
            
        else
            % Backup row into temp variable
            % temp (z, :) = DBL (2, :);  
            
            if (exist)
                temp (z, :) = DBL (2, :);  
                % remove the next row
                DBL(2, :) = [];
            else
                % Set current row
                e (j, :) = DBL ( 1, :);
                T(i).trajectory = e;
                DBL( 1, :) = [];  
                [rows, cols] = size(DBL);

                e   = [];
                j   = 1;
                i   = i + 1;
                disp(rows);
            end
            
            z = z + 1;
        end
    end
end
save(strcat(VIDEO,'_cam',lower(CAMERA_TEST),'_trajectories.mat'),'T')   % save variable in the output.mat file

