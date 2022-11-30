classdef MotionBlurParametersEstimation_exported < matlab.apps.AppBase

    % Properties that correspond to app components
    properties (Access = public)
        UIFigure                        matlab.ui.Figure
        UIAxes                          matlab.ui.control.UIAxes
        LoadImageButton                 matlab.ui.control.Button
        UIAxes_2                        matlab.ui.control.UIAxes
        SetBlurLengthEditFieldLabel     matlab.ui.control.Label
        SetBlurLengthEditField          matlab.ui.control.NumericEditField
        SetBlurAngleEditFieldLabel      matlab.ui.control.Label
        SetBlurAngleEditField           matlab.ui.control.NumericEditField
        ApplyMotionBlurButton           matlab.ui.control.Button
        AngleEstimationRadonButton      matlab.ui.control.Button
        LengthEstimationRadonButton     matlab.ui.control.Button
        EstimatedAngleEditField_2Label  matlab.ui.control.Label
        EstimatedAngleEditField         matlab.ui.control.NumericEditField
        EstimatedLengthEditField_2Label  matlab.ui.control.Label
        EstimatedLengthEditField        matlab.ui.control.NumericEditField
        AngleEstimationGaborButton      matlab.ui.control.Button
        LengthEstimationCepstrumButton  matlab.ui.control.Button
        EstimatedAngleEditField_2Label_2  matlab.ui.control.Label
        EstimatedAngleEditField_3       matlab.ui.control.NumericEditField
        EstimatedLengthEditField_2Label_2  matlab.ui.control.Label
        EstimatedLengthEditField_3      matlab.ui.control.NumericEditField
    end

    
    properties (Access = private)
        blur_length % length of motion blur
        blur_angle  % angle of motion blur
        image_file  % original image
        motion_blur  % motion blurred image
        motion_blur_hann_log_Radon % motion blur aftet log and radon transform
        estimated_angle % estimated angle
        estimated_length % estimated length
    end
    

    % Callbacks that handle component events
    methods (Access = private)

        % Button pushed function: LoadImageButton
        function LoadImageButtonPushed(app, event)
           [filename,filepath] = uigetfile({'*.*;*.jpg;*.png;*.bmp;*.oct'}, 'Select File to Open');
           fullname = [filepath, filename];
           app.image_file = im2double(imread(fullname));
           app.image_file = imresize(app.image_file,[256 256]);
           imshow(app.image_file, 'Parent', app.UIAxes);
        end

        % Value changed function: SetBlurLengthEditField
        function SetBlurLengthEditFieldValueChanged(app, event)
           app.blur_length = app.SetBlurLengthEditField.Value;
            
        end

        % Value changed function: SetBlurAngleEditField
        function SetBlurAngleEditFieldValueChanged(app, event)
            app.blur_angle = app.SetBlurAngleEditField.Value;
            
        end

        % Button pushed function: ApplyMotionBlurButton
        function ApplyMotionBlurButtonPushed(app, event)
            h = fspecial('motion',app.blur_length,app.blur_angle);
            app.motion_blur = imfilter(app.image_file,h,'conv','circular');
            app.motion_blur = imresize(app.motion_blur,[256 256]);
            imshow(app.motion_blur, 'Parent', app.UIAxes_2);
        end

        % Value changed function: EstimatedAngleEditField
        function EstimatedAngleEditFieldValueChanged(app, event)
                 app.EstimatedAngleEditField.Value = app.estimated_angle;
            
        end

        % Value changed function: EstimatedAngleEditField_3
        function EstimatedAngleEditField_3ValueChanged(app, event)
                 app.EstimatedAngleEditField_3.Value = app.estimated_angle;
            
        end

        % Value changed function: EstimatedLengthEditField
        function EstimatedLengthEditFieldValueChanged(app, event)
                 app.EstimatedLengthEditField.Value = app.estimated_length;
            
        end

        % Value changed function: EstimatedLengthEditField_3
        function EstimatedLengthEditField_3ValueChanged(app, event)
                 app.EstimatedLengthEditField_3.Value = app.estimated_length;
            
        end

        % Button pushed function: AngleEstimationRadonButton
        function AngleEstimationRadonButtonPushed(app, event)

                motion_blur_fft = fftshift(fft2(app.motion_blur));

                % creating and applying a hahn window on the fourier transform of the blurry image
                w = hanning(256)*hanning(256)';
                motion_blur_hann = motion_blur_fft.*w;
                % applying log on the image
                motion_blur_hann_log = log(motion_blur_hann);
                
                % radon transform on the image
                theta = 0:179;
                [app.motion_blur_hann_log_Radon, xp] = radon(motion_blur_hann_log,theta);
                
                % finding the maximum value of the radon transform
                PeakRadon = max(max(real(app.motion_blur_hann_log_Radon)));
                
                % finding the motion blur angle
                [row,app.estimated_angle] = find(real(app.motion_blur_hann_log_Radon) == PeakRadon);
            
                EstimatedAngleEditFieldValueChanged(app, event)
        end

        % Button pushed function: AngleEstimationGaborButton
        function AngleEstimationGaborButtonPushed(app, event)
               
                % gabor filter
                
                % creating a bank of gabor filters with 1<theta<360
                gaborArray = gabor(4,0:179);
                
                % applying the gabor filters on the motion blurred image
                gaborMag = imgaborfilt(abs(log(fft2(app.motion_blur))),gaborArray);
                
                % finding the norms of the gabor magnitude
                gabor_Mag_norms = sqrt(sum(gaborMag.^2,[1 2]));
                
                % finding the motion blur angle
                app.estimated_angle = find(gabor_Mag_norms == max(max(gabor_Mag_norms)));
                
                EstimatedAngleEditField_3ValueChanged(app, event)
        end

        % Button pushed function: LengthEstimationRadonButton
        function LengthEstimationRadonButtonPushed(app, event)

                % radon transform with specific blur angle
                motion_blur_fft = fftshift(fft2(app.motion_blur));

                % creating and applying a hahn window on the fourier transform of the blurry image
                w = hanning(256)*hanning(256)';
                motion_blur_hann = motion_blur_fft.*w;
                % applying log on the image
                motion_blur_hann_log = log(motion_blur_hann);
                
                % radon transform on the image
                theta = 0:179;
                [app.motion_blur_hann_log_Radon, xp] = radon(motion_blur_hann_log,theta);
                motion_blur_radon_angle = app.motion_blur_hann_log_Radon(:,app.blur_angle + 1)';
                
                % finding the locations of all local minimas in the radon transform
                local_minimas = islocalmin(real(motion_blur_radon_angle));
                
                % summing all local minimas
                local_minimas_sum = sum(local_minimas == 1);
                
                % finding the distance between the first and last local minimas
                minimas_distance = find(local_minimas,1,'last') - find(local_minimas,1,'first');
                
                % averaging the distances between minimas
                avg_distance = minimas_distance/(local_minimas_sum-1);
                
                % finding the motion blur length
                app.estimated_length = floor(length(app.image_file)/avg_distance);

                EstimatedLengthEditFieldValueChanged(app, event)
                
        end

        % Button pushed function: LengthEstimationCepstrumButton
        function LengthEstimationCepstrumButtonPushed(app, event)
                %% Cepstrum

                motion_blur_fft = fft2(app.motion_blur);

                % applying log on the image
                motion_blur_hann_log = log(1+abs(motion_blur_fft));
                
                % acquiring the cepstrum of the image
                cepstrum_motion_blur = ifft2(motion_blur_hann_log);
                
                % rotating the cepstrum image by blur degree
                cepstrum_motion_blur_rotate = imrotate(cepstrum_motion_blur,-app.blur_angle);
                
                cepstrum_mean = real(mean(cepstrum_motion_blur_rotate,1));
                
                % finding the motion blur length
                app.estimated_length = find(cepstrum_mean<0,1,'first');
                
                EstimatedLengthEditField_3ValueChanged(app, event)
        end
    end

    % Component initialization
    methods (Access = private)

        % Create UIFigure and components
        function createComponents(app)

            % Create UIFigure and hide until all components are created
            app.UIFigure = uifigure('Visible', 'off');
            app.UIFigure.Position = [100 100 640 480];
            app.UIFigure.Name = 'UI Figure';

            % Create UIAxes
            app.UIAxes = uiaxes(app.UIFigure);
            title(app.UIAxes, 'Original Image')
            xlabel(app.UIAxes, '')
            ylabel(app.UIAxes, '')
            app.UIAxes.DataAspectRatio = [1 1 1];
            app.UIAxes.PlotBoxAspectRatio = [1 1 1];
            app.UIAxes.Visible = 'off';
            app.UIAxes.Position = [16 246 248 222];

            % Create LoadImageButton
            app.LoadImageButton = uibutton(app.UIFigure, 'push');
            app.LoadImageButton.ButtonPushedFcn = createCallbackFcn(app, @LoadImageButtonPushed, true);
            app.LoadImageButton.Position = [16 215 248 22];
            app.LoadImageButton.Text = 'Load Image';

            % Create UIAxes_2
            app.UIAxes_2 = uiaxes(app.UIFigure);
            title(app.UIAxes_2, 'Motion Blurred Image')
            xlabel(app.UIAxes_2, '')
            ylabel(app.UIAxes_2, '')
            app.UIAxes_2.DataAspectRatio = [1 1 1];
            app.UIAxes_2.PlotBoxAspectRatio = [1 1 1];
            app.UIAxes_2.Visible = 'off';
            app.UIAxes_2.Position = [310 215 283 253];

            % Create SetBlurLengthEditFieldLabel
            app.SetBlurLengthEditFieldLabel = uilabel(app.UIFigure);
            app.SetBlurLengthEditFieldLabel.HorizontalAlignment = 'right';
            app.SetBlurLengthEditFieldLabel.Position = [53 123 97 22];
            app.SetBlurLengthEditFieldLabel.Text = 'Set Blur Length';

            % Create SetBlurLengthEditField
            app.SetBlurLengthEditField = uieditfield(app.UIFigure, 'numeric');
            app.SetBlurLengthEditField.ValueChangedFcn = createCallbackFcn(app, @SetBlurLengthEditFieldValueChanged, true);
            app.SetBlurLengthEditField.Position = [163 123 34 22];

            % Create SetBlurAngleEditFieldLabel
            app.SetBlurAngleEditFieldLabel = uilabel(app.UIFigure);
            app.SetBlurAngleEditFieldLabel.HorizontalAlignment = 'right';
            app.SetBlurAngleEditFieldLabel.Position = [49 154 101 22];
            app.SetBlurAngleEditFieldLabel.Text = 'Set Blur Angle';

            % Create SetBlurAngleEditField
            app.SetBlurAngleEditField = uieditfield(app.UIFigure, 'numeric');
            app.SetBlurAngleEditField.ValueChangedFcn = createCallbackFcn(app, @SetBlurAngleEditFieldValueChanged, true);
            app.SetBlurAngleEditField.Position = [164 154 34 22];

            % Create ApplyMotionBlurButton
            app.ApplyMotionBlurButton = uibutton(app.UIFigure, 'push');
            app.ApplyMotionBlurButton.ButtonPushedFcn = createCallbackFcn(app, @ApplyMotionBlurButtonPushed, true);
            app.ApplyMotionBlurButton.Position = [53 87 161 22];
            app.ApplyMotionBlurButton.Text = 'Apply Motion Blur';

            % Create AngleEstimationRadonButton
            app.AngleEstimationRadonButton = uibutton(app.UIFigure, 'push');
            app.AngleEstimationRadonButton.ButtonPushedFcn = createCallbackFcn(app, @AngleEstimationRadonButtonPushed, true);
            app.AngleEstimationRadonButton.Position = [287 154 175 22];
            app.AngleEstimationRadonButton.Text = 'Angle Estimation (Radon)';

            % Create LengthEstimationRadonButton
            app.LengthEstimationRadonButton = uibutton(app.UIFigure, 'push');
            app.LengthEstimationRadonButton.ButtonPushedFcn = createCallbackFcn(app, @LengthEstimationRadonButtonPushed, true);
            app.LengthEstimationRadonButton.Position = [287 123 175 22];
            app.LengthEstimationRadonButton.Text = 'Length Estimation (Radon)';

            % Create EstimatedAngleEditField_2Label
            app.EstimatedAngleEditField_2Label = uilabel(app.UIFigure);
            app.EstimatedAngleEditField_2Label.HorizontalAlignment = 'right';
            app.EstimatedAngleEditField_2Label.Position = [472 154 100 22];
            app.EstimatedAngleEditField_2Label.Text = 'Estimated Angle: ';

            % Create EstimatedAngleEditField
            app.EstimatedAngleEditField = uieditfield(app.UIFigure, 'numeric');
            app.EstimatedAngleEditField.ValueChangedFcn = createCallbackFcn(app, @EstimatedAngleEditFieldValueChanged, true);
            app.EstimatedAngleEditField.Editable = 'off';
            app.EstimatedAngleEditField.Position = [589 154 31 22];

            % Create EstimatedLengthEditField_2Label
            app.EstimatedLengthEditField_2Label = uilabel(app.UIFigure);
            app.EstimatedLengthEditField_2Label.HorizontalAlignment = 'right';
            app.EstimatedLengthEditField_2Label.Position = [472 123 102 22];
            app.EstimatedLengthEditField_2Label.Text = 'Estimated Length:';

            % Create EstimatedLengthEditField
            app.EstimatedLengthEditField = uieditfield(app.UIFigure, 'numeric');
            app.EstimatedLengthEditField.ValueChangedFcn = createCallbackFcn(app, @EstimatedLengthEditFieldValueChanged, true);
            app.EstimatedLengthEditField.Editable = 'off';
            app.EstimatedLengthEditField.Position = [589 123 31 22];

            % Create AngleEstimationGaborButton
            app.AngleEstimationGaborButton = uibutton(app.UIFigure, 'push');
            app.AngleEstimationGaborButton.ButtonPushedFcn = createCallbackFcn(app, @AngleEstimationGaborButtonPushed, true);
            app.AngleEstimationGaborButton.Position = [287 74 175 22];
            app.AngleEstimationGaborButton.Text = 'Angle Estimation (Gabor)';

            % Create LengthEstimationCepstrumButton
            app.LengthEstimationCepstrumButton = uibutton(app.UIFigure, 'push');
            app.LengthEstimationCepstrumButton.ButtonPushedFcn = createCallbackFcn(app, @LengthEstimationCepstrumButtonPushed, true);
            app.LengthEstimationCepstrumButton.Position = [287 45 175 22];
            app.LengthEstimationCepstrumButton.Text = 'Length Estimation (Cepstrum)';

            % Create EstimatedAngleEditField_2Label_2
            app.EstimatedAngleEditField_2Label_2 = uilabel(app.UIFigure);
            app.EstimatedAngleEditField_2Label_2.HorizontalAlignment = 'right';
            app.EstimatedAngleEditField_2Label_2.Position = [475 74 100 22];
            app.EstimatedAngleEditField_2Label_2.Text = 'Estimated Angle: ';

            % Create EstimatedAngleEditField_3
            app.EstimatedAngleEditField_3 = uieditfield(app.UIFigure, 'numeric');
            app.EstimatedAngleEditField_3.ValueChangedFcn = createCallbackFcn(app, @EstimatedAngleEditField_3ValueChanged, true);
            app.EstimatedAngleEditField_3.Editable = 'off';
            app.EstimatedAngleEditField_3.Position = [592 74 31 22];

            % Create EstimatedLengthEditField_2Label_2
            app.EstimatedLengthEditField_2Label_2 = uilabel(app.UIFigure);
            app.EstimatedLengthEditField_2Label_2.HorizontalAlignment = 'right';
            app.EstimatedLengthEditField_2Label_2.Position = [475 45 102 22];
            app.EstimatedLengthEditField_2Label_2.Text = 'Estimated Length:';

            % Create EstimatedLengthEditField_3
            app.EstimatedLengthEditField_3 = uieditfield(app.UIFigure, 'numeric');
            app.EstimatedLengthEditField_3.ValueChangedFcn = createCallbackFcn(app, @EstimatedLengthEditField_3ValueChanged, true);
            app.EstimatedLengthEditField_3.Editable = 'off';
            app.EstimatedLengthEditField_3.Position = [592 45 31 22];

            % Show the figure after all components are created
            app.UIFigure.Visible = 'on';
        end
    end

    % App creation and deletion
    methods (Access = public)

        % Construct app
        function app = MotionBlurParametersEstimation_exported

            % Create UIFigure and components
            createComponents(app)

            % Register the app with App Designer
            registerApp(app, app.UIFigure)

            if nargout == 0
                clear app
            end
        end

        % Code that executes before app deletion
        function delete(app)

            % Delete UIFigure when app is deleted
            delete(app.UIFigure)
        end
    end
end