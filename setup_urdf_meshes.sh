#!/usr/bin/env bash
# Recreates the symlinks from local ROS package paths into
# public/urdf/xarm_lite6/meshes/ so the URDF viewer can load xArm meshes.
#
# Run once after cloning, and again if your ROS workspace changes:
#   bash setup_urdf_meshes.sh

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
MESH_DIR="$SCRIPT_DIR/public/urdf/xarm_lite6/meshes"

# Source ROS workspace to resolve package paths
PATTY_SETUP="${PATTY_Q_WS:-$SCRIPT_DIR/../..}/install/setup.bash"
if [[ -f "$PATTY_SETUP" ]]; then
  # shellcheck disable=SC1090
  source "$PATTY_SETUP"
fi

resolve_pkg() {
  local pkg="$1"
  if command -v ros2 &>/dev/null; then
    ros2 pkg prefix "$pkg" 2>/dev/null
  fi
}

mkdir -p "$MESH_DIR"

# xarm_description (STLs for arm links + bio gripper DAEs)
XARM_PREFIX=$(resolve_pkg xarm_description || true)
if [[ -n "$XARM_PREFIX" && -d "$XARM_PREFIX/share/xarm_description" ]]; then
  ln -sfn "$XARM_PREFIX/share/xarm_description" "$MESH_DIR/xarm_description"
  echo "Linked xarm_description -> $XARM_PREFIX/share/xarm_description"
else
  echo "WARNING: xarm_description not found. Set ROS env or run: source install/setup.bash"
fi

# realsense2_description (D405 + D435 meshes)
RS_PREFIX=$(resolve_pkg realsense2_description || true)
if [[ -n "$RS_PREFIX" && -d "$RS_PREFIX/share/realsense2_description" ]]; then
  ln -sfn "$RS_PREFIX/share/realsense2_description" "$MESH_DIR/realsense2_description"
  echo "Linked realsense2_description -> $RS_PREFIX/share/realsense2_description"
else
  echo "WARNING: realsense2_description not found."
fi

# lite6_q2r2 (D405 bracket STL)
L6_PREFIX=$(resolve_pkg lite6_q2r2 || true)
if [[ -n "$L6_PREFIX" && -d "$L6_PREFIX/share/lite6_q2r2" ]]; then
  ln -sfn "$L6_PREFIX/share/lite6_q2r2" "$MESH_DIR/lite6_q2r2"
  echo "Linked lite6_q2r2 -> $L6_PREFIX/share/lite6_q2r2"
else
  echo "WARNING: lite6_q2r2 not found."
fi

echo "Done. Run 'DATASET_URL=http://localhost:8765 bun dev' to start the visualizer."
