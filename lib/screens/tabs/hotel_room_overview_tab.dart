import 'package:flutter/material.dart';
import 'dart:math' as math;

class HotelRoomOverviewTab extends StatefulWidget {
  const HotelRoomOverviewTab({Key? key}) : super(key: key);

  @override
  State<HotelRoomOverviewTab> createState() => _HotelRoomOverviewTabState();
}

class _HotelRoomOverviewTabState extends State<HotelRoomOverviewTab> {
  int? _selectedFloor;
  String? _selectedRoom;
  String _filterStatus = 'All';
  String _filterSortBy = 'Room Number';

  // Sample hotel data
  final List<FloorData> _floors = [
    FloorData(
      floorNumber: 5,
      rooms: List.generate(40, (i) => RoomData(
        roomNumber: 500 + i,
        price: 180 + (i % 3) * 20,
        status: _getRandomStatus(),
        lastActivity: _getRandomActivity(),
        checkInTime: _getRandomCheckInTime(),
        checkOutTime: _getRandomCheckOutTime(),
      )),
    ),
    FloorData(
      floorNumber: 4,
      rooms: List.generate(40, (i) => RoomData(
        roomNumber: 400 + i,
        price: 160 + (i % 3) * 20,
        status: _getRandomStatus(),
        lastActivity: _getRandomActivity(),
        checkInTime: _getRandomCheckInTime(),
        checkOutTime: _getRandomCheckOutTime(),
      )),
    ),
    FloorData(
      floorNumber: 3,
      rooms: List.generate(40, (i) => RoomData(
        roomNumber: 300 + i,
        price: 140 + (i % 3) * 20,
        status: _getRandomStatus(),
        lastActivity: _getRandomActivity(),
        checkInTime: _getRandomCheckInTime(),
        checkOutTime: _getRandomCheckOutTime(),
      )),
    ),
    FloorData(
      floorNumber: 2,
      rooms: List.generate(40, (i) => RoomData(
        roomNumber: 200 + i,
        price: 120 + (i % 3) * 20,
        status: _getRandomStatus(),
        lastActivity: _getRandomActivity(),
        checkInTime: _getRandomCheckInTime(),
        checkOutTime: _getRandomCheckOutTime(),
      )),
    ),
    FloorData(
      floorNumber: 1,
      rooms: List.generate(40, (i) => RoomData(
        roomNumber: 100 + i,
        price: 100 + (i % 3) * 20,
        status: _getRandomStatus(),
        lastActivity: _getRandomActivity(),
        checkInTime: _getRandomCheckInTime(),
        checkOutTime: _getRandomCheckOutTime(),
      )),
    ),
  ];

  static RoomStatus _getRandomStatus() {
    final rand = math.Random();
    final values = RoomStatus.values;
    return values[rand.nextInt(values.length)];
  }

  static String _getRandomActivity() {
    final activities = [
      'Check-in completed',
      'Check-out completed',
      'Room cleaned',
      'Maintenance requested',
      'Guest requested towels',
      'Room service delivered',
      'Housekeeping in progress',
      'Maintenance completed',
    ];
    return activities[math.Random().nextInt(activities.length)];
  }

  static DateTime? _getRandomCheckInTime() {
    final rand = math.Random();
    if (rand.nextBool()) {
      return DateTime.now().subtract(Duration(hours: rand.nextInt(48)));
    }
    return null;
  }

  static DateTime? _getRandomCheckOutTime() {
    final rand = math.Random();
    if (rand.nextBool()) {
      return DateTime.now().add(Duration(hours: rand.nextInt(48)));
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                'Hotel Room Overview',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const Spacer(),
              _buildFilters(),
            ],
          ),
          const SizedBox(height: 24),
          
