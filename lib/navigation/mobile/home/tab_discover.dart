import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quiet/extension.dart';

import '../../../providers/navigator_provider.dart';
import '../../../providers/personalized_playlist_provider.dart';
import '../../common/navigation_target.dart';
import '../../common/playlist/music_list.dart';
import '../../common/recommended_playlist_tile.dart';

class HomeTabDiscover extends StatelessWidget {
  const HomeTabDiscover({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 20),
        _Title(title: Text(context.strings.recommendPlayLists)),
        const _Playlists(),
        _Header("热门好歌", () {}),
        _SectionNewSongs(),
      ],
    );
  }
}

class _Title extends StatelessWidget {
  const _Title({
    Key? key,
    required this.title,
    this.subtitle,
  }) : super(key: key);

  final Widget title;
  final Widget? subtitle;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 8,
      ),
      child: Column(
        children: [
          DefaultTextStyle(
            style: context.textTheme.headline6!,
            child: title,
          ),
          if (subtitle != null) subtitle!,
        ],
      ),
    );
  }
}

class _Playlists extends ConsumerWidget {
  const _Playlists({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final playlists = ref.watch(homePlaylistProvider);
    return SizedBox(
      height: 200,
      child: playlists.when(
        data: (playlists) => ListView.builder(
          itemCount: playlists.length,
          scrollDirection: Axis.horizontal,
          itemBuilder: (context, index) {
            final playlist = playlists[index];
            print(playlist.id);
            return RecommendedPlaylistTile(
              width: 160,
              imageSize: 120,
              playlist: playlist,
              onTap: () => ref
                  .read(navigatorProvider.notifier)
                  .navigate(NavigationTarget.playlist(playlistId: playlist.id)),
            );
          },
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stacktrace) => Center(
          child: Text(context.formattedError(error)),
        ),
      ),
    );
  }
}

///common header for section
class _Header extends StatelessWidget {
  const _Header(this.text, this.onTap);

  final String text;
  final GestureTapCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 10, bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Padding(padding: EdgeInsets.only(left: 8)),
          Text(
            text,
            style: Theme.of(context)
                .textTheme
                .subtitle1!
                .copyWith(fontWeight: FontWeight.w800),
          ),
          const Icon(Icons.chevron_right),
        ],
      ),
    );
  }
}

class _SectionNewSongs extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final snapshot = ref.watch(personalizedNewSongProvider.logErrorOnDebug());
    return snapshot.when(
      data: (songs) {
        return MusicTileConfiguration(
          musics: songs,
          token: 'playlist_main_newsong',
          onMusicTap: MusicTileConfiguration.defaultOnTap,
          leadingBuilder: MusicTileConfiguration.indexedLeadingBuilder,
          trailingBuilder: MusicTileConfiguration.defaultTrailingBuilder,
          child: Column(
            children: songs.map((m) => MusicTile(m)).toList(),
          ),
        );
      },
      error: (error, stacktrace) {
        return SizedBox(
          height: 200,
          child: Center(
            child: Text(context.formattedError(error)),
          ),
        );
      },
      loading: () => const SizedBox(
        height: 200,
        child: Center(
          child: SizedBox.square(
            dimension: 24,
            child: CircularProgressIndicator(),
          ),
        ),
      ),
    );
  }
}
