% space_classifier

%% load the analysis details

subDir = '';
dataDir = fullfile('SPACE','EEG','Sessions','ftpp',subDir);
% Possible locations of the data files (dataroot)
serverDir = fullfile(filesep,'Volumes','curranlab','Data');
serverLocalDir = fullfile(filesep,'Volumes','RAID','curranlab','Data');
dreamDir = fullfile(filesep,'data','projects','curranlab');
localDir = fullfile(getenv('HOME'),'data');

% pick the right dataroot
if exist('serverDir','var') && exist(serverDir,'dir')
  dataroot = serverDir;
  %runLocally = 1;
elseif exist('serverLocalDir','var') && exist(serverLocalDir,'dir')
  dataroot = serverLocalDir;
  %runLocally = 1;
elseif exist('dreamDir','var') && exist(dreamDir,'dir')
  dataroot = dreamDir;
  %runLocally = 0;
elseif exist('localDir','var') && exist(localDir,'dir')
  dataroot = localDir;
  %runLocally = 1;
else
  error('Data directory not found.');
end

% procDir = '/Users/matt/data/SPACE/EEG/Sessions/ftpp/ft_data/cued_recall_stim_expo_stim_multistudy_image_multistudy_word_art_ftManual_ftICA/tla';
procDir = fullfile(dataroot,dataDir,'ft_data/cued_recall_stim_expo_stim_multistudy_image_multistudy_word_art_ftManual_ftICA/tla');

subjects = {
  %'SPACE001'; low trial counts
  'SPACE002';
  'SPACE003';
  'SPACE004';
  'SPACE005';
  'SPACE006';
  'SPACE007';
  %'SPACE008'; % didn't perform task correctly, didn't perform well
  'SPACE009';
  'SPACE010';
  'SPACE011';
  'SPACE012';
  'SPACE013';
  'SPACE014';
  'SPACE015';
  'SPACE016';
  %'SPACE017'; % previous assessment: really noisy EEG, half of ICA components rejected
  'SPACE018';
  %'SPACE019'; low trial counts
  'SPACE020';
  'SPACE021';
  'SPACE022';
  'SPACE027';
  'SPACE029';
  'SPACE037';
  %'SPACE039'; % noisy EEG; original EEG analyses stopped here
  'SPACE023';
  'SPACE024';
  'SPACE025';
  'SPACE026';
  'SPACE028';
  %'SPACE030'; % low trial counts
  'SPACE032';
  'SPACE034';
  'SPACE047';
  'SPACE049';
  'SPACE036';
  };

% only one cell, with all session names
sesNames = {'session_1'};

allowRecallSynonyms = true;

% replaceDataroot = {'/Users/matt/data','/Volumes/curranlab/Data'};
replaceDataroot = true;

[exper,ana,dirs,files] = mm_loadAD(procDir,subjects,sesNames,replaceDataroot);

files.figPrintFormat = 'png';
files.saveFigs = true;

%% set up channel groups

% pre-defined in this function
ana = mm_ft_elecGroups(ana);

%% list the event values to analyze; specific to each experiment

% this is useful for when there are multiple types of event values, for
% example, hits and CRs in two conditions. You don't have to enter anything
% if you just want all events from exper.eventValues together in a single
% cell because it will get set to {exper.eventValues}, but it needs to be a
% cell containing a cell of eventValue strings

% this is only used by mm_ft_checkCondComps to create pairwise combinations
% either within event types {'all_within_types'} or across all event types
% {'all_across_types'}; mm_ft_checkCondComps is called within subsequent
% analysis functions

%% classifier needs expo and multistudy

% can include targ==-1 because those are simply buffers for multistudy

sesNum = 1;

ana.eventValues = {{'expo_stim'}};
% ana.eventValues = {{'expo_stim','multistudy_word'}};
% ana.eventValues = {{'expo_stim','multistudy_word','multistudy_image'}};
ana.eventValuesSplit = { ...
  {{'Face','House'} ...
%   { ...
%   'word_RgH_rc_spac_p2' ,'word_RgH_rc_mass_p2' ...
%   'word_RgH_fo_spac_p2' ,'word_RgH_fo_mass_p2' ...
%   } ...
%   { ...
%   'img_RgH_rc_spac' ,'img_RgH_rc_mass' ...
%   'img_RgH_fo_spac' ,'img_RgH_fo_mass' ...
%   } ...
  } ...
  };
if allowRecallSynonyms
  ana.trl_expr = {...
    {{sprintf('eventNumber == %d & i_catNum == 1 & expo_response ~= 0 & rt < 3000',find(ismember(exper.eventValues{sesNum},'expo_stim'))), ...
    sprintf('eventNumber == %d & i_catNum == 2 & expo_response ~= 0 & rt < 3000',find(ismember(exper.eventValues{sesNum},'expo_stim')))} ...
%     {...
%     sprintf('eventNumber == %d & targ == 1 & cr_recog_acc == 1 & cr_recall_spellCorr > 0 & spaced == 1 & lag > 0 & presNum == 2',find(ismember(exper.eventValues{sesNum},'multistudy_word'))) ...
%     sprintf('eventNumber == %d & targ == 1 & cr_recog_acc == 1 & cr_recall_spellCorr > 0 & spaced == 0 & lag == 0 & presNum == 2',find(ismember(exper.eventValues{sesNum},'multistudy_word'))) ...
%     sprintf('eventNumber == %d & targ == 1 & cr_recog_acc == 1 & cr_recall_spellCorr == 0 & spaced == 1 & lag > 0 & presNum == 2',find(ismember(exper.eventValues{sesNum},'multistudy_word'))) ...
%     sprintf('eventNumber == %d & targ == 1 & cr_recog_acc == 1 & cr_recall_spellCorr == 0 & spaced == 0 & lag == 0 & presNum == 2',find(ismember(exper.eventValues{sesNum},'multistudy_word'))) ...
%     } ...
%     {...
%     sprintf('eventNumber == %d & targ == 1 & cr_recog_acc == 1 & cr_recall_spellCorr > 0 & spaced == 1 & lag > 0',find(ismember(exper.eventValues{sesNum},'multistudy_image'))) ...
%     sprintf('eventNumber == %d & targ == 1 & cr_recog_acc == 1 & cr_recall_spellCorr > 0 & spaced == 0 & lag == 0',find(ismember(exper.eventValues{sesNum},'multistudy_image'))) ...
%     sprintf('eventNumber == %d & targ == 1 & cr_recog_acc == 1 & cr_recall_spellCorr == 0 & spaced == 1 & lag > 0',find(ismember(exper.eventValues{sesNum},'multistudy_image'))) ...
%     sprintf('eventNumber == %d & targ == 1 & cr_recog_acc == 1 & cr_recall_spellCorr == 0 & spaced == 0 & lag == 0',find(ismember(exper.eventValues{sesNum},'multistudy_image'))) ...
%     } ...
    } ...
    };
else
  ana.trl_expr = {...
    {{sprintf('eventNumber == %d & i_catNum == 1 & expo_response ~= 0 & rt < 3000',find(ismember(exper.eventValues{sesNum},'expo_stim'))), ...
    sprintf('eventNumber == %d & i_catNum == 2 & expo_response ~= 0 & rt < 3000',find(ismember(exper.eventValues{sesNum},'expo_stim')))} ...
%     { ...
%     sprintf('eventNumber == %d & targ == 1 & cr_recog_acc == 1 & cr_recall_spellCorr == 1 & spaced == 1 & lag > 0 & presNum == 2',find(ismember(exper.eventValues{sesNum},'multistudy_word'))) ...
%     sprintf('eventNumber == %d & targ == 1 & cr_recog_acc == 1 & cr_recall_spellCorr == 1 & spaced == 0 & lag == 0 & presNum == 2',find(ismember(exper.eventValues{sesNum},'multistudy_word'))) ...
%     sprintf('eventNumber == %d & targ == 1 & cr_recog_acc == 1 & cr_recall_spellCorr < 1 & spaced == 1 & lag > 0 & presNum == 2',find(ismember(exper.eventValues{sesNum},'multistudy_word'))) ...
%     sprintf('eventNumber == %d & targ == 1 & cr_recog_acc == 1 & cr_recall_spellCorr < 1 & spaced == 0 & lag == 0 & presNum == 2',find(ismember(exper.eventValues{sesNum},'multistudy_word'))) ...
%     } ...
%     { ...
%     sprintf('eventNumber == %d & targ == 1 & cr_recog_acc == 1 & cr_recall_spellCorr == 1 & spaced == 1 & lag > 0',find(ismember(exper.eventValues{sesNum},'multistudy_image'))) ...
%     sprintf('eventNumber == %d & targ == 1 & cr_recog_acc == 1 & cr_recall_spellCorr == 1 & spaced == 0 & lag == 0',find(ismember(exper.eventValues{sesNum},'multistudy_image'))) ...
%     sprintf('eventNumber == %d & targ == 1 & cr_recog_acc == 1 & cr_recall_spellCorr < 1 & spaced == 1 & lag > 0',find(ismember(exper.eventValues{sesNum},'multistudy_image'))) ...
%     sprintf('eventNumber == %d & targ == 1 & cr_recog_acc == 1 & cr_recall_spellCorr < 1 & spaced == 0 & lag == 0',find(ismember(exper.eventValues{sesNum},'multistudy_image'))) ...
%     } ...
    } ...
    };
end

% ana.eventValues = {{'expo_stim'}};
% ana.eventValuesSplit = {{{'Face_VU','Face_SU','Face_SA','Face_VA','House_VU','House_SU','House_SA','House_VA',}}};
% ana.trl_expr = {...
%   {{sprintf('eventNumber == %d & i_catNum == 1 & expo_response == 1 & rt < 3000',find(ismember(exper.eventValues{sesNum},'expo_stim'))), ...
%   sprintf('eventNumber == %d & i_catNum == 1 & expo_response == 2 & rt < 3000',find(ismember(exper.eventValues{sesNum},'expo_stim'))), ...
%   sprintf('eventNumber == %d & i_catNum == 1 & expo_response == 3 & rt < 3000',find(ismember(exper.eventValues{sesNum},'expo_stim'))), ...
%   sprintf('eventNumber == %d & i_catNum == 1 & expo_response == 4 & rt < 3000',find(ismember(exper.eventValues{sesNum},'expo_stim'))), ...
%   sprintf('eventNumber == %d & i_catNum == 2 & expo_response == 1 & rt < 3000',find(ismember(exper.eventValues{sesNum},'expo_stim'))), ...
%   sprintf('eventNumber == %d & i_catNum == 2 & expo_response == 2 & rt < 3000',find(ismember(exper.eventValues{sesNum},'expo_stim'))), ...
%   sprintf('eventNumber == %d & i_catNum == 2 & expo_response == 3 & rt < 3000',find(ismember(exper.eventValues{sesNum},'expo_stim'))), ...
%   sprintf('eventNumber == %d & i_catNum == 2 & expo_response == 4 & rt < 3000',find(ismember(exper.eventValues{sesNum},'expo_stim')))}}};

