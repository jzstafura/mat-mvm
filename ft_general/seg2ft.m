function [ft_raw] = seg2ft(dataroot,nsFileExt,subject,session,eventValue,prepost,elecfile,artifactType)
%SEG2FT: take segmented EEG data and put it in FieldTrip format
%
% [ft_raw] = seg2ft(dataroot,nsFileExt,subject,session,eventValue,prepost,elecfile,artifactType)
%
% Output:
%   ft_raw = struct with one field for each event value
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% SETUP:
%
% Export Net Station data as either EGIS (129 channels, where the final
% channel [Cz] is the reference; extension: 'egis') or NS Simple Binary
% (extension: 'raw' or 'sbin') calibrated, including the reference channel.
% These options are in the File Export tool. create_ft_struct, the function
% that calls seg2ft, expects EGIS files to be stored in a 'ns_egis'
% directory at the level of dirs.dataDir. If using raw files, they should
% be in 'ns_raw' instead.
%
% This function can deal with event values that have zero events. It is
% probably better to check on your event count and exclude those subjects
% with zero events for any of the event values you're trying to keep before
% trying to run this script. Nonetheless, it will insert an empty event
% entry for an empty eventValue, and the subjects will be excluded when
% using mm_threshSubs.m.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ARTIFACT INFORMATION:
%
% artifactType can be 'none', 'ns_auto', 'ns_man', 'ft_man', or 'ft_ica';
% it can be one of those strings or a cell array of multiple strings (e.g.,
% {'ns_auto','ft_man'} to do both Net Station artifact rejection and
% FieldTrip manual ("visual") rejection). 'ft_ica' also includes manual
% rejection after assessing components.
%
% 'ns_auto' and 'ns_man' is processed first, then 'ft_man', then 'ft_ica'.
% Subquent processing will not include earlier rejected artifacts.  Note
% that any FT artifact processing requires manual intervention (as does
% 'ns_man'), while 'ns_auto' artifact processing does not. 'ft_man' has the
% option to repair individual channels (for all trials)
%
% If using NS art, this function expects to find a Net Station segment info
% file with a .bci extension; this contains artifact information. It is
% exported from Net Station using the File Export tool. To set up the tool,
% export format is metadata and check the segment information option. Run
% the tool on the file that was exported to egis/raw (i.e., the baseline
% correction file or the average rereference file). The bci files should be
% stored in a 'ns_bci' directory at the same level as 'ns_egis' or
% 'ns_raw'.
%
% If 'ft_man', a visualization of all channels for each event will appear,
% where each trial is shown one-by-one.
%
% If 'ft_ica', ICA will run on all trials across all event values.
% Individual components can be rejected after this.  Finally, a
% visualization of all channels for each event will appear, where each
% trial is shown one-by-one.
% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% EEGLAB DATA
%
% If using eeglab data, no artifact detection is done and no bci file is
% expected to exist. Also, the directory structure is different and can be
% gleaned by examining the code here, but right now it is only set up to
% process Erika Nyhus's KAHN2 data.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% See also: CREATE_FT_STRUCT, MM_FT_ARTIFACT, PROCESS_FT_DATA
%

%% set the artifact processing parameters

if ischar(artifactType)
  artifactType = {artifactType};
end

artifactOpts = {'none','ns_auto','ns_man','ft_man','ft_ica'};

if any(~ismember(artifactType,artifactOpts))
  error('an artifact option was not set correctly (it was set to ''%s'')',cell2mat(artifactType(~ismember(artifactType,artifactOpts))))
end

% set artifact defaults
if any(ismember(artifactType,artifactOpts)) && ~ismember('none',artifactType)
  rejArt = 1;
else
  rejArt = 0;
end

%% set up some processing parameters

% make sure eventValue is set up correctly
if ~iscell(eventValue)
  eventValue = {eventValue};
end
% if length(eventValue) > 1
%   error('Expecting only one eventValue.');
% end

if ~iscell(session)
  session = {session};
end
if length(session) > 1
  append_data = struct;
end

if strcmpi(nsFileExt,'raw') || strcmpi(nsFileExt,'sbin')
  ftype = 'egi_sbin';
  nsDir = 'ns_raw';
elseif strcmpi(nsFileExt,'egis')
  ftype = 'egi_egis';
  nsDir = 'ns_egis';
elseif strcmpi(nsFileExt,'set')
  ftype = 'eeglab_set';
  nsDir = subject;
else
  error('ftype not set because extension was not properly set.');
end

% make sure the chan locs file exists
%
% if this is an EGI electrode location file included with FieldTrip, the 3
% Fid (fiduciary) points are included, meaning there are 3 non-electrodes
% in elec.label
if ~exist(elecfile,'file')
  error('Cannot find channel locs file at %s',elecfile);
else
  [cpath,cname,cext] = fileparts(elecfile);
  if strcmpi(cext,'.sfp')
    locsFormat = 'besa_sfp';
  else
    locsFormat = [];
  end
  elec = ft_read_sens(elecfile,'fileformat',locsFormat);
