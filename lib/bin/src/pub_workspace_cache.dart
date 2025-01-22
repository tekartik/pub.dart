enum PubWorkspaceCacheAction { get, upgrade, downgrade }

/// Last action done on a workspace, invalide others.
class PubWorkspaceCache {
  final String workspaceRoot;
  final bool offline;
  final PubWorkspaceCacheAction action;

  PubWorkspaceCache(this.workspaceRoot, this.action, this.offline);

  @override
  int get hashCode => workspaceRoot.hashCode;

  @override
  bool operator ==(Object other) {
    if (other is PubWorkspaceCache) {
      return workspaceRoot == other.workspaceRoot &&
          offline == other.offline &&
          action == other.action;
    }
    return false;
  }
}

/// Workspace cache
abstract class PubWorkspacesCache {
  factory PubWorkspacesCache() => _PubWorkspacesCache();

  /// Returns true if the cache was updated (i.e. must run, next call will return false)
  bool cacheIfNeeded(PubWorkspaceCache cache);
  PubWorkspaceCache? getWorkspaceCache(String workspaceRoot);
}

class _PubWorkspacesCache implements PubWorkspacesCache {
  final _map = <String, PubWorkspaceCache>{};

  _PubWorkspacesCache();

  @override
  PubWorkspaceCache? getWorkspaceCache(String workspaceRoot) {
    return _map[workspaceRoot];
  }

  @override
  bool cacheIfNeeded(PubWorkspaceCache cache) {
    var existing = _map[cache.workspaceRoot];
    if (existing != cache) {
      _map[cache.workspaceRoot] = cache;
      return true;
    }
    return false;
  }
}

PubWorkspacesCache? pubWorkspacesCache;

/// Internal only use for run_ci binary for now
void initPubWorkspacesCache() {
  pubWorkspacesCache = PubWorkspacesCache();
}
