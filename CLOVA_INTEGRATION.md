# Clova OCR + Gemini 2.0 Flash 프론트엔드 연동 가이드

## 개요

Flutter 앱에서 Clova OCR과 Gemini 2.0 Flash를 통해 스케줄 이미지를 업로드하고 자동으로 일정을 등록하는 방법입니다.

## API 사용법

### 1. 이미지 업로드 및 AI OCR 처리

```dart
import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:convert';

class OcrService {
  static const String baseUrl = 'https://your-backend-url.com';
  
  static Future<Map<String, dynamic>> uploadScheduleImage({
    required File imageFile,
    required String userUid,
    String? displayName,
    bool useGemini = true, // Gemini 2.0 Flash 사용 여부
  }) async {
    try {
      // multipart 요청 생성
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/ocr/schedule'),
      );
      
      // 파일 추가
      request.files.add(
        await http.MultipartFile.fromPath(
          'photo',
          imageFile.path,
        ),
      );
      
      // 폼 데이터 추가
      request.fields['user_uid'] = userUid;
      if (displayName != null) {
        request.fields['display_name'] = displayName;
      }
      request.fields['use_gemini'] = useGemini.toString();
      
      // 요청 전송
      var response = await request.send();
      var responseData = await response.stream.bytesToString();
      var jsonData = json.decode(responseData);
      
      if (response.statusCode == 201) {
        return {
          'success': true,
          'data': jsonData,
        };
      } else {
        return {
          'success': false,
          'error': jsonData['error'] ?? '알 수 없는 오류',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': '네트워크 오류: $e',
      };
    }
  }
  
  // Gemini 전용 OCR 처리
  static Future<Map<String, dynamic>> uploadWithGemini({
    required File imageFile,
    required String userUid,
    String? displayName,
  }) async {
    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/ocr/schedule/gemini'),
      );
      
      request.files.add(
        await http.MultipartFile.fromPath('photo', imageFile.path),
      );
      
      request.fields['user_uid'] = userUid;
      if (displayName != null) {
        request.fields['display_name'] = displayName;
      }
      
      var response = await request.send();
      var responseData = await response.stream.bytesToString();
      var jsonData = json.decode(responseData);
      
      if (response.statusCode == 201) {
        return {'success': true, 'data': jsonData};
      } else {
        return {'success': false, 'error': jsonData['error'] ?? '오류'};
      }
    } catch (e) {
      return {'success': false, 'error': '네트워크 오류: $e'};
    }
  }
  
  // 기존 방식 OCR 처리
  static Future<Map<String, dynamic>> uploadTraditional({
    required File imageFile,
    required String userUid,
    String? displayName,
  }) async {
    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/ocr/schedule/traditional'),
      );
      
      request.files.add(
        await http.MultipartFile.fromPath('photo', imageFile.path),
      );
      
      request.fields['user_uid'] = userUid;
      if (displayName != null) {
        request.fields['display_name'] = displayName;
      }
      
      var response = await request.send();
      var responseData = await response.stream.bytesToString();
      var jsonData = json.decode(responseData);
      
      if (response.statusCode == 201) {
        return {'success': true, 'data': jsonData};
      } else {
        return {'success': false, 'error': jsonData['error'] ?? '오류'};
      }
    } catch (e) {
      return {'success': false, 'error': '네트워크 오류: $e'};
    }
  }
}
```

### 2. OCR 서비스 상태 확인

```dart
static Future<Map<String, dynamic>> checkOcrHealth() async {
  try {
    var response = await http.get(
      Uri.parse('$baseUrl/ocr/health'),
    );
    
    if (response.statusCode == 200) {
      var data = json.decode(response.body);
      return {
        'success': true,
        'data': data,
        'isHealthy': data['status'] == 'healthy',
        'clovaConnected': data['clova'] == 'connected',
        'geminiConfigured': data['gemini'] == 'configured',
      };
    } else {
      return {
        'success': false,
        'error': '서비스 상태 확인 실패',
      };
    }
  } catch (e) {
    return {
      'success': false,
      'error': '네트워크 오류: $e',
    };
  }
}
```

## Flutter 위젯 예시

### AI OCR 선택 위젯

