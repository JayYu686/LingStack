import 'dart:async';
import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/actions/catalog_actions.dart';
import '../../../core/search/committed_search_controller.dart';
import '../../../core/theme/app_visual_tokens.dart';
import '../../../core/widgets/ai_primitives.dart';
import '../../../core/widgets/ai_surface_card.dart';
import '../../../core/widgets/brand_artwork.dart';
import '../../../core/widgets/resource_card.dart';
import '../../../domain/models.dart';
import '../../../infrastructure/providers.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final pages = <Widget>[
      _ExplorerHomeTab(onSelectTab: _changeTab),
      const _ResourceBrowseTab(type: ResourceType.prompt),
      const _ResourceBrowseTab(type: ResourceType.skill),
      const _ResourceBrowseTab(type: ResourceType.mcp),
      const _MyLibraryTab(),
    ];

    return DecoratedBox(
      decoration: BoxDecoration(gradient: tokens.backgroundGradient),
      child: Scaffold(
        extendBody: true,
        backgroundColor: Colors.transparent,
        bottomNavigationBar: _AiDockBar(
          selectedIndex: _selectedIndex,
          onSelect: _changeTab,
        ),
        body: SafeArea(
          bottom: false,
          child: _AnimatedTabStage(
            selectedIndex: _selectedIndex,
            children: pages,
          ),
        ),
      ),
    );
  }

  void _changeTab(int index) {
    setState(() => _selectedIndex = index);
  }
}

class _AnimatedTabStage extends StatelessWidget {
  const _AnimatedTabStage({
    required this.selectedIndex,
    required this.children,
  });