%% expo

% can include targ==-1 because those are simply buffers for multistudy

sesNum = 1;

ana.eventValues = {{'expo_stim'}};
ana.eventValuesSplit = {{{'Face','House'}}};
ana.trl_expr = {...
  {{sprintf('eventNumber == %d & i_catNum == 1 & expo_response ~= 0 & rt < 3000',find(ismember(exper.eventValues{sesNum},'expo_stim'))), ...
  sprintf('eventNumber == %d & i_catNum == 2 & expo_response ~= 0 & rt < 3000',find(ismember(exper.eventValues{sesNum},'expo_stim')))}}};

%% multistudy events

sesNum = 1;

% ana.trl_order.multistudy_image = {'eventNumber', 'sesType', 'phaseType', 'phaseCount', 'trial', 'stimNum', 'catNum', 'targ', 'spaced', 'lag', 'presNum', 'pairOrd', 'pairNum', 'cr_recog_acc', 'cr_recall_resp', 'cr_recall_spellCorr'};

ana.eventValues = {{'multistudy_image','multistudy_word'}};
ana.eventValuesSplit = { ...
  {{'img_onePres' ...
  'img_RgH_rc_spac_p1','img_RgH_rc_spac_p2','img_RgH_rc_mass_p1','img_RgH_rc_mass_p2' ...
  'img_RgH_fo_spac_p1','img_RgH_fo_spac_p2','img_RgH_fo_mass_p1','img_RgH_fo_mass_p2' ...
  %'img_RgM_spac_p1','img_RgM_spac_p2','img_RgM_mass_p1','img_RgM_mass_p2' ...
  } ...
  {'word_onePres' ...
  'word_RgH_rc_spac_p1','word_RgH_rc_spac_p2','word_RgH_rc_mass_p1','word_RgH_rc_mass_p2' ...
  'word_RgH_fo_spac_p1','word_RgH_fo_spac_p2','word_RgH_fo_mass_p1','word_RgH_fo_mass_p2' ...
  %'word_RgM_spac_p1','word_RgM_spac_p2','word_RgM_mass_p1','word_RgM_mass_p2' ...
  }} ...
  };
if allowRecallSynonyms
  ana.trl_expr = { ...
    {{ ...
    sprintf('eventNumber == %d & targ == 1 & spaced == 0 & lag == -1 & presNum == 1',find(ismember(exper.eventValues{sesNum},'multistudy_image'))) ...
    sprintf('eventNumber == %d & targ == 1 & cr_recog_acc == 1 & cr_recall_spellCorr > 0 & spaced == 1 & lag > 0 & presNum == 1',find(ismember(exper.eventValues{sesNum},'multistudy_image'))) ...
    sprintf('eventNumber == %d & targ == 1 & cr_recog_acc == 1 & cr_recall_spellCorr > 0 & spaced == 1 & lag > 0 & presNum == 2',find(ismember(exper.eventValues{sesNum},'multistudy_image'))) ...
    sprintf('eventNumber == %d & targ == 1 & cr_recog_acc == 1 & cr_recall_spellCorr > 0 & spaced == 0 & lag == 0 & presNum == 1',find(ismember(exper.eventValues{sesNum},'multistudy_image'))) ...
    sprintf('eventNumber == %d & targ == 1 & cr_recog_acc == 1 & cr_recall_spellCorr > 0 & spaced == 0 & lag == 0 & presNum == 2',find(ismember(exper.eventValues{sesNum},'multistudy_image'))) ...
    sprintf('eventNumber == %d & targ == 1 & cr_recog_acc == 1 & cr_recall_spellCorr == 0 & spaced == 1 & lag > 0 & presNum == 1',find(ismember(exper.eventValues{sesNum},'multistudy_image'))) ...
    sprintf('eventNumber == %d & targ == 1 & cr_recog_acc == 1 & cr_recall_spellCorr == 0 & spaced == 1 & lag > 0 & presNum == 2',find(ismember(exper.eventValues{sesNum},'multistudy_image'))) ...
    sprintf('eventNumber == %d & targ == 1 & cr_recog_acc == 1 & cr_recall_spellCorr == 0 & spaced == 0 & lag == 0 & presNum == 1',find(ismember(exper.eventValues{sesNum},'multistudy_image'))) ...
    sprintf('eventNumber == %d & targ == 1 & cr_recog_acc == 1 & cr_recall_spellCorr == 0 & spaced == 0 & lag == 0 & presNum == 2',find(ismember(exper.eventValues{sesNum},'multistudy_image'))) ...
    %sprintf('eventNumber == %d & targ == 1 & cr_recog_acc == 0 & spaced == 1 & lag > 0 & presNum == 1',find(ismember(exper.eventValues{sesNum},'multistudy_image'))) ...
    %sprintf('eventNumber == %d & targ == 1 & cr_recog_acc == 0 & spaced == 1 & lag > 0 & presNum == 2',find(ismember(exper.eventValues{sesNum},'multistudy_image'))) ...
    %sprintf('eventNumber == %d & targ == 1 & cr_recog_acc == 0 & spaced == 0 & lag == 0 & presNum == 1',find(ismember(exper.eventValues{sesNum},'multistudy_image'))) ...
    %sprintf('eventNumber == %d & targ == 1 & cr_recog_acc == 0 & spaced == 0 & lag == 0 & presNum == 2',find(ismember(exper.eventValues{sesNum},'multistudy_image'))) ...
    } ...
    { ...
    sprintf('eventNumber == %d & targ == 1 & spaced == 0 & lag == -1 & presNum == 1',find(ismember(exper.eventValues{sesNum},'multistudy_word'))) ...
    sprintf('eventNumber == %d & targ == 1 & cr_recog_acc == 1 & cr_recall_spellCorr > 0 & spaced == 1 & lag > 0 & presNum == 1',find(ismember(exper.eventValues{sesNum},'multistudy_word'))) ...
    sprintf('eventNumber == %d & targ == 1 & cr_recog_acc == 1 & cr_recall_spellCorr > 0 & spaced == 1 & lag > 0 & presNum == 2',find(ismember(exper.eventValues{sesNum},'multistudy_word'))) ...
    sprintf('eventNumber == %d & targ == 1 & cr_recog_acc == 1 & cr_recall_spellCorr > 0 & spaced == 0 & lag == 0 & presNum == 1',find(ismember(exper.eventValues{sesNum},'multistudy_word'))) ...
    sprintf('eventNumber == %d & targ == 1 & cr_recog_acc == 1 & cr_recall_spellCorr > 0 & spaced == 0 & lag == 0 & presNum == 2',find(ismember(exper.eventValues{sesNum},'multistudy_word'))) ...
    sprintf('eventNumber == %d & targ == 1 & cr_recog_acc == 1 & cr_recall_spellCorr == 0 & spaced == 1 & lag > 0 & presNum == 1',find(ismember(exper.eventValues{sesNum},'multistudy_word'))) ...
    sprintf('eventNumber == %d & targ == 1 & cr_recog_acc == 1 & cr_recall_spellCorr == 0 & spaced == 1 & lag > 0 & presNum == 2',find(ismember(exper.eventValues{sesNum},'multistudy_word'))) ...
    sprintf('eventNumber == %d & targ == 1 & cr_recog_acc == 1 & cr_recall_spellCorr == 0 & spaced == 0 & lag == 0 & presNum == 1',find(ismember(exper.eventValues{sesNum},'multistudy_word'))) ...
    sprintf('eventNumber == %d & targ == 1 & cr_recog_acc == 1 & cr_recall_spellCorr == 0 & spaced == 0 & lag == 0 & presNum == 2',find(ismember(exper.eventValues{sesNum},'multistudy_word'))) ...
    %sprintf('eventNumber == %d & targ == 1 & cr_recog_acc == 0 & spaced == 1 & lag > 0 & presNum == 1',find(ismember(exper.eventValues{sesNum},'multistudy_word'))) ...
    %sprintf('eventNumber == %d & targ == 1 & cr_recog_acc == 0 & spaced == 1 & lag > 0 & presNum == 2',find(ismember(exper.eventValues{sesNum},'multistudy_word'))) ...
    %sprintf('eventNumber == %d & targ == 1 & cr_recog_acc == 0 & spaced == 0 & lag == 0 & presNum == 1',find(ismember(exper.eventValues{sesNum},'multistudy_word'))) ...
    %sprintf('eventNumber == %d & targ == 1 & cr_recog_acc == 0  & spaced == 0 & lag == 0 & presNum == 2',find(ismember(exper.eventValues{sesNum},'multistudy_word'))) ...
    }} ...
    };
