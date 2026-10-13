import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_theme.dart';
import '../../core/utils/formatters.dart';
import '../../shared/dialogs.dart';
import '../../shared/widgets/empty_state.dart';
import 'download_item.dart';
import 'downloads_controller.dart';

class DownloadsScreen extends ConsumerWidget {
  const DownloadsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final items = ref.watch(downloadsProvider);
    final controller = ref.read(downloadsProvider.notifier);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Downloads'),
        actions: [
          if (items.any((d) => !d.isActive))
            IconButton(
              tooltip: 'Clear finished',
              onPressed: () async {
                if (await confirm(
                  context,
                  title: 'Clear finished downloads?',
                  message: 'Files stay on your device.',
                  confirmLabel: 'Clear',
                )) {
                  await controller.clearFinished();
                }
              },
              icon: const Icon(Icons.clear_all_rounded),
            ),
        ],
      ),
      body: items.isEmpty
          ? const EmptyState(
              icon: Icons.download_rounded,
              title: 'No downloads',
              message: 'Files you download appear here.',
            )
          : ListView.separated(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: items.length,
              separatorBuilder: (_, _) => const Divider(indent: 20, endIndent: 20),
              itemBuilder: (context, i) => _DownloadTile(item: items[i]),
            ),
    );
  }
}

class _DownloadTile extends ConsumerWidget {
  const _DownloadTile({required this.item});

  final DownloadItem item;

  IconData get _icon {
    final mime = item.mimeType ?? '';
    final name = item.fileName.toLowerCase();
    if (mime.startsWith('image/')) return Icons.image_outlined;
    if (mime.startsWith('video/')) return Icons.movie_outlined;
    if (mime.startsWith('audio/')) return Icons.audiotrack_outlined;
    if (mime == 'application/pdf' || name.endsWith('.pdf')) return Icons.picture_as_pdf_outlined;
    if (name.endsWith('.zip') || name.endsWith('.rar') || name.endsWith('.7z')) return Icons.folder_zip_outlined;
    return Icons.insert_drive_file_outlined;
  }

  String _statusText() {
    final size = item.totalBytes > 0 ? Formatters.bytes(item.totalBytes) : null;
    return switch (item.status) {
      DownloadStatus.queued => 'Waiting…',
      DownloadStatus.running => [
        item.totalBytes > 0
            ? '${Formatters.bytes(item.receivedBytes)} of ${Formatters.bytes(item.totalBytes)}'
            : Formatters.bytes(item.receivedBytes),
        if (item.bytesPerSecond > 0) Formatters.speed(item.bytesPerSecond),
        if (item.fraction != null) '${(item.fraction! * 100).floor()}%',
      ].join(' · '),
      DownloadStatus.paused => 'Paused by the system (waiting for network)',
      DownloadStatus.completed => [
        size ?? Formatters.bytes(item.receivedBytes),
        if (item.completedAt != null) Formatters.dateTime(item.completedAt!, DateTime.now()),
      ].join(' · '),
      DownloadStatus.failed => item.error ?? 'Failed',
      DownloadStatus.canceled => 'Canceled',
    };
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final palette = context.palette;
    final controller = ref.read(downloadsProvider.notifier);
    final failed = item.status == DownloadStatus.failed;
    return ListTile(
      contentPadding: const EdgeInsets.fromLTRB(20, 6, 8, 6),
      leading: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: item.status == DownloadStatus.completed ? palette.accent : palette.surface,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(_icon, color: item.status == DownloadStatus.completed ? palette.onAccent : null),
      ),
      title: Text(
        item.fileName,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (item.isActive) ...[
            const SizedBox(height: 6),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: item.status == DownloadStatus.queued ? null : item.fraction,
                minHeight: 4,
              ),
            ),
          ],
          const SizedBox(height: 4),
          Text(
            _statusText(),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(color: failed ? Theme.of(context).colorScheme.error : palette.textSecondary, fontSize: 13),
          ),
          if (item.incognito) Text('Private tab', style: TextStyle(color: palette.textSecondary, fontSize: 12)),
        ],
      ),
      onTap: item.status == DownloadStatus.completed
          ? () async {
              if (!await controller.open(item.id) && context.mounted) {
                showMessage(context, 'No app can open this file');
              }
            }
          : null,
      trailing: item.isActive
          ? IconButton(
              tooltip: 'Cancel',
              onPressed: () => controller.cancel(item.id),
              icon: const Icon(Icons.close_rounded),
            )
          : PopupMenuButton<String>(
              tooltip: 'More',
              onSelected: (action) async {
                switch (action) {
                  case 'open':
                    if (!await controller.open(item.id) && context.mounted) {
                      showMessage(context, 'No app can open this file');
                    }
                  case 'share':
                    await controller.share(item.id);
                  case 'save':
                    final ok = await controller.saveCopy(item.id);
                    if (ok && context.mounted) showMessage(context, 'Saved');
                  case 'retry':
                    await controller.retry(item.id);
                  case 'remove':
                    await controller.remove(item.id);
                  case 'delete':
                    if (await confirm(
                      context,
                      title: 'Delete file?',
                      message: item.fileName,
                      confirmLabel: 'Delete',
                      destructive: true,
                    )) {
                      await controller.remove(item.id, deleteFile: true);
                    }
                }
              },
              itemBuilder: (_) => [
                if (item.status == DownloadStatus.completed) ...[
                  const PopupMenuItem(value: 'open', child: Text('Open')),
                  const PopupMenuItem(value: 'share', child: Text('Share')),
                  const PopupMenuItem(value: 'save', child: Text('Save a copy to…')),
                ],
                if (item.status == DownloadStatus.failed || item.status == DownloadStatus.canceled)
                  const PopupMenuItem(value: 'retry', child: Text('Retry')),
                const PopupMenuItem(value: 'remove', child: Text('Remove from list')),
                if (item.status == DownloadStatus.completed)
                  const PopupMenuItem(value: 'delete', child: Text('Delete file')),
              ],
            ),
    );
  }
}
