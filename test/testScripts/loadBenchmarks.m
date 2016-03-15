function [testpath] = loadBenchmarks(Opts)
%% testpath
clear;
p = mfilename('fullpath'); k = strfind(p, fullfile(filesep,'test')); 
testpath = [p(1:k(end)-1), fullfile(filesep,'testScripts')];
cd(testpath);

% Default benchmarks (if testScript is not run by test.m)
Def.cond = 'good'; % condition of benchmarks: 'good','bad','all'
                   % 'bad': LF10, beam, random, SpiralInductorPeec
                   % 'good': all benchmarks that are not 'bad'
Def.minSize = 0; % test benchmarks with sys.n >= minSize
Def.maxSize = 400; % test benchmarks with sys.n <= minSize
Def.number = 3; % choose maximum number of tested benchmarks

% create the options structure
if ~exist('Opts','var') || isempty(Opts)
    Opts = Def;
else
    Opts = parseOpts(Opts,Def);
end
%% Load benchmarks
%the directory "benchmark" is in sss
p = mfilename('fullpath'); k = strfind(p, fullfile('test',filesep)); 
pathBenchmarks = [p(1:k-1),'benchmarks'];
cd(pathBenchmarks);
badBenchmarks = {'LF10.mat','beam.mat','random.mat',...
    'SpiralInductorPeec.mat'};  

% check if benchmarks are in the local benchmarks folder
benchmarksCheck;

% load files
files = dir('*.mat'); 
benchmarksSysCell=cell(1,Opts.number);
nLoaded=1; %count of loaded benchmarks
disp('Loaded systems:');

warning('off');
for i=1:length(files)
    if nLoaded<Opts.number+1
        sys = loadSss(files(i).name);
        if size(sys.A,1)<=Opts.maxSize && size(sys.A,1)>=Opts.minSize
            switch(Opts.cond)
                case 'good'
                     if ~any(strcmp(files(i).name,badBenchmarks))
                        benchmarksSysCell{nLoaded}=sys;
                        nLoaded=nLoaded+1;
                        disp(files(i).name);
                     end
                case 'bad'
                     if any(strcmp(files(i).name,badBenchmarks))
                        benchmarksSysCell{nLoaded}=sys;
                        nLoaded=nLoaded+1;
                        disp(files(i).name);
                     end
                case 'all'
                      benchmarksSysCell{nLoaded}=sys;
                      nLoaded=nLoaded+1;
                      disp(files(i).name);
                otherwise 
                      error('Benchmark option is wrong.');
            end 
        end
    end
end
benchmarksSysCell(nLoaded:end)=[];
warning('on');

% change path back and save loaded systems
cd(testpath);
save('benchmarksSysCell.mat');
end