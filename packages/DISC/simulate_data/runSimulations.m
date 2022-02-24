%% run smBindingSimulations for various condtions
% Authors: David S. White
% contact: dwhite7@wisc.edu
%
% updated:
% 2019-03-07    DSW wrote the code
% 2019-05-07    DSW corrected value for n_sites in Simulations #2.This was
%               the wrong value used from the paper White et al., 2019 and
%               led to an error at line 123 of smSimulateBinding.m
%
% Overview:
% ---------
% This is a wrapper for running simulations used in White et al., 2019
%
% kinetic model used for monomeric/ tetrameric CNBD is taken from our
% previous work in Goldschen-Ohm et al., 2016, DOI: 10.7554/eLife.20797
%
% In reference to White et al., 2019 bioRxiv
%   1. Reproduces Simulations used in Fig 2a and Supplemental Fig 6-8
%   2. Reproduces Simulations used in Fig 2b.
%   3. Reproduces Simulations used in Fig 3
%   4. Reproduces Simulations used in Supplemental Fig 2

%% 1. Simulate tetrameric-CNBD (no cooperativity) with or without heterogneous fcAMP intensities
% vary number of sites and SNR
% intialize structure;
data.rois = struct;
data.fcAMP_uM = 1;
data.Q_matrix = [0, 1.3*data.fcAMP_uM; 0.35, 0]; 
data.emission_states = [0,1,];
data.bound_intensities = makedist('lognormal','mu', 4.63, 'sigma',0.43);

% with heterogenous fcAMP intensities
data.bound_variation = makedist('exponential','mu',3.81);
data.snr = makedist('lognormal', 'mu', 1.84, 'sigma',0.41);

% Run the simulations
data.duration_s = 200;
data.frame_rate_s = 0.1;
n_sites = 1; 
simulations = [];
n_sims = 500; % 50 used per condition
for n = 1:n_sims
    snr = random(data.snr,1);
    sim = smSimulateBinding(data.duration_s, data.frame_rate_s, n_sites, snr, data.Q_matrix, ...
        data.emission_states, data.bound_intensities, data.bound_variation);
    sim.time_s = [1:length(sim.time_series)]/10';
    simulations = [simulations;sim];
end
% store;
data.rois = simulations;
data_true = data; 
% manually save variable "data"
data = []; 
data.rois = simulations; 

%% 2. Run simulations of varying trajectory length for computational time comparions
% Note: This will take > 1 hour to run
data.rois = struct;
data.fcAMP_uM = 1;
data.Q_matrix = [0,0.15,0,0;0.04,0,0.23*data.fcAMP_uM,0;0,0.95,0,0.51;0,0,0.31,0];
data.emission_states = [1,1,2,2];
data.bound_intensities = [100,100];
data.bound_variation = [];
data.duration_s = [1e1,1e2,1e3,1e4,1e5];
data.frame_rate_s = 0.1;

% run the simulations
simulations= [];
SNR = 5;
n_per_condition = [25,20,15,10,5];
n_sites = 1; % correct from n_sites = 2 to correct value used in White et al., 2019.
for d = 1:length(data.duration_s)
    for n=1:n_per_condition(d)
        sim = smSimulateBinding(data.duration_s(d), data.frame_rate_s, n_sites, SNR, ...
            data.Q_matrix, data.emission_states, data.bound_intensities, data.bound_variation);
        simulations = [simulations;sim];
    end
end
% store
data.rois = simulations;

% manually save variable "data"

%% 3. Run Simulations of varying koff for event detection comparisons
data.rois = struct;
data.kon = 0.02;
data.koff = [0.001,0.005,0.01,0.05,0.1,0.5,1];
data.emission_states = [1,2];
data.bound_intensities = [100,100];
data.bound_variation = [];
data.duration_s = 200;
data.frame_rate_s = 0.1;

n_per_condition = 500; % 500 per condition used in White et al.,2019
SNR = 5;
n_sites = 1;
simulations = [];
for k = 1:length(data.koff)
    % make the Q_matrix
    Q_matrix = [0,data.kon; data.koff(k),0];
    for n=1:n_per_condition
        sim = smSimulateBinding(data.duration_s, data.frame_rate_s, n_sites, SNR, Q_matrix, ...
            data.emission_states, data.bound_intensities, data.bound_variation);
        sim.kon = data.kon;
        sim.koff = data.koff(k);
        simulations = [simulations;sim]; % correct array format
    end
end
% store
data.rois = simulations;

% manually save variable "data"

%% 4. Simulated 4 states (3 sites) at SNR = 4
data.rois = struct;
data.fcAMP_uM = 1;
data.Q_matrix = [0,0.15,0,0;0.04,0,0.23*data.fcAMP_uM,0;0,0.95,0,0.51;0,0,0.31,0];
data.emission_states = [1,1,2,2];
data.bound_intensities = makedist('lognormal','mu', 4.63, 'sigma',0.43);
data.bound_variation = [];

% Run the simulations
data.duration_s = 200;
data.frame_rate_s = 0.1;

simulations = [];
n_simulations = 500;
n_sites = 3;
snr = 4;
% run simulations
for n = 1:n_simulations
    sim = smSimulateBinding(data.duration_s, data.frame_rate_s, n_sites, snr, data.Q_matrix, ...
        data.emission_states, data.bound_intensities, data.bound_variation);
    simulations = [simulations;sim];
end

% store;
data.rois = simulations;

%% 5. Simulate 2 states with a varying step height for state 2;
min_step = 0;
max_step = 1;
inc_step = 0.05;
step_heights = [0.05:inc_step:0.5];

data.rois = struct;
data.Q_matrix = [0,0.2,0.2;0.2,0,0.2;0.2,0.2,0];
data.emission_states = [1,2,3];
data.bound_variation = [];
data.duration_s = 100;
data.frame_rate_s = 0.1;

simulations = [];
n_per_condition = 5;
n_sites = 1;
snr = 4; % value here does not matter, just needed for function

sigma_noise = linspace(0.02,0.2,10)

snr_state_2 = step_heights./sigma_noise'

total_rois = length(sigma_noise)*length(step_heights)*n_per_condition

all_simulations=[];
for k =1:length(sigma_noise);
    simulations = []; 
    for s=1:length(step_heights)
        data.bound_intensities = [min_step, step_heights(s)-min_step, max_step-step_heights(s)];
        for n = 1:n_per_condition
            sim = smSimulateBinding(data.duration_s, data.frame_rate_s, n_sites, snr, data.Q_matrix, ...
                data.emission_states, data.bound_intensities, data.bound_variation);
            % reformat for uniform sigma
            sim.zproj = normrnd(sim.ideal_seq,sigma_noise(k));
            sim.true_components = computeCenters(sim.zproj,sim.state_seq);
            sim.sigma_noise = sigma_noise(k);
            simulations = [simulations;sim];
        end
    end
    all_simulations = [all_simulations, simulations];
end

% store
data.rois=all_simulations;

runVaryStepHeight
