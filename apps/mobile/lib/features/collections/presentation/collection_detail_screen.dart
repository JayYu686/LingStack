import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/actions/catalog_actions.dart';
import '../../../core/widgets/ai_primitives.dart';
import '../../../core/widgets/ai_surface_card.dart';
import '../../../core/widgets/resource_card.dart';
import '../../../domain/models.dart';
import '../../../infrastructure/providers.dart';

class CollectionDetailScreen extends ConsumerWidget {
  const CollectionDetailScreen({super.key, required this.collectionId});

  final String collectionId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detail = ref.watch(collectionDetailProvider(collectionId));
    return Scaffold(
      appBar: AppBar(title: const Text('精选合集')),
      body: detail.when(
        data: (data) {
          if (data == null) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: AiEmptyState(
                  icon: Icons.folder_off_rounded,
                  title: '未找到这个合集',
                  description: '可能是本地目录已刷新，或者这个合集已经不在当前版本里。',
                ),
              ),
            );
          }

          return ListView(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 120),
            children: [
              AiReveal(index: 0, child: _CollectionHero(detail: data)),
              const SizedBox(height: 20),
              const AiReveal(
                index: 1,
                child: AiSectionHeader(
                  data: AiPageHeaderData(
                    eyebrow: '使用方式',
                    title: '先按这个合集走通第一遍',
                    subtitle: '合集适合把相关资源打包在一起。你可以先从一条提示词开始，再逐步补技能和 MCP。',
                  ),
                ),
              ),
              const SizedBox(height: 14),
              AiReveal(
                index: 2,
                child: AiSurfaceCard(
                  variant: AiCardVariant.subdued,
                  child: AiStepRail(
                    steps: [
                      '先打开第一条资源，看看它解决的问题是否就是你当前的问题。',
                      '如果适合，优先收藏；如果不完全适合，再导入自己的版本做微调。',
                      '当你需要把 AI 接到外部平台时，再看这个合集里的 MCP 资源。',
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              AiSectionHeader(
                data: AiPageHeaderData(
                  eyebrow: '合集内容',
                  title: '这组资源已经按顺序排好',
                  subtitle: '从上到下浏览即可；每张卡片都可以直接打开详情页。',
                ),
                trailing: AiMetricPill(
                  label: '条资源',
                  value: '${data.collection.resourceCount}',
                ),
              ),
              const SizedBox(height: 14),
              ...data.resources.asMap().entries.map(
                (entry) => Padding(
                  padding: const EdgeInsets.only(bottom: 14),
                  child: AiReveal(
                    index: entry.key + 3,
                    child: ResourceCard(
                      resource: entry.value,
                      onTap: () => openCatalogResource(context, entry.value),
                      onFavoriteToggle: () =>
                          toggleFavoriteAction(context, ref, entry.value.id),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
        loading: () => const _CollectionLoadingState(),
        error: (error, stackTrace) => Center(child: Text('加载合集失败：$error')),
      ),
    );
  }
}

class _CollectionHero extends StatelessWidget {
  const _CollectionHero({required this.detail});

  final CollectionDetail detail;

  @override
  Widget build(BuildContext context) {
    return AiSurfaceCard(
      variant: AiCardVariant.accent,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              const AiStatusPill(label: '新手优先合集', tone: AiStatusTone.accent),
              AiMetricPill(
                label: '条资源',
                value: '${detail.collection.resourceCount}',
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            detail.collection.title,
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(detail.collection.subtitle),
          const SizedBox(height: 12),
          Text(
            detail.collection.description,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}

class _CollectionLoadingState extends StatelessWidget {
  const _CollectionLoadingState();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 120),
      children: const [
        AiSkeletonBlock(height: 170),
        SizedBox(height: 18),
        AiSkeletonBlock(height: 180),
        SizedBox(height: 18),
        AiSkeletonBlock(height: 160),
        SizedBox(height: 14),
        AiSkeletonBlock(height: 160),
      ],
    );
  }
}
