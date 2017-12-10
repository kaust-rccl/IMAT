import matlab.unittest.TestSuite;
import matlab.unittest.TestRunner;
import matlab.unittest.plugins.TAPPlugin;
import matlab.unittest.plugins.ToFile;

% Stash current folder for later
currentpath = pwd;
% Determine where parent folder is
parentpath = cd(cd('..'));
% Add that folder plus all subfolders to the path
addpath(genpath(parentpath), '-begin');
% Go back to where we were
cd(currentpath);

try
    suite = TestSuite.fromFolder('unittests', 'IncludingSubfolders', true);
    % Create a typical runner with text output
    runner = TestRunner.withTextOutput();
    % Add the TAP plugin and direct its output to a file
    % tapFile = fullfile(getenv('WORKSPACE'), 'testResults.tap');
    % delete tapFile;
    % runner.addPlugin(TAPPlugin.producingOriginalFormat(ToFile(tapFile)));
    % Run the tests
    display(runner.run(suite));
    exit;
catch e
    disp(getReport(e, 'extended'));
    exit(1);
end
