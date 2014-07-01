
%% initialize

allPeakInfo = struct;

cfg = [];

%% gather data

% spacings = {'mass', 'spac', 'onePres'};
% oldnew = {'p2'};
% memConds = {'all'};

% didn't test new words, so can't assess memory, but can use p1
spacings = {'mass', 'spac'};
oldnew = {'p1', 'p2'};
memConds = {'rc','fo'};

% erpComponents = {'LPC','N400','N2'};
erpComponents = {'N2'};

% % % make sure roi has the same length as erpComponents
% % roi = {{{'Pz'}},{{'Cz'}},{{'E69','E89'}}}; % near O1, O2
% roi = {{{'Pz'}},{{'Cz'}},{{'E58','E96'}}};
roi = {{{'E58','E96'}}};

if length(erpComponents) ~= length(roi)
  error('roi must have the same length as erpComponents');
end

lpcPeak = 0.600;
n400Peak = 0.360;
%cfg.roi = {'E70', 'E83'}; % O1, O2
% cfg.roi = {'E69', 'E89'}; % Near O1, O2
% n2Peak = 0.168;
%cfg.roi = {'E58','E96'}; % T5, T6 (T5 is close 2nd biggest peak)
n2Peak = 0.176;

for sp = 1:length(spacings)
  
  for on = 1:length(oldnew)
    
    for mc = 1:length(memConds)
      
      cond_str = [];
      
      if strcmp(spacings{sp},'onePres')
        % % single presentation or first presentation
        if strcmp(memConds{mc},'all');
          cfg.conditions = {'word_onePres','word_RgH_rc_spac_p1','word_RgH_fo_spac_p1','word_RgH_rc_mass_p1','word_RgH_fo_mass_p1'};
          %cfg.conditions = {'word_onePres'};
          
          cond_str = sprintf('%s_%s',spacings{sp},memConds{mc});
        end
      elseif strcmp(spacings{sp},'mass') || strcmp(spacings{sp},'spac')
        
        if strcmp(memConds{mc},'all');
          cfg.conditions = {sprintf('word_RgH_rc_%s_%s',spacings{sp},oldnew{on}),sprintf('word_RgH_fo_%s_%s',spacings{sp},oldnew{on})};
        else
          cfg.conditions = {sprintf('word_RgH_%s_%s_%s',memConds{mc},spacings{sp},oldnew{on})};
        end
        
        cond_str = sprintf('%s_%s_%s',spacings{sp},oldnew{on},memConds{mc});
      end
      
      fprintf('================================================\n');
      fprintf('Condition: %s\n',cond_str);
      disp(cfg.conditions);
      fprintf('================================================\n');
      
      for er = 1:length(erpComponents)
        for r = 1:length(roi{er})
          
          cfg.roi = roi{er}{r};
          roi_str = sprintf('%s%s',erpComponents{er},sprintf(repmat('_%s',1,length(cfg.roi)),cfg.roi{:}));
          
          if strcmp(erpComponents{er},'LPC')
            % LPC
            cfg.order = 'descend'; % descend = positive peaks first
            % cfg.latency = [0.4 0.8];
            %cfg.latency = [lpcPeak-0.05 lpcPeak+0.05]; % LPC - around GA peak (space+mass) +/- 50
            cfg.latency = [lpcPeak-0.1 lpcPeak+0.1]; % LPC - around GA peak (space+mass) +/- 100
          elseif strcmp(erpComponents{er},'N400')
            % N400
            cfg.order = 'ascend'; % ascend = negative peaks first
            % cfg.latency = [0.2 0.6];
            %cfg.latency = [n400Peak-0.05 n400Peak+0.05]; % N400 - around GA peak (space+mass) +/- 50
            cfg.latency = [n400Peak-0.1 n400Peak+0.1]; % N400 - around GA peak (space+mass) +/- 100
          elseif strcmp(erpComponents{er},'N2')
            cfg.order = 'ascend'; % ascend = negative peaks first
            %cfg.roi = {'E70', 'E83'}; % O1, O2
            %cfg.roi = {'E69', 'E89'}; % Near O1, O2
            %n2Peak = 0.168;
            %cfg.roi = {'E58','E96'}; % T5, T6 (T5 is close 2nd biggest peak)
            %n2Peak = 0.176;
            cfg.latency = [n2Peak-0.05 n2Peak+0.05]; % around GA peak (space+mass) +/- 50
            %cfg.latency = [n2Peak-0.1 n2Peak+0.1]; % around GA peak (space+mass) +/- 100
          end
          
          % % average across time window
          %cfg.datadim = 'elec';
          % cfg.roi = {'center101'};
          % % cfg.roi = {'PS2'};
          % % cfg.roi = {'LPI3','RPI3'};
          % cfg.latency = [0.4 0.8]; % LPC
          % % % cfg.latency = [0.3 0.5]; % N400
          % % % cfg.latency = [0.35 0.45]; % N400
          % % cfg.latency = [0.314 0.414]; % N400
          
          % % average across electrodes
          cfg.datadim = 'time';
          % and time points
          cfg.avgovertime = true;
          
          % % cfg.roi = {'Cz'};
          % % cfg.roi = {'LPI3','RPI3'};
          % % cfg.roi = {'Pz'};
          % % cfg.roi = {'PS2'};
          % % cfg.roi = {'RPI3'};
          % % cfg.roi = {'E84'}; % center of RPI3
          % % cfg.roi = {'RPS2'};
          % % cfg.roi = {'E85'}; % center of RPS2
          % % cfg.roi = {'LPS2'};
          % % cfg.latency = [0 1.0];
          % % cfg.latency = [0.2 0.9];
          
          cfg.is_ga = false;
          cfg.outputSubjects = true;
          % cfg.is_ga = true;
          cfg.sesNum = 1;
          
          cfg.plotit = false;
          cfg.voltlim = [-3 3]; % LPC
          % cfg.voltlim = [-2 2]; % N400
          % cfg.voltlim = [-1 5];
          
          % peakInfo = mm_findPeak(cfg,ana,exper,ga_tla);
          peakInfo = mm_findPeak(cfg,ana,exper,data_tla);
          
          allPeakInfo.(cond_str).(roi_str) = peakInfo;
          
        end
        
      end
    end
  end
