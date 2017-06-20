function startup ()
    % Root directory
    root_dir = fileparts(mfilename('fullpath'));

    % OpenCV libraries (only on Windows; on linux, we must put them in
    % LD_LIBRARY_PATH before Matlab is started)
    if ispc()
        opencv_bin_dir = fullfile(fileparts(mfilename('fullpath')), 'external', 'opencv-bin', vicos.utils.opencv.get_arch_id(), vicos.utils.opencv.get_compiler_id(), 'bin');
        setenv('PATH', [ opencv_bin_dir, ';', getenv('PATH')]);
    end

    % mexopencv
    addpath( fullfile(root_dir, 'external', 'mexopencv') );
end
