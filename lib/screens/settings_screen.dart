import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/theme_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final theme = context.watch<ThemeProvider>();
    final cs = Theme.of(context).colorScheme;
    final isDark = theme.themeMode == ThemeMode.dark ||
        (theme.themeMode == ThemeMode.system &&
            MediaQuery.platformBrightnessOf(context) == Brightness.dark);

    return Scaffold(
      backgroundColor: cs.surface,
      body: CustomScrollView(
        slivers: [
          // ── Modern SliverAppBar ──────────────────────────────────────
          SliverAppBar(
            expandedHeight: 220,
            pinned: true,
            stretch: true,
            backgroundColor: cs.surface,
            flexibleSpace: FlexibleSpaceBar(
              stretchModes: const [StretchMode.zoomBackground],
              background: _ProfileHero(auth: auth, cs: cs),
            ),
            title: const Text(
              'Ayarlar',
              style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18),
            ),
          ),

          // ── Content ─────────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 40),
              child: Column(
                children: [
                  // Görünüm kartı
                  _SettingsCard(
                    label: 'GÖRÜNÜM',
                    children: [
                      _ThemeTile(theme: theme, cs: cs),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // Hakkında kartı
                  _SettingsCard(
                    label: 'HAKKINDA',
                    children: [
                      _InfoTile(
                        icon: Icons.info_outline_rounded,
                        title: 'Sürüm',
                        trailing: Text(
                          '1.0.0',
                          style: TextStyle(
                            color: cs.onSurfaceVariant,
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 28),

                  // Çıkış butonu
                  _LogoutButton(auth: auth, cs: cs),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Profile Hero ────────────────────────────────────────────────────────────
class _ProfileHero extends StatelessWidget {
  final AuthProvider auth;
  final ColorScheme cs;

  const _ProfileHero({required this.auth, required this.cs});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            cs.primaryContainer,
            cs.secondaryContainer,
          ],
        ),
      ),
      child: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 32),
              // Avatar
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: cs.primary,
                  boxShadow: [
                    BoxShadow(
                      color: cs.primary.withOpacity(0.35),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    auth.username.isNotEmpty
                        ? auth.username[0].toUpperCase()
                        : '?',
                    style: TextStyle(
                      color: cs.onPrimary,
                      fontSize: 32,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                auth.username,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: cs.onPrimaryContainer,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                auth.email,
                style: TextStyle(
                  fontSize: 13,
                  color: cs.onPrimaryContainer.withOpacity(0.7),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Settings Card ────────────────────────────────────────────────────────────
class _SettingsCard extends StatelessWidget {
  final String label;
  final List<Widget> children;

  const _SettingsCard({required this.label, required this.children});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.4,
              color: cs.primary,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: cs.surfaceContainerHighest.withOpacity(0.5),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(children: children),
        ),
      ],
    );
  }
}

// ── Theme Tile ───────────────────────────────────────────────────────────────
class _ThemeTile extends StatelessWidget {
  final ThemeProvider theme;
  final ColorScheme cs;

  const _ThemeTile({required this.theme, required this.cs});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: cs.primaryContainer,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(Icons.dark_mode_outlined,
                color: cs.onPrimaryContainer, size: 20),
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Text(
              'Tema',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: cs.surfaceContainer,
              borderRadius: BorderRadius.circular(10),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
            child: DropdownButton<ThemeMode>(
              value: theme.themeMode,
              underline: const SizedBox(),
              borderRadius: BorderRadius.circular(12),
              style: TextStyle(
                color: cs.onSurface,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
              items: const [
                DropdownMenuItem(value: ThemeMode.system, child: Text('Sistem')),
                DropdownMenuItem(value: ThemeMode.light, child: Text('Açık')),
                DropdownMenuItem(value: ThemeMode.dark, child: Text('Koyu')),
              ],
              onChanged: (v) => v != null ? theme.setThemeMode(v) : null,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Info Tile ────────────────────────────────────────────────────────────────
class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final Widget trailing;

  const _InfoTile({
    required this.icon,
    required this.title,
    required this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: cs.secondaryContainer,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: cs.onSecondaryContainer, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
            ),
          ),
          trailing,
        ],
      ),
    );
  }
}

// ── Logout Button ────────────────────────────────────────────────────────────
class _LogoutButton extends StatelessWidget {
  final AuthProvider auth;
  final ColorScheme cs;

  const _LogoutButton({required this.auth, required this.cs});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: OutlinedButton.icon(
        onPressed: () => _confirmLogout(context, auth),
        icon: const Icon(Icons.logout_rounded, color: Colors.red),
        label: const Text(
          'Çıkış Yap',
          style: TextStyle(
            color: Colors.red,
            fontWeight: FontWeight.w700,
            fontSize: 15,
          ),
        ),
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: Colors.red.withOpacity(0.5), width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
    );
  }

  void _confirmLogout(BuildContext context, AuthProvider auth) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Çıkış Yap',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
        content: const Text('Hesabından çıkmak istediğine emin misin?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              auth.logout();
            },
            style: FilledButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text('Çıkış Yap'),
          ),
        ],
      ),
    );
  }
}
