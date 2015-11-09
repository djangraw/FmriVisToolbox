function [avgSpeed, speed0] = motion5multiscale(filename,xRange,yRange)

% motion analysis from a rendered frame
% 
% avgSpeed = motion5multiscale(filename,xRange,yRange)
%
% Downloaded from
% http://www.nbb.cornell.edu/neurobio/land/PROJECTS/MotionDamian/pgms18dec03/motion5multiscale.m
% on 5/13/15.
%
% Updated 5/13/15 by DJ - made into function, made some plotting optional.

doPlot = false;

% handle defaults
if ~exist('filename','var') || isempty(filename)
    filename='Hdosata71510to1700';
end
if strcmp(filename(end-3:end),'.mat')
    filename = filename(1:end-4);
end
if ~exist('xRange','var') 
    xRange = [];
end
if ~exist('yRange','var') 
    yRange = [];
end
% Set up figure
if doPlot
    figure(1)
    clf
    set(gcf,'doublebuffer','on');
end

% load file
load(filename);
filename
[nY,nX,junk] = size(mov(1).cdata) ;
[junk,nT] = size(mov);
if isempty(xRange)
    xRange = 1:nX;
end
if isempty(yRange)
    yRange = 1:nY;
end
rfactor = .5; % resize factor

clear vol
%=======================================
tstep = 1;%2;
count = 1;
for i=1:tstep:nT
    im = mov(i).cdata(yRange,xRange,:);
    if size(mov(1).cdata,3)==3
        im = imresize(rgb2gray(im),rfactor,'bicubic');
    else
        im = imresize(im,rfactor,'bicubic');
    end
    if doPlot
        imagesc(im);
        colormap(gray)
        drawnow
    end
    vol(:,:,count) = double(im) ;
    count=count+1;
end
nT=fix(nT/tstep);

%get some memory back
clear mov

%normalize each frame to average pixel
meanpixel = mean(mean(mean(vol)));
for i=1:count-1
    framemeanpixel = mean(mean(vol(:,:,i)));
    vol(:,:,i) = vol(:,:,i) * (meanpixel/framemeanpixel)^.75 ;
    if doPlot
        imagesc(vol(:,:,i));
        colormap(gray)
        drawnow
    end
end
isMov=0;

% 

%======================================
%rotation/translation testing
% set(gcf,'position',[30 500 120 120])
% isMov=0;
% axis([0 1 0 1]);
% axis square
% 
% nT = 100;
% tstep=1;
% spd=2.5;
% rsize=.05;
% w = 0.05;
% len = 0.3;
% h=fspecial('gaussian',5);       
% angBar = 0;
% 
% for i=1:nT
%     cla
%     if i<nT/2
%         w = 0.02;
%         len=0.15;
%         spd = 5;
%         amp = 10;
%     else
%         w = 0.02;
%         len = 0.15;
%         spd = 5;
%         amp=10;
%     end
%     %angBar = 45 + amp*sin(2*pi*spd*i/nT);
%     angBar = angBar + spd;
%     %rectangle('position',[.2 .25+.2*cos(4*pi*i/nT) rsize .05], 'facecolor','k');
%     %rectangle('position',[.2 .05+spd*(i-5)*(i>5) rsize .05], 'facecolor','k');
%     r=translate(rotateZ(translate(scale(UnitSquare,len,w,1),len,0,0),angBar),.5,.5,0);
%     r.facecolor = [0 0 0];
%     renderpatch(r);
%     
%     axis off
%     im = getframe(gcf);
%     im = imfilter(rgb2gray(im.cdata),h);
%     vol(:,:,i) = double(im) ;
%     
% end

%======================================
%antialiased version
% set(gcf,'position',[30 500 100 100])
%  nX = 100;
% nY = 100;
% %Build the grid which determines the image resolution
% [x,y] = meshgrid(1:128,1:128);
% nT=50;
% %build the frames
% spd=2;width=5;
% for i=1:nT
%    %the frame is just a gaussian
%    %intensity 
%    im =  128 * exp(-(x-(i*spd+10)).^2/(2*width));
%    image(im);
%    %Force real pixels
%    truesize(gcf)
%    %transfer the image to a movie frame
%    vol(:,:,i) = double(im) ;
%    drawnow 
% end
%======================================

%smooth in time
%vol = smooth3(vol,'gaussian',[1,1,3]) ;

slicenum = 1 ;
[a,b,c]=size(vol);
resRange = fix(log2(min(a,b)))-1;

