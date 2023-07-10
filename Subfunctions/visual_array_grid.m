

function [dot_position dot_centre dot_colour]= visual_array_grid(EXPCONSTANTS)

% Use this function to generate the coordinates required to plot tilted
% lines, their centers and color 

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Inputs:
%       EXPCONSTANTS: structure containing with at least following fields:
%           NDOTS_MORE_DENSE: Integer (number of dots for dense array)
%           NDOTS_LESS_DENSE: Integer (number of dots for less dense array)
%           FIXATION_CENTRE: Integer 1x2 (coordinates of fixation cross
%                            center)
%           RADIUS_CIRCLE: Integer (radius of mean circle, pixels)
%           RADIUS_JITTER: Integer 1xn (jitter to mean circle, pixels)
%           RADIUS_DOT: Integer (line size)
%           ASPECT_RATIO: Float (in order to rescale images in stereoscopic
%                         view
%           IMAGE_TYPE: Integer (0 or 2 tilt right, 1 or 3 tilt left)
%           TILT_ANGLE: Float, tilt angle of lines (degrees)
%
% Outputs:
%       dot_position: array Ndots x 4 (Lines coordinates in pixels)
%       dot_centre: array Ndots x 2  (Lines centers in pixels)
%       dot_colour: array Ndots x 3 (RGB indexes for colour)
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% FIRST DEFINE ALL OUR CONSTANTS


fixation_centre=EXPCONSTANTS.FIXATION_CENTRE;


radius_dot=EXPCONSTANTS.RADIUS_DOT;
Aspect_ratio=EXPCONSTANTS.ASPECT_RATIO;
numBlock=1;
%Recovered from original function
tilt_mode=2*mod(EXPCONSTANTS.IMAGE_TYPE_FIRST(numBlock),2)-1;
Tilt_angle=tilt_mode*pi*EXPCONSTANTS.TILT_ANGLE/180;


% TILT MODE
% 0 MDL Right tilt tilt_mode=0 (-1)
% 1 MDL Left tilt tilt_mode=1  (1)


 
% Comment, now our lines have a length 2*sqrt(2)*radius_dot

% Prepare rectangular array of dots
% u_bound_x=abs(max(shuffled_radius_jitter));
% 
% %step=ceil(3*radius_dot*sqrt(2)); 
% step=ceil(radius_dot*sqrt(2)); 
% [X,Y]=meshgrid(-(u_bound*1.5):step:(u_bound*1.5));

step=ceil(sqrt(2)*radius_dot*EXPCONSTANTS.GRID_FACTOR);
% Ysize=2*abs(max(shuffled_radius_jitter));
%Ysize=0.5*EXPCONSTANTS.DRAWREGIONSIZE(1,2);

Xsize=ceil(0.25*EXPCONSTANTS.DRAWREGIONSIZE(1,1)-0.4*step);
Ysize=ceil(0.5*EXPCONSTANTS.DRAWREGIONSIZE(1,2)-0.4*step);



% Xsize=ceil(1.5*EXPCONSTANTS.RADIUS_CIRCLE-0.4*step);
% Ysize=ceil(1.5*EXPCONSTANTS.RADIUS_CIRCLE-0.4*step);


[X Y]=meshgrid(-Xsize:step:Xsize,-Ysize:step:Ysize);

X=reshape(X,size(X,1)*size(X,2),1);
Y=reshape(Y,size(Y,1)*size(Y,2),1);
Ndots=size(X,1);

max_center_jitter_x=round(step*0.25*EXPCONSTANTS.GRID_JITTER_X);
max_center_jitter_y=round(step*0.25*EXPCONSTANTS.GRID_JITTER_Y);
x_positions=round(X+randi(max_center_jitter_x,Ndots,1)-round(max_center_jitter_x*0.5)+2)+fixation_centre(1,1);
%X spans all the screen, whereas Y not!!!
y_positions=round(Y+randi(max_center_jitter_y,Ndots,1)-round(max_center_jitter_y*0.5)+2)+fixation_centre(1,2);



dot_centre=[x_positions y_positions];
  dot_colour=EXPCONSTANTS.DOT_COLOUR_MAX*ones(Ndots,3);  

%Generate coordinates for Dense and Less dense arrays (each array is tilted
%in different direction): all coordinates related to zero
 %dot_size= repmat([(radius_dot*Aspect_ratio) (radius_dot)],Ndots,1);
 dot_size= repmat([(radius_dot*Aspect_ratio)*cos(Tilt_angle) (radius_dot)*sin(Tilt_angle)],Ndots,1);

 % Translation to each required position
 dot_position=[dot_centre-dot_size dot_centre+dot_size];
                   
%  save('positions.mat','dot_pos*')
 %who %To know variables in the code 
  clearvars -except dot_position dot_colour dot_centre
 clear java
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%   


%Deprecated part of the code
    
%     %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% % Prepare vector of jittered distances to center
% repetitions=ceil(Ndots/max(size(radius_jitter)));
% radius_jitter=repmat(radius_jitter,1,repetitions);
% radius_jitter=radius_jitter(1,1:Ndots);
% shuffled_radius_jitter=radius_circle+Shuffle(radius_jitter);
% jitter_center=round(radius_dot*0.5)%round(radius_dot*0.35);
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% % Distribute the centers of the lines around the circle (randomize angular
% % order)
% n_more_dense=Shuffle(Shuffle(1:Ndots));
% theta= 2*pi*n_more_dense/Ndots; % theta a szog, ahol az egyes pontoknak el kell helyezkedniuk a korben
% x_positions = Aspect_ratio*shuffled_radius_jitter.*(cos(theta)); % az x tengelyt a cosinus adja meg
% y_positions = shuffled_radius_jitter.*(sin(theta)); % az y tengelyt pedig a sinus
% 
% % Solve any possible overlapping of the lines
% 
% % Divide the space into cells of a size big enough to avoid overlapping
% u_bound=abs(max(shuffled_radius_jitter));
% l_bound=abs(min(shuffled_radius_jitter));
% %step=ceil(3*radius_dot*sqrt(2)); 
% step=ceil(radius_dot*sqrt(2)); 
% [X,Y]=meshgrid(-(u_bound*1.5):step:(u_bound*1.5));
% X_lin=reshape(X,size(X,1)*size(X,2),1);
% Y_lin=reshape(Y,size(Y,1)*size(Y,2),1);
% %Select only cells wich are within rmin and rmax from center (coming
% %from minimum and maximum jittered radius)
% r=sqrt(X_lin.^2+Y_lin.^2);
% good_index=intersect(find(r>=l_bound),find(r<=u_bound));
% X_lin2=X_lin(good_index);
% Y_lin2=Y_lin(good_index);
% 
% %Replace calculated center positions to the nearest and not used center of
% %allowed grid cells
% good_index=(1:1:length(good_index))';
% for j=1:Ndots
%     
%     %Calculate the translation vector from selected point to allowed points
%     %in the cell grid
%     d=sqrt((X_lin2-x_positions(j)).^2+(Y_lin2-y_positions(j)).^2);
%     %Select the cell for which translation is minimum
%     min_d=find(d==min(d),1);
%     x_positions(j)=X_lin2(min_d);
%     y_positions(j)=Y_lin2(min_d);
%    %Elliminate from allowed cells the one used to place current line
%     good_index=setdiff(good_index,min_d);
%     X_lin2=X_lin2(good_index);
%     Y_lin2=Y_lin2(good_index);
%     good_index=(1:1:length(good_index))';
% end
% 
% 
% dot_colour=EXPCONSTANTS.DOT_COLOUR_MAX*ones(Ndots,3);
%  
% %Add small and random displacement to the centers of the lines (small
% %enough to avoid overlapping)
% 
% x_positions=x_positions+randi(jitter_center,size(x_positions))-0.5*jitter_center +fixation_centre(1,1);
% y_positions=y_positions+randi(jitter_center,size(y_positions))-0.5*jitter_center +fixation_centre(1,2);