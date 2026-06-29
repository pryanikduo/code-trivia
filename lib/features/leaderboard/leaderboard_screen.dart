import 'package:flutter/material.dart';
import 'package:code_trivia/core/supabase.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class LeaderboardScreen extends StatefulWidget {
  const LeaderboardScreen ({super.key});

  @override
  State<StatefulWidget> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen> {
  List<Map<String, dynamic>> _users = [];
  bool _isLoading = true;
  String _errorMessage = '';

  late final RealtimeChannel _leaderboardChannel;

@override
void initState() {
  super.initState();
  _loadLeaderboard();
  _subscribeToLeaderboard();
}

void _subscribeToLeaderboard() {
  _leaderboardChannel = supabase.channel('public:profiles');
  _leaderboardChannel.onPostgresChanges(
    event: PostgresChangeEvent.update,
    schema: 'public',
    table: 'profiles',
    callback: (payload) {
      _loadLeaderboard(); // перезагрузить при изменении любого профиля
    },
  ).subscribe();
}

  Future<void> _loadLeaderboard() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final response = await supabase
          .from('profiles')
          .select('id, username, total_score, streak, avatar_url')
          .order('total_score', ascending: false) 
          .limit(100); 

      setState(() {
        _users = List<Map<String, dynamic>>.from(response);
        _isLoading = false;
      });
      print('Response: $response');
    } catch (e) {
      setState(() {
        _errorMessage = 'Ошибка загрузки: $e';
        _isLoading = false;
      });
    }
    
  }

  @override
  void dispose() {
    _leaderboardChannel.unsubscribe();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Лидерборд'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage.isNotEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(_errorMessage, style: const TextStyle(color: Colors.red)),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _loadLeaderboard,
                    child: const Text('Повторить'),
                  ),
                ],
              ),
            )
          : _users.isEmpty
              ? const Center(child: Text('Нет данных'))
              : ListView.builder(
                  itemCount: _users.length,
                  itemBuilder: (context, index) {
                    final user = _users[index];
                    final rank = index + 1;
                    final isTop3 = rank <= 3;
                    
                    return _buildLeaderboardTile(
                      rank: rank,
                      username: user['username'] ?? 'Аноним',
                      totalScore: user['total_score'] ?? 0,
                      streak: user['streak'] ?? 0,
                      avatarUrl: user['avatar_url'],
                      isTop3: isTop3,
                    );
                  },
                ),
    );
  }

  Widget _buildLeaderboardTile({
    required int rank,
    required String username,
    required int totalScore,
    required int streak,
    String? avatarUrl,
    required bool isTop3,
  }) {
    Color? rankColor;
    IconData? medalIcon;
    double fontSize = 18;
    if (rank == 1) {
      rankColor = Colors.amber;
      medalIcon = Icons.emoji_events;
      fontSize = 24;
    } else if (rank == 2) {
      rankColor = Colors.grey[400];
      medalIcon = Icons.emoji_events;
      fontSize = 22;
    } else if (rank == 3) {
      rankColor = Colors.brown[300];
      medalIcon = Icons.emoji_events;
      fontSize = 20;
    }

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      elevation: isTop3 ? 4 : 1,
      child: ListTile(
        leading: Container(
          width: 50,
          alignment: Alignment.center,
          child: medalIcon != null
              ? Icon(medalIcon, color: rankColor, size: 32)
              : Text(
                  '$rank',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[600],
                  ),
                ),
        ),
        title: Row(
          children: [
            CircleAvatar(
              radius: 20,
              backgroundImage: avatarUrl != null ? NetworkImage(avatarUrl) : null,
              child: avatarUrl == null
                  ? const Icon(Icons.person, size: 20)
                  : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                username,
                style: TextStyle(
                  fontWeight: isTop3 ? FontWeight.bold : FontWeight.normal,
                  fontSize: 16,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(left: 52), 
          child: Text(
            'Очки: $totalScore • Дней: $streak',
            style: TextStyle(color: Colors.grey[600]),
          ),
        ),
        trailing: isTop3
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '$totalScore',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: rankColor,
                    ),
                  ),
                  const Text('очков', style: TextStyle(fontSize: 10)),
                ],
              )
            : Text(
                '$totalScore',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
      ),
    );
  }
}
