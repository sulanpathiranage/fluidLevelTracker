clear all;
%load the video here
vid = VideoReader('CP_6.25.mp4');
refImage = read(vid,1);
refImage = imrotate(refImage, -90);

%create plot
fig = figure("Name","IONP Tracker","Visible","off");
t = tiledlayout(2,2,"Parent",fig);
t.Padding = 'none';
t.TileSpacing = 'none';
ax1 = nexttile(t);
hold (ax1,'on');
title("Reference Image","Parent",ax1);
imshow(refImage,"Parent",ax1); 
ax2 = nexttile(t,[2 1]);
title('IONP Height vs. Time',"Parent",ax2);
xlabel('Time (s)',"Parent",ax2);
ylabel('IONP Height (mm)',"Parent",ax2);
ax3 = nexttile(t);
title("Real-Time IONP","Parent",ax3);
grid off;
h = animatedline(ax2,"Color","red","LineWidth",3);

%starting video analysis

for ind = 1:vid.NumFrames %looping over number of frames

    sampleImage = read(vid, ind); %first frame is the reference image (video should start with NMR in focus)
    sampleImage = imrotate(sampleImage, -90); %rotates so video is vertical, not horizontal
    diffImage = refImage - sampleImage; %detects level by subtracting current frame from reference
    dims = size(diffImage);
    R = diffImage(:,:,1);
    G = diffImage(:,:,2);
    B = diffImage(:,:,3);
    greyDiffImage = zeros(dims(1),dims(2),'uint8'); %gray-scales it so matlab only has to look at relative gray values
        for row = 1:dims(1)
            for col = 1:dims(2)
                greyDiffImage(row,col) = (0.2989 * R(row,col)) + (0.5870 * G(row,col)) + (0.1140 * B(row,col));
            end
        end
        rowMean = zeros(1,dims(1));
        for row = 1: dims(1)
            rowMean(row) = mean(greyDiffImage(row,:));
        end
    
    intensityThreshold = 7; %threhold value for detection of NMR
    topPixel = dims(1);  %starts at bottom (top right pixel is 0,0 --> bottom left pixel is dims(1),dims(2)

    for rowIndex = 1:length(rowMean) %go thru image, last row from bottom (first row from top) is the level of IONP
        if rowMean(rowIndex) > intensityThreshold
            topPixel = rowIndex;
            break;
        end
    end

    finalLevelArray(ind) = topPixel;

    figure(fig);


    M = movmean(finalLevelArray, 10); %smooth out the data, uses a rolling average

%data output
%raw numbers in command window for export as comma-delineated list 
   disp((ind/vid.NumFrames)*vid.Duration + ", " + (abs(dims(1) - M(ind))/10.9)); %more accurate x value would be (ind/vid.NumFrames)*vid.Duration*[speed up factor in videovelocity, like x7.06] - i did this in excel by hand

%     if ind > 18 %to avoid low values from rolling average, start at
%     arbritary higher index
        addpoints(h, (ind/vid.NumFrames)*vid.Duration,(abs(dims(1) - M(ind))/10.9)); %the main plot on the right of matlab figure window
        drawnow;
        fig.Visible = "on"';
%     end
    hold(ax3, 'all');  
    imshow(sampleImage,"Parent",ax3);
    quiver(dims(2)/2,topPixel,0,dims(1)-topPixel,...
        "Color","red","LineWidth",1,'Parent',ax3); %red line on the current frame of matlab figure
    
    
    hold off;
    
    
end




