function plotSimulation(robot, goal, goal_area, Title) % goal_pos,state,actions(action)

figure(1);
clf;
hold on;

%whitebg(field,[0 1 0])

t = title(Title);
set(t,'FontSize',16);

xlim([-0.8 0.8]);
ylim([-0.3 1.3]);
axis square;

% 目的地の描画
g_radii = goal_area;
viscircles([goal(1) goal(2)],g_radii);
text(goal(1)+0.1,goal(2),strcat(num2str(rad2deg(goal(3))),'°'));
c_goal = [goal(1) goal(2)];
g_goal = [goal(1) + cos(goal(3)) goal(2) + sin(goal(3))];
line_goal = [c_goal;g_goal];
plot(line_goal([1,2],1),line_goal([1,2],2),'-','Color','r');


% ロボットの描画
r_radii = 0.03;
viscircles([robot(1) robot(2)],r_radii,'Color','k');
text(robot(1)+0.1,robot(2),strcat(num2str(rad2deg(robot(3))),'°'));
c_robot = [robot(1) robot(2)];
g_robot = [robot(1) + cos(robot(3)) robot(2) + sin(robot(3))];
%plot(a([c_robot(1) g_robot(1)],1),a([c_robot(2) g_robot(2)],2),'-')
line_robot = [c_robot;g_robot];
plot(line_robot([1,2],1),line_robot([1,2],2),'-','Color','k');

%saveas(field, 'simpleSim.jpg');

grid on;
pause(0.1);
end