%for res=0:resRange
for res=0:0
    res
    %smooth over the image down-sampling each time thru
    %[5,5,5] with 1.5 is Barron (1994) optimal value
    %default is 0.65
    vol = smooth3(vol,'gaussian',[5,5,5],1.) ;
    %all the first-derivitives -- second order diff
    [gx,gy,gt]=gradient(vol) ;
    %gt = smooth3(gt,'gaussian',[1,1,3]);
    %gx = smooth3(gt,'gaussian',[3,1,1]);
    %gy = smooth3(gt,'gaussian',[1,3,1]);
    
    for i=1:nT
        nml = (gx(:,:,i).^2 + gy(:,:,i).^2);
        nml(find(nml<.00001)) = 1; %does not affect result because gx,gy are zero
        vx(:,:,i) = gt(:,:,i).*gx(:,:,i) ./nml ;
        vy(:,:,i) = gt(:,:,i).*gy(:,:,i) ./nml ;
        %speed(:,:,i) = sqrt(vx(:,:,i).^2 + vy(:,:,i).^2);
        speed(:,:,i) = sqrt(vx(:,:,i).^2 + vy(:,:,i).^2) ;
        
        %save the high resolution results
        if res==0
            sx(i)=sum(sum(vx(:,:,i)))/(a*b);
            sy(i)=sum(sum(vy(:,:,i)))/(a*b);
            %ang(i)=(atan2(sy(i),sx(i)));
            speed0(:,:,i) = speed(:,:,i);
        end
     
        %avgSpeed = sum(sum(speed(:,:,i)))/(nX*nY/4^(slicenum-1));
        s(i,slicenum)=sum(sum(speed(:,:,i)))/(a*b/4^(slicenum-1)) ;
        %image(vol(:,:,i))
        %axis off
        %drawnow
    end
    
    slicenum = slicenum + 1 ;
    if size(vol,1)<4
        break
    end
    vol = reducevolume(vol,[2,2,1]);

    clear gx gy gt vx vy nml speed;   
end

