#!/usr/bin/env bash
# ──────────────────────────────────────────────────────────────────────────────
# setup_and_run.sh  —  4-DOF Arm: Full Setup & Launch Guide
# ROS 2 Jazzy | Ubuntu 24.04
# ──────────────────────────────────────────────────────────────────────────────
set -eo pipefail

BOLD='\033[1m'; CYAN='\033[0;36m'; GREEN='\033[0;32m'
YELLOW='\033[0;33m'; RESET='\033[0m'

info()  { echo -e "${CYAN}[INFO]${RESET}  $*"; }
ok()    { echo -e "${GREEN}[ OK ]${RESET}  $*"; }
warn()  { echo -e "${YELLOW}[WARN]${RESET}  $*"; }
head()  { echo -e "\n${BOLD}$*${RESET}"; }

# ──────────────────────────────────────────────────────────────────────────────
head "STEP 1 — Source ROS 2 Jazzy"
# ──────────────────────────────────────────────────────────────────────────────
source /opt/ros/jazzy/setup.bash
ok "ROS 2 Jazzy sourced"

# ──────────────────────────────────────────────────────────────────────────────
head "STEP 2 — Install dependencies (first run only)"
# ──────────────────────────────────────────────────────────────────────────────
sudo apt-get update -qq
sudo apt-get install -y \
  ros-jazzy-robot-state-publisher \
  ros-jazzy-joint-state-publisher-gui \
  ros-jazzy-xacro \
  ros-jazzy-rviz2 \
  ros-jazzy-tf2-tools \
  ros-jazzy-tf2-ros \
  python3-colcon-common-extensions
ok "All dependencies installed"

# ──────────────────────────────────────────────────────────────────────────────
head "STEP 3 — Build the workspace"
# ──────────────────────────────────────────────────────────────────────────────
WORKSPACE="${HOME}/ros2_ws"
PKG_SRC="${WORKSPACE}/src/four_dof_arm"
PROJECT_DIR="$(cd "$(dirname "$0")" && pwd)"

mkdir -p "${PKG_SRC}"

# Only copy if we're not already in the right place
if [ "${PROJECT_DIR}" != "${PKG_SRC}" ]; then
  info "Copying package from ${PROJECT_DIR} to ${PKG_SRC}"
  cp -r "${PROJECT_DIR}"/* "${PKG_SRC}/" 2>/dev/null || true
else
  ok "Already in workspace, skipping copy"
fi

cd "${WORKSPACE}"
colcon build --packages-select four_dof_arm --symlink-install
source "${WORKSPACE}/install/setup.bash"
ok "Package built successfully"

# ──────────────────────────────────────────────────────────────────────────────
head "STEP 4 — Validate URDF with check_urdf (optional)"
# ──────────────────────────────────────────────────────────────────────────────
XACRO_FILE="${PKG_SRC}/urdf/four_dof_arm.urdf.xacro"
TMP_URDF="/tmp/four_dof_arm_check.urdf"

xacro "${XACRO_FILE}" > "${TMP_URDF}"
check_urdf "${TMP_URDF}" && ok "URDF validated — no errors"

# ──────────────────────────────────────────────────────────────────────────────
head "STEP 5 — Launch in RViz2  (Q to exit)"
# ──────────────────────────────────────────────────────────────────────────────
info "Launching: robot_state_publisher + joint_state_publisher_gui + rviz2"
ros2 launch four_dof_arm display.launch.py

# ──────────────────────────────────────────────────────────────────────────────
head "STEP 6 — TF Tree Verification commands (run in separate terminal)"
# ──────────────────────────────────────────────────────────────────────────────
echo ""
info "Commands to verify TF tree:"
echo "  ros2 run tf2_tools view_frames          # generates frames.pdf"
echo "  ros2 topic echo /tf_static              # view static transforms"
echo "  ros2 topic echo /joint_states           # live joint angles"
echo "  ros2 run tf2_ros tf2_echo world tcp     # live EE pose"
echo ""
ok "Done! Check frames.pdf for the TF tree diagram."
