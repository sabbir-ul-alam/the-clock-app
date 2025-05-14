import 'package:flutter/material.dart';
import '../services/ringtone_picker_service.dart';
import 'package:flutter_ringtone_player/flutter_ringtone_player.dart';

class RingtonePickerModal extends StatefulWidget {
  final String? selectedUri;
  const RingtonePickerModal({Key? key, this.selectedUri}) : super(key: key);

  @override
  State<RingtonePickerModal> createState() => _RingtonePickerModalState();
}

class _RingtonePickerModalState extends State<RingtonePickerModal> {
  List<Map<String, String>> _ringtones = [];
  String? _selectedUri;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _fetchRingtones();

  }

  void _fetchRingtones() async {
    final tones = await RingtonePickerService.getSystemRingtones();
    setState(() {
      _ringtones = tones;
      _selectedUri = widget.selectedUri;
      _loading = false;
    });
  }

  void _playTone(String uri) {
    print("ToneURI ${uri}");
    FlutterRingtonePlayer().play(
      android: AndroidSounds.notification,
      volume: 0.0,
      asAlarm: true,
      looping: false, // important: don't loop
    );

    Future.delayed(Duration(milliseconds: 300), () {
      FlutterRingtonePlayer().play(
        fromFile: uri,
        ios: IosSounds.alarm,
        looping: true,
        volume: 1,
        asAlarm: true,
      );
    });
  }

  void _stopTone() {
    FlutterRingtonePlayer().stop();
  }

  void _confirmSelection() {
    final selected = _ringtones.firstWhere(
          (tone) => tone['uri'] == _selectedUri,
      orElse: () => {},
    );
    if (selected.containsKey('name') && selected.containsKey('uri')) {
      RingtonePickerService.saveLastSelectedTone(selected['name']!, selected['uri']!);
    }

    _stopTone();
    Navigator.pop(context, selected);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: _loading
          ? Center(child: CircularProgressIndicator())
          : Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text("Choose Alarm Tone",
                    style: TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold)),
              ),
              if (_selectedUri != null)
                TextButton(
                  onPressed: _confirmSelection,
                  child: Text("OK"),
                )
            ],
          ),
          Divider(),
          Expanded(
            child: ListView.builder(
              itemCount: _ringtones.length,
              itemBuilder: (context, index) {
                final tone = _ringtones[index];
                final isSelected = (_selectedUri == tone['uri']);
                return ListTile(
                  leading: Icon(Icons.music_note),
                  title: Text(tone['name'] ?? 'Unnamed'),
                  trailing: isSelected ? Icon(Icons.check, color: Colors.green) : null,
                  onTap: () {
                    _stopTone();
                    setState(() => _selectedUri = tone['uri']);
                    _playTone(tone['uri']!);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _stopTone();
    super.dispose();
  }
}