  final int selectedIndex;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final reduceMotion =
        MediaQuery.maybeOf(context)?.disableAnimations ?? false;
    return Stack(
      children: [
        for (var index = 0; index < children.length; index++)
          Positioned.fill(
            child: Visibility(
              visible: index == selectedIndex,
              maintainState: true,
              maintainAnimation: true,
              child: IgnorePointer(
                ignoring: index != selectedIndex,
                child: ExcludeSemantics(
                  excluding: index != selectedIndex,
                  child: AnimatedOpacity(
                    duration: reduceMotion ? Duration.zero : tokens.motionSlow,
                    curve: Curves.easeOutCubic,
                    opacity: index == selectedIndex ? 1 : 0,
                    child: AnimatedSlide(
                      duration: reduceMotion
                          ? Duration.zero
                          : tokens.motionSlow,
                      curve: Curves.easeOutCubic,
                      offset: index == selectedIndex
                          ? Offset.zero
                          : Offset(
                              index < selectedIndex ? -0.025 : 0.025,
                              0.018,
                            ),
                      child: AnimatedScale(
                        duration: reduceMotion
                            ? Duration.zero
                            : tokens.motionSlow,
                        curve: Curves.easeOutCubic,
                        scale: index == selectedIndex ? 1 : 0.992,
                        child: TickerMode(
                          enabled: index == selectedIndex,
                          child: children[index],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _AiDockBar extends StatelessWidget {
  const _AiDockBar({required this.selectedIndex, required this.onSelect});

  final int selectedIndex;
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final reduceMotion =
        MediaQuery.maybeOf(context)?.disableAnimations ?? false;
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final compact = constraints.maxWidth < 390;
          const outerPadding = 8.0;
          const highlightInset = 10.0;
          final dockHeight = compact ? 78.0 : 82.0;
          final segmentWidth =
              (constraints.maxWidth - (outerPadding * 2)) /
              _dockDestinations.length;
          final highlightWidth = segmentWidth - highlightInset;

          return SizedBox(
            height: dockHeight,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(tokens.radiusXl),
              child: BackdropFilter(
                filter: ImageFilter.blur(
                  sigmaX: tokens.blurSigma + 2,
                  sigmaY: tokens.blurSigma + 2,
                ),
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.7),
                    borderRadius: BorderRadius.circular(tokens.radiusXl),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.76),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: tokens.shadowSoft.withValues(alpha: 0.16),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Stack(
                    children: [
                      Positioned(
                        left: 24,
                        right: 24,
                        top: 3,
                        child: IgnorePointer(
                          child: Container(
                            height: 1,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(999),
                              gradient: LinearGradient(
                                colors: [
                                  Colors.white.withValues(alpha: 0),
                                  Colors.white.withValues(alpha: 0.64),
                                  Colors.white.withValues(alpha: 0),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      AnimatedPositioned(
                        duration: reduceMotion
                            ? Duration.zero
                            : const Duration(milliseconds: 320),
                        curve: Curves.easeOutCubic,
                        left:
                            outerPadding +
                            (selectedIndex * segmentWidth) +
                            (highlightInset / 2),
                        top: 6,
                        width: highlightWidth,
                        height: dockHeight - 12,
                        child: IgnorePointer(
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.62),
                              borderRadius: BorderRadius.circular(
                                tokens.radiusLg,
                              ),
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.86),
                                width: 0.95,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: tokens.shadowSoft.withValues(
                                    alpha: 0.1,
                                  ),
                                  blurRadius: 12,
                                  offset: const Offset(0, 6),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: outerPadding,
                          vertical: 4,
                        ),
                        child: Row(
                          children: [
                            for (
                              var index = 0;
                              index < _dockDestinations.length;
                              index++
                            )
                              Expanded(
                                child: _AiDockItem(
                                  destination: _dockDestinations[index],
                                  selected: index == selectedIndex,
                                  compact: compact,
                                  onTap: () => onSelect(index),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _AiDockItem extends StatelessWidget {
  const _AiDockItem({
    required this.destination,
    required this.selected,
    required this.compact,
    required this.onTap,
  });

  final _DockDestination destination;
  final bool selected;
  final bool compact;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final reduceMotion =
        MediaQuery.maybeOf(context)?.disableAnimations ?? false;
    final iconColor = selected ? tokens.textPrimary : tokens.textSecondary;
    final labelColor = selected ? tokens.textPrimary : tokens.textSecondary;

    return Semantics(
      button: true,
      selected: selected,
      label: '${destination.label}导航',
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(tokens.radiusLg),
          child: SizedBox(
            height: compact ? 76 : 82,
            child: AnimatedSlide(
              duration: reduceMotion ? Duration.zero : tokens.motionBase,
              curve: Curves.easeOutCubic,
              offset: selected ? Offset.zero : const Offset(0, 0.015),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    destination.icon,
                    size: compact ? 21 : 22,
                    color: iconColor,
                  ),
                  SizedBox(height: compact ? 4 : 5),
                  AnimatedDefaultTextStyle(
                    duration: reduceMotion ? Duration.zero : tokens.motionBase,
                    curve: Curves.easeOutCubic,
                    style: Theme.of(context).textTheme.titleMedium!.copyWith(
                      fontSize: compact ? 11.5 : 12,
                      fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                      color: labelColor,
                      letterSpacing: 0,
                    ),
                    child: Text(destination.label),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _DockDestination {
  const _DockDestination({required this.icon, required this.label});

  final IconData icon;
  final String label;
}

const _dockDestinations = <_DockDestination>[
  _DockDestination(icon: Icons.space_dashboard_rounded, label: '首页'),
  _DockDestination(icon: Icons.auto_awesome_rounded, label: '提示词'),
  _DockDestination(icon: Icons.bolt_rounded, label: '技能'),
  _DockDestination(icon: Icons.hub_rounded, label: 'MCP'),
  _DockDestination(icon: Icons.bookmarks_rounded, label: '我的'),
];

class _ExplorerHomeTab extends ConsumerStatefulWidget {
  const _ExplorerHomeTab({required this.onSelectTab});

  final ValueChanged<int> onSelectTab;

  @override
  ConsumerState<_ExplorerHomeTab> createState() => _ExplorerHomeTabState();
}

class _ExplorerHomeTabState extends ConsumerState<_ExplorerHomeTab> {
  final TextEditingController _queryController = TextEditingController();
  late final CommittedSearchController _searchController;

  ProviderSubscription<int>? _refreshSubscription;
  HomeSnapshot? _snapshot;
  Object? _error;
  bool _isInitialLoading = true;
  bool _isSearching = false;
  int _requestSerial = 0;

  @override
  void initState() {
    super.initState();
    _searchController = CommittedSearchController(
      onCommit: (_) => _loadSnapshot(searching: true),
    );
    _refreshSubscription = ref.listenManual<int>(
      catalogRefreshTickProvider,
      (previous, next) => _loadSnapshot(searching: _snapshot != null),
    );
    _loadSnapshot();
  }

  @override
  void dispose() {
    _refreshSubscription?.close();
    _searchController.dispose();
    _queryController.dispose();
    super.dispose();
  }

  Future<void> _loadSnapshot({bool searching = false}) async {
    final requestSerial = ++_requestSerial;
    final query = _searchController.committedQuery;
    if (mounted) {
      setState(() {
        _error = _snapshot == null ? null : _error;
        if (_snapshot == null) {
          _isInitialLoading = true;
        } else {
          _isSearching = searching;
        }
      });
    }

    try {
      final repository = await ref.read(workspaceRepositoryProvider.future);
      final snapshot = await repository.loadHomeSnapshot(query: query);
      if (!mounted || requestSerial != _requestSerial) {
        return;
      }
      setState(() {
        _snapshot = snapshot;
        _error = null;
        _isInitialLoading = false;
        _isSearching = false;
      });
    } catch (error) {
      if (!mounted || requestSerial != _requestSerial) {
        return;
      }
      setState(() {
        _error = error;
        _isInitialLoading = false;
        _isSearching = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final data = _snapshot;
    if (data == null) {
      if (_isInitialLoading) {
        return const _HomeLoadingState();
      }
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text('首页加载失败：$_error'),
        ),
      );
    }

    final query = _searchController.committedQuery;
    final hero = AiReveal(
      index: 0,
      child: _HeroPanel(
        controller: _queryController,
        searchState: _isSearching
            ? AiLoadingState.loading
            : AiLoadingState.idle,
        importedCount: data.importedCount,
        officialResourceCount: data.officialResourceCount,
        collectionCount: data.collectionCount,
        catalogSyncState: data.catalogSyncState,
        onOpenStarter: () => context.go('/collection/starter-pack'),
        onOpenPrompt: () => widget.onSelectTab(1),
        onImport: () => context.go('/import'),
        onValueChanged: _searchController.handleValueChanged,
        onSubmitted: _searchController.submit,
      ),
    );

    return RefreshIndicator(
      onRefresh: () => invalidateCatalog(ref),
      child: LayoutBuilder(
        builder: (context, constraints) {
          if (query.isNotEmpty) {
            return ListView(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 120),
              children: [
                hero,
                const SizedBox(height: 24),
                const AiSectionHeader(
                  data: AiPageHeaderData(
                    eyebrow: '搜索结果',
                    title: '直接找到能拿来用的资源',
                    subtitle: '搜任务、场景或平台名称，结果会自动按你停下输入后的关键词刷新。',
                  ),
                ),
                const SizedBox(height: 16),
                if (_isSearching && data.query != query)
                  const _InlineResourceLoading()
                else if (data.searchResults.isEmpty)
                  const AiEmptyState(
                    icon: Icons.search_off_rounded,
                    title: '没找到合适的',
                    description: '换个更具体的任务词试试，比如代码审查、周报、简历、GitHub。',
                  )
                else
                  ...data.searchResults.asMap().entries.map(
                    (entry) => Padding(
                      padding: const EdgeInsets.only(bottom: 14),
                      child: AiReveal(
                        index: entry.key + 1,
                        child: ResourceCard(
                          resource: entry.value,
                          onTap: () =>
                              openCatalogResource(context, entry.value),
                          onFavoriteToggle: () => toggleFavoriteAction(
                            context,
                            ref,
                            entry.value.id,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            );
          }

          if (constraints.maxWidth >= 1100) {
            return _buildWideDashboard(context, data, hero);
          }
          return _buildNarrowDashboard(context, data, hero);
        },
      ),
    );
  }

  Widget _buildNarrowDashboard(
    BuildContext context,
    HomeSnapshot data,
    Widget hero,
  ) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 120),
      children: [
        hero,
        const SizedBox(height: 24),
        const AiSectionHeader(
          data: AiPageHeaderData(
            eyebrow: '先理解再开始',
            title: '这三类资源分别解决什么',
            subtitle: '先分清它是拿来直接用、反复复用，还是拿来连接外部工具的。',
          ),
        ),
        const SizedBox(height: 16),
        const _ConceptGrid(
          types: [ResourceType.prompt, ResourceType.skill, ResourceType.mcp],
        ),
        const SizedBox(height: 24),
        const AiSectionHeader(
          data: AiPageHeaderData(
            eyebrow: '新手优先合集',
            title: '按场景开始比按术语开始更容易',
            subtitle: '先从你今天就会遇到的任务开始，比先理解术语更容易上手。',
          ),
        ),
        const SizedBox(height: 16),
        _CollectionStrip(collections: data.featuredCollections),
        const SizedBox(height: 24),
        _CompactFeedSection(
          title: '先从这几条开始',
          subtitle: '第一次打开时，最容易马上用起来的资源。',
          resources: data.beginnerResources.take(4).toList(),
        ),
        const SizedBox(height: 24),
        _CompactFeedSection(
          title: '最近热门',
          subtitle: '最近最常被直接拿来用的资源。',
          resources: data.featuredResources.take(4).toList(),
          compact: true,
        ),
        const SizedBox(height: 24),
        _PreviewSection(
          title: '提示词精选',
          subtitle: '适合马上复制使用。',
          resources: data.prompts.take(3).toList(),
        ),
        const SizedBox(height: 24),
        _PreviewSection(
          title: '技能精选',
          subtitle: '适合接进你的代理与工作流。',
          resources: data.skills.take(3).toList(),
        ),
        const SizedBox(height: 24),
        _PreviewSection(
          title: 'MCP 精选',
          subtitle: '适合把 AI 连接到外部工具和数据。',
          resources: data.mcps.take(3).toList(),
        ),
        if (data.favoritePreview.isNotEmpty) ...[
          const SizedBox(height: 24),
          _CompactFeedSection(
            title: '最近收藏',
            subtitle: '你最近收起来的资源。',
            resources: data.favoritePreview,
            compact: true,
          ),
        ],
      ],
    );
  }

  Widget _buildWideDashboard(
    BuildContext context,
    HomeSnapshot data,
    Widget hero,
  ) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 120),
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 13,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  hero,
                  const SizedBox(height: 24),
                  const AiSectionHeader(
                    data: AiPageHeaderData(
                      eyebrow: '上手地图',
                      title: '先确认你需要哪一类资源',
                      subtitle: '提示词适合直接复制，技能适合固定做法，MCP 适合连接外部工具。',
                    ),
                  ),
                  const SizedBox(height: 16),
                  const _ConceptGrid(
                    types: [
                      ResourceType.prompt,
                      ResourceType.skill,
                      ResourceType.mcp,
                    ],
                  ),
                  const SizedBox(height: 24),
                  const AiSectionHeader(
                    data: AiPageHeaderData(
                      eyebrow: '按场景开始',
                      title: '新手优先合集',
                      subtitle: '先走通一遍最常见任务，再慢慢扩展到更多资源。',
                    ),
                  ),
                  const SizedBox(height: 16),
                  _CollectionStrip(collections: data.featuredCollections),
                  const SizedBox(height: 24),
                  _PreviewSection(
                    title: '提示词精选',
                    subtitle: '适合马上复制使用。',
                    resources: data.prompts.take(3).toList(),
                  ),
                  const SizedBox(height: 24),
                  _PreviewSection(
                    title: '技能精选',
                    subtitle: '适合接进你的代理与工作流。',
                    resources: data.skills.take(3).toList(),
                  ),
                  const SizedBox(height: 24),
                  _PreviewSection(
                    title: 'MCP 精选',
                    subtitle: '适合把 AI 连接到外部工具和数据。',
                    resources: data.mcps.take(3).toList(),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              flex: 8,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _CompactFeedSection(
                    title: '先从这几条开始',
                    subtitle: '第一次打开时，最容易快速上手的资源。',
                    resources: data.beginnerResources.take(4).toList(),
                    compact: true,
                  ),
                  const SizedBox(height: 24),
                  _CompactFeedSection(
                    title: '最近热门',
                    subtitle: '最近最常被直接使用的精选。',
                    resources: data.featuredResources.take(4).toList(),
                    compact: true,
                  ),
                  const SizedBox(height: 24),
                  if (data.favoritePreview.isNotEmpty)
                    _CompactFeedSection(
                      title: '最近收藏',
                      subtitle: '你最近收藏过的资源。',
                      resources: data.favoritePreview,
                      compact: true,
                    ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _ResourceBrowseTab extends ConsumerStatefulWidget {
  const _ResourceBrowseTab({required this.type});

  final ResourceType type;

  @override
  ConsumerState<_ResourceBrowseTab> createState() => _ResourceBrowseTabState();
}

class _ResourceBrowseTabState extends ConsumerState<_ResourceBrowseTab> {
  final TextEditingController _queryController = TextEditingController();
  late final CommittedSearchController _searchController;

  ProviderSubscription<int>? _refreshSubscription;
  ResourceBrowseSnapshot? _browseSnapshot;
  Object? _error;
  ResourceCategory _selectedCategory = ResourceCategory.all;
  String _selectedTag = '';
  ResourceQualityTier? _selectedQualityTier;
  ResourceSortMode _selectedSortMode = ResourceSortMode.recommended;
  bool _favoritesOnly = false;
  bool _importedOnly = false;
  bool _isInitialLoading = true;
  bool _isSearching = false;
  ResourceBrowseFilter? _loadedFilter;
  int _requestSerial = 0;

  @override
  void initState() {
    super.initState();
    _searchController = CommittedSearchController(
      onCommit: (_) => _loadBrowseSnapshot(searching: true),
    );
    _refreshSubscription = ref.listenManual<int>(
      catalogRefreshTickProvider,
      (previous, next) =>
          _loadBrowseSnapshot(searching: _browseSnapshot != null),
    );
    _loadBrowseSnapshot();
  }

  @override
  void dispose() {
    _refreshSubscription?.close();
    _searchController.dispose();
    _queryController.dispose();
    super.dispose();
  }

  ResourceBrowseFilter get _currentFilter => ResourceBrowseFilter(
    type: widget.type,
    query: _searchController.committedQuery,
    category: _selectedCategory,
    tag: _selectedTag,
    qualityTier: _selectedQualityTier,
    sortMode: _selectedSortMode,
    favoritesOnly: _favoritesOnly,
    importedOnly: _importedOnly,
  );

  Future<void> _loadBrowseSnapshot({bool searching = false}) async {
    final requestSerial = ++_requestSerial;
    final filter = _currentFilter;
    if (mounted) {
      setState(() {
        _error = _browseSnapshot == null ? null : _error;
        if (_browseSnapshot == null) {
          _isInitialLoading = true;
        } else {
          _isSearching = searching;
        }
      });
    }

    try {
      final repository = await ref.read(workspaceRepositoryProvider.future);
      final snapshot = await repository.loadResourceBrowseSnapshot(filter);
      if (!mounted || requestSerial != _requestSerial) {
        return;
      }

      var needsReload = false;
      if (_selectedCategory != ResourceCategory.all &&
          !snapshot.availableCategories.contains(_selectedCategory)) {
        _selectedCategory = ResourceCategory.all;
        needsReload = true;
      }
      if (_selectedTag.isNotEmpty &&
          !snapshot.availableTags.contains(_selectedTag)) {
        _selectedTag = '';
        needsReload = true;
      }
      if (_selectedQualityTier != null &&
          !snapshot.availableQualityTiers.contains(_selectedQualityTier)) {
        _selectedQualityTier = null;
        needsReload = true;
      }

      setState(() {
        _browseSnapshot = snapshot;
        _loadedFilter = filter;
        _error = null;
        _isInitialLoading = false;
        _isSearching = false;
      });

      if (needsReload) {
        unawaited(_loadBrowseSnapshot(searching: true));
      }
    } catch (error) {
      if (!mounted || requestSerial != _requestSerial) {
        return;
      }
      setState(() {
        _error = error;
        _isInitialLoading = false;
        _isSearching = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final browse = _browseSnapshot;
    if (browse == null) {
      if (_isInitialLoading) {
        return const _BrowseLoadingState();
      }
      return Center(child: Text('资源加载失败：$_error'));
    }

    final filter = _currentFilter;
    final featuredItems = browse.resources
        .where((item) => item.isFeatured)
        .take(3)
        .toList();
    final showInlineLoading = _isSearching && _loadedFilter != filter;

    return RefreshIndicator(
      onRefresh: () => invalidateCatalog(ref),
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 120),
        children: [
          AiReveal(
            index: 0,
            child: AiSectionHeader(
              data: AiPageHeaderData(
                eyebrow: _typeMentalModel(widget.type),
                title: widget.type.displayName,
                subtitle: _typePageSubtitle(widget.type),
              ),
              large: true,
            ),
          ),
          const SizedBox(height: 16),
          AiReveal(
            index: 1,
            child: AiSurfaceCard(
              variant: AiCardVariant.accent,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '先看用途，再决定怎么用',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(widget.type.beginnerGuide),
                  const SizedBox(height: 12),
                  Text(_beginnerExamples(widget.type)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          AiReveal(
            index: 2,
            child: AiCommandBar(
              controller: _queryController,
              state: showInlineLoading
                  ? AiLoadingState.loading
                  : AiLoadingState.idle,
              hintText: '搜名称、场景、标签或平台',
              compactHintText: '搜名称或标签',
              semanticsLabel: '${widget.type.label}搜索框',
              onValueChanged: _searchController.handleValueChanged,
              onSubmitted: _searchController.submit,
            ),
          ),
          const SizedBox(height: 16),
          _QualityTierStrip(
            available: browse.availableQualityTiers,
            selected: _selectedQualityTier,
            onSelected: (tier) {
              if (tier == _selectedQualityTier) {
                return;
              }
              setState(() {
                _selectedQualityTier = tier;
                _selectedTag = '';
              });
              unawaited(_loadBrowseSnapshot(searching: true));
            },
          ),
          const SizedBox(height: 12),
          _CategoryFilterStrip(
            categories: browse.availableCategories,
            selectedCategory: _selectedCategory,
            onSelected: (category) {
              if (category == _selectedCategory) {
                return;
              }
              setState(() {
                _selectedCategory = category;
                _selectedTag = '';
              });
              unawaited(_loadBrowseSnapshot(searching: true));
            },
          ),
          const SizedBox(height: 12),
          _SortModeStrip(
            modes: _sortModesForType(widget.type),
            selected: _selectedSortMode,
            onSelected: (mode) {
              if (mode == _selectedSortMode) {
                return;
              }
              setState(() => _selectedSortMode = mode);
              unawaited(_loadBrowseSnapshot(searching: true));
            },
          ),
          if (browse.availableTags.isNotEmpty) ...[
            const SizedBox(height: 12),
            _TagFilterStrip(
              tags: browse.availableTags,
              selectedTag: _selectedTag,
              onSelected: (tag) {
                if (tag == _selectedTag) {
                  return;
                }
                setState(() => _selectedTag = tag);
                unawaited(_loadBrowseSnapshot(searching: true));
              },
            ),
          ],
          const SizedBox(height: 12),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              FilterChip(
                label: const Text('只看收藏'),
                selected: _favoritesOnly,
                materialTapTargetSize: MaterialTapTargetSize.padded,
                onSelected: (value) {
                  setState(() => _favoritesOnly = value);
                  unawaited(_loadBrowseSnapshot(searching: true));
                },
              ),
              FilterChip(
                label: const Text('只看我导入的'),
                selected: _importedOnly,
                materialTapTargetSize: MaterialTapTargetSize.padded,
                onSelected: (value) {
                  setState(() => _importedOnly = value);
                  unawaited(_loadBrowseSnapshot(searching: true));
                },
              ),
            ],
          ),
          if (filter.query.isEmpty && featuredItems.isNotEmpty) ...[
            const SizedBox(height: 20),
            AiSectionHeader(
              data: AiPageHeaderData(
                eyebrow: '精选资源',
                title: '先看这些更容易上手',
                subtitle: _typeFeaturedSubtitle(widget.type),
              ),
            ),
            const SizedBox(height: 14),
            ...featuredItems.asMap().entries.map(
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
          const SizedBox(height: 20),
          AiSectionHeader(
            data: AiPageHeaderData(
              eyebrow: '全部资源',
              title: '按场景筛，再按标签收窄',
              subtitle: '先选大类，再挑更贴近任务的标签，最后再决定是否收藏或导入自己的版本。',
            ),
            trailing: showInlineLoading
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : null,
          ),
          const SizedBox(height: 14),
          if (showInlineLoading)
            const _InlineResourceLoading()
          else if (browse.resources.isEmpty)
            AiEmptyState(
              icon: Icons.layers_clear_rounded,
              title: '没找到合适的',
              description: '换个更具体的任务词试试，或者去“我的”里导入你自己的${widget.type.label}资源。',
            )
          else
            ...browse.resources.asMap().entries.map(
              (entry) => Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: AiReveal(
                  index: entry.key + 6,
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
      ),
    );
  }
}

class _MyLibraryTab extends ConsumerWidget {
  const _MyLibraryTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final snapshot = ref.watch(myLibraryProvider);
    return snapshot.when(
      data: (data) {
        return RefreshIndicator(
          onRefresh: () => invalidateCatalog(ref),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 120),
            children: [
              const AiReveal(
                index: 0,
                child: AiSectionHeader(
                  data: AiPageHeaderData(
                    eyebrow: '我的资源',
                    title: '把常用资源收拢成你自己的库',
                    subtitle: '官方资源先收藏，自己的模板再补进来，后面查找和复用都会更省事。',
                  ),
                  large: true,
                ),
              ),
              const SizedBox(height: 18),
              AiReveal(
                index: 1,
                child: AiSurfaceCard(
                  variant: AiCardVariant.accent,
                  child: Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      AiMetricPill(
                        label: '收藏',
                        value: '${data.favorites.length}',
                      ),
                      AiMetricPill(
                        label: '导入',
                        value: '${data.importedResources.length}',
                      ),
                      FilledButton.tonalIcon(
                        onPressed: () => context.go('/import'),
                        icon: const Icon(Icons.add_rounded),
                        label: const Text('导入资源'),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              _CompactFeedSection(
                title: '我的收藏',
                subtitle: '真正会反复用到的资源先收起来。',
                resources: data.favorites,
                emptyState: const AiEmptyState(
                  icon: Icons.bookmark_border_rounded,
                  title: '你还没有收藏资源',
                  description: '看到合适的提示词、技能或 MCP 后，点一下书签就会出现在这里。',
                ),
                compact: true,
              ),
              const SizedBox(height: 24),
              _CompactFeedSection(
                title: '我的导入',
                subtitle: '把你常用的模板、方法说明和工具配置都放到这里。',
                resources: data.importedResources,
                emptyState: const AiEmptyState(
                  icon: Icons.playlist_add_rounded,
                  title: '你还没有导入资源',
                  description: '建议先从一条最常用的提示词开始，后面再补自己的技能和 MCP 模板。',
                ),
                compact: true,
              ),
            ],
          ),
        );
      },
      loading: () => const _BrowseLoadingState(),
      error: (error, stackTrace) => Center(child: Text('我的资源加载失败：$error')),
    );
  }
}

class _HeroPanel extends StatelessWidget {
  const _HeroPanel({
    required this.controller,
    required this.searchState,
    required this.importedCount,
    required this.officialResourceCount,
    required this.collectionCount,
    required this.catalogSyncState,
    required this.onOpenStarter,
    required this.onOpenPrompt,
    required this.onImport,
    required this.onValueChanged,
    required this.onSubmitted,
  });

  final TextEditingController controller;
  final AiLoadingState searchState;
  final int importedCount;
  final int officialResourceCount;
  final int collectionCount;
  final CatalogSyncState catalogSyncState;
  final VoidCallback onOpenStarter;
  final VoidCallback onOpenPrompt;
  final VoidCallback onImport;
  final ValueChanged<TextEditingValue> onValueChanged;
  final ValueChanged<String> onSubmitted;

  @override
  Widget build(BuildContext context) {
    final wide = MediaQuery.sizeOf(context).width >= 920;
    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 10,
          runSpacing: 10,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: const [
            BrandBadge(),
            AiStatusPill(label: '资源总览', tone: AiStatusTone.accent),
          ],
        ),
        const SizedBox(height: 16),
        const AiSectionHeader(
          data: AiPageHeaderData(
            title: '常用提示词、技能和工具配置，统一收在这里',
            subtitle: '想找现成模板，先按场景看；知道要什么，直接搜关键词。合适的先收藏，之后再补自己的版本。',
          ),
          large: true,
        ),
        const SizedBox(height: 18),
        AiCommandBar(
          controller: controller,
          state: searchState,
          hintText: '搜任务、场景或平台，例如：代码审查、周报、简历、GitHub',
          compactHintText: '搜任务或平台，例如：代码审查、GitHub',
          semanticsLabel: '首页资源搜索框',
          onValueChanged: onValueChanged,
          onSubmitted: onSubmitted,
        ),
        const SizedBox(height: 18),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            AiMetricPill(label: '官方资源', value: '$officialResourceCount'),
            AiMetricPill(label: '精选合集', value: '$collectionCount'),
            AiMetricPill(label: '我的导入', value: '$importedCount'),
            AiStatusPill(
              label: catalogSyncState.isRemote ? '目录已连接服务' : '目录使用离线缓存',
              tone: catalogSyncState.isRemote
                  ? AiStatusTone.success
                  : AiStatusTone.warning,
            ),
          ],
        ),
        const SizedBox(height: 18),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            FilledButton.icon(
              onPressed: onOpenStarter,
              icon: const Icon(Icons.rocket_launch_rounded),
              label: const Text('先看新手入门'),
            ),
            OutlinedButton.icon(
              onPressed: onOpenPrompt,
              icon: const Icon(Icons.auto_awesome_rounded),
              label: const Text('先找一条提示词'),
            ),
            OutlinedButton.icon(
              onPressed: onImport,
              icon: const Icon(Icons.add_circle_outline_rounded),
              label: const Text('导入我的资源'),
            ),
          ],
        ),
      ],
    );

    return AiSurfaceCard(
      variant: AiCardVariant.accent,
      padding: const EdgeInsets.all(22),
      child: wide
          ? Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(flex: 7, child: content),
                const SizedBox(width: 20),
                const Expanded(
                  flex: 5,
                  child: Align(
                    alignment: Alignment.topRight,
                    child: HeroArtwork(height: 300),
                  ),
                ),
              ],
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                content,
                const SizedBox(height: 18),
                const Center(child: HeroArtwork(height: 200)),
              ],
            ),
    );
  }
}

class _ConceptGrid extends StatelessWidget {
  const _ConceptGrid({required this.types});

  final List<ResourceType> types;

  @override
  Widget build(BuildContext context) {
    final wide = MediaQuery.sizeOf(context).width >= 760;
    if (!wide) {
      return Column(
        children: types.asMap().entries.map((entry) {
          return Padding(
            padding: EdgeInsets.only(
              bottom: entry.key == types.length - 1 ? 0 : 12,
            ),
            child: AiReveal(
              index: entry.key + 2,
              child: _ConceptCard(type: entry.value),
            ),
          );
        }).toList(),
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: types.asMap().entries.map((entry) {
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(
              right: entry.key == types.length - 1 ? 0 : 12,
            ),
            child: AiReveal(
              index: entry.key + 2,
              child: _ConceptCard(type: entry.value),
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _ConceptCard extends StatelessWidget {
  const _ConceptCard({required this.type});

  final ResourceType type;

  @override
  Widget build(BuildContext context) {
    return AiSurfaceCard(
      variant: AiCardVariant.subdued,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(22),
            child: ResourceTypeArtwork(type: type, height: 108),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: _typeColor(type).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(14),
                ),
                alignment: Alignment.center,
                child: Icon(_typeIcon(type), color: _typeColor(type)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  type.displayName,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(type.shortDescription),
          const SizedBox(height: 10),
          Text(type.beginnerGuide),
          const SizedBox(height: 12),
          Text(
            _beginnerExamples(type),
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}

class _CategoryFilterStrip extends StatelessWidget {
  const _CategoryFilterStrip({
    required this.categories,
    required this.selectedCategory,
    required this.onSelected,
  });

  final List<ResourceCategory> categories;
  final ResourceCategory selectedCategory;
  final ValueChanged<ResourceCategory> onSelected;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        separatorBuilder: (context, index) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final category = categories[index];
          return Semantics(
            button: true,
            selected: category == selectedCategory,
            label: category.label,
            child: ChoiceChip(
              label: Text(category.label),
              selected: category == selectedCategory,
              showCheckmark: false,
              materialTapTargetSize: MaterialTapTargetSize.padded,
              onSelected: (_) => onSelected(category),
            ),
          );
        },
      ),
    );
  }
}

class _TagFilterStrip extends StatelessWidget {
  const _TagFilterStrip({
    required this.tags,
    required this.selectedTag,
    required this.onSelected,
  });

  final List<String> tags;
  final String selectedTag;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    final values = ['全部标签', ...tags];
    return SizedBox(
      height: 48,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: values.length,
        separatorBuilder: (context, index) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final label = values[index];
          final resolvedTag = label == '全部标签' ? '' : label;
          return Semantics(
            button: true,
            selected: resolvedTag == selectedTag,
            label: label,
            child: ChoiceChip(
              label: Text(label),
              selected: resolvedTag == selectedTag,
              showCheckmark: false,
              materialTapTargetSize: MaterialTapTargetSize.padded,
              onSelected: (_) => onSelected(resolvedTag),
            ),
          );
        },
      ),
    );
  }
}

class _QualityTierStrip extends StatelessWidget {
  const _QualityTierStrip({
    required this.available,
    required this.selected,
    required this.onSelected,
  });

  final List<ResourceQualityTier> available;
  final ResourceQualityTier? selected;
  final ValueChanged<ResourceQualityTier?> onSelected;

  @override
  Widget build(BuildContext context) {
    final values = <ResourceQualityTier?>[null, ...available];
    return SizedBox(
      height: 48,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: values.length,
        separatorBuilder: (context, index) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final tier = values[index];
          final label = tier?.label ?? '全部质量';
          return Semantics(
            button: true,
            selected: tier == selected,
            label: label,
            child: ChoiceChip(
              label: Text(label),
              selected: tier == selected,
              showCheckmark: false,
              materialTapTargetSize: MaterialTapTargetSize.padded,
              onSelected: (_) => onSelected(tier),
            ),
          );
        },
      ),
    );
  }
}

class _SortModeStrip extends StatelessWidget {
  const _SortModeStrip({
    required this.modes,
    required this.selected,
    required this.onSelected,
  });

  final List<ResourceSortMode> modes;
  final ResourceSortMode selected;
  final ValueChanged<ResourceSortMode> onSelected;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: modes.length,
        separatorBuilder: (context, index) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final mode = modes[index];
          return Semantics(
            button: true,
            selected: mode == selected,
            label: mode.label,
            child: ChoiceChip(
              label: Text(mode.label),
              selected: mode == selected,
              showCheckmark: false,
              materialTapTargetSize: MaterialTapTargetSize.padded,
              onSelected: (_) => onSelected(mode),
            ),
          );
        },
      ),
    );
  }
}

class _InlineResourceLoading extends StatelessWidget {
  const _InlineResourceLoading();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: const [
        AiSkeletonBlock(height: 148),
        SizedBox(height: 12),
        AiSkeletonBlock(height: 148),
        SizedBox(height: 12),
        AiSkeletonBlock(height: 148),
      ],
    );
  }
}

class _CollectionStrip extends StatelessWidget {
  const _CollectionStrip({required this.collections});

  final List<ResourceCollection> collections;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 210,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: collections.length,
        separatorBuilder: (_, index) => const SizedBox(width: 14),
        itemBuilder: (context, index) {
          final collection = collections[index];
          return SizedBox(
            width: 290,
            child: AiReveal(
              index: index + 3,
              child: AiSurfaceCard(
                onTap: () => context.go('/collection/${collection.id}'),
                semanticsLabel: '${collection.title}合集',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: _collectionColor(
                              collection.iconKey,
                            ).withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          alignment: Alignment.center,
                          child: Icon(
                            _collectionIcon(collection.iconKey),
                            color: _collectionColor(collection.iconKey),
                          ),
                        ),
                        const Spacer(),
                        AiMetricPill(
                          label: '条资源',
                          value: '${collection.resourceCount}',
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    Text(
                      collection.title,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    Text(collection.subtitle),
                    const SizedBox(height: 10),
                    Text(
                      collection.description,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _CompactFeedSection extends ConsumerWidget {
  const _CompactFeedSection({
    required this.title,
    required this.subtitle,
    required this.resources,
    this.emptyState,
    this.compact = false,
  });

  final String title;
  final String subtitle;
  final List<CatalogResource> resources;
  final Widget? emptyState;
  final bool compact;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AiSectionHeader(
          data: AiPageHeaderData(
            eyebrow: '资源块',
            title: title,
            subtitle: subtitle,
          ),
        ),
        const SizedBox(height: 14),
        if (resources.isEmpty)
          emptyState ??
              const AiEmptyState(
                icon: Icons.inbox_outlined,
                title: '还没有内容',
                description: '稍后再来看看这里。',
              )
        else
          ...resources.asMap().entries.map(
            (entry) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: ResourceCard(
                resource: entry.value,
                compact: compact,
                onTap: () => openCatalogResource(context, entry.value),
                onFavoriteToggle: () =>
                    toggleFavoriteAction(context, ref, entry.value.id),
              ),
            ),
          ),
      ],
    );
  }
}

class _PreviewSection extends ConsumerWidget {
  const _PreviewSection({
    required this.title,
    required this.subtitle,
    required this.resources,
  });

  final String title;
  final String subtitle;
  final List<CatalogResource> resources;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AiSectionHeader(
          data: AiPageHeaderData(
            eyebrow: '精选内容',
            title: title,
            subtitle: subtitle,
          ),
        ),
        const SizedBox(height: 14),
        ...resources.asMap().entries.map(
          (entry) => Padding(
            padding: const EdgeInsets.only(bottom: 14),
            child: AiReveal(
              index: entry.key + 1,
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
  }
}

class _HomeLoadingState extends StatelessWidget {
  const _HomeLoadingState();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 120),
      children: [
        AiSurfaceCard(
          variant: AiCardVariant.accent,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              AiSkeletonBlock(height: 28, width: 140),
              SizedBox(height: 18),
              AiSkeletonBlock(height: 40),
              SizedBox(height: 12),
              AiSkeletonBlock(height: 16),
              SizedBox(height: 22),
              AiSkeletonBlock(height: 56),
            ],
          ),
        ),
        const SizedBox(height: 22),
        const AiSkeletonBlock(height: 22, width: 210),
        const SizedBox(height: 14),
        const AiSkeletonBlock(height: 156),
        const SizedBox(height: 16),
        const AiSkeletonBlock(height: 156),
      ],
    );
  }
}

class _BrowseLoadingState extends StatelessWidget {
  const _BrowseLoadingState();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 120),
      children: const [
        AiSkeletonBlock(height: 34, width: 220),
        SizedBox(height: 12),
        AiSkeletonBlock(height: 16),
        SizedBox(height: 18),
        AiSkeletonBlock(height: 150),
        SizedBox(height: 16),
        AiSkeletonBlock(height: 56),
        SizedBox(height: 16),
        AiSkeletonBlock(height: 160),
        SizedBox(height: 12),
        AiSkeletonBlock(height: 160),
      ],
    );
  }
}

String _typeMentalModel(ResourceType type) {
  return switch (type) {
    ResourceType.prompt => '马上复制使用',
    ResourceType.skill => '接进工作流复用',
    ResourceType.mcp => '连接外部工具与数据',
  };
}

String _typePageSubtitle(ResourceType type) {
  return switch (type) {
    ResourceType.prompt => '适合马上复制使用。先选场景，再填几个关键信息。',
    ResourceType.skill => '把常做的事整理成固定方法，后面同类任务直接复用。',
    ResourceType.mcp => '给 AI 接上 GitHub、文档、数据库这类外部工具。先从你已经在用的平台开始。',
  };
}

List<ResourceSortMode> _sortModesForType(ResourceType type) {
  if (type == ResourceType.prompt) {
    return const [
      ResourceSortMode.recommended,
      ResourceSortMode.easiestToUse,
      ResourceSortMode.recentlyUsed,
    ];
  }
  return const [ResourceSortMode.recommended, ResourceSortMode.easiestToUse];
}

String _typeFeaturedSubtitle(ResourceType type) {
  return switch (type) {
    ResourceType.prompt => '先从变量少、结果直观的模板开始。',
    ResourceType.skill => '先从输入清楚、步骤明确的技能开始。',
    ResourceType.mcp => '先连你已经在用的平台，别一口气配太多。',
  };
}

String _beginnerExamples(ResourceType type) {
  return switch (type) {
    ResourceType.prompt => '从代码审查、会议纪要、周报、简历优化这类任务开始，最容易立刻看到效果。',
    ResourceType.skill => '如果你经常重复做同一种任务，可以先看会议纪要结构化、提示词评分器、GitHub 工作流这类技能。',
    ResourceType.mcp => '先从 GitHub、文档、数据库这类已经在用的平台接入，再决定要不要扩展到云平台或浏览器。',
  };
}

IconData _typeIcon(ResourceType type) {
  return switch (type) {
    ResourceType.prompt => Icons.auto_awesome_rounded,
    ResourceType.skill => Icons.bolt_rounded,
    ResourceType.mcp => Icons.hub_rounded,
  };
}

Color _typeColor(ResourceType type) {
  return switch (type) {
    ResourceType.prompt => const Color(0xFF6366F1),
    ResourceType.skill => const Color(0xFF10B981),
    ResourceType.mcp => const Color(0xFFF59E0B),
  };
}

IconData _collectionIcon(String key) {
  return switch (key) {
    'rocket' => Icons.rocket_launch_rounded,
    'terminal' => Icons.terminal_rounded,
    'sparkles' => Icons.auto_awesome_rounded,
    'briefcase' => Icons.work_outline_rounded,
    'target' => Icons.track_changes_rounded,
    'hub' => Icons.hub_rounded,
    'shield' => Icons.security_rounded,
    'graph' => Icons.insights_rounded,
    _ => Icons.folder_open_rounded,
  };
}

Color _collectionColor(String key) {
  return switch (key) {
    'rocket' => const Color(0xFF6366F1),
    'terminal' => const Color(0xFF334155),
    'sparkles' => const Color(0xFF8B5CF6),
    'briefcase' => const Color(0xFF0F766E),
    'target' => const Color(0xFF2563EB),
    'hub' => const Color(0xFFF59E0B),
    'shield' => const Color(0xFF10B981),
    'graph' => const Color(0xFFEA580C),
    _ => const Color(0xFF64748B),
  };
}
