import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_highlight/flutter_highlight.dart';
import 'package:flutter_highlight/themes/atom-one-dark.dart';

import '../theme/app_visual_tokens.dart';
import 'ai_primitives.dart';
import 'ai_surface_card.dart';

class CodeViewer extends StatelessWidget {
  const CodeViewer({super.key, required this.language, required this.code});

  final String language;
  final String code;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final minCodeWidth = math.max(0.0, MediaQuery.sizeOf(context).width - 76);
    return Semantics(
      label: '$language 代码块',
      child: AiSurfaceCard(
        variant: AiCardVariant.code,
        padding: EdgeInsets.zero,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.fromLTRB(18, 14, 12, 14),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: Colors.white.withValues(alpha: 0.08),
                  ),
                ),
              ),
              child: Row(
                children: [
                  Row(
                    children: const [
                      _WindowDot(color: Color(0xFFFB7185)),
                      SizedBox(width: 6),
                      _WindowDot(color: Color(0xFFF59E0B)),
                      SizedBox(width: 6),
                      _WindowDot(color: Color(0xFF10B981)),
                    ],
                  ),
                  const SizedBox(width: 12),
                  AiStatusPill(
                    label: language.toUpperCase(),
                    tone: AiStatusTone.accent,
                  ),
                  const Spacer(),
                  IconButton(
                    tooltip: '复制内容',
                    onPressed: () async {
                      await Clipboard.setData(ClipboardData(text: code));
                      if (!context.mounted) {
                        return;
                      }
                      ScaffoldMessenger.of(
                        context,
                      ).showSnackBar(const SnackBar(content: Text('已复制到剪贴板')));
                    },
                    icon: Icon(
                      Icons.content_copy_rounded,
                      color: Colors.white.withValues(alpha: 0.92),
                    ),
                  ),
                ],
              ),
            ),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.fromLTRB(18, 16, 18, 18),
              child: ConstrainedBox(
                constraints: BoxConstraints(minWidth: minCodeWidth),
                child: HighlightView(
                  code,
                  language: language.toLowerCase(),
                  theme: atomOneDarkTheme,
                  textStyle: TextStyle(
                    fontFamily: 'JetBrainsMono',
                    fontSize: 13.4,
                    height: 1.58,
                    color: Colors.white.withValues(alpha: 0.95),
                  ),
                  padding: EdgeInsets.zero,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 0, 18, 18),
              child: Text(
                '复制后可直接粘贴到你的 AI 客户端或配置文件里。',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: tokens.borderStrong.withValues(alpha: 0.92),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _WindowDot extends StatelessWidget {
  const _WindowDot({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 9,
      height: 9,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(99),
      ),
    );
  }
}
