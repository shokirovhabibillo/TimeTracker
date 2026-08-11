import 'schematic_exercise_animation.dart';

/// Best-effort mapping from exercise id -> movement pattern, covering
/// both the Trapezius and Street Workout catalogs.
String movementPatternForExerciseId(String id) {
  const map = {
    // Trapezius — shrug/raise family
    'backpack_shrug': MovementPattern.isolationRaise,
    'resistance_band_shrug': MovementPattern.isolationRaise,
    'dumbbell_shrug': MovementPattern.isolationRaise,
    'barbell_shrug': MovementPattern.isolationRaise,
    'cable_shrug': MovementPattern.isolationRaise,
    'machine_shrug': MovementPattern.isolationRaise,
    'wall_y_raise': MovementPattern.isolationRaise,
    'prone_y_raise': MovementPattern.isolationRaise,
    'prone_t_raise': MovementPattern.isolationRaise,
    'cable_y_raise': MovementPattern.isolationRaise,
    'scapular_retraction': MovementPattern.horizontalPull,
    'face_pull': MovementPattern.horizontalPull,
    'chest_supported_row': MovementPattern.horizontalPull,
    'seated_cable_row': MovementPattern.horizontalPull,

    // Street Workout — PULL
    'dead_hang': MovementPattern.staticHold,
    'scapular_pullup': MovementPattern.verticalPull,
    'assisted_pullup': MovementPattern.verticalPull,
    'pullup': MovementPattern.verticalPull,
    'chinup': MovementPattern.verticalPull,
    'inverted_row': MovementPattern.horizontalPull,

    // PUSH
    'incline_pushup': MovementPattern.horizontalPush,
    'pushup': MovementPattern.horizontalPush,
    'diamond_pushup': MovementPattern.horizontalPush,
    'parallel_support': MovementPattern.staticHold,
    'assisted_dip': MovementPattern.verticalPush,
    'dip': MovementPattern.verticalPush,

    // LEGS
    'bodyweight_squat_sw': MovementPattern.squat,
    'reverse_lunge': MovementPattern.squat,
    'split_squat': MovementPattern.squat,
    'stepup': MovementPattern.squat,
    'calf_raise_sw': MovementPattern.calf,
    'glute_bridge': MovementPattern.hinge,

    // CORE
    'plank': MovementPattern.staticHold,
    'side_plank': MovementPattern.staticHold,
    'dead_bug': MovementPattern.core,
    'hanging_knee_raise': MovementPattern.core,
    'knee_tuck': MovementPattern.core,
    'leg_raise': MovementPattern.core,

    // FULL BODY
    'mountain_climber': MovementPattern.core,
    'burpee': MovementPattern.squat,
  };
  return map[id] ?? MovementPattern.staticHold;
}
