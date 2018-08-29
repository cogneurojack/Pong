

function pong
fprintf('\n');
SUBJECT = input('Subject number: '); % prompt for user input


Condition = input('Order: '); % 1 = Compete; 2 = Cooperate;

Output = NaN(20,6); % The 6 columns: Subject, Condition, PR (Points Right),...
                    % PL (Points Left), R (Rally Length), t (time elapsed)
f = 1;              % Set the row of current rally (+1 for new points)  
PR = 0;
PL = 0;
righthit = 1;
lefthit  = 1;
% PONG Matlab version of the eponym game
%
%   PONG was created in the early 70's by Nolan Bushnell from Atari Inc.
%   This code should be considered as a tribute.
%   More info on Wikipedia:
%       http://en.wikipedia.org/wiki/Pong
%       http://en.wikipedia.org/wiki/Atari
%
%   Controls:
%       Right player uses mouse
%       Left player uses up/down keyboard arrows
%
%   Players can also use following keys:
%       P: game paused
%       S: switch sound on/off
%       Esc: quit game
%

%   Author: Jérôme Briot
%   Contact: dutmatlab@yahoo.fr
%   Version : 1.0 - Sep 2006
%             1.1 - Oct 2006 - improve ball management
%                            - add sound options
%             2.0 - Feb 2017 - Major refactoring
%
% assigned the deisnated keys to each player
keys.pause = 'p';
keys.quit = {'escape' 'q'};
keys.mute = {'m'};
keys.player1.up = {'a',};
keys.player1.down = {'z',};
keys.player2.up = {'uparrow'};
keys.player2.down = {'downarrow'};

thisRally = 0

% Create figure
fig = figure('units', 'pixels', 'position',[100 100 800 600], ...
    'color', 'k', 'toolbar', 'none', 'menubar', 'none', ...
    'numbertitle', 'off', 'name', 'PONG - dutmatlab@yahoo.fr - Sept 2006', ...
    'doublebuffer', 'on', 'pointer', 'custom', 'pointershapecdata', nan(16,16), ...
    'closerequestfcn', [], 'visible', 'off');

movegui(fig, 'center')

% Separate the next line because of bug in R12.1
set(fig, 'resize', 'off', 'visible', 'on')

% Create axes
axes('units', 'normalized', 'position', [0 0 1 1], ...
    'xtick', [], 'ytick', [], 'color', 'k', 'xlim', [0 1], 'ylim',[0 1])

% Create animated splash screen
t(1)=text(0.35, 0.75, 'P');
t(2)=text(0.45, 0.75, 'O');
t(3)=text(0.55, 0.75, 'N');
t(4)=text(0.65, 0.75, 'G');
t(5)=text(0.50, 0.55, 'A tribute to the eponym game by ATARI Inc.');
t(6)=text(0.50, 0.35, 'by Jérôme Briot');
t(7)=text(0.50, 0.25, 'dutmatlab@yahoo.fr');
t(8)=text(0.50, 0.15, '(Hit a key)');

set(t, 'fontname', 'courier', 'color', 'k', 'hor', 'center', 'fontweight', 'bold');
set(t(1:4), 'fontsize',60);
set(t(5:end), 'fontsize',20);
thisRally = 0;
% controls the timing of the intro
map = gray(10);

for k = 1:length(t)
    for l = 1:size(map,1)
        set(t(k), 'color', map(l,:))
        drawnow
    end
end

% Wait for player to hit a key to remove the splash screen
pause

set(fig, 'closerequestfcn', 'closereq')
delete(t)

hold on

% Draw line at the middle
plot([0.5 0.5], [0.05 0.95], 'r:', 'color', [0.8 0.8 0.8], 'linewidth', 6)

% Draw upper line
patch([0 1 1 0], [0.97 0.97 0.98 0.98], [0 0 0 0], 'facecolor', 'w', ...
    'edgecolor', 'w', 'handlevisibility', 'off')

% Draw lower line
patch([0 1 1 0], [0.02 0.02 0.03 0.03], [0 0 0 0], 'facecolor', 'w', ...
    'edgecolor', 'w', 'handlevisibility', 'off')