end

%% ANOVA: factors: spaced/massed, recalled/forgotten, old/new

% spacings = {'mass', 'spac', 'onePres'};
% oldnew = {'p2'};
% memConds = {'all'};

% didn't test new words, so can't assess memory, but can use p1
spacings = {'mass', 'spac'};
oldnew = {'p1', 'p2'};
% oldnew = {'p2'};
memConds = {'rc','fo'};

% measure = 'latency';
measure = 'voltage';

% erpComp = 'N400';
% roi = {'Pz'};

% erpComp = 'LPC';
% roi = {'Cz'};

erpComp = 'N2';
% roi = {'E69','E89'}; % near O1, O2
% roi = {'E58','E96'}; % T5, T6
roi = {'E58_E96'}; % T5, T6

anovaData = [];

for sub = 1:sum(~exper.badSub)
  theseData = [];
  
  for sp = 1:length(spacings)
    for on = 1:length(oldnew)
      for mc = 1:length(memConds)
        
        cond_str = [];
        if strcmp(spacings{sp},'onePres')
          % % single presentation or first presentation
          if strcmp(memConds{mc},'all');
            cond_str = sprintf('%s_%s',spacings{sp},memConds{mc});
          end
        elseif strcmp(spacings{sp},'mass') || strcmp(spacings{sp},'spac')
          cond_str = sprintf('%s_%s_%s',spacings{sp},oldnew{on},memConds{mc});
        end
        
        for r = 1:length(roi)
          roi_str = sprintf('%s_%s',erpComp,roi{r});
          theseData = cat(2,theseData,allPeakInfo.(cond_str).(roi_str).subjects.(measure)(sub,1));
        end
      end
    end
  end
  anovaData = cat(1,anovaData,theseData);
end

fprintf('================================================================\n');
fprintf('This test: %s:%s, %s\n',erpComp,sprintf(repmat(' %s',1,length(roi)),roi{:}),measure);

varnames = {'spacings', 'oldnew', 'memConds', 'roi'};
levelnames = cell(size(varnames));
levellengths = nan(size(varnames));
keepThese = false(size(varnames));
for c = 1:length(varnames)
  if length(eval(varnames{c})) > 1
    levelnames{c} = eval(varnames{c});
    levellengths(c) = length(eval(varnames{c}));
    keepThese(c) = true;
  end
end
varnames = varnames(keepThese);
levelnames = levelnames(keepThese);
levellengths = levellengths(keepThese);

O = teg_repeated_measures_ANOVA(anovaData, levellengths, varnames,[],[],[],[],[],[],levelnames);


% if length(memConds) > 1 && length(oldnew) > 1 && length(roi) > 1
%   levelnames = {spacings oldnew memConds};
%   varnames = {'spacing', 'oldnew', 'memory'};
%   O = teg_repeated_measures_ANOVA(anovaData, [length(spacings) length(oldnew) length(memConds)], varnames,[],[],[],[],[],[],levelnames);
% elseif length(memConds) > 1 && length(oldnew) == 1
%   levelnames = {spacings memConds};
%   varnames = {'spacing', 'memory'};
%   O = teg_repeated_measures_ANOVA(anovaData, [length(spacings) length(memConds)], varnames,[],[],[],[],[],[],levelnames);
% elseif length(memConds) == 1 && length(oldnew) > 1
%   levelnames = {spacings oldnew};
%   varnames = {'spacing', 'oldnew'};
%   O = teg_repeated_measures_ANOVA(anovaData, [length(spacings) length(oldnew)], varnames,[],[],[],[],[],[],levelnames);
% else
%   levelnames = {spacings};
%   varnames = {'spacing'};
%   O = teg_repeated_measures_ANOVA(anovaData, [length(spacings)], varnames,[],[],[],[],[],[],levelnames);
% end

