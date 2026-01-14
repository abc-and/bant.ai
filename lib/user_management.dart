import 'package:flutter/material.dart';
import 'constants/app_colors.dart';

class UserManagement extends StatefulWidget {
  const UserManagement({super.key});

  @override
  State<UserManagement> createState() => _UserManagementState();
}

class _UserManagementState extends State<UserManagement> {
  final List<User> _users = [
    User(
      id: '1',
      name: 'Admin User',
      email: 'admin@mandaue.gov.ph',
      role: 'Administrator',
      roleColor: AppColors.error,
      permissions: ['Full Access'],
      lastActive: DateTime.now().subtract(const Duration(hours: 2)),
    ),
    User(
      id: '2',
      name: 'Traffic Officer 1',
      email: 'officer1@mandaue.gov.ph',
      role: 'Officer',
      roleColor: AppColors.primary,
      permissions: ['View Violations', 'Verify Violations'],
      lastActive: DateTime.now().subtract(const Duration(days: 1)),
    ),
    User(
      id: '3',
      name: 'Traffic Officer 2',
      email: 'officer2@mandaue.gov.ph',
      role: 'Officer',
      roleColor: AppColors.primary,
      permissions: ['View Violations', 'Verify Violations'],
      lastActive: DateTime.now().subtract(const Duration(days: 3)),
    ),
    User(
      id: '4',
      name: 'Compliance Manager',
      email: 'manager@mandaue.gov.ph',
      role: 'Manager',
      roleColor: AppColors.success,
      permissions: ['View Violations', 'Verify Violations', 'Generate Reports', 'Manage Users'],
      lastActive: DateTime.now().subtract(const Duration(hours: 5)),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          _buildHeader(),
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                _buildUsersList(),
                const SizedBox(height: 24),
                _buildAddUserSection(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.white,
        border: Border(bottom: BorderSide(color: AppColors.grey200)),
      ),
      child: Row(
        children: [
          Icon(Icons.people, color: AppColors.primary, size: 32),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'User Management',
                style: TextStyle(
                  color: AppColors.primaryDark,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'Manage system users and permissions',
                style: TextStyle(
                  color: AppColors.grey600,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const Spacer(),
          ElevatedButton.icon(
            onPressed: () {
              _showAddUserDialog();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            icon: const Icon(Icons.add, color: AppColors.white, size: 20),
            label: const Text('Add New User', style: TextStyle(color: AppColors.white, fontSize: 16)),
          ),
        ],
      ),
    );
  }

  Widget _buildUsersList() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.grey200),
        boxShadow: [
          BoxShadow(
            color: AppColors.grey400.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Icon(Icons.group, color: AppColors.primary, size: 24),
                const SizedBox(width: 12),
                Text(
                  'System Users',
                  style: TextStyle(
                    color: AppColors.primaryDark,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                Text(
                  '${_users.length} Users',
                  style: TextStyle(
                    color: AppColors.grey600,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          Divider(color: AppColors.grey200, height: 1),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                _buildUserTableHeader(),
                const SizedBox(height: 12),
                ..._users.map((user) => _buildUserRow(user)).toList(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserTableHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.grey50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.grey200),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              'USER',
              style: TextStyle(
                color: AppColors.primaryDark,
                fontSize: 12,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
            ),
          ),
          Expanded(
            child: Text(
              'ROLE',
              style: TextStyle(
                color: AppColors.primaryDark,
                fontSize: 12,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
            ),
          ),
          Expanded(
            child: Text(
              'LAST ACTIVE',
              style: TextStyle(
                color: AppColors.primaryDark,
                fontSize: 12,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
            ),
          ),
          SizedBox(
            width: 100,
            child: Text(
              'ACTIONS',
              style: TextStyle(
                color: AppColors.primaryDark,
                fontSize: 12,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserRow(User user) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.grey200),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(Icons.person, color: AppColors.white, size: 24),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user.name,
                        style: TextStyle(
                          color: AppColors.primaryDark,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        user.email,
                        style: TextStyle(
                          color: AppColors.grey600,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Wrap(
                        spacing: 4,
                        children: user.permissions
                            .map((permission) => Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: AppColors.grey50,
                                    borderRadius: BorderRadius.circular(4),
                                    border: Border.all(color: AppColors.grey200),
                                  ),
                                  child: Text(
                                    permission,
                                    style: TextStyle(
                                      color: AppColors.grey600,
                                      fontSize: 9,
                                    ),
                                  ),
                                ))
                            .toList(),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: user.roleColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(
                  user.role,
                  style: TextStyle(
                    color: user.roleColor,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _formatDate(user.lastActive),
                  style: TextStyle(
                    color: AppColors.grey600,
                    fontSize: 12,
                  ),
                ),
                Text(
                  _getTimeAgo(user.lastActive),
                  style: TextStyle(
                    color: AppColors.grey500,
                    fontSize: 10,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            width: 100,
            child: Row(
              children: [
                IconButton(
                  icon: Icon(Icons.edit, color: AppColors.primary, size: 18),
                  onPressed: () => _editUser(user),
                ),
                IconButton(
                  icon: Icon(Icons.delete, color: AppColors.error, size: 18),
                  onPressed: () => _deleteUser(user),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddUserSection() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.grey200),
        boxShadow: [
          BoxShadow(
            color: AppColors.grey400.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'User Roles & Permissions',
              style: TextStyle(
                color: AppColors.primaryDark,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Define user roles and their permissions in the system',
              style: TextStyle(
                color: AppColors.grey600,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: _buildRoleCard(
                    'Administrator',
                    'Full system access',
                    AppColors.error,
                    ['Full Access'],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildRoleCard(
                    'Manager',
                    'Manage violations and reports',
                    AppColors.success,
                    ['View Violations', 'Verify Violations', 'Generate Reports', 'Manage Users'],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildRoleCard(
                    'Officer',
                    'Monitor and verify violations',
                    AppColors.primary,
                    ['View Violations', 'Verify Violations'],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildRoleCard(
                    'Viewer',
                    'Read-only access',
                    AppColors.grey600,
                    ['View Violations'],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRoleCard(String role, String description, Color color, List<String> permissions) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.grey50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Icon(Icons.security, color: color, size: 18),
              ),
              const SizedBox(width: 8),
              Text(
                role,
                style: TextStyle(
                  color: color,
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            description,
            style: TextStyle(
              color: AppColors.grey600,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 12),
          ...permissions.map((permission) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  children: [
                    Icon(Icons.check_circle, color: color, size: 12),
                    const SizedBox(width: 6),
                    Text(
                      permission,
                      style: TextStyle(
                        color: AppColors.grey700,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }

  void _showAddUserDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add New User'),
        content: SizedBox(
          width: 400,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                decoration: const InputDecoration(
                  labelText: 'Full Name',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                decoration: const InputDecoration(
                  labelText: 'Email Address',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField(
                decoration: const InputDecoration(
                  labelText: 'Role',
                  border: OutlineInputBorder(),
                ),
                items: [
                  DropdownMenuItem(value: 'Administrator', child: Text('Administrator')),
                  DropdownMenuItem(value: 'Manager', child: Text('Manager')),
                  DropdownMenuItem(value: 'Officer', child: Text('Officer')),
                  DropdownMenuItem(value: 'Viewer', child: Text('Viewer')),
                ],
                onChanged: (value) {},
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('User added successfully'),
                  backgroundColor: AppColors.success,
                ),
              );
            },
            child: const Text('Add User'),
          ),
        ],
      ),
    );
  }

  void _editUser(User user) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit User'),
        content: SizedBox(
          width: 400,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                decoration: const InputDecoration(
                  labelText: 'Full Name',
                  border: OutlineInputBorder(),
                ),
                controller: TextEditingController(text: user.name),
              ),
              const SizedBox(height: 12),
              TextField(
                decoration: const InputDecoration(
                  labelText: 'Email Address',
                  border: OutlineInputBorder(),
                ),
                controller: TextEditingController(text: user.email),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField(
                decoration: const InputDecoration(
                  labelText: 'Role',
                  border: OutlineInputBorder(),
                ),
                value: user.role,
                items: [
                  DropdownMenuItem(value: 'Administrator', child: Text('Administrator')),
                  DropdownMenuItem(value: 'Manager', child: Text('Manager')),
                  DropdownMenuItem(value: 'Officer', child: Text('Officer')),
                  DropdownMenuItem(value: 'Viewer', child: Text('Viewer')),
                ],
                onChanged: (value) {},
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('User updated successfully'),
                  backgroundColor: AppColors.success,
                ),
              );
            },
            child: const Text('Save Changes'),
          ),
        ],
      ),
    );
  }

  void _deleteUser(User user) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.warning, color: AppColors.error),
            const SizedBox(width: 12),
            const Text('Delete User'),
          ],
        ),
        content: Text('Are you sure you want to delete ${user.name}? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _users.removeWhere((u) => u.id == user.id);
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('${user.name} has been removed'),
                  backgroundColor: AppColors.success,
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Delete', style: TextStyle(color: AppColors.white)),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.month}/${date.day}/${date.year}';
  }

  String _getTimeAgo(DateTime time) {
    final diff = DateTime.now().difference(time);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${(diff.inDays / 7).floor()}w ago';
  }
}

// User model
class User {
  final String id;
  final String name;
  final String email;
  final String role;
  final Color roleColor;
  final List<String> permissions;
  final DateTime lastActive;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    required this.roleColor,
    required this.permissions,
    required this.lastActive,
  });
}