% Draw left player racket
h_left = patch([0.05 0.07 0.07 0.05], [0.455 0.455 0.545 0.545], [0 0 0 0], ...
    'facecolor', 'w', 'edgecolor', 'k');

% Draw right player racket
h_right = patch([0.95 0.93 0.93 0.95], [0.455 0.455 0.545 0.545], [0 0 0 0], ...
    'facecolor', 'w', 'edgecolor', 'k');

% Draw the ball
h_ball = patch([0.492 0.508 0.508 0.492], [0.492 0.492 0.508 0.508], [0 0 0 0], ...
    'facecolor', 'w', 'edgecolor', 'w');


%----------------------------------------------------------------------
%  this if statement originally shows the score/rally but removed the
%  display function. 
%----------------------------------------------------------------------
if Condition  == 1
    
    % Add text for score and pause
    sc_left = text(0.425 , 0.86, '0'); 
    sc_right = text(0.575 , 0.86, '0');
    t_pause = text(0.5, 0.5, 'Game paused', 'visible','off');

elseif Condition == 2 % Co-operative condition
    % Add text for score and pause
    
    Rally = PL + PR;
    RScore = num2str(Rally);
    RallyScore = text(0.475 , 0.86, RScore);
    t_pause = text(0.5, 0.5, 'Game paused', 'visible','off');

    sc_left = text(0.425 , 0.86, '0');
    sc_right = text(0.575 , 0.86, '0');
    
else
    keys.quit
    cla
    text(0.5, 0.5, 'Bye !', 'fontname', 'courier', 'fontsize', 60, ...
        'color', 'w', 'hor', 'center', 'fontweight', 'bold');
    pause(1)
    close
end


% assigned yd to player 1 and yr to player 2
yd = get(h_left, 'ydata');
yr = get(h_right, 'ydata');
flag = 1;

% Set player controls
% Left player -> KeyPressFcn - Right player -> Keyreleasefcn
set(gcf,'keypressfcn', @p1k,'keyreleasefcn', @p2k)

% Load the sound for the rebonds
if verLessThan('matlab', '8.3')
    [pong_sound_Y, pong_sound_FS] = wavread('pong.wav');
else
    [pong_sound_Y, pong_sound_FS] = audioread('pong.wav');
end

if ~verLessThan('matlab', '8.3')
    player = audioplayer(pong_sound_Y, pong_sound_FS);
end

%----------------------------------------------------------------------
%       Randomly allocate ball direction at beginning of point
%----------------------------------------------------------------------
xdir = [-1 1];
x_sign = randperm(2);
xdir = xdir(x_sign(1));

ydir = [-1 1];
y_sign = randperm(2);
ydir = ydir(y_sign(1));

%----------------------------------------------------------------------
%        Wait for player to hit a key to start the game
%----------------------------------------------------------------------


pause(1)
set(fig, 'currentchar', 'a')

Start = GetSecs;
% Set sound parameter to on
sound_level = 1;

% Initialize variables
map = gray(128);
tempo_init = 0.2; % decrease number to increase tempo
elapsed_time = 0;



%----------------------------------------------------------------------
%            Game Action
%----------------------------------------------------------------------

