import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class StatusIndicator extends StatelessWidget {
  final bool isListening;
  final bool isSyncing;
  final ConnectivityResult connectivity;

  const StatusIndicator({
    super.key,
    required this.isListening,
    required this.isSyncing,
    required this.connectivity,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildIndicator(
          icon: Icons.mic,
          color: isListening ? Colors.red : Colors.grey,
          tooltip: isListening ? 'Listening...' : 'Not listening',
        ),
        const SizedBox(width: 8),
        _buildIndicator(
          icon: Icons.sync,
          color: isSyncing ? Colors.blue : Colors.grey,
          tooltip: isSyncing ? 'Syncing...' : 'Not syncing',
        ),
        const SizedBox(width: 8),
        _buildIndicator(
          icon: _getConnectivityIcon(),
          color: _getConnectivityColor(),
          tooltip: _getConnectivityTooltip(),
        ),
      ],
    );
  }

  Widget _buildIndicator({
    required IconData icon,
    required Color color,
    required String tooltip,
  }) {
    return Tooltip(message: tooltip, child: Icon(icon, color: color, size: 20));
  }

  IconData _getConnectivityIcon() {
    switch (connectivity) {
      case ConnectivityResult.wifi:
        return Icons.wifi;
      case ConnectivityResult.mobile:
        return Icons.cell_tower;
      case ConnectivityResult.ethernet:
        return Icons.lan;
      case ConnectivityResult.bluetooth:
        return Icons.bluetooth;
      case ConnectivityResult.none:
        return Icons.cloud_off;
      default:
        return Icons.help_outline;
    }
  }

  Color _getConnectivityColor() {
    switch (connectivity) {
      case ConnectivityResult.wifi:
      case ConnectivityResult.mobile:
      case ConnectivityResult.ethernet:
        return Colors.green;
      case ConnectivityResult.bluetooth:
        return Colors.blue;
      case ConnectivityResult.none:
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _getConnectivityTooltip() {
    switch (connectivity) {
      case ConnectivityResult.wifi:
        return 'Connected to WiFi';
      case ConnectivityResult.mobile:
        return 'Connected to Mobile Data';
      case ConnectivityResult.ethernet:
        return 'Connected to Ethernet';
      case ConnectivityResult.bluetooth:
        return 'Connected via Bluetooth';
      case ConnectivityResult.none:
        return 'No Internet Connection';
      default:
        return 'Unknown Connection';
    }
  }
}
