function [local_goal_pos] = GlobalPos2LocalPos(global_goal_pos, global_robot_pos, global_robot_ang)
    trans = [cos(global_robot_ang), sin(global_robot_ang); -sin(global_robot_ang), cos(global_robot_ang)];
    global_goal_pos = [global_goal_pos(1); global_goal_pos(2)];
    global_robot_pos = [global_robot_pos(1); global_robot_pos(2)];
    local_goal_pos = transpose(trans)*(global_goal_pos - global_robot_pos);
end