n = 1;
while 1
    
    set(t_pause, 'visible','off')
    
    if flag==0
        % Quit game
        break;
        
    elseif flag==-1
        % Pause game
        set(t_pause, 'visible', 'on')
        
        set(t_pause,'color', map(n,:));
        drawnow
        
        n = n+1;
        
        if n>size(map,1);
            map = map(end:-1:1,:);
            n = 1;
        end
        
    else
        
        % Increase the speed of the ball during the game
        
        % remove "/(floor(elapsed_time/3)+1)" to maintain ball speed
        % Move the ball
        tempo = tempo_init/(floor(elapsed_time/3)+1);
        
        % How often the position of the ball is checked
        % e.g. remove rand*0.2+0.6; and put 0.1 to decrease speed...a lot!
        a = rand*0.2+0.6;
        
        
        x = get(h_ball,'xdata') + xdir*0.025*a;
        y = get(h_ball,'ydata') + ydir*0.025*a;
        
        % Check the position of the ball
        [xdir, ydir, point] = checkpos(x, y, xdir, ydir);
        
        if xdir==0
            x = [0.492 0.508 0.508 0.492];
            y = [0.492 0.492 0.508 0.508];
            xdir = -1;
        end
        
        if ydir==0
            x = [0.492 0.508 0.508 0.492];
            y = [0.492 0.492 0.508 0.508];
            xdir = 1;
            ydir = [-1 1];
            y_sign = randperm(2);
            ydir = ydir(y_sign(1));
        end
        
        set(h_ball, 'xdata', x, 'ydata', y)
        
        % Reset ball speed in case of point
        if point
            elapsed_time = 0;
        else
            elapsed_time = elapsed_time + tempo;
        end
        
        
        pause(tempo)
        drawnow
    end
    
end

set(gcf, 'keypressfcn', '', 'keyreleasefcn', '')
cla
text(0.5, 0.5, 'Bye !', 'fontname', 'courier', 'fontsize', 60, ...
    'color', 'w', 'hor', 'center', 'fontweight', 'bold');
pause(1)
close

% End of the PONG function
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%----------------------------------------------------------------------
%                      Control rackets
%----------------------------------------------------------------------
    function p1k(obj,event)
        
        % KPFCN Control the racket of left player
        %
        %   KPFCN moves the racket of left player using keyboard
        %
        
        switch event.Key
            case keys.quit
                flag = 0;
            case keys.mute
                sound_level = ~sound_level;
            case keys.pause
                n = 1;
                flag = flag*-1;
            case keys.player1.up
                if flag==1
                    yd = yd + 0.05*(yd(3)<.94);
                    set(h_left, 'ydata', yd)
                end
            case keys.player1.down
                if flag==1
                    yd = yd - 0.05*(yd(1)>.06);
                    set(h_left, 'ydata', yd)
                end
                %             otherwise
                %                 event
        end
        
    end
% End of the KPFCN function
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    function p2k(obj,event)
        
        % Keyreleasefcn    Control the racket of right player
        %
        %   Keyreleasefcn moves the racket of right player using keyboard
        %
        %
        
        switch event.Key
            case keys.quit
                flag = 0;
            case keys.mute
                sound_level = ~sound_level;
            case keys.pause
                n = 1;
                flag = flag*-1;
            case keys.player2.up
                if flag==1
                    yr = yr + 0.05*(yr(3)<.94);
                    set(h_right, 'ydata', yr)
                end
            case keys.player2.down
                if flag==1
                    yr = yr - 0.05*(yr(1)>.06);
                    set(h_right, 'ydata', yr)
                end
                %             otherwise
                %                 event
        end
        
    end
