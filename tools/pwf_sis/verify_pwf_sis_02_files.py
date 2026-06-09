from pathlib import Path

required = [
    "lib/core/theme/palwakf_sis_colors.dart",
    "lib/core/theme/palwakf_sis_theme.dart",
    "lib/core/theme/palwakf_sis_breakpoints.dart",
    "lib/core/widgets/palwakf_sis/pwf_sis_status_badge.dart",
    "lib/core/widgets/palwakf_sis/pwf_sis_runtime_state.dart",
    "lib/features/platform_design_system/presentation/pages/pwf_sis_component_gallery_page.dart",
    "lib/features/platform_design_system/presentation/pages/pwf_sis_visual_identity_bridge_page.dart",
    "lib/features/platform_design_system/presentation/routes/pwf_sis_routes.dart",
    "lib/features/awqaf_system/presentation/pilot/pwf_sis_awqaf_system_pilot_page.dart",
]

missing = [item for item in required if not Path(item).exists()]
if missing:
    print("Missing PWF-SIS files:")
    for item in missing:
        print("-", item)
    raise SystemExit(1)

print("PWF-SIS-02 required files exist.")
