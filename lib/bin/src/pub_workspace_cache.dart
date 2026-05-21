import 'package:path/path.dart';

/// Action performed on a workspace.
enum PubWorkspaceCacheAction {
  /// Pub get action.
  get,

  /// Pub upgrade action.
  upgrade,

  /// Pub downgrade action.
  downgrade,
}

/// Last action done on a workspace, invalidates others.
class PubWorkspaceCache {
  /// The root path of the workspace.
  final String workspaceRoot;

  /// Whether the command was run in offline mode.
  final bool offline;

  /// The action performed on the workspace.
  final PubWorkspaceCacheAction action;

  /// Constructor for PubWorkspaceCache.
  PubWorkspaceCache(String workspaceRoot, this.action, this.offline)
    : workspaceRoot = normalize(absolute(workspaceRoot));

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
  /// Factory constructor to create a workspace cache.
  factory PubWorkspacesCache() => _PubWorkspacesCache();

  /// Returns true if the cache was updated (i.e. must run, next call will return false)
  bool cacheIfNeeded(PubWorkspaceCache cache);

  /// Gets the workspace cache for the given root path.
  PubWorkspaceCache? getWorkspaceCache(String workspaceRoot);
}

class _PubWorkspacesCache implements PubWorkspacesCache {
  final _map = <String, PubWorkspaceCache>{};

  _PubWorkspacesCache();

  String _fixRoot(String root) {
    return normalize(absolute(root));
  }

  @override
  PubWorkspaceCache? getWorkspaceCache(String workspaceRoot) {
    return _map[_fixRoot(workspaceRoot)];
  }

  @override
  bool cacheIfNeeded(PubWorkspaceCache cache) {
    var root = _fixRoot(cache.workspaceRoot);
    var existing = _map[root];
    if (existing != cache) {
      _map[root] = cache;
      return true;
    }
    return false;
  }
}

/// Global instance of [PubWorkspacesCache].
PubWorkspacesCache? pubWorkspacesCache;

/// Internal only use for run_ci binary for now
void initPubWorkspacesCache() {
  pubWorkspacesCache = PubWorkspacesCache();
}
