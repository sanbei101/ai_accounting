import 'package:http/http.dart' as http;
import 'dart:convert';

const String apiKey = 'YOUR_DASHSCOPE_API_KEY';

class ChatMessage {
  final String role;
  final String content;

  ChatMessage({required this.role, required this.content});

  Map<String, Object> toJson() => {'role': role, 'content': content};

  factory ChatMessage.fromJson(Map<String, Object> json) {
    return ChatMessage(
      role: json['role'] as String,
      content: json['content'] as String,
    );
  }
}

class ChatRequest {
  final String model;
  final List<ChatMessage> messages;
  final bool enableThinking;

  ChatRequest({
    required this.model,
    required this.messages,
    this.enableThinking = false,
  });

  Map<String, Object> toJson() {
    final map = <String, Object>{
      'model': model,
      'messages': messages.map((m) => m.toJson()).toList(),
    };
    if (enableThinking) {
      map['enable_thinking'] = enableThinking;
    }
    return map;
  }
}

class ChatResponse {
  final String id;
  final String object;
  final int created;
  final String model;
  final List<ChatChoice> choices;
  final ChatUsage usage;

  ChatResponse({
    required this.id,
    required this.object,
    required this.created,
    required this.model,
    required this.choices,
    required this.usage,
  });

  factory ChatResponse.fromJson(Map<String, Object?> json) {
    return ChatResponse(
      id: json['id'] as String,
      object: json['object'] as String,
      created: json['created'] as int,
      model: json['model'] as String,
      choices: (json['choices'] as List<Object>)
          .map((e) => ChatChoice.fromJson(e as Map<String, Object>))
          .toList(),
      usage: ChatUsage.fromJson(json['usage'] as Map<String, Object>),
    );
  }
}

class ChatChoice {
  final int index;
  final ChatMessage message;
  final String finishReason;

  ChatChoice({
    required this.index,
    required this.message,
    required this.finishReason,
  });

  factory ChatChoice.fromJson(Map<String, Object?> json) {
    return ChatChoice(
      index: json['index'] as int,
      message: ChatMessage.fromJson(json['message'] as Map<String, Object>),
      finishReason: json['finish_reason'] as String,
    );
  }
}

class ChatUsage {
  final int promptTokens;
  final int completionTokens;
  final int totalTokens;

  ChatUsage({
    required this.promptTokens,
    required this.completionTokens,
    required this.totalTokens,
  });

  factory ChatUsage.fromJson(Map<String, Object?> json) {
    return ChatUsage(
      promptTokens: json['prompt_tokens'] as int,
      completionTokens: json['completion_tokens'] as int,
      totalTokens: json['total_tokens'] as int,
    );
  }
}

Future<String> chat(String input) async {
  final request = ChatRequest(
    model: 'qwen-plus',
    messages: [
      ChatMessage(role: 'system', content: 'You are a helpful assistant.'),
      ChatMessage(role: 'user', content: input),
    ],
  );

  final response = await http.post(
    Uri.parse(
      'https://dashscope.aliyuncs.com/compatible-mode/v1/chat/completions',
    ),
    headers: {
      'Authorization': 'Bearer $apiKey',
      'Content-Type': 'application/json',
    },
    body: jsonEncode(request.toJson()),
  );

  final data =
      jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, Object?>;
  final chatResponse = ChatResponse.fromJson(data);
  return chatResponse.choices.first.message.content;
}
