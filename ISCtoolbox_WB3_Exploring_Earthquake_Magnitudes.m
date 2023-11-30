%% Comparing Earthquake Magnitudes

%% Introduction
% The day you shout at the TV as they report the magnitude of an earthquake 
% in terms of the Richter scale is a proud day. Welcome. You are now a 
% seismologist. But, what should they be saying? This work book is about 
% the end of that sentence. "Dont say richter scale, its not the Richter 
% scale its the ...."
% Of course, if the earthquake is reasonably large (greater than magntude 
% 5.5 for instance), the answer is clear. The moment magnitude (Mw) is the
% way to go, as its directly related to the earthquakes moment. For lower 
% magnitudes (magnitude 5.0 and below) we cant always get a
% reliable measure of moment magntiude, and therefore we fall back on other 
% earthquake magnitude types, such as mb (body wave magnitude) MS (surface 
% wave magnitude), or even ml (local magnitude - a measure of magnitude 
% that is specific to one setting).
% Each of these magnitude types use a different type of data, and therefore
% are reliable at different ranges of earthquae magnitude. 

%% Body wave magnitude (mb)
% m_b is defined by the amplitude of body wave arrivals observed
% at a distance of 20 - 90 degrees from the earthquke.

%% Surface Wave Magnitude (MS)
% MS is defined from surface wave amplitides observed atleast 5 degrees
% away form the earthquake source

%% Moment Magnitude (Mw)
% Mw is defined from low pass filtered siesmic waves, and is usually
% defined when inverting for a full moment tensor.

setupISCtoolbox; % Adds the paths to Functions etc

%% Part 1: Magnitude comparisons
% Here we compare the ISc magnitudes (mb and MS) to the moment magnitude
% reported by gCMT (Mw).

% get local copy of the event IDs for the data set
prime_evids = allPrimes.EventID; %disp (prime_evids);

for n = 1:size(prime_evids, 1)

    % Get evid for given event
    evid = prime_evids(n);
    evid_idx = allMagnitudes.EventID == evid;
    
    % Get magnitudes for that event
    event_mags = allMagnitudes(evid_idx,:);

    % Get ISC mb for that event, set to NaN if not available
    idx = event_mags.MagnitudeType == 'mb';
    event_mags = event_mags(idx,:);
    idx = event_mags.Author == 'ISC';
    event_mags = event_mags(idx,:);

    if size(event_mags,1) == 1
        isc_mbs(n) = event_mags.Magnitude;
    else
        isc_mbs(n) = NaN;
    end

    % Get GCMT Mw for that event, set to NaN if not available
    event_mags = allMagnitudes(evid_idx,:);
    idx = event_mags.MagnitudeType == 'MW';
    event_mags = event_mags(idx,:);
    idx = event_mags.Author == 'GCMT';
    event_mags = event_mags(idx,:);

    if size(event_mags,1) == 1
        gcmt_mws(n) = event_mags.Magnitude;
    else
        gcmt_mws(n) = NaN;
    end
     
    % Get ISC MS for that event, set to NaN if not available
    event_mags = allMagnitudes(evid_idx,:);
    idx = event_mags.MagnitudeType == 'MS';
    event_mags = event_mags(idx,:);
    idx = event_mags.Author == 'ISC';
    event_mags = event_mags(idx,:);

    if size(event_mags,1) == 1
        isc_mSs(n) = event_mags.Magnitude;
    else
        isc_mSs(n) = NaN;
    end
end

%% Plot ISC mb magnitudes vs ISC MS
figure; hold on;
scatter( isc_mbs, gcmt_mws, 'MarkerFaceColor','b','MarkerEdgeColor','b',...
    'MarkerFaceAlpha',.2,'MarkerEdgeAlpha',.2);
xs = linspace(4.0, 7.5, 10); ys = xs;
plot(xs, ys, 'k--');

title('Magnitude comparison of ISC m_b vs GCMT M_w');
xlabel('m_b (ISC)');
ylabel('M_w (GCMT)');

%% Plot ISC mb magnitudes vs GMCT Mw
figure; hold on;
scatter( isc_mbs, gcmt_mws, 'MarkerFaceColor','b','MarkerEdgeColor','b',...
    'MarkerFaceAlpha',.2,'MarkerEdgeAlpha',.2);
xs = linspace(4.0, 7.5, 10); ys = xs;
plot(xs, ys, 'k--');

title('Magnitude comparison of ISC m_b vs GCMT M_w');
xlabel('m_b (ISC)');
ylabel('M_w (GCMT)');

