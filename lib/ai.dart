import 'package:ai_accounting/const.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

const String apiKey = 'sk-df6f938da27d4318ab8d40f324240916';

class ChatMessage {
  final String role;
  final String content;

  ChatMessage({required this.role, required this.content});

  Map<String, Object> toJson() => {'role': role, 'content': content};

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
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
    // map['response_format'] = {
    //   'type': 'json_schema',
    //   'json_schema': {
    //     'type': 'object',
    //     'properties': {
    //       'type': {
    //         'type': 'string',
    //         'enum': ['expense', 'income'],
    //       },
    //       'category': {'type': 'string'},
    //       'amount': {'type': 'number'},
    //       'date': {'type': 'string'},
    //       'remark': {'type': 'string'},
    //     },
    //     'required': ['type', 'category', 'amount', 'date', 'remark'],
    //   },
    // };
    map['response_format'] = {'type': 'json_object'};
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

  factory ChatResponse.fromJson(Map<String, dynamic> json) {
    return ChatResponse(
      id: json['id'] as String,
      object: json['object'] as String,
      created: json['created'] as int,
      model: json['model'] as String,
      choices: (json['choices'] as List)
          .map((e) => ChatChoice.fromJson(e as Map<String, dynamic>))
          .toList(),
      usage: ChatUsage.fromJson(json['usage'] as Map<String, dynamic>),
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

  factory ChatChoice.fromJson(Map<String, dynamic> json) {
    return ChatChoice(
      index: json['index'] as int,
      message: ChatMessage.fromJson(json['message'] as Map<String, dynamic>),
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

  factory ChatUsage.fromJson(Map<String, dynamic> json) {
    return ChatUsage(
      promptTokens: json['prompt_tokens'] as int,
      completionTokens: json['completion_tokens'] as int,
      totalTokens: json['total_tokens'] as int,
    );
  }
}

Future<String> chat(String input) async {
  final request = ChatRequest(
    model: 'qwen3.5-plus',
    messages: [
      ChatMessage(role: 'system', content: aiPrompt),
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
  if (response.statusCode != 200) {
    throw Exception(
      'AI接口请求失败: ${response.statusCode} ${response.reasonPhrase}',
    );
  }

  final data =
      jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
  final chatResponse = ChatResponse.fromJson(data);
  return chatResponse.choices.first.message.content;
}
