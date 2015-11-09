function hBar = SlideBarAcrossAxes(hAxes,tStart,tStop)

% Given a 'time' x axis, slide a bar across in real time, for example, to 
% compare with a movie playing at the same time. (use Ctrl-C to stop early)
%
% hBar = SlideBarAcrossAxes(hAxes,tStart,tStop)
%
% INPUTS:
% -hAxes is the handle of the axis on which you want to put the bar.
% -tStart and tStop are the start and stop times for the bar.
% 
% OUTPUTS:
% -hBar is the handle to the bar so you can delete it afterwards.
%
% Created 5/13/15 by DJ.

% set up
axes(hAxes);
hold on;
% make bar
hBar = plot(hAxes,[0,0],get(hAxes,'ylim'),'k','linewidth',2);
tNow = tStart;
tic;
% slide and redraw
while tNow<tStop
    tNow = toc + tStart;
    set(hBar,'xData',[tNow, tNow]);
    drawnow;
end