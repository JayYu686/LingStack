import 'models.dart';

class SkillSpecCompiler {
  static Map<String, dynamic> openAI(SkillResourceDetail detail) => {
    'type': 'function',
    'function': {
      'name': detail.resource.id.replaceAll('-', '_'),
      'description': detail.resource.summary,
      'parameters': detail.rawSchema,
    },
  };

  static Map<String, dynamic> anthropic(SkillResourceDetail detail) => {
    'name': detail.resource.id.replaceAll('-', '_'),
    'description': detail.resource.summary,
    'input_schema': detail.rawSchema,
  };

  static Map<String, dynamic> gemini(SkillResourceDetail detail) => {
    'name': detail.resource.id.replaceAll('-', '_'),
    'description': detail.resource.summary,
    'parameters': detail.rawSchema,
  };
}
