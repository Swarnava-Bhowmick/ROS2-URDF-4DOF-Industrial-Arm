# ros2-urdf-4dof-industrial-arm# 4-DOF Industrial Robotic Arm — URDF Model in ROS 2 (Jazzy)

A ROS 2 package containing a complete URDF/Xacro model of a **4-degree-of-freedom serial robotic arm**, visualized in RViz2 with live joint control and a verified TF tree.

Built as part of the **ROBO AI — Industrial Training Program on Robotics and AI**.

---

## 📋 Project Overview

| Field | Value |
|---|---|
| Student | Swarnava Bhowmick |
| Program | ROBO AI — Industrial Training Program (Robotics & AI) |
| ROS Distro | ROS 2 Jazzy (Ubuntu 24.04) |
| Package Name | `mrm_description` |
| Workspace | `~/simulation_ws` |
| Tools Used | Xacro, RViz2, TF2, robot_state_publisher |

This project designs a **shoulder–elbow–wrist style manipulator** (similar in layout to industrial arms like the KUKA KR series) using 5 rigid links connected by 4 revolute joints — one waist rotation (Z-axis) followed by three pitch joints (Y-axis).

---

## 🦾 Robot Structure

```
[base_link] (Grey Box 0.5 × 0.5 × 0.2 m)
     |
   joint_1  ← Revolute / Z-axis / ±180°
     |
[link_01] (Blue Cylinder r=0.1 m, L=0.4 m)
     |
   joint_2  ← Revolute / Y-axis / ±90°
     |
[link_02] (Green Cylinder r=0.07 m, L=0.5 m)
     |
   joint_3  ← Revolute / Y-axis / ±90°
     |
[link_03] (Orange Cylinder r=0.05 m, L=0.4 m)
     |
   joint_4  ← Revolute / Y-axis / ±90°
     |
[end_effector] (Red Box 0.08 × 0.08 × 0.1 m)
```

**Total reach:** ≈1.7 m (0.2 + 0.4 + 0.5 + 0.4 + 0.1)
**Total mass:** 5.5 kg
**Degrees of freedom:** 4 (all revolute)

### Links

| Link | Geometry | Dimensions | Mass (kg) | Color |
|---|---|---|---|---|
| `base_link` | Box | 0.5 × 0.5 × 0.2 m | 2.0 | Grey |
| `link_01` | Cylinder | r=0.10 m, L=0.40 m | 1.5 | Blue |
| `link_02` | Cylinder | r=0.07 m, L=0.50 m | 1.0 | Green |
| `link_03` | Cylinder | r=0.05 m, L=0.40 m | 0.7 | Orange |
| `end_effector` | Box | 0.08 × 0.08 × 0.10 m | 0.3 | Red |

### Joints

| Joint | Type | Parent → Child | Axis | Range (rad) | Effort | Velocity |
|---|---|---|---|---|---|---|
| `joint_1` | Revolute | base_link → link_01 | Z (0 0 1) | −3.14 to +3.14 | 1000 N·m | 0.5 rad/s |
| `joint_2` | Revolute | link_01 → link_02 | Y (0 1 0) | −1.57 to +1.57 | 1000 N·m | 0.5 rad/s |
| `joint_3` | Revolute | link_02 → link_03 | Y (0 1 0) | −1.57 to +1.57 | 1000 N·m | 0.5 rad/s |
| `joint_4` | Revolute | link_03 → end_effector | Y (0 1 0) | −1.57 to +1.57 | 1000 N·m | 0.5 rad/s |

Every link defines three sub-elements:
- **`<visual>`** — what RViz renders
- **`<collision>`** — geometry used by physics/collision engines
- **`<inertial>`** — mass and inertia tensor, needed for dynamics/physics simulation

---

## 📁 Package Structure

```
simulation_ws/
└── src/
    └── mrm_description/
        ├── urdf/
        │   └── mrm.xacro          # Main robot model (5 links, 4 joints)
        ├── launch/
        │   └── display.launch.py  # Launches robot_state_publisher + RViz2
        ├── rviz/
        │   └── display.rviz       # Pre-configured RViz scene
        ├── package.xml
        └── CMakeLists.txt
```

---

## 🛠️ Prerequisites

| Requirement | Detail |
|---|---|
| OS | Ubuntu 24.04 |
| ROS 2 | Jazzy Jalisco |
| Packages | `ros-jazzy-xacro`, `ros-jazzy-joint-state-publisher-gui`, `ros-jazzy-robot-state-publisher` |
| Build tool | `colcon` (`colcon-common-extensions`) |

