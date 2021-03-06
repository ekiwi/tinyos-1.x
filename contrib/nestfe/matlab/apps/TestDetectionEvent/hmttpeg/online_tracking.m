function toptrack = online_tracking(t)

% Copyright (c) 2003-2004 Songhwai Oh

global gvs G

Tall = t+1;

% tracking ... 
gvs.record.cputime(t) = cputime;
toptrack = mcmcda_tracking(t,1);
gvs.record.cputime(t) = cputime - gvs.record.cputime(t);

%%% FULL TRACK
Tnow = t;
Tinit = max(1,Tnow-gvs.winsize+1);
Tf = Tnow - Tinit + 1;
if Tnow>gvs.winsize
    full_T = ceil(Tf/2);
    part_uT = ceil(Tf/2);
else
    full_T = 1;
    part_uT = 1;
end
full_K = 0;
if Tnow==gvs.winsize
    if ~isempty(gvs.record.trackinfo.track)
        [part_T,part_K] = size(gvs.record.trackinfo.track);
        full_T = ceil(gvs.winsize/2);
        kf = 0;
        for kp=1:part_K
            if any(gvs.record.trackinfo.track(1:full_T,kp)~=0)
                kf = kf + 1;
                gvs.record.fulltrackinfo.track(1:full_T,kf) = ...
                    gvs.record.trackinfo.track(1:full_T,kp);
            end
        end
    end
elseif Tnow>gvs.winsize
    full_T = Tinit + ceil(Tf/2) - 2; 
    if ~isempty(gvs.record.fulltrackinfo.track)
        [full_T,full_K] = size(gvs.record.fulltrackinfo.track);
        gvs.record.fulltrackinfo.track(full_T+1,1:full_K) = 0;
    end
    [part_T,part_K] = size(gvs.record.trackinfo.track);
    for kf=1:full_K
        for kp=1:part_K
            vtrack = find(gvs.record.fulltrackinfo.track(:,kf)>0);
            full_tf = vtrack(length(vtrack));
            if full_tf>=Tinit
                part_tf = full_tf-Tinit+1;
                if gvs.record.fulltrackinfo.track(full_tf,kf) ...
                        == gvs.record.trackinfo.track(part_tf,kp)
                    if Tnow < Tall
                        gvs.record.fulltrackinfo.track(full_tf:full_T+1,kf) = ...
                            gvs.record.trackinfo.track(part_tf:part_uT,kp);
                    else
                        gvs.record.fulltrackinfo.track(full_tf:Tall,kf) = ...
                            gvs.record.trackinfo.track(part_tf:part_T,kp);
                    end
                end
            end
        end
    end
    kf = full_K;
    for kp=1:part_K
        % add new tracks
        if all(gvs.record.trackinfo.track(1:part_uT-1,kp)==0) ...
                && gvs.record.trackinfo.track(part_uT,kp)>0
            kf = kf + 1;
            if Tnow < Tall
                gvs.record.fulltrackinfo.track(full_T+1,kf) = ...
                    gvs.record.trackinfo.track(part_uT,kp);
            else
                gvs.record.fulltrackinfo.track(full_T+1:Tall,kf) = ...
                    gvs.record.trackinfo.track(part_uT:part_T,kp);
            end
        end
    end
    
end
if Tnow==Tall && ~isempty(gvs.record.fulltrackinfo.track)
    full_T = size(gvs.record.fulltrackinfo.track,1);
    if full_T<Tall
        gvs.record.fulltrackinfo.track(full_T+1:Tall,:) = 0;
    end
end







