// lib/screens/family_members_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/family_member.dart';
import '../providers/app_settings_provider.dart';
import '../providers/family_provider.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../theme/app_theme.dart';
import '../widgets/app_card.dart';
import '../widgets/app_top_bar.dart';
import 'add_family_member_screen.dart';

class FamilyMembersScreen extends StatelessWidget {
  const FamilyMembersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final palette = context.watch<AppSettingsProvider>().palette;
    final members = context.watch<FamilyProvider>().members;

    return Scaffold(
      appBar: const AppTopBar(title: 'Family Members'),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Container(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
              decoration: BoxDecoration(
                gradient: palette.heroGradient,
                borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(28),
                    bottomRight: Radius.circular(28)),
              ),
              child: Text('Manage dependents and act on their behalf',
                  style: AppTextStyles.body.copyWith(color: Colors.white)),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.all(20),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                ...members.map((m) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _MemberCard(member: m, palette: palette),
                    )),
                const SizedBox(height: 4),
                _AddMemberButton(palette: palette),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

class _MemberCard extends StatelessWidget {
  final FamilyMember member;
  final palette;
  const _MemberCard({required this.member, required this.palette});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: member.isActive
          ? null
          : () => context.read<FamilyProvider>().setActive(member.id),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
                gradient: palette.heroGradient, shape: BoxShape.circle),
            child: Center(
              child: Text(member.initials,
                  style: const TextStyle(
                      color: Colors.white, fontWeight: FontWeight.w700)),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(member.fullName,
                    style: AppTextStyles.h3.copyWith(fontSize: 15)),
                const SizedBox(height: 2),
                Text(
                    '${member.relation} · ${member.age} yrs · CPR ${member.cprMasked}',
                    style: AppTextStyles.caption),
                Text(member.healthCenter,
                    style:
                        AppTextStyles.caption.copyWith(color: palette.primary)),
              ],
            ),
          ),
          const SizedBox(width: 8),
          member.isActive
              ? Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                      color: palette.primary,
                      borderRadius: BorderRadius.circular(30)),
                  child: const Text('ACTIVE',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w700)),
                )
              : OutlinedButton(
                  onPressed: () =>
                      context.read<FamilyProvider>().setActive(member.id),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(0, 34),
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    side: BorderSide(
                        color: palette.primary.withValues(alpha: 0.4)),
                    foregroundColor: palette.primary,
                  ),
                  child: const Text('SWITCH',
                      style:
                          TextStyle(fontSize: 11, fontWeight: FontWeight.w700)),
                ),
        ],
      ),
    );
  }
}

class _AddMemberButton extends StatelessWidget {
  final palette;
  const _AddMemberButton({required this.palette});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const AddFamilyMemberScreen()),
      ),
      borderRadius: BorderRadius.circular(AppTheme.radiusMd),
      child: DottedBorderBox(
        color: palette.primary,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.add_rounded, color: palette.primary, size: 20),
              const SizedBox(width: 8),
              Text('Add family member',
                  style: AppTextStyles.body.copyWith(
                      color: palette.primary, fontWeight: FontWeight.w700)),
            ],
          ),
        ),
      ),
    );
  }
}

/// Lightweight dashed-border container — no external package dependency.
class DottedBorderBox extends StatelessWidget {
  final Widget child;
  final Color color;
  const DottedBorderBox({super.key, required this.child, required this.color});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _DashedBorderPainter(color: color),
      child: child,
    );
  }
}

class _DashedBorderPainter extends CustomPainter {
  final Color color;
  _DashedBorderPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withValues(alpha: 0.5)
      ..strokeWidth = 1.4
      ..style = PaintingStyle.stroke;
    final rrect = RRect.fromRectAndRadius(
        Offset.zero & size, const Radius.circular(AppTheme.radiusMd));
    const dashWidth = 6.0, dashSpace = 4.0;
    final path = Path()..addRRect(rrect);
    for (final metric in path.computeMetrics()) {
      var distance = 0.0;
      while (distance < metric.length) {
        canvas.drawPath(
            metric.extractPath(distance, distance + dashWidth), paint);
        distance += dashWidth + dashSpace;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DashedBorderPainter oldDelegate) =>
      oldDelegate.color != color;
}