else
  ana.trl_expr = { ...
    {{ ...
    sprintf('eventNumber == %d & targ == 1 & spaced == 0 & lag == -1 & presNum == 1',find(ismember(exper.eventValues{sesNum},'multistudy_image'))) ...
    sprintf('eventNumber == %d & targ == 1 & cr_recog_acc == 1 & cr_recall_spellCorr == 1 & spaced == 1 & lag > 0 & presNum == 1',find(ismember(exper.eventValues{sesNum},'multistudy_image'))) ...
    sprintf('eventNumber == %d & targ == 1 & cr_recog_acc == 1 & cr_recall_spellCorr == 1 & spaced == 1 & lag > 0 & presNum == 2',find(ismember(exper.eventValues{sesNum},'multistudy_image'))) ...
    sprintf('eventNumber == %d & targ == 1 & cr_recog_acc == 1 & cr_recall_spellCorr == 1 & spaced == 0 & lag == 0 & presNum == 1',find(ismember(exper.eventValues{sesNum},'multistudy_image'))) ...
    sprintf('eventNumber == %d & targ == 1 & cr_recog_acc == 1 & cr_recall_spellCorr == 1 & spaced == 0 & lag == 0 & presNum == 2',find(ismember(exper.eventValues{sesNum},'multistudy_image'))) ...
    sprintf('eventNumber == %d & targ == 1 & cr_recog_acc == 1 & cr_recall_spellCorr < 1 & spaced == 1 & lag > 0 & presNum == 1',find(ismember(exper.eventValues{sesNum},'multistudy_image'))) ...
    sprintf('eventNumber == %d & targ == 1 & cr_recog_acc == 1 & cr_recall_spellCorr < 1 & spaced == 1 & lag > 0 & presNum == 2',find(ismember(exper.eventValues{sesNum},'multistudy_image'))) ...
    sprintf('eventNumber == %d & targ == 1 & cr_recog_acc == 1 & cr_recall_spellCorr < 1 & spaced == 0 & lag == 0 & presNum == 1',find(ismember(exper.eventValues{sesNum},'multistudy_image'))) ...
    sprintf('eventNumber == %d & targ == 1 & cr_recog_acc == 1 & cr_recall_spellCorr < 1 & spaced == 0 & lag == 0 & presNum == 2',find(ismember(exper.eventValues{sesNum},'multistudy_image'))) ...
    %sprintf('eventNumber == %d & targ == 1 & cr_recog_acc == 0 & spaced == 1 & lag > 0 & presNum == 1',find(ismember(exper.eventValues{sesNum},'multistudy_image'))) ...
    %sprintf('eventNumber == %d & targ == 1 & cr_recog_acc == 0 & spaced == 1 & lag > 0 & presNum == 2',find(ismember(exper.eventValues{sesNum},'multistudy_image'))) ...
    %sprintf('eventNumber == %d & targ == 1 & cr_recog_acc == 0 & spaced == 0 & lag == 0 & presNum == 1',find(ismember(exper.eventValues{sesNum},'multistudy_image'))) ...
    %sprintf('eventNumber == %d & targ == 1 & cr_recog_acc == 0 & spaced == 0 & lag == 0 & presNum == 2',find(ismember(exper.eventValues{sesNum},'multistudy_image'))) ...
    } ...
    { ...
    sprintf('eventNumber == %d & targ == 1 & spaced == 0 & lag == -1 & presNum == 1',find(ismember(exper.eventValues{sesNum},'multistudy_word'))) ...
    sprintf('eventNumber == %d & targ == 1 & cr_recog_acc == 1 & cr_recall_spellCorr == 1 & spaced == 1 & lag > 0 & presNum == 1',find(ismember(exper.eventValues{sesNum},'multistudy_word'))) ...
    sprintf('eventNumber == %d & targ == 1 & cr_recog_acc == 1 & cr_recall_spellCorr == 1 & spaced == 1 & lag > 0 & presNum == 2',find(ismember(exper.eventValues{sesNum},'multistudy_word'))) ...
    sprintf('eventNumber == %d & targ == 1 & cr_recog_acc == 1 & cr_recall_spellCorr == 1 & spaced == 0 & lag == 0 & presNum == 1',find(ismember(exper.eventValues{sesNum},'multistudy_word'))) ...
    sprintf('eventNumber == %d & targ == 1 & cr_recog_acc == 1 & cr_recall_spellCorr == 1 & spaced == 0 & lag == 0 & presNum == 2',find(ismember(exper.eventValues{sesNum},'multistudy_word'))) ...
    sprintf('eventNumber == %d & targ == 1 & cr_recog_acc == 1 & cr_recall_spellCorr < 1 & spaced == 1 & lag > 0 & presNum == 1',find(ismember(exper.eventValues{sesNum},'multistudy_word'))) ...
    sprintf('eventNumber == %d & targ == 1 & cr_recog_acc == 1 & cr_recall_spellCorr < 1 & spaced == 1 & lag > 0 & presNum == 2',find(ismember(exper.eventValues{sesNum},'multistudy_word'))) ...
    sprintf('eventNumber == %d & targ == 1 & cr_recog_acc == 1 & cr_recall_spellCorr < 1 & spaced == 0 & lag == 0 & presNum == 1',find(ismember(exper.eventValues{sesNum},'multistudy_word'))) ...
    sprintf('eventNumber == %d & targ == 1 & cr_recog_acc == 1 & cr_recall_spellCorr < 1 & spaced == 0 & lag == 0 & presNum == 2',find(ismember(exper.eventValues{sesNum},'multistudy_word'))) ...
    %sprintf('eventNumber == %d & targ == 1 & cr_recog_acc == 0 & spaced == 1 & lag > 0 & presNum == 1',find(ismember(exper.eventValues{sesNum},'multistudy_word'))) ...
    %sprintf('eventNumber == %d & targ == 1 & cr_recog_acc == 0 & spaced == 1 & lag > 0 & presNum == 2',find(ismember(exper.eventValues{sesNum},'multistudy_word'))) ...
    %sprintf('eventNumber == %d & targ == 1 & cr_recog_acc == 0 & spaced == 0 & lag == 0 & presNum == 1',find(ismember(exper.eventValues{sesNum},'multistudy_word'))) ...
    %sprintf('eventNumber == %d & targ == 1 & cr_recog_acc == 0  & spaced == 0 & lag == 0 & presNum == 2',find(ismember(exper.eventValues{sesNum},'multistudy_word'))) ...
    }} ...
    };
end

% ana.eventValues = {{'multistudy_image', 'multistudy_word'}};
% ana.eventValuesSplit = { ...
%   {{'img_onePres' ...
%   'img_RgH_spac_p1','img_RgH_spac_p2','img_RgH_mass_p1','img_RgH_mass_p2' ...
%   %'img_RgM_spac_p1','img_RgM_spac_p2','img_RgM_mass_p1','img_RgM_mass_p2' ...
%   } ...
%   {'word_onePres' ...
%   'word_RgH_spac_p1','word_RgH_spac_p2','word_RgH_mass_p1','word_RgH_mass_p2' ...
%   %'word_RgM_spac_p1','word_RgM_spac_p2','word_RgM_mass_p1','word_RgM_mass_p2' ...
%   }} ...
%   };
% ana.trl_expr = { ...
%   {{ ...
%   sprintf('eventNumber == %d & targ == 1 & spaced == 0 & lag == -1 & presNum == 1',find(ismember(exper.eventValues{sesNum},'multistudy_image'))) ...
%   sprintf('eventNumber == %d & targ == 1 & cr_recog_acc == 1 & spaced == 1 & lag > 0 & presNum == 1',find(ismember(exper.eventValues{sesNum},'multistudy_image'))) ...
%   sprintf('eventNumber == %d & targ == 1 & cr_recog_acc == 1 & spaced == 1 & lag > 0 & presNum == 2',find(ismember(exper.eventValues{sesNum},'multistudy_image'))) ...
%   sprintf('eventNumber == %d & targ == 1 & cr_recog_acc == 1 & spaced == 0 & lag == 0 & presNum == 1',find(ismember(exper.eventValues{sesNum},'multistudy_image'))) ...
%   sprintf('eventNumber == %d & targ == 1 & cr_recog_acc == 1 & spaced == 0 & lag == 0 & presNum == 2',find(ismember(exper.eventValues{sesNum},'multistudy_image'))) ...
%   %sprintf('eventNumber == %d & targ == 1 & cr_recog_acc == 0 & spaced == 1 & lag > 0 & presNum == 1',find(ismember(exper.eventValues{sesNum},'multistudy_image'))) ...
%   %sprintf('eventNumber == %d & targ == 1 & cr_recog_acc == 0 & spaced == 1 & lag > 0 & presNum == 2',find(ismember(exper.eventValues{sesNum},'multistudy_image'))) ...
%   %sprintf('eventNumber == %d & targ == 1 & cr_recog_acc == 0 & spaced == 0 & lag == 0 & presNum == 1',find(ismember(exper.eventValues{sesNum},'multistudy_image'))) ...
%   %sprintf('eventNumber == %d & targ == 1 & cr_recog_acc == 0 & spaced == 0 & lag == 0 & presNum == 2',find(ismember(exper.eventValues{sesNum},'multistudy_image'))) ...
%   } ...
%   { ...
%   sprintf('eventNumber == %d & targ == 1 & spaced == 0 & lag == -1 & presNum == 1',find(ismember(exper.eventValues{sesNum},'multistudy_word'))) ...
%   sprintf('eventNumber == %d & targ == 1 & cr_recog_acc == 1 & spaced == 1 & lag > 0 & presNum == 1',find(ismember(exper.eventValues{sesNum},'multistudy_word'))) ...
%   sprintf('eventNumber == %d & targ == 1 & cr_recog_acc == 1 & spaced == 1 & lag > 0 & presNum == 2',find(ismember(exper.eventValues{sesNum},'multistudy_word'))) ...
%   sprintf('eventNumber == %d & targ == 1 & cr_recog_acc == 1 & spaced == 0 & lag == 0 & presNum == 1',find(ismember(exper.eventValues{sesNum},'multistudy_word'))) ...
%   sprintf('eventNumber == %d & targ == 1 & cr_recog_acc == 1 & spaced == 0 & lag == 0 & presNum == 2',find(ismember(exper.eventValues{sesNum},'multistudy_word'))) ...
%   %sprintf('eventNumber == %d & targ == 1 & cr_recog_acc == 0 & spaced == 1 & lag > 0 & presNum == 1',find(ismember(exper.eventValues{sesNum},'multistudy_word'))) ...
%   %sprintf('eventNumber == %d & targ == 1 & cr_recog_acc == 0 & spaced == 1 & lag > 0 & presNum == 2',find(ismember(exper.eventValues{sesNum},'multistudy_word'))) ...
%   %sprintf('eventNumber == %d & targ == 1 & cr_recog_acc == 0 & spaced == 0 & lag == 0 & presNum == 1',find(ismember(exper.eventValues{sesNum},'multistudy_word'))) ...
%   %sprintf('eventNumber == %d & targ == 1 & cr_recog_acc == 0  & spaced == 0 & lag == 0 & presNum == 2',find(ismember(exper.eventValues{sesNum},'multistudy_word'))) ...
%   }} ...
%   };

% ana.eventValues = {{'multistudy_image','multistudy_word'}};
% ana.eventValuesSplit = {...
%   {{'img_onePres', 'img_spac_p1','img_spac_p2','img_mass_p1','img_mass_p2'} ...
%   {'word_onePres', 'word_spac_p1','word_spac_p2','word_mass_p1','word_mass_p2'}} ...
%   };
% ana.trl_expr = {...
%   {{...
%   sprintf('eventNumber == %d & targ == 1 & spaced == 0 & lag == -1 & presNum == 1',find(ismember(exper.eventValues{sesNum},'multistudy_image'))) ...
%   sprintf('eventNumber == %d & targ == 1 & spaced == 1 & lag > 0 & presNum == 1',find(ismember(exper.eventValues{sesNum},'multistudy_image'))) ...
%   sprintf('eventNumber == %d & targ == 1 & spaced == 1 & lag > 0 & presNum == 2',find(ismember(exper.eventValues{sesNum},'multistudy_image'))) ...
%   sprintf('eventNumber == %d & targ == 1 & spaced == 0 & lag == 0 & presNum == 1',find(ismember(exper.eventValues{sesNum},'multistudy_image'))) ...
%   sprintf('eventNumber == %d & targ == 1 & spaced == 0 & lag == 0 & presNum == 2',find(ismember(exper.eventValues{sesNum},'multistudy_image'))) ...
%   } ...
%   {...
%   sprintf('eventNumber == %d & targ == 1 & spaced == 0 & lag == -1 & presNum == 1',find(ismember(exper.eventValues{sesNum},'multistudy_word'))) ...
%   sprintf('eventNumber == %d & targ == 1 & spaced == 1 & lag > 0 & presNum == 1',find(ismember(exper.eventValues{sesNum},'multistudy_word'))) ...
%   sprintf('eventNumber == %d & targ == 1 & spaced == 1 & lag > 0 & presNum == 2',find(ismember(exper.eventValues{sesNum},'multistudy_word'))) ...
%   sprintf('eventNumber == %d & targ == 1 & spaced == 0 & lag == 0 & presNum == 1',find(ismember(exper.eventValues{sesNum},'multistudy_word'))) ...
%   sprintf('eventNumber == %d & targ == 1 & spaced == 0 & lag == 0 & presNum == 2',find(ismember(exper.eventValues{sesNum},'multistudy_word'))) ...
%   }} ...
%   };