%% Plot ISC mb magnitudes vs ISC mS
figure; hold on;
scatter(gcmt_mws, isc_mSs, 'MarkerFaceColor','b','MarkerEdgeColor','b',...
    'MarkerFaceAlpha',.2,'MarkerEdgeAlpha',.2);
xs = linspace(4.0, 7.5, 10); ys = xs;
plot(xs, ys, 'k--');

title('Magnitude comparison of gCMT M_w vs ISC m_S');
xlabel('M_w (gCMT)');
ylabel('m_S (ISC)');

min_mags = min(min(isc_mbs), min(gcmt_mws));
max_mags = max(max(isc_mbs), max(gcmt_mws)); 
xlim([min_mags, max_mags]);
ylim([min_mags, max_mags]);
axis square;                % Set the axis limits to be equal!
clear xs ys idx n evid_idx; % Clear up some stuff



%% Calculating magnitude of completion and b-values for an earthquake 
%% data set

% We know that the number of earthquakes that occur on Earth, or on any 
% given region of the earth, increases logarithmically as the earthquake 
% magnitude decreases. In other words, a magntiude 4.0 earthquake is far 
% more likely (and are far more common) than a magnitude 5.0 earthquake.

% This is expressed by the Gutenburg-Richter law, which describes the 
% relation between the frequency of an earthquake, and the magnitude of an 
% Earthquake with the following equation;

% logN = a - bM

% Where N is the number of earthquakes with magntiude M or greater, and a 
% and b are the intersect and gradient of the linear relation respectively.

% Several important features of the seismicity of a region can be
% delineated from this linear relation. Firstly, the a-value is directly 
% contolled by the number of earthquakes (i.e. the seismicity rate) in the 
% region and time period considered. Secondly, the b-value is controlled by 
% the proportion of relatively large earthquakes to smaller earthquakes.

% In tectonic earthquakes, the b-value is almost alway close to 1.0, but 
% studying varitations b-values can be very illuminating, espacially in 
% volcanic seismicity and induced seismity for instance.

% This linear relationship begins to break down for smaller magnitude 
% earthquakes. This has nothing to do with the underlying physics, or even
% statistics of earthquake occurence. Rather, and more simply it is because 
% smaller earthquakes are harded to detect. Additionally, and particularly 
% of relevence to this work book, not all magntiude types can be calulated 
% for small earthquakes. e.g. as we said at the start, it is difficult to 
% measurre Mw for earthquakes less than 5.0.

% The minimum magnitude at which the Gutenburd-Richter relation holds is 
% referred to the magnitude of completness (Mc), and is the magnitude below 
% which either not all earthquakes are detectable, or not all earthquakes
% have the relavant magnitude type determined.

% Below we calculate the magnitude of completeness, and b-values for your
% cohsen data set for each of the globally determined magnitude types (Mw,
% Mb ad MS).

%% Calculte Mc and b-value for body wave magnitudes (mb)
Mc_manual = 0;     % Set to zero for undefined
Mmax_manual = 0;   % This is the maximum magntiude that b-value calculation 
                   % fits. Set ot zero for undefined
plot_mc_b_fig = 1; % Select whethre to plot the b-value fit (1=yes, 0=no)
[a_mb,b_mb] = estimate_mc_b(isc_mbs, Mc_manual, Mmax_manual, 1);


%% Calculte Mc and b-value for body wave magnitudes (MS)
Mc_manual = 0;     % Set to zero for undefined
Mmax_manual = 0;   % This is the maximum magntiude that b-value calculation 
                   % fits. Set ot zero for undefined
plot_mc_b_fig = 1; % Select whethre to plot the b-value fit (1=yes, 0=no)
[a_MS,b_MS] = estimate_mc_b(isc_mSs, Mc_manual, Mmax_manual, 1);

%% Calculte Mc and b-value for body wave magnitudes (Mw)
Mc_manual = 0;     % Set to zero for undefined
Mmax_manual = 0;   % This is the maximum magntiude that b-value calculation 
                   % fits. Set ot zero for undefined
plot_mc_b_fig = 1; % Select whethre to plot the b-value fit (1=yes, 0=no)
[a_Mw,b_Mw] = estimate_mc_b(gcmt_mws, Mc_manual, Mmax_manual, 1);

%% Questions
% Which magntiude types have the lowest magnitude of completeness?

% Which magnitude types give the most reliable measure of b-value?

% Is this true for other tectonic regions?

% Does the automatically determined Mc value seem reliable for all 
% magnitude types? You can optimise it by manually defining Mc in the 
% inputs of the function 'estimate_mc_b'.

% What difference does this make to the resulting b-value?

%% More Advanced Questions
% Can you determine the magnitude of completeness and b-value from a local
% magnitude catalogue (e.g. Ml_JMA in Japan)?