          if (_selectedFloor == null) ...[
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    _buildBuildingVisualization(),
                  ],
                ),
              ),
            ),
          ] else ...[
            Row(
              children: [
                IconButton(
                  onPressed: () => setState(() => _selectedFloor = null),
                  icon: const Icon(Icons.arrow_back),
                  tooltip: 'Back to Building View',
                ),
                Text(
                  'Floor $_selectedFloor',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: _buildFloorView(_selectedFloor!),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildFilters() {
    return Row(
      children: [
        // Status Filter
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[300]!),
            borderRadius: BorderRadius.circular(8),
          ),
          child: DropdownButton<String>(
            value: _filterStatus,
            underline: const SizedBox(),
            items: ['All', 'Available', 'Occupied', 'Reserved', 'Out of Service']
                .map((status) => DropdownMenuItem(value: status, child: Text(status)))
                .toList(),
            onChanged: (value) {
              if (value != null) {
                setState(() => _filterStatus = value);
              }
            },
          ),
        ),
        const SizedBox(width: 12),
        // Sort Filter
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[300]!),
            borderRadius: BorderRadius.circular(8),
          ),
          child: DropdownButton<String>(
            value: _filterSortBy,
            underline: const SizedBox(),
            items: ['Room Number', 'Price', 'Status']
                .map((sort) => DropdownMenuItem(value: sort, child: Text(sort)))
                .toList(),
            onChanged: (value) {
              if (value != null) {
                setState(() => _filterSortBy = value);
              }
            },
          ),
        ),
      ],
    );
  }

  Widget _buildBuildingVisualization() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Building Overview',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                // Building visualization
                Expanded(
                  flex: 2,
                  child: Container(
                    height: 400,
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey[300]!),
                    ),
                    child: Column(
                      children: List.generate(_floors.length, (index) {
                        final floor = _floors[index];
                        final stats = _getFloorStats(floor);
                        
                        return Expanded(
                          child: GestureDetector(
                            onTap: () => setState(() => _selectedFloor = floor.floorNumber),
                            child: Container(
                              margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.grey[300]!),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Row(
                                children: [
                                  // Floor number
                                  Container(
                                    width: 60,
                                    alignment: Alignment.center,
                                    child: Text(
                                      'Floor ${floor.floorNumber}',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                  const VerticalDivider(width: 1),
                                  // Room stats
                                  Expanded(
                                    child: Padding(
                                      padding: const EdgeInsets.all(12),
                                      child: Row(
                                        children: [
                                          _buildStatItem('Total', stats.total, Colors.grey[600]!),
                                          _buildStatItem('Available', stats.available, Colors.green),
                                          _buildStatItem('Occupied', stats.occupied, Colors.orange),
                                          _buildStatItem('Reserved', stats.reserved, Colors.blue),
                                          _buildStatItem('Out of Service', stats.outOfService, Colors.red),
                                        ],
                                      ),
                                    ),
                                  ),
                                  const Icon(Icons.arrow_forward_ios, size: 16),
                                ],
                              ),
                            ),
                          ),
                        );
                      }),
                    ),
                  ),
                ),
                const SizedBox(width: 24),
                // Summary stats
                Expanded(
                  child: _buildSummaryStats(),
                ),
              ],
            ),
            const SizedBox(height: 24),
            // Room Status Legend at the bottom
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[200]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Room Status Legend',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 16,
                    runSpacing: 8,
                    children: RoomStatus.values.map((status) {
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: Colors.grey[300]!),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 14,
                              height: 14,
                              decoration: BoxDecoration(
                                color: _getRoomStatusColor(status),
                                borderRadius: BorderRadius.circular(3),
                                border: Border.all(color: _getRoomStatusColor(status).withOpacity(0.3)),
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              status.name,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: _getRoomTextColor(status),
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, int count, Color color) {
    return Expanded(
      child: Column(
        children: [
          Text(
            count.toString(),
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryStats() {
    final totalRooms = _floors.fold(0, (sum, floor) => sum + floor.rooms.length);
    final totalStats = _getTotalStats();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Hotel Summary',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        _buildSummaryCard('Total Rooms', totalRooms.toString(), Icons.hotel, Colors.blue),
        const SizedBox(height: 8),
        _buildSummaryCard('Available', totalStats.available.toString(), Icons.check_circle, Colors.green),
        const SizedBox(height: 8),
        _buildSummaryCard('Occupied', totalStats.occupied.toString(), Icons.person, Colors.orange),
        const SizedBox(height: 8),
        _buildSummaryCard('Reserved', totalStats.reserved.toString(), Icons.bookmark, Colors.blue),
        const SizedBox(height: 8),
        _buildSummaryCard('Out of Service', totalStats.outOfService.toString(), Icons.warning, Colors.red),
        const SizedBox(height: 16),
        _buildOccupancyRate(totalStats.available, totalRooms),
      ],
    );
  }

  Widget _buildSummaryCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOccupancyRate(int available, int total) {
    final occupancyRate = ((total - available) / total * 100).toStringAsFixed(1);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.blue[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Occupancy Rate',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            '$occupancyRate%',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.blue[700],
            ),
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: (total - available) / total,
            backgroundColor: Colors.blue[100],
            valueColor: AlwaysStoppedAnimation<Color>(Colors.blue[700]!),
          ),
        ],
      ),
    );
  }

  Widget _buildFloorView(int floorNumber) {
    final floor = _floors.firstWhere((f) => f.floorNumber == floorNumber);
    final filteredRooms = _getFilteredRooms(floor.rooms);
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'Rooms ${floorNumber}00-${floorNumber}39',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                Text(
                  '${filteredRooms.length} rooms shown',
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 10,
                  childAspectRatio: 1.2,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                ),
                itemCount: filteredRooms.length,
                itemBuilder: (context, index) {
                  final room = filteredRooms[index];
                  return _buildRoomBox(room);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRoomBox(RoomData room) {
    final isSelected = _selectedRoom == room.roomNumber.toString();
    
    return GestureDetector(
      onTap: () => _showRoomDetails(room),
      child: Container(
        decoration: BoxDecoration(
          color: _getRoomStatusColor(room.status),
          borderRadius: BorderRadius.circular(8),
          border: isSelected 
              ? Border.all(color: Colors.blue, width: 2)
              : Border.all(color: Colors.grey[300]!),
          boxShadow: isSelected 
              ? [
                  BoxShadow(
                    color: Colors.blue.withOpacity(0.3),
                    blurRadius: 4,
                    spreadRadius: 1,
                  ),
                ]
              : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              room.roomNumber.toString(),
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: _getRoomTextColor(room.status),
              ),
            ),
            const SizedBox(height: 2),
            Text(
              '\$${room.price}',
              style: TextStyle(
                fontSize: 10,
                color: _getRoomTextColor(room.status),
              ),
            ),
            const SizedBox(height: 2),
            Icon(
              _getRoomStatusIcon(room.status),
              size: 12,
              color: _getRoomTextColor(room.status),
            ),
          ],
        ),
      ),
    );
  }



  void _showRoomDetails(RoomData room) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Room ${room.roomNumber}'),
        content: SizedBox(
          width: 400,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildRoomDetailRow('Status', room.status.name, _getRoomStatusColor(room.status)),
              _buildRoomDetailRow('Price', '\$${room.price}', Colors.green),
              if (room.checkInTime != null)
                _buildRoomDetailRow('Check-in', _formatDateTime(room.checkInTime!), Colors.blue),
              if (room.checkOutTime != null)
                _buildRoomDetailRow('Check-out', _formatDateTime(room.checkOutTime!), Colors.orange),
              const SizedBox(height: 16),
              const Text(
                'Recent Activity',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  room.lastActivity,
                  style: const TextStyle(fontSize: 12),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Actions',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: [
                  ElevatedButton.icon(
                    onPressed: () => _markAsCleaned(room),
                    icon: const Icon(Icons.cleaning_services, size: 16),
                    label: const Text('Mark Cleaned'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: () => _blockRoom(room),
                    icon: const Icon(Icons.block, size: 16),
                    label: const Text('Block Room'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: () => _reportIssue(room),
                    icon: const Icon(Icons.report_problem, size: 16),
                    label: const Text('Report Issue'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildRoomDetailRow(String label, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: color.withOpacity(0.3)),
            ),
            child: Text(
              value,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w500,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Helper methods
  FloorStats _getFloorStats(FloorData floor) {
    int available = 0, occupied = 0, reserved = 0, outOfService = 0;
    
    for (final room in floor.rooms) {
      switch (room.status) {
        case RoomStatus.available:
          available++;
          break;
        case RoomStatus.occupied:
          occupied++;
          break;
        case RoomStatus.reserved:
          reserved++;
          break;
        case RoomStatus.outOfService:
          outOfService++;
          break;
      }
    }
    
    return FloorStats(
      total: floor.rooms.length,
      available: available,
      occupied: occupied,
      reserved: reserved,
      outOfService: outOfService,
    );
  }

  TotalStats _getTotalStats() {
    int available = 0, occupied = 0, reserved = 0, outOfService = 0;
    
    for (final floor in _floors) {
      for (final room in floor.rooms) {
        switch (room.status) {
          case RoomStatus.available:
            available++;
            break;
          case RoomStatus.occupied:
            occupied++;
            break;
          case RoomStatus.reserved:
            reserved++;
            break;
          case RoomStatus.outOfService:
            outOfService++;
            break;
        }
      }
    }
    
    return TotalStats(
      available: available,
      occupied: occupied,
      reserved: reserved,
      outOfService: outOfService,
    );
  }

  List<RoomData> _getFilteredRooms(List<RoomData> rooms) {
    List<RoomData> filtered = rooms;
    
    // Apply status filter
    if (_filterStatus != 'All') {
      final status = RoomStatus.values.firstWhere(
        (s) => s.name.toLowerCase() == _filterStatus.toLowerCase(),
      );
      filtered = filtered.where((room) => room.status == status).toList();
    }
    
    // Apply sort
    switch (_filterSortBy) {
      case 'Room Number':
        filtered.sort((a, b) => a.roomNumber.compareTo(b.roomNumber));
        break;
      case 'Price':
        filtered.sort((a, b) => a.price.compareTo(b.price));
        break;
      case 'Status':
        filtered.sort((a, b) => a.status.name.compareTo(b.status.name));
        break;
    }
    
    return filtered;
  }

  Color _getRoomStatusColor(RoomStatus status) {
    switch (status) {
      case RoomStatus.available:
        return Colors.green[400]!; // More vibrant green
      case RoomStatus.occupied:
        return Colors.orange[400]!; // More vibrant orange
      case RoomStatus.reserved:
        return Colors.blue[400]!; // More vibrant blue
      case RoomStatus.outOfService:
        return Colors.red[400]!; // More vibrant red
    }
  }

  Color _getRoomTextColor(RoomStatus status) {
    switch (status) {
      case RoomStatus.available:
        return Colors.green[900]!; // Darker green for better contrast
      case RoomStatus.occupied:
        return Colors.orange[900]!; // Darker orange for better contrast
      case RoomStatus.reserved:
        return Colors.blue[900]!; // Darker blue for better contrast
      case RoomStatus.outOfService:
        return Colors.red[900]!; // Darker red for better contrast
    }
  }

  IconData _getRoomStatusIcon(RoomStatus status) {
    switch (status) {
      case RoomStatus.available:
        return Icons.check_circle;
      case RoomStatus.occupied:
        return Icons.person;
      case RoomStatus.reserved:
        return Icons.bookmark;
      case RoomStatus.outOfService:
        return Icons.warning;
    }
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.month}/${dateTime.day}/${dateTime.year}, ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  void _markAsCleaned(RoomData room) {
    // Implementation for marking room as cleaned
    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Room ${room.roomNumber} marked as cleaned')),
    );
  }

  void _blockRoom(RoomData room) {
    // Implementation for blocking room
    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Room ${room.roomNumber} has been blocked')),
    );
  }

  void _reportIssue(RoomData room) {
    // Implementation for reporting issue
    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Issue reported for Room ${room.roomNumber}')),
    );
  }
}

// Data classes
enum RoomStatus { available, occupied, reserved, outOfService }

class RoomData {
  final int roomNumber;
  final double price;
  final RoomStatus status;
  final String lastActivity;
  final DateTime? checkInTime;
  final DateTime? checkOutTime;

  RoomData({
    required this.roomNumber,
    required this.price,
    required this.status,
    required this.lastActivity,
    this.checkInTime,
    this.checkOutTime,
  });
}

class FloorData {
  final int floorNumber;
  final List<RoomData> rooms;

  FloorData({
    required this.floorNumber,
    required this.rooms,
  });
}

class FloorStats {
  final int total;
  final int available;
  final int occupied;
  final int reserved;
  final int outOfService;

  FloorStats({
    required this.total,
    required this.available,
    required this.occupied,
    required this.reserved,
    required this.outOfService,
  });
}

class TotalStats {
  final int available;
  final int occupied;
  final int reserved;
  final int outOfService;

  TotalStats({
    required this.available,
    required this.occupied,
    required this.reserved,
    required this.outOfService,
  });
} 