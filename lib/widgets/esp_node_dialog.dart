import 'package:flutter/material.dart';
import '../models/esp_node_model.dart';
import '../services/esp_service.dart';
import '../theme/app_theme.dart';

/// Dialog untuk mengelola daftar ESP32 nodes (tambah / edit / hapus).
class EspNodeDialog extends StatefulWidget {
  const EspNodeDialog({super.key});

  static Future<void> show(BuildContext context) async {
    await showDialog(
      context: context,
      builder: (_) => const EspNodeDialog(),
    );
  }

  @override
  State<EspNodeDialog> createState() => _EspNodeDialogState();
}

class _EspNodeDialogState extends State<EspNodeDialog> {
  bool _showForm = false;
  EspNodeModel? _editingNode;

  late TextEditingController _nameCtrl;
  late TextEditingController _ipCtrl;
  String _selectedType = 'sensor';

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController();
    _ipCtrl = TextEditingController();
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _ipCtrl.dispose();
    super.dispose();
  }

  void _resetForm() {
    _nameCtrl.clear();
    _ipCtrl.clear();
    _selectedType = 'sensor';
    _editingNode = null;
    _showForm = false;
  }

  void _startAdd() {
    _resetForm();
    setState(() => _showForm = true);
  }

  void _startEdit(EspNodeModel node) {
    _nameCtrl.text = node.name;
    _ipCtrl.text = node.ip;
    _selectedType = node.type;
    _editingNode = node;
    setState(() => _showForm = true);
  }

  void _saveNode() {
    final name = _nameCtrl.text.trim();
    final ip = _ipCtrl.text.trim();
    if (name.isEmpty || ip.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nama dan IP harus diisi')),
      );
      return;
    }

    final service = EspService.instance;
    if (_editingNode != null) {
      service.updateNode(_editingNode!.copyWith(name: name, ip: ip, type: _selectedType));
    } else {
      final id = 'esp-${DateTime.now().millisecondsSinceEpoch}';
      service.addNode(EspNodeModel(id: id, name: name, ip: ip, type: _selectedType));
    }

    _resetForm();
    setState(() {});
  }

  void _deleteNode(EspNodeModel node) {
    EspService.instance.removeNode(node.id);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final nodes = EspService.instance.nodes;
    final selectedId = EspService.instance.selectedNodeId;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      backgroundColor: AppColors.surfaceContainerLowest,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [Color(0xFF0F172A), AppColors.primary],
                ),
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: const Color(0xFF34D399).withValues(alpha: 0.20),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color(0xFF34D399).withValues(alpha: 0.40)),
                    ),
                    child: const Icon(Icons.memory_rounded, color: Color(0xFF34D399), size: 20),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _showForm
                              ? (_editingNode != null ? 'Edit ESP32' : 'Tambah ESP32')
                              : 'Kelola ESP32 Nodes',
                          style: AppTextStyles.labelLg(color: Colors.white)
                              .copyWith(fontWeight: FontWeight.w800),
                        ),
                        Text(
                          _showForm
                              ? 'Isi nama dan IP perangkat'
                              : '${nodes.length} perangkat terdaftar',
                          style: const TextStyle(color: Color(0xFFB3D9FF), fontSize: 10),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close_rounded, color: Colors.white, size: 20),
                  ),
                ],
              ),
            ),

            // Content
            Flexible(
              child: _showForm ? _buildForm() : _buildNodeList(nodes, selectedId),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNodeList(List<EspNodeModel> nodes, String? selectedId) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Flexible(
          child: nodes.isEmpty
              ? const Padding(
                  padding: EdgeInsets.all(32),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.sensor_occupied_rounded, size: 48, color: AppColors.outline),
                      SizedBox(height: 12),
                      Text('Belum ada ESP32',
                          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                      SizedBox(height: 4),
                      Text('Tekan tombol + untuk menambahkan',
                          style: TextStyle(fontSize: 12, color: AppColors.outline)),
                    ],
                  ),
                )
              : ListView.separated(
                  shrinkWrap: true,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  itemCount: nodes.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 8),
                  itemBuilder: (ctx, i) {
                    final node = nodes[i];
                    final isSelected = node.id == selectedId;
                    return GestureDetector(
                      onTap: () {
                        EspService.instance.selectNode(node.id);
                        Navigator.pop(ctx);
                      },
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColors.primaryContainer.withValues(alpha: 0.30)
                              : const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: isSelected ? AppColors.primary : const Color(0xFFE2E8F0),
                            width: isSelected ? 1.5 : 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 38,
                              height: 38,
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? AppColors.primary.withValues(alpha: 0.15)
                                    : const Color(0xFFF1F5F9),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Icon(
                                node.type == 'camera'
                                    ? Icons.videocam_rounded
                                    : Icons.sensors_rounded,
                                size: 20,
                                color: isSelected ? AppColors.primary : AppColors.onSurfaceVariant,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    node.name,
                                    style: TextStyle(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 13,
                                      color: isSelected ? AppColors.primary : AppColors.onSurface,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    node.ip,
                                    style: const TextStyle(
                                      fontFamily: 'monospace',
                                      fontSize: 11,
                                      color: AppColors.onSurfaceVariant,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (isSelected)
                              const Icon(Icons.check_circle_rounded, size: 18, color: AppColors.primary),
                            const SizedBox(width: 4),
                            PopupMenuButton<String>(
                              onSelected: (val) {
                                if (val == 'edit') _startEdit(node);
                                if (val == 'delete') _deleteNode(node);
                              },
                              iconSize: 18,
                              itemBuilder: (_) => const [
                                PopupMenuItem(value: 'edit', child: Text('Edit')),
                                PopupMenuItem(value: 'delete', child: Text('Hapus')),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ),
        // Tombol Tambah
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: _startAdd,
              icon: const Icon(Icons.add_rounded, size: 18),
              label: const Text('Tambah ESP32'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primary,
                side: const BorderSide(color: AppColors.primary),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildForm() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Nama
          TextField(
            controller: _nameCtrl,
            decoration: InputDecoration(
              isDense: true,
              labelText: 'Nama Perangkat',
              hintText: 'Contoh: Sensor Bedeng Barat',
              prefixIcon: const Icon(Icons.label_rounded, size: 18),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            ),
          ),
          const SizedBox(height: 12),

          // IP
          TextField(
            controller: _ipCtrl,
            style: const TextStyle(fontFamily: 'monospace', fontSize: 13, fontWeight: FontWeight.w700),
            decoration: InputDecoration(
              isDense: true,
              labelText: 'IP ESP32',
              hintText: 'Contoh: 192.168.1.50',
              helperText: 'IP di jaringan WiFi (lihat Serial Monitor)',
              prefixIcon: const Icon(Icons.sensors_rounded, size: 18),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            ),
          ),
          const SizedBox(height: 12),

          // Tipe
          Row(
            children: [
              Expanded(
                child: _buildTypeChip('sensor', 'Sensor Node', Icons.sensors_rounded),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildTypeChip('camera', 'Kamera Node', Icons.videocam_rounded),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Tombol Simpan & Batal
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: _resetForm,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.onSurfaceVariant,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: const Text('Batal'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _saveNode,
                  icon: const Icon(Icons.check_rounded, size: 16),
                  label: Text(_editingNode != null ? 'Simpan' : 'Tambah'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.onPrimary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTypeChip(String value, String label, IconData icon) {
    final isActive = _selectedType == value;
    return GestureDetector(
      onTap: () => setState(() => _selectedType = value),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: isActive ? AppColors.primary.withValues(alpha: 0.12) : const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isActive ? AppColors.primary : const Color(0xFFE2E8F0),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 16, color: isActive ? AppColors.primary : AppColors.outline),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 12,
                color: isActive ? AppColors.primary : AppColors.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