fprintf('Prev test: %s:%s, %s\n',erpComp,sprintf(repmat(' %s',1,length(roi)),roi{:}),measure);
fprintf('================================================================\n');

%% gather data for pairwise t-tests

% erpComp = 'LPC';
erpComp = 'N400';

fprintf('%s\n',erpComp);

space_peak = allPeakInfo.spaced_all.(erpComp).subjects.latency(:,1);
space_volt = allPeakInfo.spaced_all.(erpComp).subjects.voltage(:,1);

mass_peak = allPeakInfo.massed_all.(erpComp).subjects.latency(:,1);
mass_volt = allPeakInfo.massed_all.(erpComp).subjects.voltage(:,1);

one_peak = allPeakInfo.once_all.(erpComp).subjects.latency(:,1);
one_volt = allPeakInfo.once_all.(erpComp).subjects.voltage(:,1);

%% ttest - latency

fprintf('space: %.4f sec\n',mean(space_peak));
fprintf('mass: %.4f sec\n',mean(mass_peak));
fprintf('one: %.4f sec\n',mean(one_peak));

[h,p,ci,stats] = ttest(space_peak,mass_peak,'alpha',0.05,'tail','both');
fprintf('Space vs mass: t(%d)=%.4f, p=%.8f\n',stats.df,stats.tstat,p);

[h,p,ci,stats] = ttest(space_peak,one_peak,'alpha',0.05,'tail','both');
fprintf('Space vs one: t(%d)=%.4f, p=%.8f\n',stats.df,stats.tstat,p);

[h,p,ci,stats] = ttest(mass_peak,one_peak,'alpha',0.05,'tail','both');
fprintf('Mass vs one: t(%d)=%.4f, p=%.8f\n',stats.df,stats.tstat,p);

%% ttest - voltage

fprintf('space: %.4f uV\n',mean(space_volt));
fprintf('mass: %.4f uV\n',mean(mass_volt));
fprintf('one: %.4f uV\n',mean(one_volt));

[h,p,ci,stats] = ttest(space_volt,mass_volt,'alpha',0.05,'tail','both');
fprintf('Space vs mass: t(%d)=%.4f, p=%.8f\n',stats.df,stats.tstat,p);

[h,p,ci,stats] = ttest(space_volt,one_volt,'alpha',0.05,'tail','both');
fprintf('Space vs one: t(%d)=%.4f, p=%.8f\n',stats.df,stats.tstat,p);

[h,p,ci,stats] = ttest(mass_volt,one_volt,'alpha',0.05,'tail','both');
fprintf('Mass vs one: t(%d)=%.4f, p=%.8f\n',stats.df,stats.tstat,p);


%% voltage interaction

fprintf('space - one: %.4f uV\n',mean(space_volt - one_volt));
fprintf('mass - one: %.4f uV\n',mean(mass_volt - one_volt));

[h,p,ci,stats] = ttest([space_volt - one_volt],[mass_volt - one_volt],'alpha',0.05,'tail','both');
fprintf('Space/one vs mass/one: t(%d)=%.4f, p=%.8f\n',stats.df,stats.tstat,p);


%% correlation - loading

subDir = '';
behDir = fullfile(exper.name,'Behavioral','Sessions',subDir);
behDir = fullfile(dirs.dataroot,behDir);

collapsePhases = true;
if collapsePhases
  collapseStr = '_collapsed';
else
  collapseStr = '';
end

% split into quantile divisions?
nDivisions = 1;
% nDivisions = 2;
% nDivisions = 3;
% nDivisions = 4;

if nDivisions > 1
  quantStr = sprintf('_%dquantileDiv',nDivisions);
else
  quantStr = '';
end

% load the behavioral data
%resultsFile = fullfile(dataroot,dirs.behDir,sprintf('%s_behav_results%s%s.mat',expName,quantStr,collapseStr));
resultsFile = fullfile(behDir,sprintf('%s_behav_results%s%s.mat',exper.name,quantStr,collapseStr));

fprintf('Loading %s...',resultsFile);
load(resultsFile);
fprintf('Done.\n');

%% correlation

ses = 'oneDay';
phase = 'cued_recall';
test = 'recall';
measure = 'recall_nHit';
% measure = 'recall_hr';

manip = 'massed';
data1 = results.(ses).(phase).(manip).(test).(measure)(~exper.badSub);

[rho,p] = corr(data1,space_volt - one_volt);

% [rho,p] = corr(data1,mass_volt - one_volt);
