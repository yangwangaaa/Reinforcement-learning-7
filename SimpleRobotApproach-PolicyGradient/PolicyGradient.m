function [sigma, mu] = PolicyGradient(L, M, T, N, gamma, alpha)
Global.Robot.pos = [0, 0];
MaxAng = pi/2;
MinAng = -(pi/2);

step = 0.1;

mu = rand(N-1, 1);
sigma = rand;

MaxR=[];
AvgR=[];
Dsum=[];

figure(1);clf;
movegui(figure(2),'west')
figure(2);clf;
movegui(figure(2),'center')
figure(3);clf;
movegui(figure(3),'east')
figure(4);clf;

for l=1:L
    dr = 0;
    for m=1:M
        drs(m) = 0;
        der(m, :) = zeros(1,N);
        Global.Goal.pos = [0, 0.8];
        Global.Robot.angle = deg2rad(90*randn-90);
        for t=1:T
            state = zeros(N-1,1);
            %get state
            state =GlobalPos2LocalPos(Global.Goal.pos, Global.Robot.pos, Global.Robot.angle);
            action = randn*sigma + mu'*state;
            action = min(action, MaxAng);
            action = max(action, MinAng);
            % stepSim
            [Global.Robot.angle Global.Robot.pos] = setWorldState(Global.Robot.pos,Global.Robot.angle, action, step);
            der(m, 1:N-1) = der(m, 1:N-1) + ((action - mu'*state)*state/(sigma.^2))';
            der(m, N) = der(m, N) + ((action-mu'*state).^2-sigma.^2)/(sigma.^3);
            rewards(m, t) = getReward(state);
            drs(m) = drs(m) + gamma^(t-1)*rewards(m, t);
            dr = dr + gamma^(t-1)*rewards(m, t);
            if( and(m==M,1) )
                plotSimulation(Global.Goal.pos, Global.Robot.pos,Global.Robot.angle , strcat('Policy=',num2str(l),' Episode=',num2str(m)));
                if t>1
                    figure(2);
                    hold on;
                    bar(t,rewards(m, t));
                    text(t-0.5 ,rewards(m, t)-0.1 ,strcat(num2str(round(rad2deg(state)))));
                    xlim([0 T]);
                else
                    figure(2);
                    clf;
                end
            end
            %{
            if( and(m==M,1) )
                figure(3);
                clf;
                hold on;
                x = linspace(-pi/2, pi/2);
                plot([action,action],[0,1],'r');
                plot(x,gaussianFunction(mu,sigma,x));
                xlim([-pi/2 pi/2]);
                ylim([0 1]);
                pause(0.01);
            end
            %}
        end
    end
    b = drs * diag(der*der') / trace(der*der');
    derJ = 1/M * ((drs-b) * der)';
    mu = mu + alpha *derJ(1:N-1);
    sigma = sigma + alpha * derJ(N);    
    disp(strcat('Episode:',num2str(l),' /Max:',num2str(max(max(rewards))), ' /Min:', num2str(min(min(rewards))), ' /Mean:', num2str(mean(mean(rewards)))));
    MaxR=[MaxR max(max(rewards))];
    AvgR=[AvgR mean(mean(rewards))];
    Dsum=[Dsum dr/M];
end
figure(4);
subplot(3,1,1)
plot(1:L,MaxR)
title('max reward');
subplot(3,1,2)
plot(1:L,AvgR)
title('average');
subplot(3,1,3)
plot(1:L,Dsum)
title('discount sum');
end