%****************************************
% figure(2)
% clf
% s = medfilt2(s,[3,1]);
% h = surfl(s)
% 
% %p = patch(surf2patch(h));
% %delete(h);
% %light
% %set(p,'edgecolor','none')
% %set(p,'facecolor',[.6 .6 .3])
% 
% set(gca,'xtick',1:resRange);
% tickstr = min(a,b) * 2.^(-(1:resRange)+1);
% set(gca, 'xticklabel',tickstr')
% zlabel('Total Pixel Motion')
% ylabel('Time (frame #)');
% xlabel('resolution (pixels)')
% colormap('pink')
% title([filename,':  Time/Scale motion']) 
% rotate3d on

%****************************************
%vx,vy, vs t
% figure(4)
% clf
% set(gcf,'doublebuffer','on');
% %subplot(1,2,2) %The right eye
% sx = medfilt1(sx,3);
% sy = medfilt1(sy,3);
% 
% plot3(2:nT-1,sx(2:nT-1),sy(2:nT-1))
% box on
% blim=5;
% %axis([0 nT -blim blim -blim blim])
% %set(gca,'xlim',[0 nT],'ylim',[-10 10],'zlim',[-10 10])
% xlabel('time')
% ylabel('sx')
% zlabel('sy')
% title([filename,':  SpeedX,SpeedY vs Time']) 
% %ylabel('Average Angle')
% rotate3d on
% hold on
% if isMov
%     %plot(sum(s,2),'r')
%     movedot = plot3(1,sx(1),sy(1),'or','markerfacecolor','red');
%     for j=1:3
%         for i=2:nT-1
%             %draw the spider
%             figure(1)
%             im = mov(i*tstep).cdata ;
%             imagesc(im);
%             colormap(gray)
%             
%             %amimate the dot
%             figure(4)
%             set(movedot, 'xdata',i,'ydata',sx(i),'zdata',sy(i));
%             drawnow
%         end
%     end
% end

% set(gca,'projection','perspective')
% view(10,30)
% %positions of the right eye
% from=get(gca,'cameraposition');
% to=get(gca,'cameratarget');
% up=get(gca,'cameraupvector');
% 
% ax1=gca;
% subplot(1,2,1) %The left eye
% %copy the whole data structure to a new axis
% copyobj(get(ax1,'children'),gca);
% box on
% axis([0 nT -blim blim -blim blim])
% %axis([-1 1 -1 1 0 1])
% set(gca,'projection','perspective')
% d=2; %eye spacing
% %get the position of the left eye
% lefteye=from+d*cross((from-to),up)...
%    /sqrt(sum((from-to).^2)) ;
% set(gca,'cameraposition',lefteye);

%****************************************
%figure(3)
% clf
% %subplot(2,1,2)
% %pwelch(s(:,1));
% subplot(2,1,1)
% plot(s(:,1))
% hold on
% subplot(2,1,2)
% ang=(atan2(sy,sx));
% plot(ang,'-ro')
% %plot(sum(s,2),'r')
% if isMov
%     subplot(2,1,1)
%     movedot = plot(0,0,'or');
%     for j=1:1
%         for i=2:nT-1
%             %draw the spider
%             figure(1)
%             im = mov(i*tstep).cdata ;
%             imagesc(im);
%             colormap(gray)
%             
%             %amimate the dot
%             figure(3)
%             set(movedot, 'xdata',i,'ydata',s(i,1))
%             drawnow
%             pause
%         end
%     end
% end

%****************************************
figure(5)
clf
nbins = 50;

%find the significant range
mm = max(max(max(speed0))); 
bincenter = 0:mm/nbins:mm;
spdhist = [];
maxbin = 0;
for i=1:nT
    spdhist(i,:) = log10(hist(reshape(speed0(:,:,i),1,a*b), bincenter));
    %signif = find(spdhist(i,:) > 1) ;
    %if maxbin<sign
end
avgspdhist = sum(spdhist,1)/nT;
signif = find(avgspdhist > 1) ;
% mm = bincenter(signif(end)); % caused error...

%===========================================
%NOTE hard-coded mm overrides previous calc
mm=10;
%============================================

%find significant histogram
bincenter = 0:mm/nbins:mm;
spdhist = [];
for i=1:nT
    spdhist(i,:) = (hist(reshape(speed0(:,:,i),1,a*b), bincenter));
    %spdhist(i,:) = (hist(reshape(speed0(:,:,i),1,a*b), bincenter));
end
spdhist(spdhist<0)=0;

subplot(2,1,1)
%avgspdhist = repmat(sum(spdhist,1)/nT,nT,1);
%diffhist = spdhist-avgspdhist;
%diffhist = spdhist./avgspdhist;
diffhist = spdhist;

% maxhist = max(max(diffhist));
% minhist = min(min(diffhist));
%diffhist = (diffhist-minhist)/(maxhist-minhist);
filename
save([filename, 'gram.mat'],'spdhist');
save([filename, 'wave.mat'],'s');
%loggain = 30;
%image(loggain*(diffhist)')

imagesc(diffhist(:,4:end)'.^.5)
colormap(1-gray(25))
axis image
set(gca,'ydir','normal')
% bar3(spdhist(:,1:end))
%colormap('jet(20)')
% c1res=14;
% c1=ones(c1res,3);
% for i=1:c1res
%     c1(i,:) = [1, 1-(i/c1res)^1.75, 1-(i/c1res)^1.75];%1.75
% end
% c2 =  bone(15); c0 = [1 1 1];
% colormap([c2; c1]);
ylabel('Speed bin')
xlabel('Frame num')
title([filename,':  Color = log(# pixels)-log(avg # pixels)'],'interpreter','none')
set(gca,'yticklabel',round(100*bincenter(10:10:nbins))/100)
% cbhandle = colorbar;
% set(cbhandle,'yticklabel',...
%     round(100*(str2num(get(cbhandle,'yticklabel'))/loggain))/100)

subplot(2,1,2)
plot(s(:,1))
hold on
xlabel('Frame num')
ylabel('Avg Speed')
set(gca,'position',[0.13 0.11 0.66 0.343902]);
set(gca,'xlim',[1, nT])
if isMov
    movedot = plot(0,0,'or');
    hold on
    for j=1:1
        for i=2:nT-1
            %draw the spider
            figure(1)
            im = mov(i*tstep).cdata ;
            imagesc(im);
            colormap(gray)
            
            %amimate the dot
            figure(5)
            set(movedot, 'xdata',i,'ydata',s(i,1))
            drawnow
            pause
        end
    end
end
%****************************************
figure(6)
clf
nbins = 25;

subplot(4,1,1)
hist(s(:,1),nbins)
xlabel('Speed bin')
ylabel('# of frames')
title([filename,':  Summary Hisotgrams'],'interpreter','none') 
    
subplot(4,1,2)
ang=(atan2(sy,sx));
hist(ang,nbins)
xlabel('Angle bin')
ylabel('# of frames')

subplot(4,1,3)
hist(sx,nbins)
xlabel('Sx bin')
ylabel('# of frames')

subplot(4,1,4)
hist(sy,nbins)
xlabel('Sy bin')
ylabel('# of frames')

avgSpeed = s;