% End of the Keyreleasefcn function
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    function [new_xdir,new_ydir,point] = checkpos(x,y,xdir,ydir)
        
        % CHECKPOS  Check the position of the ball
        %
        
                % Get rackets position
                y_right=get(h_right,'ydata');
                y_left=get(h_left,'ydata');
        
        % Check if the ball hits any racket
        keeper_right = any(inpolygon(x+0.008,y+0.008, get(h_right,'xdata'), get(h_right,'ydata')));
        keeper_left = any(inpolygon(x-0.008,y-0.008, get(h_left,'xdata'), get(h_left,'ydata')));
        
        
        % The ball hits the upper/lower limit
        if y<0.058
            if sound_level
                if verLessThan('matlab', '8.3')
                    wavplay(pong_sound_Y, pong_sound_FS)
                else
                    play(player);
                end
            end
            
            new_ydir = -ydir;
            new_xdir = xdir;
            point = 0;
        elseif y>0.942
            if sound_level
                if verLessThan('matlab', '8.3')
                    wavplay(pong_sound_Y, pong_sound_FS)
                else
                    play(player);
                end
            end
            
            new_ydir = -ydir;
            new_xdir = xdir;
            point = 0;
            % The ball hits the racket of the right player
        elseif keeper_right
            
            if sound_level
                if verLessThan('matlab', '8.3')
                    wavplay(pong_sound_Y, pong_sound_FS)
                else
                    play(player);
                end
            end
            
            tm = GetSecs - Start  % Check how long they've been playing ...
                                  % for and if over 5 minutes Quit.
                                  if tm>= 300
                                      flag = 0;
                                  else
                                      flag = flag;
                                  end
                                  
            new_xdir = -xdir;
            new_ydir = ydir;
            point = 0;
            thisRally = thisRally + righthit % add one to length of rally
            righthit = 0;
            lefthit  = 1;
            % The ball hits the racket of the left player
            
        elseif keeper_left
            
            if sound_level
                if verLessThan('matlab', '8.3')
                    wavplay(pong_sound_Y, pong_sound_FS)
                else
                    play(player);
                end
            end
            
            tm = GetSecs - Start  % Check how long they've been playing ...
                                  % for and if over 5 minutes Quit.
                                  if tm>= 300
                                      flag = 0;
                                  else
                                      flag = flag;
                                  end
            new_xdir = -xdir;
            new_ydir = ydir;
            point = 0;
            thisRally = thisRally + lefthit % add one to length of rally
            righthit = 1;
            lefthit= 0;
            % One point for the right player
        elseif (x+0.008)>0.93
            score = get(sc_left, 'string');
            set(sc_left,'string', str2double(score)+1);
            PL = get(sc_left,'string');
            PL = str2num(PL)
            new_xdir = 0;
            new_ydir = 1;
            point = 1;
           
            time  = GetSecs - Start;
            tm = GetSecs - Start  % Check how long they've been playing ...
                                  % for and if over 5 minutes Quit.
                                  if tm>= 300
                                      flag = 0;
                                  else
                                      flag = flag;
                                  end
            theRally = thisRally
            thisRally = 0;
            
            set(RallyScore, 'string', num2str(theRally));
           
            Output(f,1) = SUBJECT; 
            Output(f,2) = Condition;
            Output(f,3) = PR;
            Output(f,4) = PL;
            Output(f,5) = theRally;
            Output(f,6) = time;
            f = f+1
            % One point for the left player
        elseif (x+0.008)<0.07
            
            score = get(sc_right, 'string');
            set(sc_right,'string', str2double(score)+1);
            PR = get(sc_right, 'string');
            PR = str2num(PR)
            new_xdir = 1;
            new_ydir = 0;
            point = 1;
           
            time = GetSecs - Start; 
            tm = GetSecs - Start  % Check how long they've been playing ...
                                  % for and if over 5 minutes Quit.
                                  if tm>= 300
                                      flag = 0;
                                  else
                                      flag = flag;
                                  end
            theRally = thisRally
            thisRally = 0;
            
            set(RallyScore, 'string', num2str(theRally));
            
            Output(f,1) = SUBJECT; 
            Output(f,2) = Condition;
            Output(f,3) = PR;
            Output(f,4) = PL;
            Output(f,5) = theRally;
            Output(f,6) = time;
            f = f+1
            
            % The ball keep moving
        else new_xdir = xdir;
            new_ydir = ydir;
            point = 0;
            
        end
        

    end
% End of the CHECKPOS function
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Output


if Start >=300
    filename = sprintf('PONG%d.xlsx', SUBJECT);
    pathname =...
'/Users/jackmoore/OneDrive - Goldsmiths College/Projects/Social Outcomes & Agency/SO&A_Pong/Data';
    ThisOutput = table(Output);
%     ThisOutput.Properties.VariableNames = {'Subject'; 'Condition';...
%         'RightPlayer'; 'LeftPlayer'; 'RallyLength'; 'time'};
    
    try
        %load SO&A_Data.mat;
        data = xlsread([pathname filename]);
    catch
        %save SO&A_Data respTableXLS;
        writetable(ThisOutput, [pathname filename], 'Sheet', 1, 'Range', 'A1');
    end
        
    
end
end
% End of the PONG function
% Hello Github
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
