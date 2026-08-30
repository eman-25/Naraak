// lib/screens/family_members_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/family_member.dart';
import '../providers/app_settings_provider.dart';
import '../providers/family_provider.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import 'add_family_member_screen.dart';

/// Family management — pure content (no Scaffold/AppBar; the shell renders
/// the top bar). Matches the reference: page title, a teal "currently
/// viewing" card for the active member, then a grid of the rest with a
/// "Link a family member" dashed card.
class FamilyMembersScreen extends StatelessWidget {
  const FamilyMembersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final palette = context.watch<AppSettingsProvider>().palette;
    final members = context.watch<FamilyProvider>().members;
    final active = members.where((m) => m.isActive).toList();
    final others = members.where((m) => !m.isActive).toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 860),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextButton.icon(
              onPressed: () => Navigator.of(context).pop(),
              style: TextButton.styleFrom(
                foregroundColor: palette.primary,
                padding: EdgeInsets.zero,
              ),
              icon: const Icon(Icons.arrow_back_rounded, size: 16),
              label: const Text('Back',
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12)),
            ),
            const SizedBox(height: 12),
            Text('YOUR HOUSEHOLD',
                style: AppTextStyles.overline.copyWith(color: palette.primary)),
            const SizedBox(height: 6),
            Text('Family management', style: AppTextStyles.h1.copyWith(fontSize: 26)),
            const SizedBox(height: 6),
            Text('Switch to a verified family member when arranging eligible services.',
                style: AppTextStyles.bodySecondary),
            const SizedBox(height: 22),
            if (active.isNotEmpty) _ActiveMemberCard(member: active.first, palette: palette),
            const SizedBox(height: 20),
            LayoutBuilder(builder: (context, constraints) {
              final columns = constraints.maxWidth > 560 ? 2 : 1;
              return GridView.count(
                crossAxisCount: columns,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 14,
                crossAxisSpacing: 14,
                childAspectRatio: columns == 2 ? 1.15 : 1.5,
                children: [
                  ...others.map((m) => _MemberCard(member: m, palette: palette)),
                  const _AddMemberCard(),
                ],
              );
            }),
          ],
        ),
      ),
    );
  }
}

class _ActiveMemberCard extends StatelessWidget {
  final FamilyMember member;
  final dynamic palette;
  const _ActiveMemberCard({required this.member, required this.palette});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: palette.primaryDark,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 7,
                height: 7,
                decoration: const BoxDecoration(
                    color: Color(0xFF9DE3B7), shape: BoxShape.circle),
              ),
              const SizedBox(width: 8),
              Text('CURRENTLY VIEWING',
                  style: AppTextStyles.overline
                      .copyWith(color: const Color(0xFFBDE2DE), fontSize: 10)),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              CircleAvatar(
                radius: 22,
                backgroundColor: Colors.white24,
                child: Text(member.initials,
                    style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 14)),
              ),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(member.fullName,
                        style: AppTextStyles.h3
                            .copyWith(color: Colors.white, fontSize: 17)),
                    const SizedBox(height: 4),
                    Text('My profile · CPR ${member.cprMasked}',
                        style: AppTextStyles.caption
                            .copyWith(color: const Color(0xFFC8E1E0))),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFE3F4EB),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.check_rounded, size: 11, color: Color(0xFF1E9E6B)),
                    SizedBox(width: 2),
                    Text('Verified',
                        style: TextStyle(
                            color: Color(0xFF1E9E6B),
                            fontSize: 9,
                            fontWeight: FontWeight.w800)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MemberCard extends StatelessWidget {
  final FamilyMember member;
  final dynamic palette;
  const _MemberCard({required this.member, required this.palette});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        border:
            Border.all(color: isDark ? AppColors.darkOutline : AppColors.outline),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: const Color(0xFFE3D4C7),
                child: Text(member.initials,
                    style: const TextStyle(
                        color: Color(0xFF7A5547),
                        fontWeight: FontWeight.w800,
                        fontSize: 12)),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFE3F4EB),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Text('Verified',
                    style: TextStyle(
                        color: Color(0xFF1E9E6B),
                        fontSize: 9,
                        fontWeight: FontWeight.w800)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(member.fullName, style: AppTextStyles.h3.copyWith(fontSize: 15)),
          const SizedBox(height: 3),
          Text('${member.relation} · ${member.age} years old',
              style: AppTextStyles.caption),
          const SizedBox(height: 10),
          Row(children: [
            Icon(Icons.shield_outlined, size: 12, color: palette.primary),
            const SizedBox(width: 5),
            Expanded(
              child: Text('CPR · ${member.cprMasked}',
                  style: AppTextStyles.caption.copyWith(fontSize: 10.5),
                  overflow: TextOverflow.ellipsis),
            ),
          ]),
          const SizedBox(height: 4),
          Row(children: [
            Icon(Icons.location_on_outlined, size: 12, color: palette.primary),
            const SizedBox(width: 5),
            Expanded(
              child: Text(member.healthCenter,
                  style: AppTextStyles.caption.copyWith(fontSize: 10.5),
                  overflow: TextOverflow.ellipsis),
            ),
          ]),
          const Spacer(),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () =>
                  context.read<FamilyProvider>().setActive(member.id),
              style: OutlinedButton.styleFrom(
                foregroundColor: palette.primary,
                side: BorderSide(color: palette.primary.withValues(alpha: 0.4)),
                padding: const EdgeInsets.symmetric(vertical: 10),
              ),
              child: Text('Switch to ${member.fullName.split(' ').first}',
                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700)),
            ),
          ),
        ],
      ),
    );
  }
}

class _AddMemberCard extends StatelessWidget {
  const _AddMemberCard();

  @override
  Widget build(BuildContext context) {
    final palette = context.watch<AppSettingsProvider>().palette;
    return InkWell(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const AddFamilyMemberScreen()),
      ),
      borderRadius: BorderRadius.circular(15),
      child: DottedBorderBox(
        color: palette.primary,
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: palette.primary.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.people_alt_rounded, color: palette.primary, size: 20),
                ),
                const SizedBox(height: 10),
                Text('Link a family member',
                    style: AppTextStyles.body
                        .copyWith(fontWeight: FontWeight.w700, fontSize: 13)),
                const SizedBox(height: 4),
                Text('They will need to verify the relationship.',
                    style: AppTextStyles.caption,
                    textAlign: TextAlign.center),
              ],
            ),
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
        Offset.zero & size, const Radius.circular(15));
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
