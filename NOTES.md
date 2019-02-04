# Self-Driving Car iOS Client Notes:

Steering path visualization:

ROS publishes data through /visual/ios/steering_path??. Data type, Float32MultiArray. When received, the array is split into two parts, 0:101 for x, 101:202 for y. 