%% recognition events

% sesNum = 1;

% ana.trl_order.cued_recall_stim = {'eventNumber', 'sesType', 'phaseType', 'phaseCount', 'trial', 'stimNum', 'i_catNum', 'targ', 'spaced', 'lag', 'pairNum', 'recog_resp', 'recog_acc', 'recog_rt', 'new_resp', 'new_acc', 'new_rt', 'recall_resp', 'recall_spellCorr', 'recall_rt'};

% ana.eventValues = {{'cued_recall_stim'}};
% ana.eventValuesSplit = {{{'RgH','CR'}}};
% ana.trl_expr = {...
%   {{sprintf('eventNumber == %d & targ == 1 & recog_resp == 1 & recog_acc == 1 & recog_rt < 3000',find(ismember(exper.eventValues{sesNum},'cued_recall_stim'))), ...
%   sprintf('eventNumber == %d & targ == 0 & recog_resp == 2 & recog_acc == 1 & recog_rt < 3000 & new_resp ~= 0 & new_acc == 1',find(ismember(exper.eventValues{sesNum},'cued_recall_stim')))}}};

% ana.eventValues = {{'cued_recall_stim'}};
% ana.eventValuesSplit = {{{'RgH_rc_spac','RgH_rc_mass','RgH_fo_spac','RgH_fo_mass','CR'}}};
% if allowRecallSynonyms
%   ana.trl_expr = {...
%     {{sprintf('eventNumber == %d & targ == 1 & recog_resp == 1 & recog_acc == 1 & recog_rt < 3000 & recall_spellCorr > 0 & spaced == 1 & lag > 0',find(ismember(exper.eventValues{sesNum},'cued_recall_stim'))), ...
%     sprintf('eventNumber == %d & targ == 1 & recog_resp == 1 & recog_acc == 1 & recog_rt < 3000 & recall_spellCorr > 0 & spaced == 0 & lag == 0',find(ismember(exper.eventValues{sesNum},'cued_recall_stim'))), ...
%     sprintf('eventNumber == %d & targ == 1 & recog_resp == 1 & recog_acc == 1 & recog_rt < 3000 & recall_spellCorr == 0 & spaced == 1 & lag > 0',find(ismember(exper.eventValues{sesNum},'cued_recall_stim'))), ...
%     sprintf('eventNumber == %d & targ == 1 & recog_resp == 1 & recog_acc == 1 & recog_rt < 3000 & recall_spellCorr == 0 & spaced == 0 & lag == 0',find(ismember(exper.eventValues{sesNum},'cued_recall_stim'))), ...
%     sprintf('eventNumber == %d & targ == 0 & recog_resp == 2 & recog_acc == 1 & recog_rt < 3000 & new_resp ~= 0 & new_acc == 1',find(ismember(exper.eventValues{sesNum},'cued_recall_stim')))}}};
% else
%   ana.trl_expr = {...
%     {{sprintf('eventNumber == %d & targ == 1 & recog_resp == 1 & recog_acc == 1 & recog_rt < 3000 & recall_spellCorr == 1 & spaced == 1 & lag > 0',find(ismember(exper.eventValues{sesNum},'cued_recall_stim'))), ...
%     sprintf('eventNumber == %d & targ == 1 & recog_resp == 1 & recog_acc == 1 & recog_rt < 3000 & recall_spellCorr == 1 & spaced == 0 & lag == 0',find(ismember(exper.eventValues{sesNum},'cued_recall_stim'))), ...
%     sprintf('eventNumber == %d & targ == 1 & recog_resp == 1 & recog_acc == 1 & recog_rt < 3000 & recall_spellCorr < 1 & spaced == 1 & lag > 0',find(ismember(exper.eventValues{sesNum},'cued_recall_stim'))), ...
%     sprintf('eventNumber == %d & targ == 1 & recog_resp == 1 & recog_acc == 1 & recog_rt < 3000 & recall_spellCorr < 1 & spaced == 0 & lag == 0',find(ismember(exper.eventValues{sesNum},'cued_recall_stim'))), ...
%     sprintf('eventNumber == %d & targ == 0 & recog_resp == 2 & recog_acc == 1 & recog_rt < 3000 & new_resp ~= 0 & new_acc == 1',find(ismember(exper.eventValues{sesNum},'cued_recall_stim')))}}};
% end

%% load in the subject data

% % make sure ana.eventValues is set properly
% if ~iscell(ana.eventValues{1})
%   ana.eventValues = {ana.eventValues};
% end
% if ~isfield(ana,'eventValues') || isempty(ana.eventValues{1})
%   ana.eventValues = {exper.eventValues};
% end

% [data_tla,exper] = mm_ft_loadSubjectData(exper,dirs,ana,'tla',1,'trialinfo');
[data_tla,exper] = mm_loadSubjectData(exper,dirs,ana,'tla',1,'trialinfo');

% %% get rid of the bad channels
%
% cfg = [];
% cfg.printRoi = {{'LAS'},{'RAS'},{'LPS'},{'RPS'}};
% [data_tla] = mm_rmBadChan(cfg,exper,ana,data_tla);

% overwrite ana.eventValues with the new split events
ana.eventValues = ana.eventValuesSplit;

%% decide who to kick out based on trial counts

% Subjects with bad behavior
% exper.badBehSub = {{}};
exper.badBehSub = {{'SPACE001','SPACE008','SPACE017','SPACE019','SPACE039'}};

% exclude subjects with low event counts
[exper,ana] = mm_threshSubs_multiSes(exper,ana,5,[],'vert');

%% lowpass filter and segment for ERPs

% data_tla_backup = data_tla;
% 
% lpfilt = false;
% 
% if lpfilt
%   sampleRate = 250;
%   lpfreq = 40;
%   lofiltord = 4;
%   lpfilttype = 'but';
% end
% 
% cfg_sel = [];
% cfg_sel.latency = [-0.2 1.0];
% 
% for ses = 1:length(exper.sesStr)
%   for typ = 1:length(ana.eventValues{ses})
%     for evVal = 1:length(ana.eventValues{ses}{typ})
%       for sub = 1:length(exper.subjects)
%         fprintf('%s, %s, %s\n',exper.subjects{sub},exper.sesStr{ses},ana.eventValues{ses}{typ}{evVal});
%         
%         if lpfilt
%           for i = 1:size(data_tla.(exper.sesStr{ses}).(ana.eventValues{ses}{typ}{evVal}).sub(sub).data.trial,1)
%             data_tla.(exper.sesStr{ses}).(ana.eventValues{ses}{typ}{evVal}).sub(sub).data.trial(i,:,:) = ft_preproc_lowpassfilter( ...
%               squeeze(data_tla.(exper.sesStr{ses}).(ana.eventValues{ses}{typ}{evVal}).sub(sub).data.trial(i,:,:)), ...
%               sampleRate,lpfreq,lofiltord,lpfilttype);
%           end
%         end
%         
%         % select
%         data_tla.(exper.sesStr{ses}).(ana.eventValues{ses}{typ}{evVal}).sub(sub).data = ft_selectdata_new(cfg_sel,data_tla.(exper.sesStr{ses}).(ana.eventValues{ses}{typ}{evVal}).sub(sub).data);
%         
%       end
%     end
%   end
% end

%% classifier - use face/house to predict image paired with P2 word

% dataTypes = {'img_RgH_rc_spac', 'img_RgH_rc_mass', 'word_RgH_rc_spac', 'word_RgH_rc_mass', ...
%   'img_RgH_fo_spac', 'img_RgH_fo_mass', 'word_RgH_fo_spac', 'word_RgH_fo_mass'};

% thisROI = 'all129';
% thisROI = 'center91';
thisROI = 'center101';

% latencies = [0.0 0.2; 0.2 0.4; 0.4 0.6; 0.6 0.8; 0.8 1.0];
% latencies = [0.1 0.3; 0.3 0.5; 0.5 0.7; 0.7 0.9];
% latencies = [0.0 0.5; 0.5 1.0];
% latencies = [0.2 0.8];

classif_start = 0;
classif_end = 1.0;

% Twenty-one 200 ms overlapping windows, every 40 ms
classif_width = 0.2;
window_spacing = 0.04;

% % not overlapping
% classif_width = 0.1;
% window_spacing = 0.1;

% % bigger windows
% classif_start = 0.1;
% classif_end = 1.0;
% classif_width = 0.3;
% window_spacing = 0.3;

latencies = [classif_start:window_spacing:(classif_end - classif_width); (classif_start+classif_width):window_spacing:classif_end]';

avgoverchan = 'no';
avgovertime = 'no';
% avgovertime = 'yes';

parameter = 'trial';

if allowRecallSynonyms
  synStr = 'syn';
else
  synStr = 'nosyn';
end

alpha = 0.2;
% alpha = 0.8;
% % L1
% alpha = 1;
% % L2
% alpha = 0;

% sub = 1;
% ses = 1;

%dataTypes_train = {'img_RgH_rc_spac_p1', 'img_RgH_rc_mass_p1', 'img_RgH_fo_spac_p1', 'img_RgH_fo_mass_p1'};

% train on expo faces and houses
dataTypes_train = {'Face', 'House'};
equateTrainTrials = true;
standardizeTrain = true;

train_catNumCol = 7;

% % test on p2 word
% dataTypes_test = dataTypes_train;
% dataTypes_test = {'word_RgH_rc_spac_p2', 'word_RgH_rc_mass_p2', 'word_RgH_fo_spac_p2', 'word_RgH_fo_mass_p2'};
% dataTypes_test = {'img_RgH_rc_spac', 'img_RgH_rc_mass', 'img_RgH_fo_spac', 'img_RgH_fo_mass'};
% equateTestTrials = false;
% standardizeTest = true;
% standardizeTestSeparately = false;

% test_sesName = 'oneDay';
% test_phaseName = 'multistudy';
% test_phaseCountCol = 4;
% test_trialCol = 5;
% test_stimNumCol = 6;
% test_presNumCol = 11;
% test_pairNumCol = 13;

% data1 = data_tla.(exper.sesStr{ses}).(ana.eventValues{typ}{1}).sub(sub).data;
% data2 = data_tla.(exper.sesStr{ses}).(ana.eventValues{typ}{2}).sub(sub).data;
% data1_trials = data_tla.(exper.sesStr{ses}).Face.sub(sub).data;
% data2_trials = data_tla.(exper.sesStr{ses}).House.sub(sub).data;

