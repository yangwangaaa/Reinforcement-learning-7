function theta = LeastSquaresPolicyIteration(L, M, T, B,center) % L:�������� M:�G�s�\�[�h T:�X�e�b�v B:�K�E�X�֐��̌�

left = [0.1*1/2, 0.1*sqrt(3)/2, -30];
foward = [0, 0.1*1, 0];
right = [0.1*1/2, 0.1*sqrt(3)/2, 30];
actions = deg2rad([-30, 0, 30, 5, -5]);          % �s���̌��
nactions = length(actions);                             % �s���̐�
ganmma = 0.95;                            % ������ 0.8
epsilon = 0.1;                          % ��-greedy�̕ϐ� 0.2 �������Ȃ��
sigma = 1;                              % �K�E�X�֐��̕� 0.5

%�S�[��
goal_pos_x = 0.0;
goal_pos_y = 1.0;
goal_area = 0.15;
goal_direction = deg2rad(65);
goal_pos = [goal_pos_x goal_pos_y];
goal = [goal_pos goal_direction];

% �f�U�C���s��X �x�N�g��r�̏�����
X = []; %M*T,3*B

best_theta = zeros(B*nactions, 1);
pmean_r = -2;
% ���f���p�����[�^�̏�����
theta = zeros(B*nactions, 1);

MaxR=[];
AvgR=[];
Dsum=[];

% ��������
for l=1:L
    dr = 0;
    r = [];
    X = [];
    x = [];
    % �W�{
    for m=1:M
        
        %robot�̃X�^�[�g�ʒu�̕ύX
        %min_x = -0.5;
        %max_x = 0.5;
        %min_y = 0;
        %max_y = 0.8;
        
        %robot_pos_x = round((max_x-min_x).*rand()+min_x, 1);
        %robot_pos_y =  round((max_y-min_y).*rand()+min_y, 1);
        robot_pos_x = 0;
        robot_pos_y = 0;
        robot_pos = [robot_pos_x, robot_pos_y];
        robot_theta = deg2rad(90);
        robot = [robot_pos, robot_theta];                                  %���{�b�g�Ɋւ���O���[�o�����W�̒l
        
        % ���ڂ̃G�s�\�[�h�̏����l
        %f_state = getRobotState(goal_pos, robot);
        f_state = GlobalPos2LocalPos(goal,robot);
        
        
        for t=1:T
            state = f_state;
            
            % ���(�ʒu ���x �s��)�̊ϑ�
            dist = sum((center - repmat(state',B,1)).^2,2);
            %test = repmat(state',B,1);
            
            %==========================================
            % ����
            phis = exp(-dist/2/(sigma.^2));
            
            % ���݂̏�ԂɊւ�����֐�
            Q = phis'*reshape(theta, B, nactions);
            %==========================================
            
            % ����
            policy = zeros(nactions,1);
            
            % ��greedy
            [v, a] = max(Q);
            policy = ones(nactions, 1)*epsilon/nactions;
            policy(a) = 1-epsilon+epsilon / nactions;
            
            %�s���I��
            ran = rand;
            if(ran < policy(1))
                l_action = 1;
            elseif(ran < policy(1) + policy(2))
                l_action = 2;
            elseif(ran < policy(1) + policy(2) + policy(3))
                l_action = 3;
            elseif(ran < policy(1) + policy(2) + policy(3) + policy(4))
                l_action = 4;
            else
                l_action = 5;
            end
                        
            %�s���̎��s
            robot = stepSimulation(robot, actions(l_action), l_action);
            %f_state = getRobotState(goal_pos, robot);
            f_state = GlobalPos2LocalPos(goal,robot);
            %---------------------------------------
            if t>1
                aphi = zeros(B*nactions, 1);
                for a=1:nactions
                    aphi = aphi + getPhi(state, a, center, B, sigma, nactions)*policy(a);
                end
                pphi = getPhi(pstate, paction, center, B, sigma, nactions);
                
                %(M*T)*B�f�U�C���s��w, M*T�����x�N�g��r
                x = [(pphi - ganmma * aphi)'];
                X = [X; x];
                r = [r,getReward(state, robot, goal)]; 
                if abs(getReward(state, robot, goal)) < goal_area && (robot(3) == goal(3))
                    %disp('!!!!!!!!!!!!!!!!!!!!!!!!!!');
                    %disp('!!!!!!!!!!!GOAL!!!!!!!!!!!');
                    %disp('!!!!!!!!!!!!!!!!!!!!!!!!!!');
                    break;
                end
            end
            paction = l_action;
            pstate = state;
            
            if m==M
                disp(strcat('Step=' ,num2str(t) ,'/NextAction:' ,num2str(rad2deg(actions(l_action))) ,'/RobotPos(x,y):(' ,num2str(robot(1)),', ',num2str(robot(2)),')' ,'/GoalPos(x,y):(' ,num2str(goal_pos_x) ,', ' ,num2str(goal_pos_y) ,'),'  ,'/State(x,y):(',num2str(state(1)) ,', ' ,num2str(state(2)),')', '/Reward=',num2str(r(length(r)))));
            end
            
            if and(t==T,m==M)
                disp('*************EPISODE*************');
            end
            
            % ��Ԃ̕`��
            plot_f = and(m==M,1);
            if plot_f
                plotSimulation(robot, goal, goal_area, strcat('Policy=',num2str(l),' Episode=',num2str(m)));
                %dplotSimulation(robot, state, goal_area, strcat('Policy=',num2str(l),' Episode=',num2str(m)));
                figure(2);
                if t==1
                    clf;
                else
                    hold on;
                    bar(t,r(length(r)));
                    text(t,r(length(r))-0.01,strcat(num2str(rad2deg(robot(3))),'��'));
                    xlim([0 T]);
                    pause(0.1);
                end
            end

        end
    end
    
    %�����]��
    theta = pinv(X'*X)*X'*r';
    MaxR=[MaxR max(r)];
    AvgR=[AvgR mean(r)];
    Dsum=[Dsum dr/M];
    
    % ���ϕ�V����ԍ�������theta��ۑ����Ă���
    if mean(r) > pmean_r
        best_theta = theta;
        pmean_r = mean(r);
    end
    if l==L 
        theta = best_theta;
    end
end
figure(4);
subplot(3,1,1)
plot(1:L,MaxR)
title('�ő��V');
subplot(3,1,2)
plot(1:L,AvgR)
ylim([-1.5 0])
title('���ϕ�V');
subplot(3,1,3)
plot(1:L,Dsum)
title('������V');
end