```dart
import 'package:image_picker/image_picker.dart';

class ScheduleUploadWidget extends StatefulWidget {
  final String userUid;
  final String? displayName;
  
  const ScheduleUploadWidget({
    Key? key,
    required this.userUid,
    this.displayName,
  }) : super(key: key);

  @override
  _ScheduleUploadWidgetState createState() => _ScheduleUploadWidgetState();
}

class _ScheduleUploadWidgetState extends State<ScheduleUploadWidget> {
  File? _selectedImage;
  bool _isUploading = false;
  bool _useGemini = true; // 기본값: Gemini 사용
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1920,
      maxHeight: 1080,
      imageQuality: 85,
    );
    
    if (image != null) {
      setState(() {
        _selectedImage = File(image.path);
      });
    }
  }

  Future<void> _uploadImage() async {
    if (_selectedImage == null) return;

    setState(() {
      _isUploading = true;
    });

    try {
      Map<String, dynamic> result;
      
      if (_useGemini) {
        result = await OcrService.uploadWithGemini(
          imageFile: _selectedImage!,
          userUid: widget.userUid,
          displayName: widget.displayName,
        );
      } else {
        result = await OcrService.uploadTraditional(
          imageFile: _selectedImage!,
          userUid: widget.userUid,
          displayName: widget.displayName,
        );
      }

      if (result['success']) {
        final data = result['data'];
        final method = data['analysis_method'] ?? 'unknown';
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${data['inserted']}개의 일정이 등록되었습니다! (${method})'),
            backgroundColor: Colors.green,
          ),
        );
        
        // 성공 후 이미지 초기화
        setState(() {
          _selectedImage = null;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('오류: ${result['error']}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('업로드 중 오류가 발생했습니다: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isUploading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // AI 분석 방식 선택
        Card(
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'AI 분석 방식 선택',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: RadioListTile<bool>(
                        title: Text('🤖 Gemini 2.0 Flash'),
                        subtitle: Text('더 정확한 분석'),
                        value: true,
                        groupValue: _useGemini,
                        onChanged: (value) {
                          setState(() {
                            _useGemini = value!;
                          });
                        },
                      ),
                    ),
                    Expanded(
                      child: RadioListTile<bool>(
                        title: Text('📊 기존 방식'),
                        subtitle: Text('빠른 처리'),
                        value: false,
                        groupValue: _useGemini,
                        onChanged: (value) {
                          setState(() {
                            _useGemini = value!;
                          });
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        
        SizedBox(height: 16),
        
        // 이미지 선택 버튼
        ElevatedButton.icon(
          onPressed: _isUploading ? null : _pickImage,
          icon: Icon(Icons.photo_library),
          label: Text('스케줄 이미지 선택'),
        ),
        
        SizedBox(height: 16),
        
        // 선택된 이미지 미리보기
        if (_selectedImage != null) ...[
          Container(
            height: 200,
            width: double.infinity,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(8),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.file(
                _selectedImage!,
                fit: BoxFit.cover,
              ),
            ),
          ),
          
          SizedBox(height: 16),
          
          // 업로드 버튼
          ElevatedButton.icon(
            onPressed: _isUploading ? null : _uploadImage,
            icon: _isUploading 
              ? SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Icon(_useGemini ? Icons.psychology : Icons.analytics),
            label: Text(_isUploading 
              ? '처리 중...' 
              : '${_useGemini ? 'Gemini' : '기존 방식'}으로 분석 및 업로드'
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: _useGemini ? Colors.blue : Colors.orange,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ],
    );
  }
}
```

## 사용 시 주의사항

1. **이미지 품질**: 명확하고 선명한 이미지를 사용하세요
2. **파일 크기**: 너무 큰 이미지는 업로드 시간이 오래 걸릴 수 있습니다
3. **네트워크**: 안정적인 인터넷 연결이 필요합니다
4. **권한**: 갤러리 접근 권한이 필요합니다
5. **API 키**: Gemini 2.0 Flash 사용 시 Google AI Studio API 키가 필요합니다

## 에러 처리

- **400**: 필수 파라미터 누락
- **500**: 서버 내부 오류
- **503**: OCR 서비스 연결 실패

## 테스트

개발 중에는 다음 명령어로 OCR 서비스 상태를 확인할 수 있습니다:

```bash
# 서비스 상태 확인
curl https://your-backend-url.com/ocr/health

# Gemini OCR 테스트
curl -X POST https://your-backend-url.com/ocr/schedule/gemini \
  -F "photo=@schedule.jpg" \
  -F "user_uid=test_user" \
  -F "display_name=김지성"

# 기존 방식 OCR 테스트
curl -X POST https://your-backend-url.com/ocr/schedule/traditional \
  -F "photo=@schedule.jpg" \
  -F "user_uid=test_user" \
  -F "display_name=김지성"
``` 