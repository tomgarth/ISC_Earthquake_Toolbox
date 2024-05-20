function [allPrimes] = fix_primes(allPrimes, allHypocentres)

    % Fix the primes, by taking single solurtion events from the 
    % hypocentre list

    prime_dates = allPrimes.Date;
    prime_evids = allPrimes.EventID;

    for n = 1:numel(prime_evids)

        if isnat(prime_dates(n)) == true

            % Get locations for that event
            evid = prime_evids(n);
            evid_idx = allHypocentres.EventID == evid;
            event_locs = allHypocentres(evid_idx,:);

            % Populate the missing primes
            allPrimes.Date(n)           = event_locs.Date;
            allPrimes.Err(n)            = event_locs.Err;
            allPrimes.RMS(n)            = event_locs.RMS;
            allPrimes.Latitude(n)       = event_locs.Latitude;
            allPrimes.Longitude(n)      = event_locs.Longitude;
            allPrimes.Smaj(n)           = event_locs.Smaj;
            allPrimes.Smin(n)           = event_locs.Smin;
            allPrimes.Az(n)             = event_locs.Az;
            allPrimes.Depth(n)          = event_locs.Depth;
            allPrimes.EpicentreFixed(n) = event_locs.EpicentreFixed;
            allPrimes.Err1(n)           = event_locs.Err1;
            allPrimes.Ndef(n)           = event_locs.Ndef;
            allPrimes.Nsta(n)           = event_locs.Nsta;
            allPrimes.Gap(n)            = event_locs.Gap;
            allPrimes.mdist(n)          = event_locs.mdist;
            allPrimes.Qual(n)           = event_locs.Qual;
            allPrimes.Author(n)         = event_locs.Author;
            allPrimes.OrigID(n)         = event_locs.OrigID;
            allPrimes.EventID(n)        = event_locs.EventID;
            
        end
    end
end