Install the required ROS 2 packages if not already present:

```bash
sudo apt update
sudo apt install ros-jazzy-xacro ros-jazzy-joint-state-publisher-gui \
                  ros-jazzy-robot-state-publisher ros-jazzy-rviz2 \
                  python3-colcon-common-extensions
```

---

## 🚀 Step-by-Step Setup & Run Guide

### 1. Create and enter the workspace
```bash
mkdir -p ~/simulation_ws/src
cd ~/simulation_ws/src
```

### 2. Add the package
Place the `mrm_description` folder (containing `urdf/`, `launch/`, `rviz/`, `package.xml`, `CMakeLists.txt`) inside `~/simulation_ws/src/`.

### 3. Build the workspace
```bash
cd ~/simulation_ws
colcon build
```

### 4. Source the environment
Open a terminal and run, in order:
```bash
source /opt/ros/jazzy/setup.bash      # Source ROS 2 Jazzy itself
source ~/simulation_ws/install/setup.bash   # Source your built workspace
```
> ⚠️ You must re-run these two `source` commands in **every new terminal** you open for this project.

### 5. Launch the robot in RViz2
```bash
ros2 launch mrm_description display.launch.py
```
This starts `robot_state_publisher` (which publishes link transforms from the URDF) and opens RViz2 with the model loaded, plus a `joint_state_publisher_gui` window with sliders for each joint.

### 6. Move the arm
Use the slider GUI window that pops up to move `joint_1`–`joint_4` in real time and watch the arm move in RViz2.

### 7. (Optional) Verify the TF tree
In a **second terminal**, source ROS 2 and the workspace again, then run:
```bash
source /opt/ros/jazzy/setup.bash
source ~/simulation_ws/install/setup.bash
ros2 run tf2_tools view_frames
```
This records all broadcast transforms for 5 seconds and saves a PDF (e.g. `frames_<timestamp>.pdf`) showing the full parent → child TF chain.

### 8. (Optional) Inspect topics
```bash
ros2 topic list              # See all active topics
ros2 topic echo /joint_states  # Watch live joint angle values
```

---

## ✅ Validation Checklist

| Check | Result |
|---|---|
| Fixed Frame set to `base_link` | ✔️ |
| RobotModel display loads without errors | ✔️ |
| TF display shows all 5 frames with correct axes | ✔️ |
| Joint sliders move joints in real time | ✔️ |
| No red warnings in RViz status bar | ✔️ |
| All link geometries visible | ✔️ |

---

## 📊 Results Summary

| Criterion | Expected | Achieved | Status |
|---|---|---|---|
| Link definitions | 5 links | 5 links | ✅ Pass |
| Joint definitions | 4 revolute | 4 revolute | ✅ Pass |
| Visual + collision elements | All links | All links | ✅ Pass |
| Joint limits defined | All joints | All joints | ✅ Pass |
| RViz loads without error | 0 warnings | 0 warnings | ✅ Pass |
| TF tree — all frames present | 5 frames | 5 frames | ✅ Pass |
| TF broadcast rate | ≥10 Hz | 10.2 Hz | ✅ Pass |
| TF buffer continuity | 5 s | 5.0 s | ✅ Pass |
| Workspace build | success | no errors | ✅ Pass |
| Inertial properties defined | All links | All links | ✅ Pass |

TF frames broadcast at **10.2 Hz**, comfortably above the 10 Hz minimum requirement, with a full 5-second buffer across the chain `base_link → link_01 → link_02 → link_03 → end_effector`.

---

## 🔭 Next Steps

- Integrate with **MoveIt2** for motion planning and inverse kinematics.
- Bring the model into **Gazebo** for physics-based simulation.
- Add `ros2_control` hardware interfaces to drive real/simulated actuators.

---

## 📄 Core File: `mrm.xacro`

The complete robot description lives in `urdf/mrm.xacro`. It defines:
- 5 material colors (grey, blue, green, orange, red)
- 5 links with visual, collision, and inertial properties
- 4 revolute joints chaining the links together into `robot name="four_dof_arm"`

Build and load it via the commands in the **Step-by-Step Setup & Run Guide** above — no manual XML editing is required to reproduce the results in this README.

---

## 👤 Author

**Swarnava Bhowmick**
ROBO AI Industrial Training Program
Submitted to: My Equation™ — Tech Analogy Pvt. Ltd.
June 2026
