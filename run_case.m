function run_case(caseNo, faultType, qMismatch)
%RUN_CASE  Run one demo case of Islanding_case.slx and open the scopes.
%
%   run_case(1,'none')     grid connected, normal operation
%   run_case(1,'LG')       grid connected, LG fault at 2.0 s   (also 'LL','LLG','LLL','LLLG')
%   run_case(2)            islanding at 2.0 s, island survives (matched load)
%   run_case(2,'none',1)   islanding at 2.0 s with 1 % reactive mismatch, inverter trips
%   run_case(3,'LLL')      islanding at 2.0 s, then LLL fault at 2.3 s
%
%   The case is set for this run only; the saved model file is not changed.

if nargin < 1, caseNo = 1; end
if nargin < 2, faultType = 'none'; end
if nargin < 3, qMismatch = 0; end
valid = {'none','LG','LL','LLG','LLL','LLLG'};
k = find(strcmpi(faultType, valid), 1);
if isempty(k), error('faultType must be one of: %s', strjoin(valid, ', ')); end
if ~ismember(caseNo, [1 2 3]), error('caseNo must be 1, 2 or 3'); end

model = 'Islanding_case';
here  = fileparts(mfilename('fullpath'));
if ~bdIsLoaded(model), open_system(fullfile(here, [model '.slx'])); else, open_system(model); end

init = get_param(model, 'InitFcn');
init = regexprep(init, 'CaseNo\s*=\s*\d+;',        sprintf('CaseNo    = %d;', caseNo));
init = regexprep(init, 'FaultType\s*=\s*''\w*'';', sprintf('FaultType = ''%s'';', valid{k}));
init = regexprep(init, 'Qmismatch\s*=\s*[-\d.]+;', sprintf('Qmismatch = %g;', qMismatch));
set_param(model, 'InitFcn', init);

names = {'grid connected', 'islanding', 'fault during islanding'};
fprintf('Running case %d (%s), fault type %s, Qmismatch %g %% ...\n', caseNo, names{caseNo}, valid{k}, qMismatch);
set_param(model, 'SimulationCommand', 'start');
end
