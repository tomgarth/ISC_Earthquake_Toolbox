function [] = plotMTtransect(mt, type, centerX, centerY, plotScale, azi, maxlength, maxdepth, ax)

% plotMT
%   A funtion that takes a moment tensor input and plots it in 2D, 3D 
%   or map mode. The function is based on James Condors' focalmech.m code,
%   and utilises the convert_MT function from Carl Tapes' MATLAB moment
%   tensor codes. Additionally, the export_fig tool box is used to create
%   figures with transaparancy that can be plotted in the MATLAB mapping
%   toolbox.
% 
% mt      - Moment tensor to be plotted.
% type    - Moment tensor format used (e.g. AkiRich, GCMT or Stein&Wyss)
% mode    - Plot type (e.g 2D, 3D or map).
% centerX - Centre X coordinate for MT plotting (cartesian for  2D & 3D, 
%           latitude and longitude for map mode).
% centerY - Centre Y coordinate for MT plotting (cartesian for  2D & 3D,
%           latitude and longitude for map mode).
% centerZ - Centre Y coordinate for MT plotting.
% diam    - Diameter of MT to be plotted.


% Make sure the moment tensor is in Aki & Richards form
if strcmp (type, 'AkiRich') == 0

    if strcmp(type, 'GCMT') == 1
        [mt,~] = convert_MT(1,2,mt);
    elseif strcmp(type, 'Stein&Wyss') == 1
        [mt,~] = convert_MT(3,2,mt);
    end

end

% Plot the moment tensor

% Get u matrix from focalmech matlab function
figure;
[uz, trend, plunge] = focalmech(mt, 0, 0, 1);
close;

% Normalise uz values to range -1, 1
uz_mod = uz ./ abs(uz);
for n = 1:numel(uz)
    if uz(n) == 0
        uz_mod = 0;
    end
end
uz = uz_mod;

% Convert PLUNGE AND TREND (radians) into PLUNGE and AZIMUTH (degrees)
plunge_deg  = plunge / pi * 180;
trend_deg   = trend / pi * 180;
azimuth_deg = (trend_deg-180) * -1;
for n = 1:numel(plunge_deg)
    if plunge_deg(n) < 0
        plunge_deg(n) = nan;
    end
end

% Set 2D arrays defining the moment tensor
plunge_deg = reshape(plunge_deg, [numel(plunge_deg), 1 ]);
trend_deg = reshape(trend_deg, [numel(trend_deg), 1]);
azimuth_deg = reshape(azimuth_deg, [numel(azimuth_deg), 1]);
uz = reshape(uz, [numel(uz), 1 ]);

% Take mirror view of uz
uz_flip = uz;
uz_flip = flip(uz_flip, 1); % Flip on axis 1
uz_flip = flip(uz_flip, 2); % Flip on axis 2
uz_flip = reshape(uz_flip, [numel(uz_flip), 1 ]);

z = sind(plunge_deg);
d = cosd(plunge_deg);
x = d.*sind(azimuth_deg);
y = d.*cosd(azimuth_deg);

% Convert the spherical coordinates to a mesh
sqr_mtx_sz = sqrt(numel(x));

X1 = reshape(x, [sqr_mtx_sz, sqr_mtx_sz]);
Y1 = reshape(y, [sqr_mtx_sz, sqr_mtx_sz]);
Z1 = reshape(z, [sqr_mtx_sz, sqr_mtx_sz]);
U1 = reshape(uz, [sqr_mtx_sz, sqr_mtx_sz]);

X2 = reshape(x, [sqr_mtx_sz, sqr_mtx_sz]);
Y2 = reshape(y, [sqr_mtx_sz, sqr_mtx_sz]);
Z2 = reshape(z*-1, [sqr_mtx_sz, sqr_mtx_sz]);
U2 = reshape(uz_flip, [sqr_mtx_sz, sqr_mtx_sz]);

X(1:size(X1,1),1:size(X1,2)) = X1;
X(size(X1,1)+1:size(X1,1)+size(X1,2),1:size(X2,2)) = X2;
X(1:size(X1,1),1:size(X1,2)) = X1;
X(size(X1,1)+1:size(X1,1)+size(X1,2),1:size(X2,2)) = X2;
Y(1:size(X1,1),1:size(X1,2)) = Y1;
Y(size(X1,1)+1:size(X1,1)+size(X1,2),1:size(X2,2)) = Y2;
Z(1:size(X1,1),1:size(X1,2)) = Z1;
Z(size(X1,1)+1:size(X1,1)+size(X1,2),1:size(X2,2)) = Z2;
U(1:size(X1,1),1:size(X1,2)) = U1;
U(size(X1,1)+1:size(X1,1)+size(X1,2),1:size(X2,2)) = U2;

% Get the points of the MT image as a 1D array
x = reshape(X,[],1);
y = reshape(Y,[],1);
z = reshape(Z,[],1);
u = reshape(U,[],1);

% Remove values with NaN in and 1D table
x_orig = x;
x = x(~isnan(x_orig));
y = y(~isnan(x_orig));
z = z(~isnan(x_orig));
u = u(~isnan(x_orig));

y_orig = y;
x = x(~isnan(y_orig));
y = y(~isnan(y_orig));
z = z(~isnan(y_orig));
u = u(~isnan(y_orig));

z_orig = z;
x = x(~isnan(z_orig));
y = y(~isnan(z_orig));
z = z(~isnan(z_orig));
u = u(~isnan(z_orig));

% Define x, y and z coordinates where u is 1 or -1
all=[x,y,z,u];

% Plot the volume enclosing the negative points
neg=all(u==-1,:);
xx_neg = neg(:,1);
yy_neg = neg(:,2);
zz_neg = neg(:,3);
xx_neg = [xx_neg; 0];
yy_neg = [yy_neg; 0];
zz_neg = [zz_neg; 0];
dout_neg = delaunayTriangulation(xx_neg,yy_neg,zz_neg);
cout_neg = convexHull(dout_neg);
figure()
surf(xx_neg(cout_neg),yy_neg(cout_neg),zz_neg(cout_neg), ...
    'FaceColor','w','edgecolor','none');

% Plot the volume enclosing the positive points
pos=all(u==1,:);
xx_pos = pos(:,1);
yy_pos = pos(:,2);
zz_pos = pos(:,3);
xx_pos = [xx_pos; 0];
yy_pos = [yy_pos; 0];
zz_pos = [zz_pos; 0];
dout_pos = delaunayTriangulation(xx_pos,yy_pos,zz_pos);
cout_pos = convexHull(dout_pos);

% Plot the volume enclosing the negative points

hold on;
surf(xx_pos(cout_pos),yy_pos(cout_pos),zz_pos(cout_pos), ...
    'FaceColor','k','edgecolor','none');
% axis off
ax = gca;
axis ('off') 

% View 3D Plot from correct transect azimuth
view(azi,0);

% Create 2D plot of focal mechanism viewed from correct transect azimuth
export_fig transectMT.png -transparent -r5;
close;

% Scale the focal mechanisms
xscale = (plotScale*(maxlength/maxdepth))/5;
yscale = (plotScale)/2;

% Read and plot Focal Mechanism to transect 
[img,map,alphachannel] = imread('transectMT.png');
image(img,'AlphaData',alphachannel,'xdata',[(centerX-xscale) (centerX+xscale)],'ydata',[(centerY+yscale)  (centerY-yscale)])

% Delete tmp png file if already exists
if exist('transectMT.png', 'file')
    delete('transectMT.png');
end