end
nChan_elecfile = size(elec.label,1);

%% for each session, read in the EEG file

for ses = 1:length(session)
  sesName = session{ses};
  
  % set ses_str to make sure it starts with a character, not a #, etc.
  ses_str = sprintf('ses_%s',sesName);
  
  if strcmpi(nsFileExt,'sbin') || strcmpi(nsFileExt,'raw') || strcmpi(nsFileExt,'egis')
    % make sure the EEG file exists
    nsfile = dir(fullfile(dataroot,sesName,nsDir,[subject,'*.',nsFileExt]));
    if isempty(nsfile)
      error('Cannot find %s*.%s file in %s',subject,nsFileExt,fullfile(dataroot,sesName,nsDir));
    elseif length(nsfile) > 1
      error('More than one %s*.%s file found in %s',subject,nsFileExt,fullfile(dataroot,sesName,nsDir));
    elseif length(nsfile) == 1
      infile_ns = fullfile(dataroot,sesName,nsDir,nsfile.name);
    end
    
  elseif strcmpi(nsFileExt,'set')
    % this is really just set up to analyze Erika Nyhus's KAHN2 data
    
    isclean = 1;
    
    if isclean
      clean_str = 'clean';
    else
      clean_str = '';
    end
    
    nsfile = dir(fullfile(dataroot,nsDir,[subject,sprintf('%s%s%s.',sesName,cell2mat(eventValue),clean_str),nsFileExt]));
    if isempty(nsfile)
      error('Cannot find %s file in %s',[subject,sprintf('%s%s%s.',sesName,cell2mat(eventValue),clean_str),nsFileExt],fullfile(dataroot,nsDir));
    elseif length(nsfile) > 1
      error('More than one %s file found in %s',[subject,sprintf('%s%s%s.',sesName,cell2mat(eventValue),clean_str),nsFileExt],fullfile(dataroot,nsDir));
    elseif length(nsfile) == 1
      infile_ns = fullfile(dataroot,nsDir,nsfile.name);
    end
  end
  
  % % debug
  % hdr = ft_read_header(infile_ns,'headerformat',ftype);
  % data = ft_read_data(infile_ns,'dataformat',ftype);
  % event = ft_read_event(infile_ns,'eventformat',ftype);
  
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % Initial parameters for reading the data
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  
  cfg = [];
  cfg.dataset = infile_ns;
  cfg.headerfile = infile_ns;
  if ~isempty(ftype)
    cfg.dataformat = ftype;
    cfg.headerformat = ftype;
  end
  cfg.continuous = 'no';
  
  % % debug
  % data = preprocessing(cfg);
  
  %% Select events
  
  % % debug
  % cfg = [];
  % cfg.dataset = infile_ns;
  % cfg.trialdef.eventtype = '?';
  % allEv = ft_definetrial(cfg);
  
  % find out which events are in infile_ns and throw an error if eventValue
  % is not one of these
  cfg_noEv = [];
  cfg_noEv.dataset = infile_ns;
  cfg_noEv.trialdef.eventtype = '?';
  allEv = ft_definetrial(cfg_noEv);
  evVals = cell(size(allEv.event));
  for i = 1:length(allEv.event)
    evVals{i} = allEv.event(i).value;
  end
  evVals = unique(evVals);
  if ~ismember(eventValue,evVals)
    fprintf('The available event values in %s are: %s\n',infile_ns,sprintf(repmat('''%s'' ',1,length(evVals)),evVals{:}));
    error('%s is not in the EEG file. You should redefine exper.eventValues.',cell2mat(eventValue));
  elseif ismember(eventValue,evVals)
    fprintf('You can safely ignore the warning about ''no trialfun was specified''.\n')
  end
  
  % set up for defining the trials based on file type
  cfg.trialdef.eventvalue = eventValue;
  cfg.trialdef.prestim = abs(prepost(1)); % in seconds; must be positive
  cfg.trialdef.poststim = prepost(2); % in seconds; must be positive
  if strcmpi(nsFileExt,'sbin') || strcmpi(nsFileExt,'raw') || strcmpi(nsFileExt,'egis')
    cfg.trialfun = 'seg_trialfun';
    cfg.trialdef.eventtype = 'trial';
  elseif strcmpi(nsFileExt,'set')
    cfg.trialfun = 'trialfun_general';
    cfg.trialdef.eventtype = 'trigger';
  end
  % define the trials
  try
    cfg = ft_definetrial(cfg);
  catch ME
    % if there were zero trials for this event type
    if strfind(ME.message,'no trials were defined')
      fprintf('No %s events found!\n',cell2mat(eventValue));
    end
    fprintf('Returning an empty dataset for %s. This will save an error file when running the ft_*analysis function.\n',cell2mat(eventValue));
    
    % set an empty cell and return to the calling function
    data.trial = {};
    return
  end
  
  %% Get the data and process it if necessary
  
  % get the actual data
  data = ft_preprocessing(cfg);
  
  % find out how many channels are in the data
  nChan_data = length(data.label);
  
  %% Check on channel information
  
  % check on whether we have the reference channel (we want to have it);
  % assuming that the last channel in the series is the reference channel
  %
  % The channel files included with FieldTrip have 3 "extra" (fiduciary)
  % channels defined, so we need to also check using an extra 3 chans
  % subtracted off
  if (nChan_data == nChan_elecfile - 1) || (nChan_data == nChan_elecfile - 4)
    % one less channel because we're checking to see if the reference
    % channel is missing
    error('This dataset is either not rereferenced or the reference channel was not exported. Go back and rereference or export the reference channel in Net Station before running this script!');
  elseif (nChan_data == nChan_elecfile || nChan_data == nChan_elecfile - 3) && var(data.trial{1}(nChan_data,:)) == 0
    % var=0 means that the final (reference) electrode is flat and this
    % data set has not been (average) rereferenced
    error('This dataset is not rereferenced. Go back and rereference in Net Station before running this script!');
  elseif (nChan_data == nChan_elecfile || nChan_data == nChan_elecfile - 3) && var(data.trial{1}(nChan_data,:)) ~= 0
    % has full number of channels and is already rereferenced (final channel is not flat)
    fprintf('Channels are already (average) rereferenced, as they should be.\n');
    
    % depending on whether the channel string was capitalized or lowercase
    % in the electrode template, make the data elec label match. This is
    % actually important for how FieldTrip deals with electrode numbers.
    %
    % TODO: We now always want to use capital letters, so this should
    % probably be changed.
    if strcmp(elec.label{ceil(nChan_data/2)}(1),'E')
      isCapital = 1;
    elseif strcmp(elec.label{ceil(nChan_data/2)}(1),'e')
      isCapital = 0;
    else
      warning([mfilename,':electrodeCapitalization'],'There is no ''E'' or ''e'' at the start of the electrode number! Going with uppercase.')
      isCapital = 1;
    end
    
    if isCapital
      % capitalize the E for each electrode, or add it in if it's not there
      for c = 1:nChan_data
        if strcmp(data.label{c}(1),'e')
          data.label{c} = upper(data.label{c});
        elseif ~strcmp(data.label{c}(1),'e') && ~strcmp(data.label{c}(1),'E')
          data.label{c} = ['E' data.label{c}];
        end
      end
    elseif ~isCapital
      % make sure the e for each electrode is lowercase, or add it in if
      % it's not there
      for c = 1:nChan_data
        if strcmp(data.label{c}(1),'E')
          data.label{c} = lower(data.label{c});
        elseif ~strcmp(data.label{c}(1),'e') && ~strcmp(data.label{c}(1),'E')
          data.label{c} = ['e' data.label{c}];
        end
      end
    end
    
    % set the last channel name to 'Cz' if that's what was set in
    % elec.label (e.g., instead of 'E129')
    if strcmp(elec.label{end},'Cz')
      if isCapital
        lastChanStr = sprintf('E%d',nChan_data);
      elseif ~isCapital
        lastChanStr = sprintf('e%d',nChan_data);
      end
      %lastChanStr = 'Cz';
      chanindx = find(strcmpi(data.label,lastChanStr));
      if ~isempty(chanindx)
        % set the label for the reference channel
        %data.label{chanindx} = elec.label{chanindx};
        data.label{chanindx} = elec.label{end};
      end
    end
    
  else
    error('Not sure what to do about rereferencing!');
  end
  
  %% artifact rejection
  
  if ~rejArt
    fprintf('Not performing any artifact rejection.\n');
  else
    data = mm_ft_artifact(dataroot,subject,sesName,eventValue,artifactType,data);
  end
  
  
  %% if we're combining multiple sessions, add the data to the append struct
  if length(session) > 1
    append_data.(ses_str) = data;
  end
end

%% Append sessions, if necessary
  
% run ft_appenddata if we're combining multiple sessions
if length(session) > 1
  ses_str = sprintf('ses_%s',session{1});
  append_str = sprintf('append_data.%s',ses_str);
  
  for ses = 2:length(session)
    ses_str = sprintf('ses_%s',session{ses});
    append_str = cat(2,append_str,sprintf(',append_data.%s',ses_str));
  end
  
  data = eval(sprintf('ft_appenddata([],%s);',append_str));
end

%% Separate the event values

% initialize the struct to return
ft_raw = struct;

if length(eventValue) > 1
  for evVal = 1:length(eventValue)
    
    cfg = [];
    trl = ft_findcfg(data.cfg,'trl');
    cfg.trl = trl(trl(:,4) == evVal,1:3);
    
    if ~isempty(cfg.trl)
      fprintf('Selecting %d trials for %s...\n',size(cfg.trl,1),eventValue{evVal});
      ft_raw.(eventValue{evVal}) = ft_redefinetrial(cfg,data);
      fprintf('Done.\n');
    else
      fprintf('No trials found for %s!\n',eventValue{evVal});
      ft_raw.(eventValue{evVal}).trial = {};
      %keyboard
    end
  end
elseif length(eventValue) == 1
  ft_raw.(eventValue) = data;
end

end
