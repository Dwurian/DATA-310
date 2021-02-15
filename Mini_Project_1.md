# Mini Project 1 Report

The output from the program can be accessed [here](output_of_Dance.avi)

The program is not very effective at identifying violations. It handles occlusion poorly, sometimes people that are obstructed are not recognized by the program. It also sometimes fails at depth perception, and miscassify two people at different depths as being too close. 

The distance detector uses computer vision to recognize people, and then determine the distance between two people by measuring the distance between the center of each "block of person" and then using geometry to calculate the distance in real life. An interaction is categorized as a violation if the distance of two people is too close. 

This would not be a very effective approach to estimate new infections in real time. Besides improving the program's accuracy in calculation distance, I would also add a functionality to determine if each person is wearing face covering. If possible, I would also try to implement some deeper activity undeerstanding to monitor actions such as coughing and sneezing. 