% testAcc = nan(length(exper.subjects),length(exper.sesStr),size(latencies,1),length(dataTypes_test);
testAcc_matrix = nan(length(exper.subjects),length(exper.sesStr),size(latencies,1),size(latencies,1));
testAUC_matrix = nan(length(exper.subjects),length(exper.sesStr),size(latencies,1),size(latencies,1));

nfolds = 5;

% % contingency table
% continTab = cell(length(exper.subjects),length(exper.sesStr),size(latencies,1),length(dataTypes_test));
% trainLambda = nan(length(exper.subjects),length(exper.sesStr),size(latencies,1));
% trainWeights = cell(length(exper.subjects),length(exper.sesStr),size(latencies,1));
% facehouseClass = cell(length(exper.subjects),length(exper.sesStr),size(latencies,1));

%% run classifier

for sub = 1:length(exper.subjects)
  fprintf('%s...',exper.subjects{sub});
  for ses = 1:length(exper.sesStr)
    fprintf('%s...',exper.sesStr{ses});
    
    if ~exper.badSub(sub,ses)
      % load the events file so we know what category each study word was
      % paired with
      eventsFile = fullfile(dirs.dataroot,dirs.behDir,exper.subjects{sub},'events','events.mat');
      if exist(eventsFile,'file')
        fprintf('Loading events file...');
        load(eventsFile)
        fprintf('Done.\n');
      else
        error('events file not found: %s',eventsFile);
      end
      
      % equate the training categories
      trlIndTrain = cell(length(dataTypes_train),1);
      if equateTrainTrials
        nTrainTrial = nan(length(dataTypes_train),1);
        for d = 1:length(dataTypes_train)
          nTrainTrial(d) = size(data_tla.(exper.sesStr{ses}).(dataTypes_train{d}).sub(sub).data.(parameter),1);
        end
        fprintf('\tEquating training categories to have %d trials.\n',min(nTrainTrial));
        for d = 1:length(dataTypes_train)
          trlInd = randperm(nTrainTrial(d));
          trlIndTrain{d,1} = sort(trlInd(1:min(nTrainTrial)));
        end
      else
        fprintf('\tNot equating training category trial counts.\n');
        for d = 1:length(dataTypes_train)
          trlIndTrain{d,1} = 'all';
        end
      end
      
%       % equate the testing categories
%       trlIndTest = cell(length(dataTypes_test),1);
%       if equateTestTrials
%         nTestTrial = nan(length(dataTypes_test),1);
%         for d = 1:length(dataTypes_test)
%           nTestTrial(d) = size(data_tla.(exper.sesStr{ses}).(dataTypes_test{d}).sub(sub).data.(parameter),1);
%         end
%         fprintf('Equating testing categories to have %d trials.\n',min(nTestTrial));
%         for d = 1:length(dataTypes_test)
%           trlInd = randperm(nTestTrial(d));
%           trlIndTest{d,1} = sort(trlInd(1:min(nTestTrial)));
%         end
%       else
%         fprintf('\tNot equating testing category trial counts.\n');
%         for d = 1:length(dataTypes_test)
%           trlIndTest{d,1} = 'all';
%         end
%       end
      
      for lat = 1:size(latencies,1)
        fprintf('\t%.2fs to %.2fs...\n',latencies(lat,1),latencies(lat,2));
        
        cfg_data = [];
        cfg_data.latency = latencies(lat,:);
        cfg_data.channel = cat(2,ana.elecGroups{ismember(ana.elecGroupsStr,thisROI)});
        cfg_data.avgoverchan = avgoverchan;
        cfg_data.avgovertime = avgovertime;
        
        data_train = struct;
        
        % select the data
        for d = 1:length(dataTypes_train)
          cfg_data.trials = trlIndTrain{d};
          data_train.(dataTypes_train{d}) = ft_selectdata_new(cfg_data,data_tla.(exper.sesStr{ses}).(dataTypes_train{d}).sub(sub).data);
        end
        
        % get the category number for each training image
        imageCategory_train = data_train.(dataTypes_train{1}).trialinfo(:,train_catNumCol);
        for d = 2:length(dataTypes_train)
          imageCategory_train = cat(1,imageCategory_train,data_train.(dataTypes_train{d}).trialinfo(:,train_catNumCol));
        end
        
        % pull out the data and concatenate (for DMLT)
        dat_train = data_train.(dataTypes_train{1}).(parameter);
        for d = 2:length(dataTypes_train)
          dat_train = cat(1,dat_train,data_train.(dataTypes_train{d}).(parameter));
        end
        
        % unroll channels and timepoints within each trial
        dim = size(dat_train);
        dat_train = reshape(dat_train, dim(1), prod(dim(2:end)));
        %dat_train_ravel = reshape(dat_train,dim);
        
        % whether to standardize the training data
        if standardizeTrain
          fprintf('\t\tStandardizing the training data...');
          
          m = dml.standardizer;
          m = m.train(dat_train);
          dat_train = m.test(dat_train);
          %dat_train_ravel = reshape(dat_train,dim);
          
          %       mu = nanmean(dat);
          %       sigma = nanstd(dat);
          %
          %       dat = dat;
          %       idx = ~isnan(mu);
          %       dat(:,idx) = bsxfun(@minus,dat(:,idx),mu(idx));
          %       idx = ~isnan(sigma) & ~(sigma==0);
          %       dat(:,idx) = bsxfun(@rdivide,dat(:,idx),sigma(idx));
          %       dat_ravel = reshape(dat,dim);
          %
          %       % put it back
          %       data1.(parameter) = dat_z_ravel(1:size(data1.(parameter),1),:,:);
          %       data2.(parameter) = dat_z_ravel(size(data2.(parameter),1)+1:size(data1.(parameter),1)+size(data2.(parameter),1),:,:);
          
          fprintf('Done.\n');
        end
        
        fprintf('\t\tTraining classifier...');
%         %facehouse = {dml.standardizer dml.enet('family','binomial','alpha',alpha)};
%         facehouse = dml.enet('family','binomial','alpha',alpha);
%         facehouse = facehouse.train(dat_train,imageCategory_train);
%         %facehouse_svm = dml.svm;
%         %facehouse_svm = facehouse_svm.train(dat_train,imageCategory_train);
%         fprintf('Done.\n');
%         facehouseClass{sub,ses,lat} = facehouse;
%         trainLambda(sub,ses,lat) = facehouse.lambda;
%         trainWeights{sub,ses,lat} = facehouse.weights;
        
        % train using cross validation; fills in the diagonal on matrix
        facehouse = dml.crossvalidator('mva', dml.enet('family','binomial','alpha',alpha), 'type', 'nfold', 'folds', nfolds, 'compact', false, 'verbose', true);
        facehouse = facehouse.train(dat_train,imageCategory_train);
        fprintf('Done.\n');
        
        %facehouse.statistic('accuracy')
        
        for lat2 = 1:size(latencies,1)
          thisLat_acc = [];
          thisLat_AUC = [];
          
          if lat2 ~= lat
            %fprintf('\t%.2fs to %.2fs...\n',latencies(lat2,1),latencies(lat2,2));
            
            cfg_data = [];
            cfg_data.latency = latencies(lat2,:);
            cfg_data.channel = cat(2,ana.elecGroups{ismember(ana.elecGroupsStr,thisROI)});
            cfg_data.avgoverchan = avgoverchan;
            cfg_data.avgovertime = avgovertime;
            
            data_train2 = struct;
            
            % select the data
            for d = 1:length(dataTypes_train)
              cfg_data.trials = trlIndTrain{d};
              data_train2.(dataTypes_train{d}) = ft_selectdata_new(cfg_data,data_tla.(exper.sesStr{ses}).(dataTypes_train{d}).sub(sub).data);
            end
            
            % get the category number for each training image
            imageCategory_train = data_train2.(dataTypes_train{1}).trialinfo(:,train_catNumCol);
            for d = 2:length(dataTypes_train)
              imageCategory_train = cat(1,imageCategory_train,data_train2.(dataTypes_train{d}).trialinfo(:,train_catNumCol));
            end
            
            % pull out the data and concatenate (for DMLT)
            dat_train2 = data_train2.(dataTypes_train{1}).(parameter);
            for d = 2:length(dataTypes_train)
              dat_train2 = cat(1,dat_train2,data_train2.(dataTypes_train{d}).(parameter));
            end
            
            % unroll channels and timepoints within each trial
            dim = size(dat_train2);
            dat_train2 = reshape(dat_train2, dim(1), prod(dim(2:end)));
            %dat_train_ravel = reshape(dat_train2,dim);
            
            % whether to standardize the training data
            if standardizeTrain
              fprintf('\t\tStandardizing the training data (part deux)...');
              
              m = dml.standardizer;
              m = m.train(dat_train2);
              dat_train2 = m.test(dat_train2);
              
              fprintf('Done.\n');
            end
            
          end
          
          % get the data for the other time bins; fills in off-diagonal
          for nf = 1:nfolds
            if lat2 ~= lat
              % only test using the testfold trials from this fold
              Z = facehouse.mva{nf}.test(dat_train2(facehouse.testfolds{nf},:));
            else
              Z = facehouse.result{nf};
            end
            
            [~,I] = max(Z,[],2);
            
            thisLat_acc = cat(2,thisLat_acc,mean(I == imageCategory_train(facehouse.testfolds{nf})));
            
            [X,Y,T,AUC] = perfcurve(imageCategory_train(facehouse.testfolds{nf}),Z(:,1),1);
            thisLat_AUC = cat(2,thisLat_AUC,AUC);
          end
          
          testAcc_matrix(sub,ses,lat,lat2) = mean(thisLat_acc);
          testAUC_matrix(sub,ses,lat,lat2) = mean(thisLat_AUC);
        end
        
        
%         cfg = [];
%         %cfg.parameter = 'trial';
%         %cfg.layout = 'GSN-HydroCel-129.sfp';
%         %cfg.method = 'crossvalidate_mm';
%         cfg.mva = dml.enet('family','binomial','alpha',alpha);
%         %cfg.mva = dml.svm;
%         cfg.statistic = {'accuracy', 'binomial', 'contingency', 'confusion'};
%         cfg.compact = true;
%         cfg.verbose = true;
%         cfg.resample = false;
%         cfg.type = 'nfold';
%         cfg.nfolds = 5;
%         %cfg.type = 'split';
%         %cfg.proportion = 0.75;
%         
%         % cfg.design = imageCategory_train';
%         % cfg.design = pairedCategory_test';
%         
%         if strcmp(cfg.type,'nfold')
%           facehouse2 = dml.crossvalidator('mva',cfg.mva,'type',cfg.type,'folds',cfg.nfolds,'stat',cfg.statistic,'resample',cfg.resample,'compact',cfg.compact,'verbose',cfg.verbose);
%         elseif strcmp(cfg.type,'split')
%           facehouse2 = dml.crossvalidator('mva',cfg.mva,'type',cfg.type,'proportion',cfg.proportion,'stat',cfg.statistic,'resample',cfg.resample,'compact',cfg.compact,'verbose',cfg.verbose);
%         elseif strcmp(cfg.type,'loo') || strcmp(cfg.type,'bloo')
%           facehouse2 = dml.crossvalidator('mva',cfg.mva,'type',cfg.type,'stat',cfg.statistic,'resample',cfg.resample,'compact',cfg.compact,'verbose',cfg.verbose);
%         end
%         facehouse2 = facehouse2.train(dat_train,imageCategory_train);
%         
% %         keyboard
%         
%         trainClass = struct;
%         trainClass.model = facehouse2.model;
%         %trainClass.obj = facehouse;
%         
%         % reshape the weights so they align with electrodes and samples
%         if length(trainClass.model) > 1
%           fn = fieldnames(trainClass.model{1});
%           for i=1:length(trainClass.model)
%             for k=1:length(fn)
%               if numel(trainClass.model{i}.(fn{k}))==prod(dim(2:end))
%                 trainClass.model{i}.(fn{k}) = squeeze(reshape(trainClass.model{i}.(fn{k}),dim(2:end)));
%               end
%             end
%           end
%         elseif length(trainClass.model) == 1
%           fn = fieldnames(trainClass.model);
%           for k=1:length(fn)
%             if numel(trainClass.model.(fn{k}))==prod(dim(2:end))
%               trainClass.model.(fn{k}) = squeeze(reshape(trainClass.model.(fn{k}),dim(2:end)));
%             end
%           end
%         end
%         
%         % average the models
%         if length(trainClass.model) > 1
%           %trainClass.mymodel = trainClass.model{1}.weights;
%           %trainClass.mymodel = trainClass.model{1}.primal;
%           
%           trainClass.mymodel = [];
%           trainClass.mybias = [];
%           trainClass.mylambda = [];
%           for m = 1:length(trainClass.model)
%             trainClass.mymodel = cat(3,trainClass.mymodel,trainClass.model{m}.weights);
%             trainClass.mybias = cat(3,trainClass.mybias,trainClass.model{m}.bias);
%             trainClass.mylambda = cat(3,trainClass.mylambda,trainClass.model{m}.lambda);
%             
%             %trainClass.mymodel = cat(3,trainClass.mymodel,trainClass.model{m}.primal);
%           end
%           trainClass.mymodel = mean(trainClass.mymodel,3);
%           trainClass.mybias = mean(trainClass.mybias,3);
%           trainClass.mylambda = mean(trainClass.mylambda,3);
%         else
%           trainClass.mymodel = trainClass.model.weights;
%           trainClass.mybias = trainClass.model.bias;
%           trainClass.mylambda = trainClass.model.lambda;
%           %trainClass.mymodel = trainClass.model.primal;
%         end
        
%         % plot it
%         trainClass.dimord = 'chan';
%         trainClass.label = data_train.(dataTypes_train{1}).label;
%         % dummy trial
%         trainClass.trial = [];
%         cfg = [];
%         cfg.parameter = 'mymodel';
%         cfg.layout = 'GSN-HydroCel-129.sfp';
%         cfg.xlim = latencies(lat,:);
%         cfg.comments = '';
%         cfg.colorbar = 'yes';
%         cfg.interplimits= 'electrodes';
%         ft_topoplotER(cfg,trainClass);
        
        
%         fprintf('\t\tSetting up testing data...\n');
%         % set up the test data
%         data_test = struct;
%         
%         if standardizeTestSeparately
%           for d = 1:length(dataTypes_test)
%             % select the data
%             %for d = 1:length(dataTypes_test)
%             cfg_data.trials = trlIndTest{d};
%             data_test.(dataTypes_test{d}) = ft_selectdata_new(cfg_data,data_tla.(exper.sesStr{ses}).(dataTypes_test{d}).sub(sub).data);
%             %end
%             
%             % find whether p2 words were paired with a face or a house
%             pairedCategory_test = [];
%             %for d = 1:length(dataTypes_test)
%             for i = 1:size(data_test.(dataTypes_test{d}).(parameter),1)
%               phaseNum = data_test.(dataTypes_test{d}).trialinfo(i,test_phaseCountCol);
%               
%               thisEventInd = find(...
%                 ismember({events.(test_sesName).(sprintf('%s_%d',test_phaseName,phaseNum)).data.type},'STUDY_IMAGE') & ...
%                 [events.(test_sesName).(sprintf('%s_%d',test_phaseName,phaseNum)).data.trial] == data_test.(dataTypes_test{d}).trialinfo(i,test_trialCol) & ...
%                 [events.(test_sesName).(sprintf('%s_%d',test_phaseName,phaseNum)).data.stimNum] == data_test.(dataTypes_test{d}).trialinfo(i,test_stimNumCol) & ...
%                 [events.(test_sesName).(sprintf('%s_%d',test_phaseName,phaseNum)).data.presNum] == data_test.(dataTypes_test{d}).trialinfo(i,test_presNumCol) & ...
%                 [events.(test_sesName).(sprintf('%s_%d',test_phaseName,phaseNum)).data.pairNum] == data_test.(dataTypes_test{d}).trialinfo(i,test_pairNumCol) ...
%                 );
%               
%               if isempty(thisEventInd)
%                 thisEventInd = find(...
%                   ismember({events.(test_sesName).(sprintf('%s_%d',test_phaseName,phaseNum)).data.type},'STUDY_WORD') & ...
%                   [events.(test_sesName).(sprintf('%s_%d',test_phaseName,phaseNum)).data.trial] == data_test.(dataTypes_test{d}).trialinfo(i,test_trialCol) & ...
%                   [events.(test_sesName).(sprintf('%s_%d',test_phaseName,phaseNum)).data.stimNum] == data_test.(dataTypes_test{d}).trialinfo(i,test_stimNumCol) & ...
%                   [events.(test_sesName).(sprintf('%s_%d',test_phaseName,phaseNum)).data.presNum] == data_test.(dataTypes_test{d}).trialinfo(i,test_presNumCol) & ...
%                   [events.(test_sesName).(sprintf('%s_%d',test_phaseName,phaseNum)).data.pairNum] == data_test.(dataTypes_test{d}).trialinfo(i,test_pairNumCol) ...
%                   );
%               end
%               
%               if ~isempty(thisEventInd) && length(thisEventInd) == 1
%                 pairCatNum = events.(test_sesName).(sprintf('%s_%d',test_phaseName,phaseNum)).data(thisEventInd+1).catNum;
%                 pairedCategory_test = cat(1,pairedCategory_test,pairCatNum);
%               elseif ~isempty(thisEventInd) && length(thisEventInd) > 1
%                 %keyboard
%                 error('Found more than one event!');
%               elseif isempty(thisEventInd)
%                 %keyboard
%                 error('No events found!');
%               end
%             end
%             %end
%             
%             % get the test data
%             dat_test = data_test.(dataTypes_test{d}).(parameter);
%             
%             % concatenate the data
%             %dat_test = data_test.(dataTypes_test{1}).(parameter);
%             %for d = 2:length(dataTypes_test)
%             %  dat_test = cat(1,dat_test,data_test.(dataTypes_test{d}).(parameter));
%             %end
%             
%             dim = size(dat_test);
%             dat_test = reshape(dat_test, dim(1), prod(dim(2:end)));
%             %dat_test_ravel = reshape(dat_test,dim);
%             
%             % whether to standardize the testing data
%             if standardizeTest
%               fprintf('\t\tStandardizing the testing data (%s)...',dataTypes_test{d});
%               
%               m = dml.standardizer;
%               m = m.train(dat_test);
%               dat_test = m.test(dat_test);
%               %dat_test_ravel = reshape(dat_test,dim);
%               
%               %       mu = nanmean(dat);
%               %       sigma = nanstd(dat);
%               %
%               %       dat = dat;
%               %       idx = ~isnan(mu);
%               %       dat(:,idx) = bsxfun(@minus,dat(:,idx),mu(idx));
%               %       idx = ~isnan(sigma) & ~(sigma==0);
%               %       dat(:,idx) = bsxfun(@rdivide,dat(:,idx),sigma(idx));
%               %       dat_ravel = reshape(dat,dim);
%               %
%               %       % put it back
%               %       data1.(parameter) = dat_z_ravel(1:size(data1.(parameter),1),:,:);
%               %       data2.(parameter) = dat_z_ravel(size(data2.(parameter),1)+1:size(data1.(parameter),1)+size(data2.(parameter),1),:,:);
%               
%               fprintf('Done.\n');
%             end
%             
%             %cv = cv.train(dat_test,pairedCategory_test);
%             
%             faceInd = pairedCategory_test == 1;
%             houseInd = pairedCategory_test == 2;
%             
%             fprintf('\t\tTest data: %s\n',dataTypes_test{d});
%             fprintf('\t\t%d trials: %d paired with faces, %d paired with houses\n',size(dat_test,1),sum(faceInd),sum(houseInd));
%             fprintf('\t\tRunning classifier on testing data...');
%             Z = facehouse.test(dat_test);
%             %Z = facehouse_svm.test(dat_test);
%             fprintf('Done.\n');
%             
%             % find which category it fit best
%             [Y,I] = max(Z,[],2);
%             
%             testAcc(sub,ses,lat,d) = mean(I == pairedCategory_test);
%             
%             %[I pairedCategory_test]
%             fprintf('\t\tAccuracy (%s): %.4f\n',dataTypes_test{d},testAcc(sub,ses,lat,d));
%             
%             
%             faceCorr = pairedCategory_test(faceInd) == I(faceInd);
%             faceWrong = pairedCategory_test(faceInd) ~= I(faceInd);
%             houseCorr = pairedCategory_test(houseInd) == I(houseInd);
%             houseWrong = pairedCategory_test(houseInd) ~= I(houseInd);
%             
%             continTab{sub,ses,lat,d} = [sum(faceCorr), sum(faceWrong); sum(houseWrong), sum(houseCorr)];
%             
%             % contingency table
%             fprintf('\n');
%             fprintf('\t\tPredicted\n');
%             fprintf('\t\t%s\t%s\n',dataTypes_train{1},dataTypes_train{2});
%             fprintf('True\t%s\t%d\t%d\n',dataTypes_train{1},continTab{sub,ses,lat,d}(1,1),continTab{sub,ses,lat,d}(1,2));
%             fprintf('\t%s\t%d\t%d\n',dataTypes_train{2},continTab{sub,ses,lat,d}(2,1),continTab{sub,ses,lat,d}(2,2));
%             fprintf('\n');
%           end % d
%         else
%           % standardize test data together
%           
%           % select the data
%           for d = 1:length(dataTypes_test)
%             cfg_data.trials = trlIndTest{d};
%             data_test.(dataTypes_test{d}) = ft_selectdata_new(cfg_data,data_tla.(exper.sesStr{ses}).(dataTypes_test{d}).sub(sub).data);
%           end
%           
%           % find whether p2 words were paired with a face or a house
%           pairedCategory_test = [];
%           for d = 1:length(dataTypes_test)
%             for i = 1:size(data_test.(dataTypes_test{d}).(parameter),1)
%               phaseNum = data_test.(dataTypes_test{d}).trialinfo(i,test_phaseCountCol);
%               
%               thisEventInd = find(...
%                 ismember({events.(test_sesName).(sprintf('%s_%d',test_phaseName,phaseNum)).data.type},'STUDY_IMAGE') & ...
%                 [events.(test_sesName).(sprintf('%s_%d',test_phaseName,phaseNum)).data.trial] == data_test.(dataTypes_test{d}).trialinfo(i,test_trialCol) & ...
%                 [events.(test_sesName).(sprintf('%s_%d',test_phaseName,phaseNum)).data.stimNum] == data_test.(dataTypes_test{d}).trialinfo(i,test_stimNumCol) & ...
%                 [events.(test_sesName).(sprintf('%s_%d',test_phaseName,phaseNum)).data.presNum] == data_test.(dataTypes_test{d}).trialinfo(i,test_presNumCol) & ...
%                 [events.(test_sesName).(sprintf('%s_%d',test_phaseName,phaseNum)).data.pairNum] == data_test.(dataTypes_test{d}).trialinfo(i,test_pairNumCol) ...
%                 );
%               
%               if isempty(thisEventInd)
%                 thisEventInd = find(...
%                   ismember({events.(test_sesName).(sprintf('%s_%d',test_phaseName,phaseNum)).data.type},'STUDY_WORD') & ...
%                   [events.(test_sesName).(sprintf('%s_%d',test_phaseName,phaseNum)).data.trial] == data_test.(dataTypes_test{d}).trialinfo(i,test_trialCol) & ...
%                   [events.(test_sesName).(sprintf('%s_%d',test_phaseName,phaseNum)).data.stimNum] == data_test.(dataTypes_test{d}).trialinfo(i,test_stimNumCol) & ...
%                   [events.(test_sesName).(sprintf('%s_%d',test_phaseName,phaseNum)).data.presNum] == data_test.(dataTypes_test{d}).trialinfo(i,test_presNumCol) & ...
%                   [events.(test_sesName).(sprintf('%s_%d',test_phaseName,phaseNum)).data.pairNum] == data_test.(dataTypes_test{d}).trialinfo(i,test_pairNumCol) ...
%                   );
%               end
%               
%               if ~isempty(thisEventInd) && length(thisEventInd) == 1
%                 pairCatNum = events.(test_sesName).(sprintf('%s_%d',test_phaseName,phaseNum)).data(thisEventInd+1).catNum;
%                 
%                 % % verifying that images are classified correctly
%                 % pairCatNum = events.(sesName).(sprintf('%s_%d',phaseName,phaseNum)).data(thisEventInd).catNum;
%                 pairedCategory_test = cat(1,pairedCategory_test,pairCatNum);
%               elseif ~isempty(thisEventInd) && length(thisEventInd) > 1
%                 %keyboard
%                 error('Found more than one event!');
%               elseif isempty(thisEventInd)
%                 %keyboard
%                 error('No events found!');
%               end
%             end
%           end
%           
%           % concatenate the data
%           dat_test = data_test.(dataTypes_test{1}).(parameter);
%           testDataIndices = ones(size(data_test.(dataTypes_test{1}).(parameter),1),1);
%           for d = 2:length(dataTypes_test)
%             dat_test = cat(1,dat_test,data_test.(dataTypes_test{d}).(parameter));
%             testDataIndices = cat(1,testDataIndices,d * ones(size(data_test.(dataTypes_test{d}).(parameter),1),1));
%           end
%           
%           dim = size(dat_test);
%           dat_test = reshape(dat_test, dim(1), prod(dim(2:end)));
%           %dat_test_ravel = reshape(dat_test,dim);
%           
%           % whether to standardize the testing data
%           if standardizeTest
%             fprintf('\t\tStandardizing the testing data...');
%             
%             m = dml.standardizer;
%             m = m.train(dat_test);
%             dat_test = m.test(dat_test);
%             %dat_test_ravel = reshape(dat_test,dim);
%             
%             %       mu = nanmean(dat);
%             %       sigma = nanstd(dat);
%             %
%             %       dat = dat;
%             %       idx = ~isnan(mu);
%             %       dat(:,idx) = bsxfun(@minus,dat(:,idx),mu(idx));
%             %       idx = ~isnan(sigma) & ~(sigma==0);
%             %       dat(:,idx) = bsxfun(@rdivide,dat(:,idx),sigma(idx));
%             %       dat_ravel = reshape(dat,dim);
%             %
%             %       % put it back
%             %       data1.(parameter) = dat_z_ravel(1:size(data1.(parameter),1),:,:);
%             %       data2.(parameter) = dat_z_ravel(size(data2.(parameter),1)+1:size(data1.(parameter),1)+size(data2.(parameter),1),:,:);
%             
%             fprintf('Done.\n');
%           end
%           
%           for d = 1:length(dataTypes_test)
%             datInd = testDataIndices == d;
%             thisPairedCategory_test = pairedCategory_test(datInd,:);
%             faceInd = thisPairedCategory_test == 1;
%             houseInd = thisPairedCategory_test == 2;
%             
%             fprintf('\t\tTest data: %s\n',dataTypes_test{d});
%             fprintf('\t\t%d trials: %d paired with faces, %d paired with houses\n',size(dat_test(datInd,:),1),sum(faceInd),sum(houseInd));
%             fprintf('\t\tRunning classifier on testing data...');
%             Z = facehouse.test(dat_test(datInd,:));
%             %Z = facehouse_svm.test(dat_test(datInd,:));
%             fprintf('Done.\n');
%             
%             % find which category it fit best
%             [Y,I] = max(Z,[],2);
%             
%             testAcc(sub,ses,lat,d) = mean(I == pairedCategory_test(datInd,:));
%             
%             %[I pairedCategory_test]
%             fprintf('\t\tAccuracy (%s): %.4f\n',dataTypes_test{d},testAcc(sub,ses,lat,d));
%             
%             faceCorr = thisPairedCategory_test(faceInd) == I(faceInd);
%             faceWrong = thisPairedCategory_test(faceInd) ~= I(faceInd);
%             houseCorr = thisPairedCategory_test(houseInd) == I(houseInd);
%             houseWrong = thisPairedCategory_test(houseInd) ~= I(houseInd);
%             
%             continTab{sub,ses,lat,d} = [sum(faceCorr), sum(faceWrong); sum(houseWrong), sum(houseCorr)];
%             
%             % contingency table
%             fprintf('\n');
%             fprintf('\t\tPredicted\n');
%             fprintf('\t\t%s\t%s\n',dataTypes_train{1},dataTypes_train{2});
%             fprintf('True\t%s\t%d\t%d\n',dataTypes_train{1},continTab{sub,ses,lat,d}(1,1),continTab{sub,ses,lat,d}(1,2));
%             fprintf('\t%s\t%d\t%d\n',dataTypes_train{2},continTab{sub,ses,lat,d}(2,1),continTab{sub,ses,lat,d}(2,2));
%             fprintf('\n');
%           end % d
%           
%         end
      end % lat
    else
      fprintf('bad subject!\n');
    end % badSub
  end % ses
end % sub

%save(sprintf('fhClass_100HzLP_fhC_%s_%s_%dlat_alpha%s_2Mar2014.mat',synStr,thisROI,size(latencies,1),strrep(num2str(alpha),'.','')),'testAcc','continTab','facehouseClass','trainLambda','trainWeights','-v7.3');
save(sprintf('fhClass_%dfoldAcrossTrain_100HzLP_%s_%s_%dlat_alpha%s_%s.mat',nfolds,synStr,thisROI,size(latencies,1),strrep(num2str(alpha),'.',''),date),'testAcc_matrix','testAUC_matrix');

figure; imagesc(latencies(:,1),latencies(:,1),squeeze(mean(testAcc_matrix(:,1,:,:),1))'); axis xy; axis square; colorbar;title('Accuracy');
figure; imagesc(latencies(:,1),latencies(:,1),squeeze(mean(testAUC_matrix(:,1,:,:),1))'); axis xy; axis square; colorbar;title('Area Under Curve');

%% classifier face/house performance

classAcc = zeros(length(exper.subjects),size(testAcc,3),length(exper.sesStr));

for sub = 1:length(exper.subjects)
  if ~exper.badSub(sub)
    %if goodSub(sub)
    for ses = 1:length(exper.sesStr)
      theseData = [];
      
        for t = 1:size(testAcc,3)
          
          classAcc(sub,t,ses) = mean(facehouseClass{sub,ses,t}.performance);
          
        end
    end
  end
end


%% testAcc RMANOVA

% cnds = {'img_RgH_rc_spac_word_RgH_rc_spac', 'img_RgH_fo_spac_word_RgH_fo_spac', 'img_RgH_rc_mass_word_RgH_rc_mass', 'img_RgH_fo_mass_word_RgH_fo_mass'};
% 
% nThresh = 1;
% 
% goodSub = ones(length(exper.subjects),1);
% 
% for ses = 1:length(exper.sesStr)
%   for cnd = 1:length(cnds)
%     goodSub = goodSub .* D.(cnds{cnd}).nTrial(:,ses) >= nThresh;
%   end
% end

anovaData = [];

for sub = 1:length(exper.subjects)
  if ~exper.badSub(sub)
    %if goodSub(sub)
    for ses = 1:length(exper.sesStr)
      theseData = [];
      
      for d = 1:size(testAcc,4)
        for t = 1:size(testAcc,3)
          theseData = cat(2,theseData,testAcc(sub,ses,t,d));
        end
      end
    end
    anovaData = cat(1,anovaData,theseData);
  end
end

varnames = {'spacing','subseqMem','time'};
levelnames = {{'spac','mass'}, {'rc', 'fo'}, {'.1-.3', '.3-.5', '.5-.7', '.7-.9'}};
O = teg_repeated_measures_ANOVA(anovaData, [2 2 size(testAcc,3)], varnames,[],[],[],[],[],[],levelnames);

%% plot spacing x subsequent memory interaction

% recalled
spaced = 1;
massed = 2;
rc_spaced_mean = mean(testAcc(~exper.badSub(:,ses),ses,:,spaced),3);
rc_massed_mean = mean(testAcc(~exper.badSub(:,ses),ses,:,massed),3);

% forgotten
spaced = 3;
massed = 4;
fo_spaced_mean = mean(testAcc(~exper.badSub(:,ses),ses,:,spaced),3);
fo_massed_mean = mean(testAcc(~exper.badSub(:,ses),ses,:,massed),3);

figure
hold on

rc_mark = 'ko';
fo_mark = 'rx';

% recalled
plot(0.9*ones(sum(~exper.badSub(:,ses)),1), rc_spaced_mean,rc_mark,'LineWidth',1);
plot(1.9*ones(sum(~exper.badSub(:,ses)),1), rc_massed_mean,rc_mark,'LineWidth',1);

% forgotten
plot(1.1*ones(sum(~exper.badSub(:,ses)),1), fo_spaced_mean,fo_mark,'LineWidth',1);
plot(2.1*ones(sum(~exper.badSub(:,ses)),1), fo_massed_mean,fo_mark,'LineWidth',1);

meanSizeR = 15;
meanSizeF = 20;

% recalled
hr = plot(1, mean(rc_spaced_mean),rc_mark,'LineWidth',3,'MarkerSize',meanSizeR);
plot(2, mean(rc_massed_mean),rc_mark,'LineWidth',3,'MarkerSize',meanSizeR);

% forgotten
hf = plot(1, mean(fo_spaced_mean),fo_mark,'LineWidth',3,'MarkerSize',meanSizeF);
plot(2, mean(fo_massed_mean),fo_mark,'LineWidth',3,'MarkerSize',meanSizeF);

hold off
axis square
axis([0.75 2.25 0.25 0.65]);

set(gca,'XTick', [1 2]);

set(gca,'XTickLabel',{'Spaced','Massed'});
ylabel('Classification accuracy');

title('Spacing \times Subsequent Memory');
legend([hr, hf],{'Recalled','Forgotten'},'Location','North');

publishfig(gcf,0,[],[],[]);

print(gcf,'-depsc2','~/Desktop/class_spacXsm.eps');

% figure;
% boxplot([mean(testAcc(~exper.badSub(:,ses),ses,:,spaced),3);mean(testAcc(~exper.badSub(:,ses),ses,:,massed),3)],[ones(sum(~exper.badSub(:,ses)),1);2*ones(sum(~exper.badSub(:,ses)),1)]);
% set(gca,'XTickLabel',{'Spaced','Massed'});
% ylabel('Classification accuracy');
% 
% mean(mean(testAcc(~exper.badSub(:,ses),ses,:,massed),3))


%% testAcc

% ses = 1;
% lat = 2;
% mean(testAcc(~exper.badSub(:,ses),ses,lat,1),1)
% mean(testAcc(~exper.badSub(:,ses),ses,lat,2),1)
% mean(testAcc(~exper.badSub(:,ses),ses,lat,3),1)
% mean(testAcc(~exper.badSub(:,ses),ses,lat,4),1)

alpha = 0.05;
tails = 'both';
for ses = 1:length(exper.sesStr)
  fprintf('%s...',exper.sesStr{ses});
  for lat = 1:size(latencies,1)
    fprintf('%.2fs to %.2fs...\n',latencies(lat,1),latencies(lat,2));
    
    % recalled
    fprintf('Recalled\n');
    spaced = 1;
    massed = 2;
    data1_str = dataTypes_test{spaced};
    data2_str = dataTypes_test{massed};
    data1 = testAcc(~exper.badSub(:,ses),ses,lat,spaced);
    data2 = testAcc(~exper.badSub(:,ses),ses,lat,massed);
    
%     data2_str = 'chance';
%     data2 = 0.5*ones(sum(~exper.badSub(:,ses)),1);
%     d = mm_effect_size('single',data1,0.5);
%     [h, p, ci, stats] = ttest(data1,data2,alpha,tails);
    
    d = mm_effect_size('within',data1,data2);
    [h, p, ci, stats] = ttest(data1,data2,alpha,tails);
    
    fprintf('%s (M=%.3f; SEM=%.3f) vs\t%s (M=%.3f; SEM=%.3f):\n\tt(%d)=%.2f, d=%.2f, SD=%.2f, SEM=%.2f, p=%.5f\n', ...
      data1_str, ...
      mean(data1), ...
      std(data1) / sqrt(length(data1)), ...
      data2_str, ...
      mean(data2), ...
      std(data2) / sqrt(length(data2)), ...
      stats.df, ...
      stats.tstat, ...
      d, ...
      std(data1 - data2),...
      std(data1 - data2) / sqrt(length(data1)),...
      p);
    
    % forgotten
    fprintf('Forgotten\n');
    spaced = 3;
    massed = 4;
    data1_str = dataTypes_test{spaced};
    data2_str = dataTypes_test{massed};
    data1 = testAcc(~exper.badSub(:,ses),ses,lat,spaced);
    data2 = testAcc(~exper.badSub(:,ses),ses,lat,massed);
    
    d = mm_effect_size('within',data1,data2);
    [h, p, ci, stats] = ttest(data1,data2,alpha,tails);
    
    fprintf('%s (M=%.2f; SEM=%.2f) vs\t%s (M=%.2f; SEM=%.2f):\n\tt(%d)=%.2f, d=%.2f, SD=%.2f, SEM=%.2f, p=%.5f\n', ...
      data1_str, ...
      mean(data1), ...
      std(data1) / sqrt(length(data1)), ...
      data2_str, ...
      mean(data2), ...
      std(data2) / sqrt(length(data2)), ...
      stats.df, ...
      stats.tstat, ...
      d, ...
      std(data1 - data2),...
      std(data1 - data2) / sqrt(length(data1)),...
      p);
  end
end

%% classification from the tutorial

cfg_ana = [];

cfg_ana.latencies = [0.0 0.2; 0.1 0.3; 0.2 0.4; 0.4 0.6; 0.6 0.8; 0.8 1.0];
lat = 2;
typ = 1;

sub = 1;
ses = 1;

% data1 = data_tla.(exper.sesStr{ses}).(ana.eventValues{typ}{1}).sub(sub).data;
% data2 = data_tla.(exper.sesStr{ses}).(ana.eventValues{typ}{2}).sub(sub).data;
data1 = data_tla.(exper.sesStr{ses}).img_onePres.sub(sub).data;
data2 = data_tla.(exper.sesStr{ses}).word_onePres.sub(sub).data;

cfg = [];
cfg.parameter = 'trial';
cfg.layout = 'GSN-HydroCel-129.sfp';
% cfg.method = 'crossvalidate_mm';
% cfg.resample = true;
cfg.method = 'crossvalidate';

cfg.statistic = {'accuracy' 'binomial' 'contingency'};

cfg.latency = cfg_ana.latencies(lat,:);
cfg.channel = 'all';
cfg.avgoverchan = 'no';
cfg.avgovertime = 'yes';

% data1 = ft_selectdata_new(cfg,data_tla.(exper.sesStr{ses}).(ana.eventValues{typ}{1}).sub(sub).data);
% data2 = ft_selectdata_new(cfg,data_tla.(exper.sesStr{ses}).(ana.eventValues{typ}{2}).sub(sub).data);

% data1 = ft_selectdata_old(data_tla.(exper.sesStr{ses}).(ana.eventValues{typ}{1}).sub(sub).data,...
%   'param',cfg.parameter,...
%   'toilim',cfg.latency,...
%   'channel',cfg.channel,...
%   'avgoverchan',cfg.avgoverchan,...
%   'avgovertime',cfg.avgovertime);
%
% data2 = ft_selectdata_old(data_tla.(exper.sesStr{ses}).(ana.eventValues{typ}{2}).sub(sub).data,...
%   'param',cfg.parameter,...
%   'toilim',cfg.latency,...
%   'channel',cfg.channel,...
%   'avgoverchan',cfg.avgoverchan,...
%   'avgovertime',cfg.avgovertime);


cfg.design = [ones(size(data1.(cfg.parameter),1),1); 2*ones(size(data2.(cfg.parameter),1),1)]';

cfg.mva = {dml.standardizer dml.enet('family','binomial','alpha',0.2)};
%cfg.mva = {dml.standardizer dml.enet('family','binomial','alpha',1)};
%cfg.mva = {dml.crossvalidator('mva',{dml.enet('family','binomial','alpha',0.2)},'stat',{'accuracy','binomial','contingency'},'resample',true,'verbose',true)};
% cfg.mva = dml.analysis({dml.enet('family','binomial','alpha',0.2)});
% ,'stat',{'accuracy','binomial','contingency'},'resample',true,'verbose',true;

stat = ft_timelockstatistics(cfg,data1,data2);

% stat.mymodel = stat.model{1}.primal;
stat.mymodel = stat.model{1}.weights;
cfg = [];
cfg.parameter = 'mymodel';
cfg.layout = 'GSN-HydroCel-129.sfp';
cfg.xlim = cfg_ana.latencies(lat,:);
cfg.comments = '';
cfg.colorbar = 'yes';
cfg.interplimits= 'electrodes';
ft_topoplotER(cfg,stat);


%     % whether to equate the training data
%     equateTrainTrials = false;
%     if equateTrainTrials
%       minEv = Inf;
%       min_d = [];
%       for d = 1:length(dataTypes_train)
%         if size(data_tla.(exper.sesStr{ses}).(dataTypes_train{d}).sub(sub).data.(parameter),1) < minEv
%           minEv = size(data_tla.(exper.sesStr{ses}).(dataTypes_train{d}).sub(sub).data.(parameter),1);
%           min_d = d;
%         end
%       end
%       for d = 1:length(dataTypes_train)
%         cfg = [];
%         if d == min_d
%           cfg.trials = 'all';
%         else
%           cfg.trials = randperm(minEv);
%         end
%         data_train.(dataTypes_train{d}) = ft_selectdata_new(cfg,data_tla.(exper.sesStr{ses}).(dataTypes_train{d}).sub(sub).data);
%       end
%     else
%       for d = 1:length(dataTypes_train)
%         data_train.(dataTypes_train{d}) = data_tla.(exper.sesStr{ses}).(dataTypes_train{d}).sub(sub).data;
%       end
%     end


%     % whether to equate the test data
%     equateTestTrials = false;
%     if equateTestTrials
%       minEv = Inf;
%       min_d = [];
%       for d = 1:length(dataTypes_test)
%         if size(data_tla.(exper.sesStr{ses}).(dataTypes_test{d}).sub(sub).data.(parameter),1) < minEv
%           minEv = size(data_tla.(exper.sesStr{ses}).(dataTypes_test{d}).sub(sub).data.(parameter),1);
%           min_d = d;
%         end
%       end
%       for d = 1:length(dataTypes_test)
%         cfg = [];
%         if d == min_d
%           cfg.trials = 'all';
%         else
%           cfg.trials = randperm(minEv);
%         end
%         data_test.(dataTypes_test{d}) = ft_selectdata_new(cfg,data_tla.(exper.sesStr{ses}).(dataTypes_test{d}).sub(sub).data);
%       end
%     else
%       for d = 1:length(dataTypes_test)
%         data_test.(dataTypes_test{d}) = data_tla.(exper.sesStr{ses}).(dataTypes_test{d}).sub(sub).data;
%       end
%     end

